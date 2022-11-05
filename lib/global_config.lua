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
    ErmConfig.ATTACK_POINT_CALCULATION = defines.time.minute + 1

    ErmConfig.ONE_MINUTE_CRON = 30 * defines.time.second + 1
    ErmConfig.FIFTEEN_SECONDS_CRON = 10 * defines.time.second + 1
    ErmConfig.TWO_SECONDS_CRON = 2 * defines.time.second + 1

    ErmConfig.TEN_SECONDS_CRON = 5 * defines.time.second + 1
    ErmConfig.ONE_SECOND_CRON = defines.time.second + 1
    ErmConfig.QUICK_CRON = 21
else
    ErmConfig.LEVEL_PROCESS_INTERVAL = 10 * defines.time.minute
    ErmConfig.ATTACK_GROUP_GATHERING_CRON = settings.startup['enemyracemanager-attack-meter-group-interval'].value * defines.time.minute + 1
    ErmConfig.ATTACK_POINT_CALCULATION = defines.time.minute + 1

    -- +1 to spread the job across all ticks
    -- execute all job on designated tick
    ErmConfig.ONE_MINUTE_CRON = defines.time.minute + 1
    ErmConfig.FIFTEEN_SECONDS_CRON = 15 * defines.time.second + 1
    ErmConfig.TWO_SECONDS_CRON = 2 * defines.time.second + 1

    -- execute one job on designated tick
    ErmConfig.TEN_SECONDS_CRON = 10 * defines.time.second + 1
    ErmConfig.ONE_SECOND_CRON = defines.time.second + 1
    ErmConfig.QUICK_CRON = 21
end

-- EVENTS
ErmConfig.EVENT_TIER_WENT_UP = 'erm_tier_went_up'
ErmConfig.EVENT_LEVEL_WENT_UP = 'erm_level_went_up'

ErmConfig.BASE_BUILT_EVENT = 'erm_base_built'

-- How to use event erm_race_setting_updated
-- Check race exists
-- update settings
ErmConfig.RACE_SETTING_UPDATE = 'erm_race_setting_update'

ErmConfig.RACE_MODE_PREFIX = 'erm_'

ErmConfig.MAX_LEVELS = 20
ErmConfig.MAX_ELITE_LEVELS = 5

ErmConfig.BOSS_MAX_TIERS = 5
-- 5 Tiers of boss and their properties
ErmConfig.BOSS_DESPAWN_TIMER = {45, 45, 60, 75, 99}

local boss_difficulty = {
    [BOSS_NORMAL] = {25, 30, 36, 42, 50},
    [BOSS_HARD] = {35, 42, 50, 61, 75},
    [BOSS_GODLIKE] = {50, 62, 75, 87, 99}
}
ErmConfig.BOSS_LEVELS = boss_difficulty[settings.startup['enemyracemanager-boss-difficulty'].value]

local boss_spawn_size = {
    [BOSS_SPAWN_SQUAD] = 10,
    [BOSS_SPAWN_PATROL] = 20,
    [BOSS_SPAWN_PLATOON] = 40,
}
ErmConfig.boss_spawn_size = boss_spawn_size[settings.startup['enemyracemanager-boss-unit-spawn-size'].value]
ErmConfig.BOSS_BUILDING_HITPOINT = {10000000, 20000000, 32000000, 50000000, 99999999}

ErmConfig.BOSS_BUILDING_HITPOINT = {1000, 20000000, 32000000, 50000000, 99999999}

ErmConfig.BOSS_MAX_SUPPORT_STRUCTURES = {15, 24, 30, 40, 50}
ErmConfig.BOSS_SPAWN_SUPPORT_STRUCTURES = {5, 6, 7, 9, 12}
-- 1 phase change and 5 types of attacks based on damage taken
ErmConfig.BOSS_DEFENSE_ATTACKS = {15000000, 999999, 200000, 99999, 69420, 20000}
ErmConfig.BOSS_MAX_ATTACKS_PER_HEARTBEAT = {2, 3, 3, 4, 4}

