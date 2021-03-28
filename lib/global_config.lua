---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/21/2020 3:16 PM
--- require('__enemyracemanager__/lib/global_config')
---
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/setting-constants')

local String = require('__stdlib__/stdlib/utils/string')
local Table = require('__stdlib__/stdlib/utils/table')

local ErmConfig = {}

ErmConfig.MAX_TIER = 3

ErmConfig.MAP_PROCESS_CHUNK_BATCH = 20
-- Processing Event Interval
ErmConfig.CHUNK_QUEUE_PROCESS_INTERVAL = 30
ErmConfig.LEVEL_PROCESS_INTERVAL = 5 * defines.time.minute

-- EVENTS
ErmConfig.EVENT_TIER_WENT_UP = 'erm_tier_went_up'
ErmConfig.EVENT_LEVEL_WENT_UP = 'erm_level_went_up'

-- How to use event erm_race_setting_updated
-- Check race exists
-- update settings
ErmConfig.RACE_SETTING_UPDATE = 'erm_race_setting_update'

ErmConfig.RACE_MODE_PREFIX = 'erm_'

ErmConfig.MAX_LEVELS = 20

ErmConfig.enemy_races = {MOD_NAME}
ErmConfig.enemy_races_loaded = false

ErmConfig.installed_races = {MOD_NAME}
ErmConfig.installed_races_loaded = false

local is_enemy_race = function(name)
    local helper_mods = {
        erm_terran=true,
    }
    if helper_mods[name] == nil then
        return true
    end

    return false
end

function ErmConfig.get_max_level()
    local level = 10;
    if settings.startup['enemyracemanager-max-level'].value == MAX_LEVEL_20 then
        level = 20
    elseif settings.startup['enemyracemanager-max-level'].value == MAX_LEVEL_5 then
        level = 5
    end
    return level
end

function ErmConfig.get_max_attack_range()
    local attack_range = 14
    if settings.startup['enemyracemanager-max-attack-range'].value == ATTACK_RANGE_20 then
        attack_range = 20
    end
    return attack_range
end

function ErmConfig.mapgen_is_mixed()
    if settings.startup['enemyracemanager-mapping-method'].value == MAP_GEN_DEFAULT then
        return true
    end

    return false
end

function ErmConfig.mapgen_is_2_races_split()
    if settings.startup['enemyracemanager-mapping-method'].value == MAP_GEN_2_RACES_SPLIT then
        return true
    end

    return false
end

function ErmConfig.mapgen_is_one_race_per_surface()
    if settings.startup['enemyracemanager-mapping-method'].value == MAP_GEN_1_RACE_PER_SURFACE then
        return true
    end

    return false
end

function ErmConfig.positive_axis_race()
    return settings.startup['enemyracemanager-2way-group-enemy-positive'].value
end

function ErmConfig.negative_axis_race()
    return settings.startup['enemyracemanager-2way-group-enemy-negative'].value
end

function ErmConfig.get_enemy_races()
    if #ErmConfig.enemy_races == 1 and ErmConfig.enemy_races_loaded == false then
        for name, version in pairs(game.active_mods) do
            if String.find(name, ErmConfig.RACE_MODE_PREFIX) and is_enemy_race(name) then
                Table.insert(ErmConfig.enemy_races, name)
            end
        end
        ErmConfig.enemy_races_loaded = true;
    end
    return ErmConfig.enemy_races
end

function ErmConfig.get_installed_races()
    if #ErmConfig.installed_races == 1 and ErmConfig.installed_races_loaded == false then
        for name, version in pairs(game.active_mods) do
            if String.find(name, ErmConfig.RACE_MODE_PREFIX) then
                Table.insert(ErmConfig.installed_races, name)
            end
        end
        ErmConfig.installed_races_loaded = true;
    end
    return ErmConfig.installed_races
end

return ErmConfig