local String = require('__stdlib__/stdlib/utils/string')
local Table = require('__stdlib__/stdlib/utils/table')

local RaceSettingHelper = {}

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

local remove_from_current_entity_table = function(race_settings, unit_type, unit_name)
    local key = 'current_' .. unit_type .. '_tier'
    local target_index = find_unit_from_current_table(race_settings, unit_type, unit_name)
    if target_index then
        table.remove(race_settings[key], target_index)
    end
end

local add_to_entity_table = function(race_settings, unit_type, unit_tier, unit_name)
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

local remove_from_entity_table = function(race_settings, unit_type, unit_tier, unit_name)
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

function RaceSettingHelper.add_structure_to_tier(race_settings, tier, structure)
    add_to_entity_table(race_settings, 'support_structures', tier, structure)
end

function RaceSettingHelper.remove_structure_to_tier(race_settings, tier, structure)
    remove_from_entity_table(race_settings, 'support_structures', tier, structure)
end

function RaceSettingHelper.add_command_center_to_tier(race_settings, tier, structure)
    add_to_entity_table(race_settings, 'command_centers', tier, structure)
end

function RaceSettingHelper.remove_command_center_to_tier(race_settings, tier, structure)
    remove_from_entity_table(race_settings, 'command_centers', tier, structure)
end

function RaceSettingHelper.add_unit_to_tier(race_settings, tier, structure)
    add_to_entity_table(race_settings, 'units', tier, structure)
end

function RaceSettingHelper.remove_unit_to_tier(race_settings, tier, structure)
    remove_from_entity_table(race_settings, 'units', tier, structure)
end

function RaceSettingHelper.clean_up_race()
    for _, item in pairs(global.race_settings) do
        if item.race ~= MOD_NAME and game.active_mods[item.race] == nil then
            global.race_settings = Table.remove_keys(global.race_settings, { item.race })
            game.merge_forces('enemy_'..item.race, 'enemy')
        end
    end
end

function RaceSettingHelper.pick_a_spawner(target_race)
    local structure_tier = global.race_settings[target_race]['current_support_structures_tier']
    local strucutre_base = global.race_settings[target_race]['current_command_centers_tier']
    local pick = math.random();

    local base_name = ''
    if pick < 0.125 then
        base_name = strucutre_base[math.random(1, #strucutre_base)]
    else
        base_name = structure_tier[math.random(1, #structure_tier)]
    end

    return base_name
end

function RaceSettingHelper.pick_a_turret(target_race)
    local turret_tier = global.race_settings[target_race]['current_turrets_tier']
    local base_name = turret_tier[math.random(1, #turret_tier)]
    return base_name
end

return RaceSettingHelper
