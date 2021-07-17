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

if DEBUG_MODE then
    ErmConfig.LEVEL_PROCESS_INTERVAL = defines.time.minute
else
    ErmConfig.LEVEL_PROCESS_INTERVAL = 10 * defines.time.minute
end

ErmConfig.CRON = defines.time.minute


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

ErmConfig.CONFIG_CACHE_LENGTH = 5 * defines.time.minute

local is_enemy_race = function(name)
    local helper_mods = {
        erm_terran=true,
    }
    if helper_mods[name] == nil then
        return true
    end

    return false
end

local is_cache_expired = function(last_tick, length) 
    return (game.tick + length) > last_tick
end

local current_level_setting
function ErmConfig.get_max_level()
    if current_level_setting == nil then
        current_level_setting = 10;
        if settings.startup['enemyracemanager-max-level'].value == MAX_LEVEL_20 then
            current_level_setting = 20
        elseif settings.startup['enemyracemanager-max-level'].value == MAX_LEVEL_5 then
            current_level_setting = 5
        end
    end

    return current_level_setting
end

local current_range
function ErmConfig.get_max_attack_range()
    if current_range == nil then
        current_range = 14
        if settings.startup['enemyracemanager-max-attack-range'].value == ATTACK_RANGE_20 then
            current_range = 20
        end
    end        
    return current_range
end

local mapping_method
function ErmConfig.get_mapping_method()
    if mapping_method == nil then
        mapping_method = settings.startup['enemyracemanager-mapping-method'].value
    end
    return mapping_method  
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

local build_style_setting
local build_style_last_tick

function ErmConfig.build_style()
    if build_style_setting == nil or is_cache_expired(build_style_last_tick, ErmConfig.CONFIG_CACHE_LENGTH) then
        build_style_setting = settings.global['enemyracemanager-build-style'].value
        build_style_last_tick = game.tick
    end        
    return build_style_setting
end

local build_formation_setting
local build_formation_last_tick
function ErmConfig.build_formation()
    if build_formation_setting == nil or is_cache_expired(build_formation_last_tick, ErmConfig.CONFIG_CACHE_LENGTH) then
        build_formation_setting = settings.global['enemyracemanager-build-formation'].value
        build_formation_last_tick = game.tick
    end        
    return build_formation_setting
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


local get_cron_randomizer = function()
    return math.random(1, 600)
end

-- Spread cron job across the 10 seconds, instead of same tick.
function ErmConfig.get_cron_tick()
    return ErmConfig.CRON + get_cron_randomizer()
end

return ErmConfig