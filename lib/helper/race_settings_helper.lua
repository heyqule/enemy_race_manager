local String = require('__stdlib__/stdlib/utils/string')
local Table = require('__stdlib__/stdlib/utils/table')

local RaceSettingHelper = {
    default_mod_name = 'erm_vanilla'
}

local FEATURE_RACE_NAME = 1
local FEATURE_RACE_SPAWN_DATA = 2
local FEATURE_RACE_SPAWN_COST = 3
local FEATURE_RACE_SPAWN_CACHE = 4
local FEATURE_RACE_SPAWN_CACHE_SIZE = 5

local find_unit_from_current_table = function(race_settings, unit_type, unit_name)
    local key = 'current_' .. unit_type .. '_tier'
    for index, value in pairs(race_settings[key]) do
        if value == unit_name then
            return index
        end
    end
    return nil
end

local add_to_current_entity_table = function(race_settings, unit_type, unit_name)
    local key = 'current_' .. unit_type .. '_tier'
    local target_index = find_unit_from_current_table(race_settings, unit_type, unit_name)
    if target_index == nil then
        race_settings[key][#race_settings[key] + 1] = unit_name
    end
end

local has_unit_tier = function(race_settings, unit_type, unit_tier)
    return race_settings and race_settings[unit_type] and race_settings[unit_type][unit_tier]
end

local remove_from_current_entity_table = function(race_settings, unit_type, unit_name)
    local key = 'current_' .. unit_type .. '_tier'
    local target_index = find_unit_from_current_table(race_settings, unit_type, unit_name)
    if target_index then
        table.remove(race_settings[key], target_index)
    end
end

local add_to_entity_table = function(race_settings, unit_type, unit_tier, unit_name)
    if has_unit_tier(race_settings, unit_type, unit_tier) then
        local target_index
        for index, value in pairs(race_settings[unit_type][unit_tier]) do
            if value == unit_name then
                target_index = index
            end
        end

        if target_index == nil then
            race_settings[unit_type][unit_tier][#race_settings[unit_type][unit_tier] + 1] = unit_name

            if race_settings['tier'] >= unit_tier then
                add_to_current_entity_table(race_settings, unit_type, unit_name)
            end
        end
    end
end

local remove_from_entity_table = function(race_settings, unit_type, unit_tier, unit_name)
    if has_unit_tier(race_settings, unit_type, unit_tier) then
        local target_index
        for index, value in pairs(race_settings[unit_type][unit_tier]) do
            if value == unit_name then
                target_index = index
            end
        end

        if target_index then
            table.remove(race_settings[unit_type][unit_tier], target_index)
            remove_from_current_entity_table(race_settings, unit_type, unit_name)
        end
    end
end

function RaceSettingHelper.add_structure_to_tier(race_settings, tier, structure)
    add_to_entity_table(race_settings, 'support_structures', tier, structure)
end

function RaceSettingHelper.remove_structure_from_tier(race_settings, tier, structure)
    remove_from_entity_table(race_settings, 'support_structures', tier, structure)
end

function RaceSettingHelper.add_command_center_from_tier(race_settings, tier, structure)
    add_to_entity_table(race_settings, 'command_centers', tier, structure)
end

function RaceSettingHelper.remove_command_center_to_tier(race_settings, tier, structure)
    remove_from_entity_table(race_settings, 'command_centers', tier, structure)
end

function RaceSettingHelper.add_unit_to_tier(race_settings, tier, structure)
    add_to_entity_table(race_settings, 'units', tier, structure)
end

function RaceSettingHelper.remove_unit_from_tier(race_settings, tier, structure)
    remove_from_entity_table(race_settings, 'units', tier, structure)
end

function RaceSettingHelper.add_turret_to_tier(race_settings, tier, structure)
    add_to_entity_table(race_settings, 'turrets', tier, structure)
end

function RaceSettingHelper.remove_turret_from_tier(race_settings, tier, structure)
    remove_from_entity_table(race_settings, 'turrets', tier, structure)
end

function RaceSettingHelper.clean_up_race()
    if global.race_settings == nil then
        return
    end

    for _, item in pairs(global.race_settings) do
        if item.race ~= RaceSettingHelper.default_mod_name and game.active_mods[item.race] == nil then
            global.race_settings = Table.remove_keys(global.race_settings, { item.race })
            game.merge_forces('enemy_' .. item.race, 'enemy')
        end
    end
end

function RaceSettingHelper.pick_a_spawner(target_race)
    local support_structures = global.race_settings[target_race]['current_support_structures_tier']
    local base_structures = global.race_settings[target_race]['current_command_centers_tier']
    local pick = math.random();

    local base_name = ''
    if pick < 0.125 then
        base_name = base_structures[math.random(1, #base_structures)]
    else
        base_name = support_structures[math.random(1, #support_structures)]
    end

    return base_name
end

function RaceSettingHelper.pick_a_turret(target_race)
    local turret_tier = global.race_settings[target_race]['current_turrets_tier']
    local base_name = turret_tier[math.random(1, #turret_tier)]
    return base_name
end

function RaceSettingHelper.pick_a_command_center(target_race)
    local cc_tier = global.race_settings[target_race]['current_command_centers_tier']
    local base_name = cc_tier[math.random(1, #cc_tier)]
    return base_name
end

function RaceSettingHelper.pick_a_support_building(target_race)
    local support_tier = global.race_settings[target_race]['current_support_structures_tier']
    local base_name = support_tier[math.random(1, #support_tier)]
    return base_name
end

function RaceSettingHelper.pick_an_unit(target_race)
    local units = global.race_settings[target_race]['current_units_tier']
    local unit_name = units[math.random(1, #units)]
    return unit_name
end

function RaceSettingHelper.pick_an_unit_from_tier(target_race, tier)
    local units = global.race_settings[target_race]['units'][tier]
    local unit_name = units[math.random(1, #units)]
    return unit_name
end

function RaceSettingHelper.has_flying_unit(target_race)
    if global.race_settings[target_race]['flying_units'] == nil then
        return false
    end

    return true
end

function RaceSettingHelper.pick_a_flying_unit_from_tier(target_race, tier)
    local units = global.race_settings[target_race]['flying_units'][tier]
    local unit_name = units[math.random(1, #units)]
    return unit_name
end

function RaceSettingHelper.has_dropship_unit(target_race)
    if global.race_settings[target_race]['dropship'] == nil then
        return false
    end

    return true
end

function RaceSettingHelper.pick_dropship_unit(target_race)
    return global.race_settings[target_race]['dropship']
end

function RaceSettingHelper.is_timed_unit(target_race, unit_name)
    return global.race_settings[target_race]['timed_units'][unit_name]
end

function RaceSettingHelper.is_command_center(target_race, name)
    local command_centers = global.race_settings[target_race]['current_command_centers_tier']
    for _, val in pairs(command_centers) do
        if val == name then
            return true
        end
    end
    return false
end

function RaceSettingHelper.get_current_unit_tier(target_race)
    return global.race_settings[target_race].current_units_tier
end

function RaceSettingHelper.get_current_turret_tier(target_race)
    return global.race_settings[target_race].current_turrets_tier
end

function RaceSettingHelper.get_current_building_tier(target_race)
    return global.race_settings[target_race].current_building_tier
end

function RaceSettingHelper.get_current_command_centers(target_race)
    return global.race_settings[target_race].current_command_centers_tier
end

function RaceSettingHelper.get_attack_meter(target_race)
    return global.race_settings[target_race].attack_meter
end

function RaceSettingHelper.add_to_attack_meter(target_race, value)
    global.race_settings[target_race].attack_meter = math.min(global.race_settings[target_race].attack_meter + value, 999999)
    if (value > 0) then
        RaceSettingHelper.set_accumulated_attack_meter(target_race, global.race_settings[target_race].attack_meter_total + math.min(value, 999999))
    end
end

function RaceSettingHelper.get_next_attack_threshold(target_race)
    return global.race_settings[target_race].next_attack_threshold
end

function RaceSettingHelper.set_next_attack_threshold(target_race, value)
    global.race_settings[target_race].next_attack_threshold = math.floor(value)
end

function RaceSettingHelper.get_accumulated_attack_meter(target_race)
    return global.race_settings[target_race].attack_meter_total
end

function RaceSettingHelper.set_accumulated_attack_meter(target_race, value)
    global.race_settings[target_race].attack_meter_total = value
end

function RaceSettingHelper.get_last_accumulated_attack_meter(target_race)
    return global.race_settings[target_race].last_attack_meter_total
end

function RaceSettingHelper.set_last_accumulated_attack_meter(target_race, value)
    global.race_settings[target_race].last_attack_meter_total = value
end

function RaceSettingHelper.get_evolution_base_point(target_race)
    return global.race_settings[target_race].evolution_base_point
end

function RaceSettingHelper.add_to_evolution_base_point(target_race, value)
    global.race_settings[target_race].evolution_base_point = global.race_settings[target_race].evolution_base_point + value
end

function RaceSettingHelper.get_level(target_race)
    return global.race_settings[target_race].level
end

function RaceSettingHelper.get_tier(target_race)
    return global.race_settings[target_race].tier
end

function RaceSettingHelper.get_race_entity_name(target_race, name, level)
    return target_race .. '/' .. name .. '/' .. level
end

function RaceSettingHelper.add_killed_units_count(target_race, count)
    if global.race_settings[target_race].unit_killed_count == nil then
        global.race_settings[target_race].unit_killed_count = 0
    end
    global.race_settings[target_race].unit_killed_count = global.race_settings[target_race].unit_killed_count + count
end

function RaceSettingHelper.add_killed_structure_count(target_race, count)
    if global.race_settings[target_race].structure_killed_count == nil then
        global.race_settings[target_race].structure_killed_count = 0
    end
    global.race_settings[target_race].structure_killed_count = global.race_settings[target_race].structure_killed_count + count
end

function RaceSettingHelper.refresh_current_tier(race_name)
    local race_settings = global.race_settings[race_name]
    local i = 1

    if race_settings.units == nil then
        return
    end

    race_settings.current_units_tier = {}
    race_settings.current_turrets_tier = {}
    race_settings.current_command_centers_tier = {}
    race_settings.current_support_structures_tier = {}
    race_settings.current_building_tier = {}

    while i <= race_settings.tier do
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
    global.race_settings[race_name] = race_settings
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

function RaceSettingHelper.process_unit_spawn_rate_cache(race_data)
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
        race_data['featured_groups_total'] = #race_data.featured_groups
    end

    if race_data.featured_flying_groups then
        for _, featured_groups in pairs(race_data.featured_flying_groups) do
            process_spawn_chance_cache(featured_groups)
        end
        race_data['featured_flying_groups_total'] = #race_data.featured_flying_groups
    end

    return race_data
end

function RaceSettingHelper.get_featured_squad_id(race_name)
    return math.random(1, global.race_settings[race_name]['featured_groups_total'])
end

function RaceSettingHelper.get_featured_flying_squad_id(race_name)
    return math.random(1, global.race_settings[race_name]['featured_flying_groups_total'])
end

function RaceSettingHelper.get_featured_unit_cost(target_race, featured_group_id)
    local featured_group = global.race_settings[target_race]['featured_groups'][featured_group_id]
    return featured_group[FEATURE_RACE_SPAWN_COST];
end

function RaceSettingHelper.pick_featured_unit(target_race, featured_group_id)
    local featured_group = global.race_settings[target_race]['featured_groups'][featured_group_id]
    return featured_group[FEATURE_RACE_NAME][featured_group[FEATURE_RACE_SPAWN_CACHE][math.random(1, featured_group[FEATURE_RACE_SPAWN_CACHE_SIZE])]]
end

function RaceSettingHelper.pick_featured_flying_unit(target_race, featured_group_id)
    local featured_group = global.race_settings[target_race]['featured_flying_groups'][featured_group_id]
    return featured_group[FEATURE_RACE_NAME][featured_group[FEATURE_RACE_SPAWN_CACHE][math.random(1, featured_group[FEATURE_RACE_SPAWN_CACHE_SIZE])]]
end

function RaceSettingHelper.has_featured_flying_squad(target_race)
    if global.race_settings[target_race]['featured_flying_groups'] == nil then
        return false
    end

    return true
end

function RaceSettingHelper.has_featured_squad(target_race)
    if global.race_settings[target_race]['featured_groups'] == nil then
        return false
    end

    return true
end

function RaceSettingHelper.get_total_featured_squads(target_race)
    return global.race_settings[target_race]['featured_groups_total'] or 0
end

function RaceSettingHelper.get_total_featured_flying_squads(target_race)
    return global.race_settings[target_race]['featured_flying_groups_total'] or 0
end

function RaceSettingHelper.can_spawn(chance_value)
    return math.random(1, 100) > (100 - chance_value)
end

function RaceSettingHelper.is_in_boss_mode()
    return global.boss.entity and global.boss.entity.valid
end

function RaceSettingHelper.has_boss(target_race)
    return global.race_settings[target_race]['boss_building'] or false
end

function RaceSettingHelper.boss_tier(target_race)
    return global.race_settings[target_race]['boss_tier'] or 1
end

function RaceSettingHelper.k2_creep_enabled(target_race)
    if global.race_settings[target_race]['enable_k2_creep'] == false then
        return false
    end

    return true
end

return RaceSettingHelper
