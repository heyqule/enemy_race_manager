---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/24/2020 8:21 PM
---
--- require('__enemyracemanager__/lib/level_processor')
--- References:
--- https://lua-api.factorio.com/latest/LuaForce.html
---
local Table = require('__stdlib__/stdlib/utils/table')
local String = require('__stdlib__/stdlib/utils/string')
local Event = require('__stdlib__/stdlib/event/event')
local Math = require('__stdlib__/stdlib/utils/math')

local ErmConfig = require('lib/global_config')
local ErmForceHelper = require('lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')

local LevelManager = {}

-- unit tier control
local tier_map = { 0.4, 0.8 }

-- Evolution point for leveling
local evolution_points = { 1, 3, 6, 10, 15, 21, 28, 38, 50, 70, 100, 150, 210, 280, 360, 450, 550, 700, 1000 }

local level_up_tier = function(current_tier, race_settings, race_name)
    race_settings[race_name].tier = current_tier + 1
    ErmRaceSettingsHelper.refresh_current_tier(race_name)
end

local handle_unit_tier = function(race_settings, force, race_name, dispatch)
    local current_tier = race_settings[race_name].tier
    if current_tier < ErmConfig.MAX_TIER and force.evolution_factor >= tier_map[current_tier] then
        level_up_tier(current_tier, race_settings, race_name)
        if dispatch then
            Event.dispatch(
                    { name = Event.get_event_name(ErmConfig.EVENT_TIER_WENT_UP),
                      affected_race = race_settings[race_name] })
        end
    end
end

local can_level_up_by_evolution_points = function(current_level, race_settings, race_name)
    return current_level < ErmConfig.get_max_level() and
            race_settings[race_name].evolution_point >= evolution_points[current_level]
end

local warn_user = function(current_level, race_settings, race_name)
    if ErmConfig.spawner_kills_deduct_evolution_points() and race_settings[race_name].evolution_point >= (evolution_points[current_level] * 0.95) and not race_settings[race_name].level_warned then
        race_settings[race_name].level_warned = true
        game.print(race_settings[race_name].race..' has over 95% evolution points to next level!');
    end
end

local handle_unit_level = function(race_settings, force, race_name, dispatch)
    local current_level = race_settings[race_name].level

    warn_user(current_level, race_settings, race_name)
    -- Handle Evolution Level
    if can_level_up_by_evolution_points(current_level, race_settings, race_name) then
        race_settings[race_name].level = current_level + 1
        race_settings[race_name].level_warned = false
        if dispatch then
            game.print(race_settings[race_name].race .. ' = L' .. race_settings[race_name].level)
            Event.dispatch({
                name = Event.get_event_name(ErmConfig.EVENT_LEVEL_WENT_UP),
                affected_race = race_settings[race_name] })
        end
    end
end

local calculate_evolution_points = function(race_settings, settings, force, race_name)
    race_settings[race_name].evolution_point = race_settings[race_name].evolution_base_point + (force.evolution_factor_by_pollution + force.evolution_factor_by_time + force.evolution_factor_by_killing_spawners) * settings.global['enemyracemanager-evolution-point-multipliers'].value
    race_settings[race_name].global_evolution_point = race_settings[race_name].evolution_point
    return race_settings[race_name].evolution_point
end

local has_valid_race_settings = function(race_settings, race_name)
    return race_settings and race_settings[race_name]
end

function LevelManager.calculateEvolutionPoints(race_settings, forces, settings)
    for _, force in pairs(forces) do
        local force_name = force.name
        local race_name = ErmForceHelper.extract_race_name_from(force_name)
        if ErmConfig.race_is_active(race_name) then
            -- Handle Score Level
            calculate_evolution_points(race_settings, settings, force, race_name)
        end
    end
end

function LevelManager.calculateLevels()
    if ErmRaceSettingsHelper.is_in_boss_mode() then
        return
    end

    local race_settings = global.race_settings
    local forces = game.forces
    local settings = settings

    for _, force in pairs(forces) do
        if not String.find(force.name, 'enemy', 1, true) then
            goto skip_calculate_level_for_force
        end

        local force_name = force.name
        local race_name = ErmForceHelper.extract_race_name_from(force_name)

        if has_valid_race_settings(race_settings, race_name) then
            local current_race_setting = race_settings[race_name]
            local current_level = current_race_setting.level

            -- Handle Score Level
            calculate_evolution_points(race_settings, settings, force, race_name)

            handle_unit_tier(race_settings, force, race_name, true)

            if current_level == ErmConfig.get_max_level() then
                goto skip_calculate_level_for_force
            end

            handle_unit_level(race_settings, force, race_name, true)
        end

        :: skip_calculate_level_for_force ::
    end
