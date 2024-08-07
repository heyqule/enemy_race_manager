---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/21/2020 3:16 PM
--- require('__enemyracemanager__/lib/global_config')
---
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/setting-constants')

local GlobalConfig = {}

GlobalConfig.MAX_TIER = 3

GlobalConfig.MAP_PROCESS_CHUNK_BATCH = 20
-- Processing Event Interval
GlobalConfig.CHUNK_QUEUE_PROCESS_INTERVAL = 31

GlobalConfig.LEVEL_PROCESS_INTERVAL = 10 * defines.time.minute
GlobalConfig.ATTACK_GROUP_GATHERING_CRON = settings.startup['enemyracemanager-attack-meter-group-interval'].value * defines.time.minute + 1
GlobalConfig.ATTACK_POINT_CALCULATION = defines.time.minute + 3
GlobalConfig.BOSS_QUEUE_CRON = 11
GlobalConfig.TELEPORT_QUEUE_CRON = 33
GlobalConfig.AUTO_DEPLOY_CRON = 311
GlobalConfig.SPAWN_SCOUTS_INTERVAL = 25301

-- +1 to spread the job across all ticks
-- execute all job on designated tick
GlobalConfig.ONE_MINUTE_CRON = defines.time.minute + 1
GlobalConfig.FIFTEEN_SECONDS_CRON = 15 * defines.time.second + 1
GlobalConfig.TWO_SECONDS_CRON = 2 * defines.time.second + 1

-- execute one job on designated tick
GlobalConfig.TEN_SECONDS_CRON = 10 * defines.time.second + 1
GlobalConfig.ONE_SECOND_CRON = defines.time.second + 1
GlobalConfig.QUICK_CRON = 11

-- Run garbage collection and statistics on each nauvis day
GlobalConfig.GC_AND_STATS = 25000

-- EVENTS
GlobalConfig.EVENT_TIER_WENT_UP = 'erm_tier_went_up'
GlobalConfig.EVENT_LEVEL_WENT_UP = 'erm_level_went_up'

GlobalConfig.EVENT_FLUSH_GLOBAL = 'erm_flush_global'
GlobalConfig.EVENT_ADJUST_ATTACK_METER = 'erm_adjust_attack_meter'
GlobalConfig.EVENT_ADJUST_ACCUMULATED_ATTACK_METER = 'erm_adjust_accumulated_attack_meter'

--- Group command management
GlobalConfig.EVENT_BASE_BUILT = 'erm_base_built'
GlobalConfig.EVENT_INTERPLANETARY_ATTACK_SCAN = 'erm_interplanetary_attack_scan'
GlobalConfig.EVENT_REQUEST_PATH = 'erm_request_path'
GlobalConfig.EVENT_REQUEST_BASE_BUILD = 'erm_request_base_build'
GlobalConfig.EVENT_INTERPLANETARY_ATTACK_EXEC = 'erm_interplanatary_attack_exec'

-- How to use event erm_race_setting_updated
-- Check race exists
-- update settings
GlobalConfig.RACE_SETTING_UPDATE = 'erm_race_setting_update'
GlobalConfig.PREPARE_WORLD = 'erm_prepare_world'

GlobalConfig.MAX_LEVELS = 20
GlobalConfig.MAX_ELITE_LEVELS = 5

GlobalConfig.BOSS_MAX_TIERS = 5
-- 5 Tiers of boss and their properties
GlobalConfig.BOSS_DESPAWN_TIMER = { 60, 75, 90, 105, 120 }

local boss_difficulty = {
    [BOSS_NORMAL] = { 25, 30, 36, 42, 50 },
    [BOSS_HARD] = { 36, 42, 51, 62, 75 },
    [BOSS_GODLIKE] = { 51, 62, 74, 86, 99 }
}
GlobalConfig.BOSS_LEVELS = boss_difficulty[settings.startup['enemyracemanager-boss-difficulty'].value]

local boss_spawn_size = {
    [BOSS_SPAWN_SQUAD] = 5,
    [BOSS_SPAWN_PATROL] = 10,
    [BOSS_SPAWN_PLATOON] = 20,
}
GlobalConfig.boss_spawn_size = boss_spawn_size[settings.startup['enemyracemanager-boss-unit-spawn-size'].value]
GlobalConfig.BOSS_BUILDING_HITPOINT = { 10000000, 20000000, 32000000, 50000000, 75000000 }

