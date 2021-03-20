local String = require('__stdlib__/stdlib/utils/string')

local RaceSettingHelper = {}

local find_unit_from_current_table = function(race_settings, unit_type, unit_name)
    local key = 'current_'..unit_type..'_tier'
    for index, value in pairs(race_settings[key]) do
        if value == unit_name then
            return index
        end
    end
    return nil
end

local add_to_current_entity_table = function(race_settings, unit_type, unit_name)
    local key = 'current_'..unit_type..'_tier'
    local target_index = find_unit_from_current_table(race_settings, unit_type, unit_name)
    if target_index == nil then
        race_settings[key][#race_settings[key]+1] = unit_name
    end
end

local remove_from_current_entity_table = function(race_settings, unit_type, unit_name)
    local key = 'current_'..unit_type..'_tier'
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
        race_settings[unit_type][unit_tier][#race_settings[unit_type][unit_tier]+1] = unit_name

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

return RaceSettingHelper
