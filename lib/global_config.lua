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
ErmConfig.CHUNK_QUEUE_PROCESS_INTERVAL = 31

if DEBUG_MODE then
    ErmConfig.LEVEL_PROCESS_INTERVAL = defines.time.minute
    ErmConfig.ATTACK_GROUP_GATHERING_CRON = defines.time.minute + 1

    ErmConfig.TEN_MINUTES_CRON = defines.time.minute + 1
    ErmConfig.ONE_MINUTE_CRON = defines.time.minute + 1
    ErmConfig.TEN_SECONDS_CRON = 2 * defines.time.second + 1
    ErmConfig.ONE_SECOND_CRON = defines.time.second / 4 + 1
else
    ErmConfig.LEVEL_PROCESS_INTERVAL = 60 * defines.time.minute
    ErmConfig.ATTACK_GROUP_GATHERING_CRON = settings.startup['enemyracemanager-attack-meter-group-interval'].value * defines.time.minute + 1

    -- +1 to spread the job across all ticks
    ErmConfig.TEN_MINUTES_CRON = 10 * defines.time.minute + 1
    ErmConfig.ONE_MINUTE_CRON = defines.time.minute + 1
    ErmConfig.TEN_SECONDS_CRON = 10 * defines.time.second + 1
    ErmConfig.ONE_SECOND_CRON = defines.time.second + 1
end

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
ErmConfig.CONFIG_CACHE_SIZE = 256

local refreshable_settings = {
    startup = {
        'enemyracemanager-max-attack-range',
        'enemyracemanager-max-level',
        'enemyracemanager-mapping-method',
        'enemyracemanager-max-group-size'
    },
    global = {
        'enemyracemanager-build-style',
        'enemyracemanager-build-formation',
        'enemyracemanager-evolution-point-accelerator',
        'enemyracemanager-evolution-point-multipliers',
        'enemyracemanager-attack-meter-enable',
        'enemyracemanager-attack-meter-threshold',
        'enemyracemanager-attack-meter-threshold-deviation',
        'enemyracemanager-flying-squad-enable',
        'enemyracemanager-flying-squad-chance',
        'enemyracemanager-dropship-squad-enable',
        'enemyracemanager-dropship-squad-chance',
        'enemyracemanager-precision-strike-flying-unit-enable',
        'enemyracemanager-precision-strike-flying-unit-chance',
        'enemyracemanager-precision-strike-warning'
    }
}

local is_enemy_race = function(name)
    local helper_mods = {
        erm_terran=true,
    }
    if helper_mods[name] == nil then
        return true
    end

    return false
end

local convert_max_level =  function(setting_value)
    local current_level_setting = 10;

    if setting_value == MAX_LEVEL_20 then
        current_level_setting = 20
    elseif setting_value == MAX_LEVEL_15 then
        current_level_setting = 15
    elseif setting_value == MAX_LEVEL_5 then
        current_level_setting = 5
    end

    return current_level_setting
end

local convert_max_range =  function(setting_value)
    local current_range = 14
    if setting_value == ATTACK_RANGE_20 then
        current_range = 20
    end
    return current_range
end

local get_global_setting_value = function(setting_name)
    local setting_value = global.settings[setting_name]
    if setting_value == nil then
        setting_value = settings.global[setting_name].value
        global.settings[setting_name] = setting_value
    end
    return setting_value
end

function ErmConfig.is_cache_expired(last_tick, length)
    return (game.tick + length) > last_tick
end

function ErmConfig.refresh_config()
    for _, setting_name in pairs(refreshable_settings.startup) do
        if setting_name == 'enemyracemanager-max-level' then
            global.settings[setting_name] = convert_max_level(settings.startup[setting_name].value)
        elseif setting_name == 'enemyracemanager-max-attack-range' then
            global.settings[setting_name] = convert_max_range(settings.startup[setting_name].value)
        else
            global.settings[setting_name] = settings.startup[setting_name].value
        end
    end

    for _, setting_name in pairs(refreshable_settings.global) do
        global.settings[setting_name] = settings.global[setting_name].value
    end
end