--if DEBUG_MODE then
--    GlobalConfig.BOSS_BUILDING_HITPOINT = {1000000, 2000000, 3200000, 5000000, 7500000}
--end

GlobalConfig.BOSS_MAX_SUPPORT_STRUCTURES = { 15, 24, 30, 40, 50 }
GlobalConfig.BOSS_SPAWN_SUPPORT_STRUCTURES = { 5, 6, 7, 8, 10 }
-- 1 phase change and 5 types of attacks based on damage taken
GlobalConfig.BOSS_DEFENSE_ATTACKS = { 12000000, 999999, 500000, 250000, 69420, 20000 }
GlobalConfig.BOSS_MAX_ATTACKS_PER_HEARTBEAT = { 3, 3, 4, 4, 4 }

-- 320 radius toward the target area.
GlobalConfig.BOSS_ARTILLERY_SCAN_RADIUS = 320
GlobalConfig.BOSS_ARTILLERY_SCAN_RANGE = 3200
GlobalConfig.BOSS_ARTILLERY_SCAN_ENTITY_LIMIT = 100


GlobalConfig.IS_FFA = settings.startup['enemyracemanager-free-for-all'].value
GlobalConfig.FFA_MULTIPLIER = settings.startup['enemyracemanager-free-for-all-multiplier'].value

GlobalConfig.MAX_TIME_TO_LIVE_UNIT = 800
GlobalConfig.TIME_TO_LIVE_UNIT_BATCH = 64
GlobalConfig.OVERFLOW_TIME_TO_LIVE_UNIT_BATCH = 320

local refreshable_settings = {
    startup = {
        'enemyracemanager-max-attack-range',
        'enemyracemanager-max-level',
        'enemyracemanager-mapping-method',
        'enemyracemanager-environmental-raids',
    },
    global = {
        'enemyracemanager-max-gathering-groups',
        'enemyracemanager-max-group-size',
        'enemyracemanager-build-style',
        'enemyracemanager-build-formation',
        'enemyracemanager-evolution-point-multipliers',
        'enemyracemanager-evolution-point-spawner-kills-deduction',
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
        'enemyracemanager-time-based-points',
        'enemyracemanager-environmental-raids-units',
        'enemyracemanager-environmental-raids-chance',
        'enemyracemanager-environmental-raids-build-base-chance',
        'enemyracemanager-interplanetary-raids',
        'enemyracemanager-interplanetary-raids-build-base-chance'
    }
}

---
--- Only assign empty as erm_vanilla in control phase
---
local get_selected_race_value = function(value)
    if (value == 'empty' and global) then
        return 'erm_vanilla'
    end

    return value
end

local convert_max_level = function(setting_value)
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

local check_register_erm_race = function(mod_name)
    if (remote.interfaces[mod_name] and
            remote.interfaces[mod_name]['register_new_enemy_race'] and
            remote.call(mod_name, 'register_new_enemy_race') == true) then
        return true
    end
    return false
end

function GlobalConfig.is_cache_expired(last_tick, length)
    return (game.tick + length) > last_tick
end

function GlobalConfig.refresh_config()
    for _, setting_name in pairs(refreshable_settings.startup) do
        if setting_name == 'enemyracemanager-max-level' then
            global.settings[setting_name] = convert_max_level(settings.startup[setting_name].value)
        elseif setting_name == 'enemyracemanager-max-attack-range' then
            global.settings[setting_name] = settings.startup[setting_name].value
        else
            global.settings[setting_name] = settings.startup[setting_name].value
        end
    end

    for _, setting_name in pairs(refreshable_settings.global) do
        global.settings[setting_name] = settings.global[setting_name].value
    end
end

function GlobalConfig.get_max_level()
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

function GlobalConfig.get_max_attack_range()
    local current_range
    if global_setting_exists() then
        current_range = global.settings['enemyracemanager-max-attack-range']
    end

    if current_range == nil then
        current_range = settings.startup['enemyracemanager-max-attack-range'].value

        if global_setting_exists() then
            global.settings['enemyracemanager-max-attack-range'] = current_range
        end
    end
    return current_range
end

function GlobalConfig.get_max_projectile_range(multiplier)
    multiplier = multiplier or 1
    return 64 * multiplier
end

function GlobalConfig.get_mapping_method()
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

function GlobalConfig.mapgen_is_mixed()
    if GlobalConfig.get_mapping_method() == MAP_GEN_DEFAULT then
        return true
    end

    return false