-- 320 radius toward the target area.
ErmConfig.BOSS_ARTILLERY_SCAN_RADIUS = 320
ErmConfig.BOSS_ARTILLERY_SCAN_RANGE = 3200
ErmConfig.BOSS_ARTILLERY_SCAN_ENTITY_LIMIT = 100

ErmConfig.CONFIG_CACHE_LENGTH = 5 * defines.time.minute
ErmConfig.CONFIG_CACHE_SIZE = 1024
if DEBUG_MODE then
    ErmConfig.CONFIG_CACHE_LENGTH = 1 * defines.time.minute
    ErmConfig.CONFIG_CACHE_SIZE = 8
end

ErmConfig.FFA_MULTIPLIER = 10
ErmConfig.BUILD_GROUP_CAP = 50

local refreshable_settings = {
    startup = {
        'enemyracemanager-max-attack-range',
        'enemyracemanager-max-level',
        'enemyracemanager-mapping-method',
        'enemyracemanager-level-curve-multiplier',
    },
    global = {
        'enemyracemanager-max-gathering-groups',
        'enemyracemanager-max-group-size',
        'enemyracemanager-build-style',
        'enemyracemanager-build-formation',
        'enemyracemanager-evolution-point-accelerator',
        'enemyracemanager-evolution-point-multipliers',
        'enemyracemanager-attack-meter-enable',
        'enemyracemanager-attack-meter-threshold',
        'enemyracemanager-attack-meter-threshold-deviation',
        'enemyracemanager-attack-meter-collector-multiplier',
        'enemyracemanager-rocket-attack-point-enable',
        'enemyracemanager-rocket-attack-point',
        'enemyracemanager-super-weapon-attack-point-enable',
        'enemyracemanager-super-weapon-attack-point',
        'enemyracemanager-super-weapon-counter-attack-enable',
        'enemyracemanager-flying-squad-enable',
        'enemyracemanager-flying-squad-chance',
        'enemyracemanager-dropship-squad-enable',
        'enemyracemanager-dropship-squad-chance',
        'enemyracemanager-featured-squad-chance',
        'enemyracemanager-elite-squad-enable',
        'enemyracemanager-elite-squad-attack-points',
        'enemyracemanager-elite-squad-level',
        'enemyracemanager-precision-strike-flying-unit-enable',
        'enemyracemanager-precision-strike-flying-unit-chance',
        'enemyracemanager-precision-strike-warning',
        'enemyracemanager-time-based-enable',
        'enemyracemanager-time-based-points'
    }
}

---
--- Only assign empty as erm_vanilla in control phase
---
local get_selected_race_value = function(value)
    if(value == 'empty' and global) then
        return 'erm_vanilla'
    end

    return value
end

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

local global_setting_exists = function()
    return global and global.settings
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
    if global_setting_exists() then
        current_level_setting = global.settings['enemyracemanager-max-level']
    end

    if current_level_setting == nil then
        current_level_setting = convert_max_level(settings.startup['enemyracemanager-max-level'].value)

        if global_setting_exists() then
            global.settings['enemyracemanager-max-level'] = current_level_setting
        end
    end

    return current_level_setting
end

function ErmConfig.get_level_curve_multiplier()
    return get_global_setting_value('enemyracemanager-level-curve-multiplier')
end

function ErmConfig.get_max_attack_range()
    local current_range
    if global_setting_exists() then
        current_range = global.settings['enemyracemanager-max-attack-range']
    end

    if current_range == nil then
        local setting_value = settings.startup['enemyracemanager-max-attack-range'].value
        current_range = 14
        if setting_value == ATTACK_RANGE_20 then
            current_range = 20
        end

        if global_setting_exists() then
            global.settings['enemyracemanager-max-attack-range'] = current_range
        end
    end        
    return current_range
end

function ErmConfig.get_max_projectile_range(multipler)
    multipler = multipler or 1
    return 64 * multipler
end


function ErmConfig.get_mapping_method()
    local mapping_method
    if global_setting_exists() then
        mapping_method = global.settings['enemyracemanager-mapping-method']
    end

    if mapping_method == nil then
        mapping_method = settings.startup['enemyracemanager-mapping-method'].value

        if global_setting_exists() then
            global.settings['enemyracemanager-mapping-method'] = mapping_method
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

