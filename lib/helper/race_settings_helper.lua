
local Table = require("__erm_libs__/stdlib/table")
local UtilHelper = require("__enemyracemanager__/lib/helper/util_helper")

local RaceSettingsHelper = {
    default_force_names = {
        enemy = true,
        enemy_pentapod = true
    }
}

local FEATURE_RACE_NAME = 1
local FEATURE_RACE_SPAWN_DATA = 2
local FEATURE_RACE_SPAWN_COST = 3
local FEATURE_RACE_SPAWN_CACHE = 4
local FEATURE_RACE_SPAWN_CACHE_SIZE = 5

RaceSettingsHelper.can_spawn = UtilHelper.can_spawn

function RaceSettingsHelper.clean_up_race()
    if storage.race_settings == nil then
        return
    end

    for _, item in pairs(storage.race_settings) do
        if not RaceSettingsHelper.default_force_names[item.race] and 
           script.active_mods[string.gsub(item.race,"enemy_","")] == nil 
        then
            storage.race_settings = Table.remove_keys(storage.race_settings, { item.race })
            if game.forces["enemy_" .. item.race] then
                game.merge_forces("enemy_" .. item.race, "enemy")
            end
        end
    end
end

function RaceSettingsHelper.pick_a_spawner(target_race_name)
    local support_structures = storage.race_settings[target_race_name]["current_support_structures_tier"]
    local base_structures = storage.race_settings[target_race_name]["current_command_centers_tier"]
    local pick = math.random();

    local base_name = ""
    if pick < 0.125 then
        base_name = base_structures[math.random(1, #base_structures)]
    else
        base_name = support_structures[math.random(1, #support_structures)]
    end

    return base_name
end

function RaceSettingsHelper.pick_a_turret(target_race_name)
    local turret_tier = storage.race_settings[target_race_name]["current_turrets_tier"]
    local base_name = turret_tier[math.random(1, #turret_tier)]
    return base_name
end

function RaceSettingsHelper.pick_a_command_center(target_race_name)
    local cc_tier = storage.race_settings[target_race_name]["current_command_centers_tier"]
    local base_name = cc_tier[math.random(1, #cc_tier)]
    return base_name
end

function RaceSettingsHelper.pick_a_support_building(target_race_name)
    local support_tier = storage.race_settings[target_race_name]["current_support_structures_tier"]
    local base_name = support_tier[math.random(1, #support_tier)]
    return base_name
end

function RaceSettingsHelper.pick_an_unit(target_race_name)
    local units = storage.race_settings[target_race_name]["current_units_tier"]
    local unit_name = units[math.random(1, #units)]
    return unit_name
end

function RaceSettingsHelper.pick_an_unit_from_tier(target_race_name, tier)
    local units = storage.race_settings[target_race_name]["units"][tier]
    local unit_name = units[math.random(1, #units)]
    return unit_name
end

function RaceSettingsHelper.has_flying_unit(target_race_name)
    if storage.race_settings[target_race_name]["flying_units"] == nil then
        return false
    end

    return true
end

function RaceSettingsHelper.pick_a_flying_unit_from_tier(target_race_name, tier)
    local units = storage.race_settings[target_race_name]["flying_units"][tier]
    local unit_name = units[math.random(1, #units)]
    return unit_name
end

function RaceSettingsHelper.has_dropship_unit(target_race_name)
    if storage.race_settings[target_race_name]["dropship"] == nil then
        return false
    end

    return true
end

function RaceSettingsHelper.pick_dropship_unit(target_race_name)
    return storage.race_settings[target_race_name]["dropship"]
end

function RaceSettingsHelper.is_timed_unit(target_race_name, unit_name)
    return storage.race_settings[target_race_name]["timed_units"][unit_name]
end

function RaceSettingsHelper.is_command_center(target_race_name, name)
    local command_centers = storage.race_settings[target_race_name]["current_command_centers_tier"]
    for _, val in pairs(command_centers) do
        if val == name then
            return true
        end
    end
    return false
end

function RaceSettingsHelper.get_current_unit_tier(target_race_name)
    return storage.race_settings[target_race_name].current_units_tier
end

function RaceSettingsHelper.get_current_turret_tier(target_race_name)
    return storage.race_settings[target_race_name].current_turrets_tier
end

function RaceSettingsHelper.get_current_building_tier(target_race_name)
    return storage.race_settings[target_race_name].current_building_tier
end

function RaceSettingsHelper.get_current_command_centers(target_race_name)
    return storage.race_settings[target_race_name].current_command_centers_tier
end

function RaceSettingsHelper.get_attack_meter(target_race_name)
    return storage.race_settings[target_race_name].attack_meter
end

function RaceSettingsHelper.add_to_attack_meter(target_race_name, value, skip_accumulate)
    local skip_accumulate = skip_accumulate or false
    storage.race_settings[target_race_name].attack_meter = math.max( math.min(storage.race_settings[target_race_name].attack_meter + value, 999999),  0)
    if (value > 0) and not skip_accumulate then
        RaceSettingsHelper.set_accumulated_attack_meter(target_race_name, storage.race_settings[target_race_name].attack_meter_total + math.min(value, 999999))
    end
end

function RaceSettingsHelper.set_attack_meter(target_race_name, value)
    storage.race_settings[target_race_name].attack_meter = value
end


function RaceSettingsHelper.add_accumulated_attack_meter(target_race_name, value)
    storage.race_settings[target_race_name].attack_meter_total =  math.max( storage.race_settings[target_race_name].attack_meter_total + math.min(value, 999999), 0)
end

function RaceSettingsHelper.get_next_attack_threshold(target_race_name)
    return storage.race_settings[target_race_name].next_attack_threshold
end

function RaceSettingsHelper.set_next_attack_threshold(target_race_name, value)
    storage.race_settings[target_race_name].next_attack_threshold = math.floor(value)
end

function RaceSettingsHelper.get_accumulated_attack_meter(target_race_name)
    return storage.race_settings[target_race_name].attack_meter_total
end

function RaceSettingsHelper.set_accumulated_attack_meter(target_race_name, value)
    storage.race_settings[target_race_name].attack_meter_total = value
end

function RaceSettingsHelper.get_last_accumulated_attack_meter(target_race_name)
    return storage.race_settings[target_race_name].last_attack_meter_total
end

function RaceSettingsHelper.set_last_accumulated_attack_meter(target_race_name, value)
    storage.race_settings[target_race_name].last_attack_meter_total = value
end

function RaceSettingsHelper.get_race_entity_name(target_race_name, name, level)
    return target_race_name .. "--" .. name .. "--" .. level
end


function RaceSettingsHelper.get_tier(target_race_name)
    return storage.race_settings[target_race_name].tier
end

function RaceSettingsHelper.get_colliding_unit(force_name)
    local collide_unit_name = storage.race_settings[force_name].colliding_unit
    if not collide_unit_name then
        collide_unit_name = storage.race_settings[force_name]["units"][1][1]
    end
    return RaceSettingsHelper.get_race_entity_name(
            force_name,
            collide_unit_name,
            1
    )
end

function RaceSettingsHelper.add_killed_units_count(target_race_name, surface_name, count)
    if storage.race_settings[target_race_name].unit_killed_count == nil then
        storage.race_settings[target_race_name].unit_killed_count = 0
    end
    storage.race_settings[target_race_name].unit_killed_count = storage.race_settings[target_race_name].unit_killed_count + count

    if storage.race_settings[target_race_name].unit_killed_count_by_planet[surface_name] == nil then
        storage.race_settings[target_race_name].unit_killed_count_by_planet[surface_name] = 0
    end
    storage.race_settings[target_race_name].unit_killed_count_by_planet[surface_name] = storage.race_settings[target_race_name].unit_killed_count_by_planet[surface_name] + count
end

function RaceSettingsHelper.add_killed_structure_count(target_race_name, surface_name, count)
    if storage.race_settings[target_race_name].structure_killed_count == nil then
        storage.race_settings[target_race_name].structure_killed_count = 0
    end
    storage.race_settings[target_race_name].structure_killed_count = storage.race_settings[target_race_name].structure_killed_count + count

    if storage.race_settings[target_race_name].structure_killed_count_by_planet[surface_name] == nil then
        storage.race_settings[target_race_name].structure_killed_count_by_planet[surface_name] = 0
    end
    storage.race_settings[target_race_name].structure_killed_count_by_planet[surface_name] = storage.race_settings[target_race_name].structure_killed_count_by_planet[surface_name] + count
end

function RaceSettingsHelper.refresh_current_tier(force_name, tier)
    local race_settings = storage.race_settings[force_name]
    local i = 1
    tier = tier or 1
    if race_settings.tier and
        tier <= race_settings.tier and
        race_settings.current_units_tier ~= nil
    then
        return
    end

    storage.race_settings[force_name].tier = tier

    if race_settings.units == nil then
        return
    end

    race_settings.current_units_tier = {}
    race_settings.current_turrets_tier = {}
    race_settings.current_command_centers_tier = {}
    race_settings.current_support_structures_tier = {}
    race_settings.current_building_tier = {}

    while i <= tier do
        race_settings.current_units_tier = Table.array_combine(race_settings.current_units_tier, race_settings.units[i])
        race_settings.current_turrets_tier = Table.array_combine(race_settings.current_turrets_tier, race_settings.turrets[i])
        race_settings.current_command_centers_tier = Table.array_combine(race_settings.current_command_centers_tier, race_settings.command_centers[i])
        race_settings.current_support_structures_tier = Table.array_combine(race_settings.current_support_structures_tier, race_settings.support_structures[i])
        i = i + 1
    end

    race_settings.current_building_tier = Table.unique_values(Table.array_combine(
            race_settings.current_command_centers_tier,
            race_settings.current_support_structures_tier
    ))
    storage.race_settings[force_name] = race_settings
end

local process_spawn_chance_cache = function(featured_group)
    featured_group[FEATURE_RACE_SPAWN_CACHE] = {}
    for key, spawn_rate in pairs(featured_group[FEATURE_RACE_SPAWN_DATA]) do
        for i = 1, spawn_rate, 1 do
            table.insert(featured_group[FEATURE_RACE_SPAWN_CACHE], key)
        end
    end
    featured_group[FEATURE_RACE_SPAWN_CACHE_SIZE] = #featured_group[FEATURE_RACE_SPAWN_CACHE]
end

function RaceSettingsHelper.process_unit_spawn_rate_cache(race_data)
    if race_data.droppable_units then
        for _, unit_tier in pairs(race_data.droppable_units) do
            process_spawn_chance_cache(unit_tier)
        end
    end

    if race_data.construction_buildings then
        for _, unit_tier in pairs(race_data.construction_buildings) do
            process_spawn_chance_cache(unit_tier)
        end
    end

    if race_data.featured_groups then
        for _, featured_groups in pairs(race_data.featured_groups) do
            process_spawn_chance_cache(featured_groups)
        end
        race_data["featured_groups_total"] = #race_data.featured_groups
    end

    if race_data.featured_flying_groups then
        for _, featured_groups in pairs(race_data.featured_flying_groups) do
            process_spawn_chance_cache(featured_groups)
        end
        race_data["featured_flying_groups_total"] = #race_data.featured_flying_groups
    end

    return race_data
end

function RaceSettingsHelper.get_featured_squad_id(race_name)
    return math.random(1, storage.race_settings[race_name]["featured_groups_total"])
end

function RaceSettingsHelper.get_featured_flying_squad_id(race_name)
    return math.random(1, storage.race_settings[race_name]["featured_flying_groups_total"])
end

function RaceSettingsHelper.get_featured_unit_cost(target_race_name, featured_group_id)
    local featured_group = storage.race_settings[target_race_name]["featured_groups"][featured_group_id]
    return featured_group[FEATURE_RACE_SPAWN_COST];
end

function RaceSettingsHelper.pick_featured_unit(target_race_name, featured_group_id)
    local featured_group = storage.race_settings[target_race_name]["featured_groups"][featured_group_id]
    return featured_group[FEATURE_RACE_NAME][featured_group[FEATURE_RACE_SPAWN_CACHE][math.random(1, featured_group[FEATURE_RACE_SPAWN_CACHE_SIZE])]]
end

function RaceSettingsHelper.pick_featured_flying_unit(target_race_name, featured_group_id)
    local featured_group = storage.race_settings[target_race_name]["featured_flying_groups"][featured_group_id]
    return featured_group[FEATURE_RACE_NAME][featured_group[FEATURE_RACE_SPAWN_CACHE][math.random(1, featured_group[FEATURE_RACE_SPAWN_CACHE_SIZE])]]
end

function RaceSettingsHelper.has_featured_flying_squad(target_race_name)
    if storage.race_settings[target_race_name]["featured_flying_groups"] == nil then
        return false
    end

    return true
end

function RaceSettingsHelper.has_featured_squad(target_race_name)
    if storage.race_settings[target_race_name]["featured_groups"] == nil then
        return false
    end

    return true
end

function RaceSettingsHelper.get_total_featured_squads(target_race_name)
    return storage.race_settings[target_race_name]["featured_groups_total"] or 0
end

function RaceSettingsHelper.get_total_featured_flying_squads(target_race_name)
    return storage.race_settings[target_race_name]["featured_flying_groups_total"] or 0
end

function RaceSettingsHelper.is_in_boss_mode()
    return storage.boss.entity and storage.boss.entity.valid
end

function RaceSettingsHelper.has_boss(target_race_name)
    return storage.race_settings[target_race_name]["boss_building"] or false
end

function RaceSettingsHelper.boss_tier(target_race_name)
    return storage.race_settings[target_race_name]["boss_tier"] or 1
end

function RaceSettingsHelper.get_boss_settings(target_race_name)
    return  storage.race_settings[target_race_name]["boss_settings"]
end

function RaceSettingsHelper.can_perform_interplanetary_raid(target_race_name)
    return storage.race_settings[target_race_name]["interplanetary_attack_active"] or false
end

function RaceSettingsHelper.set_interplanetary_raid_for(target_race_name, value)
    storage.race_settings[target_race_name]["interplanetary_attack_active"] = value
end

function RaceSettingsHelper.get_home_planet(target_race_name)
    return storage.race_settings[target_race_name]["home_planet"]
end

function RaceSettingsHelper.get_builder(target_race_name)
    return storage.race_settings[target_race_name]["builder"]
end

function RaceSettingsHelper.is_primitive(target_race_name)
    return storage.race_settings[target_race_name]["is_primitive"] or true
end

function RaceSettingsHelper.get_emotion_data(target_race_name)
    return storage.race_settings[target_race_name]["emotion_data"]
end

function RaceSettingsHelper.get_boss_emotion_data(target_race_name)
    return storage.race_settings[target_race_name]["boss_emotion_data"]
end

return RaceSettingsHelper