end

function GlobalConfig.mapgen_is_2_races_split()
    if GlobalConfig.get_mapping_method() == MAP_GEN_2_RACES_SPLIT then
        return true
    end

    return false
end

function GlobalConfig.mapgen_is_4_races_split()
    if GlobalConfig.get_mapping_method() == MAP_GEN_4_RACES_SPLIT then
        return true
    end

    return false
end

function GlobalConfig.mapgen_is_one_race_per_surface()
    if GlobalConfig.get_mapping_method() == MAP_GEN_1_RACE_PER_SURFACE then
        return true
    end

    return false
end

function GlobalConfig.positive_axis_race()
    return get_selected_race_value(settings.startup['enemyracemanager-2way-group-enemy-positive'].value)
end

function GlobalConfig.negative_axis_race()
    return get_selected_race_value(settings.startup['enemyracemanager-2way-group-enemy-negative'].value)
end

function GlobalConfig.top_left_race()
    return get_selected_race_value(settings.startup['enemyracemanager-4way-top-left'].value)
end

function GlobalConfig.top_right_race()
    return get_selected_race_value(settings.startup['enemyracemanager-4way-top-right'].value)
end

function GlobalConfig.bottom_left_race()
    return get_selected_race_value(settings.startup['enemyracemanager-4way-bottom-left'].value)
end

function GlobalConfig.bottom_right_race()
    return get_selected_race_value(settings.startup['enemyracemanager-4way-bottom-right'].value)
end

function GlobalConfig.build_style()
    return get_global_setting_value('enemyracemanager-build-style')
end

function GlobalConfig.build_formation()
    return get_global_setting_value('enemyracemanager-build-formation')
end

function GlobalConfig.attack_meter_enabled()
    return get_global_setting_value('enemyracemanager-attack-meter-enable')
end

function GlobalConfig.attack_meter_threshold()
    return get_global_setting_value('enemyracemanager-attack-meter-threshold')
end

function GlobalConfig.attack_meter_deviation()
    return get_global_setting_value('enemyracemanager-attack-meter-threshold-deviation')
end

function GlobalConfig.attack_meter_collector_multiplier()
    return get_global_setting_value('enemyracemanager-attack-meter-collector-multiplier')
end

function GlobalConfig.flying_squad_enabled()
    return get_global_setting_value('enemyracemanager-flying-squad-enable')
end

function GlobalConfig.flying_squad_chance()
    return get_global_setting_value('enemyracemanager-flying-squad-chance')
end

function GlobalConfig.dropship_enabled()
    return get_global_setting_value('enemyracemanager-dropship-squad-enable')
end

function GlobalConfig.dropship_chance()
    return get_global_setting_value('enemyracemanager-dropship-squad-chance')
end

function GlobalConfig.featured_squad_chance()
    return get_global_setting_value('enemyracemanager-featured-squad-chance')
end

function GlobalConfig.elite_squad_enable()
    return get_global_setting_value('enemyracemanager-elite-squad-enable')
end

function GlobalConfig.elite_squad_attack_points()
    return get_global_setting_value('enemyracemanager-elite-squad-attack-points')
end

function GlobalConfig.elite_squad_level()
    return get_global_setting_value('enemyracemanager-elite-squad-level')
end

function GlobalConfig.flying_squad_precision_enabled()
    return get_global_setting_value('enemyracemanager-precision-strike-flying-unit-enable')
end

function GlobalConfig.flying_squad_precision_chance()
    return get_global_setting_value('enemyracemanager-precision-strike-flying-unit-chance')
end

function GlobalConfig.precision_strike_warning()
    return get_global_setting_value('enemyracemanager-precision-strike-warning')
end

function GlobalConfig.max_group_size()
    return get_global_setting_value('enemyracemanager-max-group-size')
end

function GlobalConfig.time_base_attack_enabled()
    return get_global_setting_value('enemyracemanager-time-based-enable')
end

function GlobalConfig.time_base_attack_points()
    return get_global_setting_value('enemyracemanager-time-based-points')
end

function GlobalConfig.rocket_attack_point_enable()
    return get_global_setting_value('enemyracemanager-rocket-attack-point-enable')
end

function GlobalConfig.rocket_attack_points()
    return get_global_setting_value('enemyracemanager-rocket-attack-point')
end

