---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 10/30/2024 10:08 PM
---
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local QualityProcessor = {}

--- The following is the spawn rate of each tier under different difficulty
--- legendary, epic, exceptional, great, normal
local max_difficulties = {
    [QUALITY_CASUAL] = {0, 0, 0.3, 0.7, 0},
    [QUALITY_NORMAL] = {0, 0.1, 0.60, 0.3, 0},
    [QUALITY_ADVANCED] = {0.05, 0.25, 0.7, 0, 0},
    [QUALITY_HARDCORE] = {0.2, 0.3, 0.5, 0, 0},
    [QUALITY_FIGHTER] = {0.5, 0.5, 0, 0, 0},
    [QUALITY_CRUSADER] = {0.75, 0.25, 0, 0, 0},
    [QUALITY_THEONE] = {1, 0, 0, 0, 0},
}
local setting_difficulty, setting_advancement

local max_out_target = 10000
local evolution_target = 3000
local attack_point_target = 7000
local attack_point_divider = 2000000
local top_tier = 5
local SCAN_RADIUS = 64
local can_spawn_as_decimal = true

local update_storages = function()
    if storage.quality_on_planet == nil then
        storage.quality_on_planet = storage.quality_on_planet or {}
        storage.skip_quality_rolling = false
    end

    setting_difficulty = settings.global["enemyracemanager-difficulty"].value
    setting_advancement = settings.global["enemyracemanager-advancement"].value
end

---- Similar to spawn table, lerp probability
---
---  usage get_interpolated_value({ { 0, 0.7 }, { 0.2, 0.5 }, { 0.4, 0.4 }, { 0.6, 0.2 }, { 0.8, 0.2 }, { 1.0, 0.15 } }, 0.1) => 0.6
local get_interpolated_value = function(data, time)
    if time < data[1][1] then
        --- bypass picking probability if it hasn't reach the start time
        return 0
    end

    for i = 1, #data - 1 do
        local t1, v1 = data[i][1], data[i][2]
        local t2, v2 = data[i + 1][1], data[i + 1][2]

        -- Check if the given time is exactly at a defined point
        if time == t1 then
            return v1
        elseif time == t2 then
            return v2
        end

        -- Check if the given time falls between two points
        if time > t1 and time < t2 then
            -- Perform linear interpolation
            local ratio = (time - t1) / (t2 - t1)
            return v1 + ratio * (v2 - v1)
        end
    end

    -- Return 0 if time is out of bounds, use previous roll.
    return 0
end

--- Table arrange from legendary to normal.  Leg roll first, normal roll last
local build_quality_table = function(difficulties)
    return {
        { { 7500, 0  }, { 10000, difficulties[1] } },
        { { 5000, 0  }, { 8000, difficulties[2] * 0.75 } , { 10000, difficulties[2] } },
        { { 3000, 0 }, { 5000, math.max(math.min(difficulties[3] * 1.5, 1), 0.5) }, { 7000, difficulties[3] }, { 10000, difficulties[3] } },
        { { 1500, 0 }, { 3500, math.max(math.min(difficulties[4] * 1.5, 1), 0.75) }, { 5000, difficulties[4] }, { 10000, difficulties[4] } },
        { { 0, 1 }, { 4000, 1 }, { 5000, difficulties[5] } }
    }
end
----
--- Normal start at 100% from QP = 0 - 5000
--- Uncommon start at QP = 2000 - 7000
--- Rare start at QP = 4000 - 9000
--- Epic start at QP = 60%
--- Legendary start at QP = 80%
local calculate_chance_cache = function(planet_data, time)
    local selected_difficulties = max_difficulties[setting_difficulty]
    local spawn_table = planet_data.spawn_table or {}
    if setting_difficulty ~= planet_data.table_difficulty then
        spawn_table = build_quality_table(selected_difficulties)
    end
    planet_data.spawn_table = spawn_table
    planet_data.difficulty = setting_difficulty
    planet_data.spawn_rates = {}
    for index, value_set in pairs(spawn_table) do
        planet_data.spawn_rates[index] = get_interpolated_value(value_set, time)
    end
    local spawn_rates_size = table_size(planet_data.spawn_rates)
    planet_data.spawn_rates_size = spawn_rates_size
    planet_data.lowest_allowed_tier = spawn_rates_size
    
    for index, _ in pairs(planet_data.spawn_rates) do
        local next_rate = planet_data.spawn_rates[index + 1]
        if next_rate and next_rate ~= 0 then
            planet_data.lowest_allowed_tier = index + 1
        end
    end

    if planet_data.spawn_rates[planet_data.lowest_allowed_tier] ~= 0 then
        planet_data.spawn_rates[planet_data.lowest_allowed_tier] = 1
    end        

    return planet_data
end