end

function LevelManager.calculateMultipleLevels()
    local race_settings = global.race_settings
    local forces = game.forces
    local settings = settings

    for _, force in pairs(forces) do
        if not String.find(force.name, 'enemy', 1, true) then
            goto skip_calculate_multiple_level_for_force
        end

        local force_name = force.name
        local race_name = ErmForceHelper.extract_race_name_from(force_name)

        if has_valid_race_settings(race_settings, race_name) and race_settings[race_name].level > ErmConfig.get_max_level() then
            race_settings[race_name].level = ErmConfig.get_max_level()
            game.print('Max level reduced: ' .. race_settings[race_name].race .. ' = L' .. race_settings[race_name].level)
            Event.dispatch({
                name = Event.get_event_name(ErmConfig.EVENT_LEVEL_WENT_UP), affected_race = race_settings[race_name] })
        end

        if has_valid_race_settings(race_settings, race_name) then
            local current_level = race_settings[race_name].level
            local level_up = false

            for i = current_level, ErmConfig.get_max_level() do

                calculate_evolution_points(race_settings, settings, force, race_name)

                handle_unit_tier(race_settings, force, race_name, false)

                if current_level == ErmConfig.get_max_level() then
                    goto skip_calculate_multiple_level_for_force
                end

                handle_unit_level(race_settings, force, race_name, false)

                if current_level ~= race_settings[race_name].level then
                    level_up = true
                end
                current_level = race_settings[race_name].level
            end

            if level_up then
                game.print(race_settings[race_name].race .. ' = L' .. race_settings[race_name].level)
                Event.dispatch({
                    name = Event.get_event_name(ErmConfig.EVENT_LEVEL_WENT_UP), affected_race = race_settings[race_name] })
                Event.dispatch(
                        { name = Event.get_event_name(ErmConfig.EVENT_TIER_WENT_UP),
                          affected_race = race_settings[race_name] })
            end
        end
        :: skip_calculate_multiple_level_for_force ::
    end
end

function LevelManager.get_level_for_race(race_settings, race_name)
    if has_valid_race_settings(race_settings, race_name) then
        return race_settings[race_name].level
    end
    return nil
end

function LevelManager.get_tier_for_race(race_settings, race_name)
    if has_valid_race_settings(race_settings, race_name) then
        return race_settings[race_name].tier
    end
    return nil
end

function LevelManager.get_calculated_current_level(race_setting)
    local max_level = ErmConfig.get_max_level()
    for key, value in pairs(evolution_points) do
        if (key == max_level) then
            break
        end

        if key < max_level and race_setting.evolution_point < value then
            return key
        end
    end

    return max_level
end

function LevelManager.canLevelByCommand(race_settings, force, race_name, target_level)
    local calculated_level = LevelManager.get_calculated_current_level(race_settings[race_name])

    if target_level < calculated_level then
        return false
    end

    return true
end

function LevelManager.levelByCommand(race_settings, race_name, target_level)
    race_settings[race_name].level = target_level

    game.print(race_settings[race_name].race .. ' = L' .. race_settings[race_name].level)
    Event.dispatch({
        name = Event.get_event_name(ErmConfig.EVENT_LEVEL_WENT_UP), affected_race = race_settings[race_name] })
end

function LevelManager.getEvolutionFactor(race_name)
    local new_force_name = ErmForceHelper.get_force_name_from(race_name)

    if game.forces[new_force_name] then
        return game.forces[new_force_name].evolution_factor
    end

    return 'n/a'
end

function LevelManager.print_level_curve_table()
    local string = ''
    for i = 1, ErmConfig.get_max_level() - 1 do
        string = string .. tostring(i + 1) .. " = " .. tostring(evolution_points[i]) .. ', '
    end
    game.print('Level Curve: ' .. string)
end

return LevelManager