function GlobalConfig.super_weapon_attack_points_enable()
    return get_global_setting_value('enemyracemanager-super-weapon-attack-point-enable')
end

function GlobalConfig.super_weapon_attack_points()
    return get_global_setting_value('enemyracemanager-super-weapon-attack-point')
end

function GlobalConfig.super_weapon_counter_attack_enable()
    return get_global_setting_value('enemyracemanager-super-weapon-counter-attack-enable')
end

function GlobalConfig.spawner_kills_deduct_evolution_points()
    return get_global_setting_value('enemyracemanager-evolution-point-spawner-kills-deduction')
end

function GlobalConfig.environmental_attack_enable()
    return get_global_setting_value('enemyracemanager-environmental-raids')
end

function GlobalConfig.environmental_attack_units_count()
    return get_global_setting_value('enemyracemanager-environmental-raids-units')
end

function GlobalConfig.environmental_attack_raid_chance()
    return get_global_setting_value('enemyracemanager-environmental-raids-chance')
end

function GlobalConfig.environmental_attack_raid_build_base_chance()
    return get_global_setting_value('enemyracemanager-environmental-raids-build-base-chance')
end

function GlobalConfig.interplanetary_attack_enable()
    return get_global_setting_value('enemyracemanager-interplanetary-raids')
end

function GlobalConfig.interplanetary_attack_raid_build_base_chance()
    return get_global_setting_value('enemyracemanager-interplanetary-raids-build-base-chance')
end

function GlobalConfig.initialize_races_data()
    global.installed_races = { MOD_NAME }
    if settings.startup['enemyracemanager-enable-bitters'].value then
        global.active_races = { [MOD_NAME] = true }
    end

    for name, _ in pairs(script.active_mods) do
        if check_register_erm_race(name) then
            table.insert(global.installed_races, name)
        end
    end

    if GlobalConfig.mapgen_is_2_races_split() then
        global.active_races = {
            [GlobalConfig.positive_axis_race()] = true,
            [GlobalConfig.negative_axis_race()] = true
        }
    elseif GlobalConfig.mapgen_is_4_races_split() then
        global.active_races = {
            [GlobalConfig.top_left_race()] = true,
            [GlobalConfig.top_right_race()] = true,
            [GlobalConfig.bottom_left_race()] = true,
            [GlobalConfig.bottom_right_race()] = true
        }
    else
        for name, _ in pairs(script.active_mods) do
            if check_register_erm_race(name) then
                global.active_races[name] = true
            end
        end
    end

    global.active_races_num = table_size(global.active_races)

    for key, _ in pairs(global.active_races) do
        table.insert(global.active_races_names, key)
    end
end

function GlobalConfig.get_enemy_races()
    return global.active_races_names
end

function GlobalConfig.get_enemy_races_total()
    return global.active_races_num
end

function GlobalConfig.race_is_active(race_name)
    return global.active_races[race_name] == true
end

function GlobalConfig.get_installed_races()
    return global.installed_races
end

function GlobalConfig.format_daytime(start_tick, end_tick)
    local difference = end_tick - start_tick
    local day = math.floor(difference / defines.time.day)
    local hour_difference = difference - (day * defines.time.day)
    local hour = math.floor(hour_difference / defines.time.hour)
    local minute_difference = difference - (day * defines.time.day) - (hour * defines.time.hour)
    local minute = math.floor(minute_difference / defines.time.minute)
    local second_difference = difference - (day * defines.time.day) - (hour * defines.time.hour) - (minute * defines.time.minute)
    local second = math.floor(second_difference / defines.time.second)
    return day, hour, minute, second
end

function GlobalConfig.format_daytime_string(start_tick, end_tick)
    local day, hour, minute, second = GlobalConfig.format_daytime(start_tick, end_tick)
    local datetime_str = ''
    if day > 0 then
        datetime_str = datetime_str .. string.format('%02d D ', day)
    end

    datetime_str = datetime_str .. string.format('%02d:%02d:%02d', hour, minute, second)

    return datetime_str;
end

function GlobalConfig.add_attack_group_attackable_entity(name)
    if game.entity_prototypes[name] then
        local name_exists = false
        for _, value in pairs(global.attack_group_attackable_entity_names) do
            if value == name then
                name_exists = true
                break;
            end
        end

        if not name_exists then
            table.insert(global.attack_group_attackable_entity_names, name)
        end
    end
end

return GlobalConfig