local is_erm_managed = function(force)
    return ForceHelper.is_enemy_force(force) and GlobalConfig.race_is_erm_managed(force.name)
end
---
--- Planet evolution takes 30%, accumulated attack point takes 70%
function QualityProcessor.calculate_quality_points()
    update_storages()
    local evolution_enabled = game.map_settings.enemy_evolution.enabled
    for _, force in pairs(game.forces) do
        if ForceHelper.is_enemy_force(force) then
            local quality_data = storage.quality_on_planet[force.name] or {}
            local accumulated_attack_meter = RaceSettingsHelper.get_accumulated_attack_meter(force.name)
            for _, planet in pairs(game.planets) do
                if planet.surface then
                    local data = quality_data[planet.name] or {}

                    local quality_points
                    if evolution_enabled then
                        quality_points = ( math.min((force.get_evolution_factor(planet.surface.name)), 1) ) * evolution_target +
                                math.min((accumulated_attack_meter / attack_point_divider) * attack_point_target, attack_point_target)
                    else
                        local final_target = evolution_target + attack_point_target
                        quality_points = math.min((accumulated_attack_meter / attack_point_divider) * final_target, final_target)
                    end

                    quality_points = quality_points * setting_advancement

                    data.points = math.floor(quality_points)
                    if quality_points >= max_out_target then
                        data.max_out = true
                    else
                        data.max_out = false
                    end

                    if quality_points <= 1000 then
                        data.tier = 1
                    elseif quality_points > 1000 and quality_points <= 2500 then
                        data.tier = 2
                    else
                        data.tier = 3
                    end

                    -- update custom group unit tier, let it use the highest tiers from any planet.
                    RaceSettingsHelper.refresh_current_tier(force.name, data.tier)

                    quality_data[planet.name] = calculate_chance_cache(data, quality_points)
                end
            end
            storage.quality_on_planet[force.name] = quality_data
        end
    end
end

function QualityProcessor.get_quality_point(force_name, planet_name)
    if storage.quality_on_planet[force_name][planet_name] == nil then
        QualityProcessor.calculate_quality_points()
    end

    return storage.quality_on_planet[force_name][planet_name].points
end

function QualityProcessor.is_maxed_out(force_name, planet_name)
    if storage.quality_on_planet[force_name][planet_name] == nil then
        QualityProcessor.calculate_quality_points()
    end

    return  storage.quality_on_planet[force_name][planet_name].max_out
end

function QualityProcessor.get_spawn_rates(force_name, planet_name)
    if storage.quality_on_planet[force_name][planet_name] == nil then
        QualityProcessor.calculate_quality_points()
    end

    return storage.quality_on_planet[force_name][planet_name].spawn_rates
end

function QualityProcessor.get_data_set(force_name)
    if storage.quality_on_planet[force_name] == nil then
        QualityProcessor.calculate_quality_points()
    end
    return storage.quality_on_planet[force_name]
end

function QualityProcessor.roll_quality(force_name, surface_name, is_elite)
    if setting_difficulty == nil then
        update_storages()
    end
    is_elite = is_elite or false
    if not storage.quality_on_planet[force_name] or not storage.quality_on_planet[force_name][surface_name]
    then
        QualityProcessor.calculate_quality_points()
    end

    --- Home planet spawns, always use the top tier
    local surface = game.surfaces[surface_name]
    local race_settings = storage.race_settings[force_name]
    if surface.planet and race_settings and race_settings.home_planet == surface.planet.name
    then
        return top_tier
    end

    local planet_data = storage.quality_on_planet[force_name][surface_name]

    -- Use random roll normal - epic on a non-planet surfaces.
    if planet_data == nil then
        return math.random(1,4)
    end

    local spawn_rates, spawn_rates_size,
          lowest_tier, selected_tier, can_spawn

    if is_elite == false then
        spawn_rates = planet_data.spawn_rates
        spawn_rates_size = planet_data.spawn_rates_size
        lowest_tier = planet_data.lowest_allowed_tier
    else
        spawn_rates = planet_data.spawn_rates
        for key, rates in pairs(spawn_rates) do
            if spawn_rates[key] > 0 then
                spawn_rates[key] = math.min((rates + 0.33), 1)
            end
        end
        spawn_rates_size = planet_data.spawn_rates_size
        lowest_tier = planet_data.lowest_allowed_tier
    end

    selected_tier = lowest_tier

    for index, spawn_rate in pairs(spawn_rates) do
        if spawn_rate > 0 then
            selected_tier = index
            if selected_tier == lowest_tier then
                can_spawn = true
            else
                can_spawn = RaceSettingsHelper.can_spawn(spawn_rates[selected_tier], can_spawn_as_decimal)
            end

            if can_spawn then
                break
            end
        end
    end

    return (spawn_rates_size - selected_tier + 1)
end