function ErmConfig.mapgen_is_4_races_split()
    if ErmConfig.get_mapping_method() == MAP_GEN_4_RACES_SPLIT then
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
    return get_selected_race_value(settings.startup['enemyracemanager-2way-group-enemy-positive'].value)
end

function ErmConfig.negative_axis_race()
    return get_selected_race_value(settings.startup['enemyracemanager-2way-group-enemy-negative'].value)
end

function ErmConfig.top_left_race()
    return get_selected_race_value(settings.startup['enemyracemanager-4way-top-left'].value)
end

function ErmConfig.top_right_race()
    return get_selected_race_value(settings.startup['enemyracemanager-4way-top-right'].value)
end

function ErmConfig.bottom_left_race()
    return get_selected_race_value(settings.startup['enemyracemanager-4way-bottom-left'].value)
end

function ErmConfig.bottom_right_race()
    return get_selected_race_value(settings.startup['enemyracemanager-4way-bottom-right'].value)
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

function ErmConfig.attack_meter_collector_multiplier()
    return get_global_setting_value('enemyracemanager-attack-meter-collector-multiplier')
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

function ErmConfig.featured_squad_chance()
    return get_global_setting_value('enemyracemanager-featured-squad-chance')
end

function ErmConfig.elite_squad_enable()
    return get_global_setting_value('enemyracemanager-elite-squad-enable')
end

function ErmConfig.elite_squad_attack_points()
    return get_global_setting_value('enemyracemanager-elite-squad-attack-points')
end

function ErmConfig.elite_squad_level()
    return get_global_setting_value('enemyracemanager-elite-squad-level')
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

function ErmConfig.time_base_attack_enabled()
    return get_global_setting_value('enemyracemanager-time-based-enable')
end

function ErmConfig.time_base_attack_points()
    return get_global_setting_value('enemyracemanager-time-based-points')
end

function ErmConfig.rocket_attack_point_enable()
    return get_global_setting_value('enemyracemanager-rocket-attack-point-enable')
end

function ErmConfig.rocket_attack_points()
    return get_global_setting_value('enemyracemanager-rocket-attack-point')
end

function ErmConfig.super_weapon_attack_points_enable()
    return get_global_setting_value('enemyracemanager-super-weapon-attack-point-enable')
end

function ErmConfig.super_weapon_attack_points()
    return get_global_setting_value('enemyracemanager-super-weapon-attack-point')
end

function ErmConfig.super_weapon_counter_attack_enable()
    return get_global_setting_value('enemyracemanager-super-weapon-counter-attack-enable')
end


function ErmConfig.initialize_races_data()
    global.installed_races = {MOD_NAME}
    global.active_races = {[MOD_NAME] = true}

    for name, _ in pairs(game.active_mods) do
        if String.find(name, ErmConfig.RACE_MODE_PREFIX, 1, true) and is_enemy_race(name) then
            Table.insert(global.installed_races, name)
        end
    end

    if ErmConfig.mapgen_is_2_races_split() then
        global.active_races = {
            [ErmConfig.positive_axis_race()] = true,
            [ErmConfig.negative_axis_race()] = true
        }
    elseif ErmConfig.mapgen_is_4_races_split() then
        global.active_races = {
            [ErmConfig.top_left_race()] = true,
            [ErmConfig.top_right_race()] = true,
            [ErmConfig.bottom_left_race()] = true,
            [ErmConfig.bottom_right_race()] = true
        }
    else
        for name, _ in pairs(game.active_mods) do
            if String.find(name, ErmConfig.RACE_MODE_PREFIX, 1, true) and is_enemy_race(name) then
                global.active_races[name] = true
            end
        end
    end

    global.active_races_num = Table.size(global.active_races)

    for key, _ in pairs(global.active_races) do
        Table.insert(global.active_races_names, key)
    end
end

function ErmConfig.get_enemy_races()
    return global.active_races_names
end

function ErmConfig.get_enemy_races_total()
    return global.active_races_num
end

function ErmConfig.race_is_active(race_name)
    return global.active_races[race_name] == true
end


function ErmConfig.get_installed_races()
    return global.installed_races
end

return ErmConfig