function ErmConfig.get_max_level()
    local current_level_setting
    if global then
        current_level_setting = global.settings['enemyracemanager-max-level']
    end

    if current_level_setting == nil then
        current_level_setting = convert_max_level(settings.startup['enemyracemanager-max-level'].value)

        if global then
            global.settings['enemyracemanager-max-level'] = current_level_setting
        end
    end

    return current_level_setting
end

function ErmConfig.get_max_attack_range()
    local current_range
    if global then
        current_range = global.settings['enemyracemanager-max-attack-range']
    end

    if current_range == nil then
        local setting_value = settings.startup['enemyracemanager-max-attack-range'].value
        current_range = 14
        if setting_value == ATTACK_RANGE_20 then
            current_range = 20
        end

        if global then
            global.settings['enemyracemanager-max-attack-range'] = current_range
        end
    end        
    return current_range
end


function ErmConfig.get_mapping_method()
    local mapping_method
    if global then
        mapping_method = global.settings['enemyracemanager-mapping-method']
    end

    if mapping_method == nil then
        mapping_method = settings.startup['enemyracemanager-mapping-method'].value

        if global then
            global.settings['enemyracemanager-max-attack-range'] = mapping_method
        end
    end
    return mapping_method  
end

function ErmConfig.mapgen_is_mixed()
    if ErmConfig.get_mapping_method() == MAP_GEN_DEFAULT then
        return true
    end

    return false
end

function ErmConfig.mapgen_is_2_races_split()
    if ErmConfig.get_mapping_method() == MAP_GEN_2_RACES_SPLIT then
        return true
    end

    return false
end

function ErmConfig.mapgen_is_one_race_per_surface()
    if ErmConfig.get_mapping_method() == MAP_GEN_1_RACE_PER_SURFACE then
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

function ErmConfig.build_style()
    return get_global_setting_value('enemyracemanager-build-style')
end


function ErmConfig.build_formation()
    return get_global_setting_value('enemyracemanager-build-formation')
end

function ErmConfig.attack_meter_enabled()
    return get_global_setting_value('enemyracemanager-attack-meter-enable')
end

function ErmConfig.attack_meter_threshold()
    return get_global_setting_value('enemyracemanager-attack-meter-threshold')
end

function ErmConfig.attack_meter_deviation()
    return get_global_setting_value('enemyracemanager-attack-meter-threshold-deviation')
end

function ErmConfig.flying_squad_enabled()
    return get_global_setting_value('enemyracemanager-flying-squad-enable')
end

function ErmConfig.flying_squad_chance()
    return get_global_setting_value('enemyracemanager-flying-squad-chance')
end

function ErmConfig.dropship_enabled()
    return get_global_setting_value('enemyracemanager-dropship-squad-enable')
end

function ErmConfig.dropship_chance()
    return get_global_setting_value('enemyracemanager-dropship-squad-chance')
end

function ErmConfig.flying_squad_precision_enabled()
    return get_global_setting_value('enemyracemanager-precision-strike-flying-unit-enable')
end

function ErmConfig.flying_squad_precision_chance()
    return get_global_setting_value('enemyracemanager-precision-strike-flying-unit-chance')
end

function ErmConfig.precision_strike_warning()
    return get_global_setting_value('enemyracemanager-precision-strike-warning')
end

function ErmConfig.max_group_size()
    return get_global_setting_value('enemyracemanager-max-group-size')
end

function ErmConfig.get_enemy_races()
    if #ErmConfig.enemy_races == 1 and ErmConfig.enemy_races_loaded == false then
        for name, version in pairs(game.active_mods) do
            if String.find(name, ErmConfig.RACE_MODE_PREFIX, 1, true) and is_enemy_race(name) then
                Table.insert(ErmConfig.enemy_races, name)
            end
        end
        ErmConfig.enemy_races_loaded = true;
    end
    return ErmConfig.enemy_races
end

function ErmConfig.get_installed_races()
    if #ErmConfig.installed_races == 1 and ErmConfig.installed_races_loaded == false then
        for name, _ in pairs(game.active_mods) do
            if String.find(name, ErmConfig.RACE_MODE_PREFIX, 1, true) then
                Table.insert(ErmConfig.installed_races, name)
            end
        end
        ErmConfig.installed_races_loaded = true;
    end
    return ErmConfig.installed_races
end

return ErmConfig