--- Tier mapping.
--- Tier 1 is under 1000 points
--- Tier 2 is between 1000 - 2000 points
--- Tier 3 is 2000+ points
function QualityProcessor.get_tier(force_name, surface_name)
    return storage.quality_on_planet[force_name][surface_name].tier
end

function QualityProcessor.reset_globals()
    storage.quality_on_planet = {}
end

function QualityProcessor.roll(entity)
    -- is_running_roll to prevent recursive roll on create entity event
    -- storage.skip_quality_rolling allows bypassing roll manually
    -- unit from spawner doesn't need to roll
    -- unit which is not from enemy force or not erm units doesn't need to roll.
    if storage.is_running_roll or storage.skip_quality_rolling or
       (entity.commandable and entity.commandable.spawner) or
       not is_erm_managed(entity.force) or
       not ForceHelper.is_erm_unit(entity)
    then
        storage.skip_quality_rolling = false
        storage.is_running_roll = false
        return entity
    end

    local name_token = ForceHelper.get_name_token(entity.name)
    if name_token == nil then
        return entity
    end
    
    local unit_tier = tonumber(name_token[3])

    -- Prevent roll if unit_tier not found
    if unit_tier == nil then
        return entity
    end

    local force = entity.force
    local surface = entity.surface
    local race_settings = storage.race_settings[force.name]

    local selected_tier
    local spawn_rates_size
    local can_spawn = false
    --- Home planet spawns, always use the top tier
    if surface.planet and race_settings and race_settings.home_planet == surface.planet.name
    then
        selected_tier = top_tier
        can_spawn = true
    end

    if not can_spawn then
        if not storage.quality_on_planet[force.name] or not storage.quality_on_planet[force.name][surface.name]
        then
            QualityProcessor.calculate_quality_points()
        end

        local planet_data = storage.quality_on_planet[force.name][surface.name]

        if not planet_data then
            storage.is_running_roll = false
            return entity
        end
        local spawn_rates = planet_data.spawn_rates
        spawn_rates_size = planet_data.spawn_rates_size
        local lowest_tier = planet_data.lowest_allowed_tier
        selected_tier = lowest_tier

        local converted_unit_tier = (spawn_rates_size - unit_tier + 1)

        --- If Unit tier has spawn rates, then doesn't need to re-roll.
        local need_swap = spawn_rates[converted_unit_tier] == 0
        if not need_swap then
            return entity
        end            

        for index, spawn_rate in pairs(spawn_rates) do
            if spawn_rate > 0 then
                selected_tier = index
                if selected_tier == lowest_tier then
                    can_spawn = true
                else
                    can_spawn = RaceSettingsHelper.can_spawn(spawn_rates[selected_tier], can_spawn_as_decimal)
                end

                if can_spawn then
                    break
                end
            end
        end

        -- Tier conversion
        selected_tier = (spawn_rates_size - selected_tier + 1)
        --- no need to swap if unit is already at the same or higher than selected tier and doesn't have spaw flag.
        if unit_tier >= selected_tier and not need_swap then
            return entity
        end
    end

    if can_spawn then
        local position = surface.find_non_colliding_position(entity.name, entity.position,
               16, 2)

        if position then
            storage.is_running_roll = true
            local new_unit = surface.create_entity {
                name = name_token[1].."--"..name_token[2].."--"..selected_tier,
                force = force,
                position = position,
                create_build_effect_smoke = false,
                spawn_decorations = true
            }

            if new_unit then
                if entity.commandable and entity.commandable.parent_group then
                    entity.commandable.parent_group.add_member(new_unit)
                end
                entity.destroy()
                
                return new_unit
            end
        end
    end

    return entity
end

function QualityProcessor.reset_all_progress()
    for _, force_name in pairs(ForceHelper.get_enemy_forces()) do
        storage.race_settings[force_name].tier = 1
        storage.race_settings[force_name].attack_meter = 0
        storage.race_settings[force_name].accumulated_attack_meter = 0
        local force = game.forces[force_name]
        force.reset_evolution()
    end
    QualityProcessor.calculate_quality_points()
end

function QualityProcessor.remove_surface(surface_name)
    for fname, surfaces in pairs(storage.quality_on_planet) do
        for sname, surface in pairs(surfaces) do
            if sname == surface_name then
                storage.quality_on_planet[fname][sname] = nil
            end
        end
    end
end

function QualityProcessor.skip_roll_quality()
    storage.skip_quality_rolling = true
end

--- Register events
QualityProcessor.events =
{
    [defines.events.on_runtime_mod_setting_changed] = update_storages()
}

QualityProcessor.on_nth_tick = {
    [301] = QualityProcessor.calculate_quality_points
}

QualityProcessor.on_init = function(event)
    update_storages()
end

QualityProcessor.on_configuration_changed = function(event)
    update_storages()
end

return QualityProcessor
