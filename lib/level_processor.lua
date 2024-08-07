---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/24/2020 8:21 PM
---
--- require('__enemyracemanager__/lib/level_processor')
--- References:
--- https://lua-api.factorio.com/latest/LuaForce.html
---
local String = require('__stdlib__/stdlib/utils/string')
local Event = require('__stdlib__/stdlib/event/event')


local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local RaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')

local LevelManager = {}

-- unit tier control
local tier_map = { 0.4, 0.8 }

-- Evolution point for leveling
local evolution_points = { 1, 3, 6, 10, 15, 21, 28, 38, 50, 70, 100, 150, 210, 280, 360, 450, 550, 700, 1000 }

if settings.startup['enemyracemanager-evolution-point-ll-express'].value == LEVEL_MODE_EXPRESS then
    evolution_points = {1, 2, 4, 7, 12, 18, 26, 36, 48, 66, 94, 140, 190, 255, 330, 420, 530, 666, 900}
elseif settings.startup['enemyracemanager-evolution-point-ll-express'].value == LEVEL_MODE_SHINKANSEN then
    evolution_points = {1, 2, 3, 5, 10, 16, 23, 31, 42, 55, 69, 105, 160, 225, 320, 420, 530, 666, 800}
end

local level_up_tier = function(current_tier, race_settings, race_name)
    race_settings[race_name].tier = current_tier + 1
    RaceSettingsHelper.refresh_current_tier(race_name)
end

local handle_unit_tier = function(race_settings, force, race_name, dispatch)
    local current_tier = race_settings[race_name].tier
    if current_tier < GlobalConfig.MAX_TIER and force.evolution_factor >= tier_map[current_tier] then
        level_up_tier(current_tier, race_settings, race_name)
        if dispatch then
            --Event.dispatch(
            --        { name = Event.get_event_name(GlobalConfig.EVENT_TIER_WENT_UP),
            --          affected_race = race_settings[race_name] })
            Event.raise_event(Event.get_event_name(GlobalConfig.EVENT_TIER_WENT_UP),
                    {
                      affected_race = race_settings[race_name]
                    })
        end
    end
end

local can_level_up_by_evolution_points = function(current_level, race_settings, race_name)
    return current_level < GlobalConfig.get_max_level() and
            race_settings[race_name].evolution_point >= evolution_points[current_level]
end

local warn_user = function(current_level, race_settings, race_name)
    if GlobalConfig.spawner_kills_deduct_evolution_points() and race_settings[race_name].evolution_point >= (evolution_points[current_level] * 0.95) and not race_settings[race_name].level_warned then
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

            Event.raise_event(Event.get_event_name(GlobalConfig.EVENT_LEVEL_WENT_UP),
                    {
                        affected_race = race_settings[race_name]
                    })
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

function LevelManager.calculate_evolution_points(race_settings, forces, settings)
    for _, force in pairs(forces) do
        local force_name = force.name
        local race_name = ForceHelper.extract_race_name_from(force_name)
        if GlobalConfig.race_is_active(race_name) then
            -- Handle Score Level
            calculate_evolution_points(race_settings, settings, force, race_name)
        end
    end
end

function LevelManager.calculate_levels()
    if RaceSettingsHelper.is_in_boss_mode() then
        return
    end

    local race_settings = global.race_settings
    local forces = game.forces
    local settings = settings

    for _, force in pairs(forces) do
        if not ForceHelper.is_enemy_force(force) then
            goto skip_calculate_level_for_force
        end

        local force_name = force.name
        local race_name = ForceHelper.extract_race_name_from(force_name)

        if GlobalConfig.race_is_active(race_name) and has_valid_race_settings(race_settings, race_name) then
            local current_race_setting = race_settings[race_name]
            local current_level = current_race_setting.level

            -- Handle Score Level
            calculate_evolution_points(race_settings, settings, force, race_name)

            handle_unit_tier(race_settings, force, race_name, true)

            if current_level == GlobalConfig.get_max_level() then
                goto skip_calculate_level_for_force
            end

            handle_unit_level(race_settings, force, race_name, true)
        end

        :: skip_calculate_level_for_force ::
    end
end

function LevelManager.calculate_multiple_levels()
    local race_settings = global.race_settings
    local forces = game.forces
    local settings = settings

    for _, force in pairs(forces) do
        if not ForceHelper.is_enemy_force(force) then
            goto skip_calculate_multiple_level_for_force
        end

        local force_name = force.name
        local race_name = ForceHelper.extract_race_name_from(force_name)

        if GlobalConfig.race_is_active(race_name) and has_valid_race_settings(race_settings, race_name) and race_settings[race_name].level > GlobalConfig.get_max_level() then
            race_settings[race_name].level = GlobalConfig.get_max_level()
            game.print('Max level reduced: ' .. race_settings[race_name].race .. ' = L' .. race_settings[race_name].level)

            Event.raise_event(Event.get_event_name(GlobalConfig.EVENT_LEVEL_WENT_UP),
                    {
                        affected_race = race_settings[race_name]
                    })
        end

        if has_valid_race_settings(race_settings, race_name) then
            local current_level = race_settings[race_name].level
            local level_up = false

            for i = current_level, GlobalConfig.get_max_level() do

                calculate_evolution_points(race_settings, settings, force, race_name)

                handle_unit_tier(race_settings, force, race_name, false)

                if current_level == GlobalConfig.get_max_level() then
                    break;
                end

                handle_unit_level(race_settings, force, race_name, false)

                if current_level ~= race_settings[race_name].level then
                    level_up = true
                end
                current_level = race_settings[race_name].level
            end
            
            if level_up then
                game.print(race_settings[race_name].race .. ' = L' .. race_settings[race_name].level)

                Event.raise_event(Event.get_event_name(GlobalConfig.EVENT_LEVEL_WENT_UP),
                        {
                            affected_race = race_settings[race_name]
                        })

                Event.raise_event(Event.get_event_name(GlobalConfig.EVENT_TIER_WENT_UP),
                        {
                            affected_race = race_settings[race_name]
                        })
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
    local max_level = GlobalConfig.get_max_level()
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

function LevelManager.level_by_command(race_settings, race_name, target_level)
    race_settings[race_name].level = target_level

    game.print(race_settings[race_name].race .. ' = L' .. race_settings[race_name].level)

    Event.raise_event(Event.get_event_name(GlobalConfig.EVENT_LEVEL_WENT_UP),
        {
            affected_race = race_settings[race_name]
        }
    )
end

function LevelManager.get_evolution_factor(race_name)
    local new_force_name = ForceHelper.get_force_name_from(race_name)

    if game.forces[new_force_name] then
        return game.forces[new_force_name].evolution_factor
    end

    return 0
end

function LevelManager.print_level_curve_table()
    local string = ''
    for i = 1, GlobalConfig.get_max_level() - 1 do
        string = string .. tostring(i + 1) .. " = " .. tostring(evolution_points[i]) .. ', '
    end
    game.print('Level Curve: ' .. string)
end

function LevelManager.reset_all_progress()
    for _, force_name in pairs(ForceHelper.get_enemy_forces()) do
        local race_name = ForceHelper.extract_race_name_from(force_name)
        global.race_settings[race_name].level = 1
        global.race_settings[race_name].tier = 1
        global.race_settings[race_name].evolution_point = 0
        global.race_settings[race_name].evolution_base_point = 0
        local force = game.forces[force_name]
        force.reset_evolution()
    end
end

return LevelManager