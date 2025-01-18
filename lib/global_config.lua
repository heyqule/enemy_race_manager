---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/21/2020 3:16 PM
--- require("__enemyracemanager__/lib/global_config")
---
require("util")
require("__enemyracemanager__/setting-constants")

local GlobalConfig = {}

GlobalConfig.MAX_TIER = 3
--- Tick base EVENTS
GlobalConfig.RACE_SETTING_UPDATE_INTERVAL = 5 * minute
GlobalConfig.ATTACK_GROUP_GATHERING_CRON = 1 * minute + 1
GlobalConfig.ATTACK_POINT_CALCULATION = minute + 3
GlobalConfig.BOSS_QUEUE_CRON = 11
GlobalConfig.TELEPORT_QUEUE_CRON = 33
GlobalConfig.AUTO_DEPLOY_CRON = 3 * second + 1
GlobalConfig.SPAWN_SCOUTS_INTERVAL = 25301
GlobalConfig.TIME_BASED_ATTACK_POINT_CRON = 1 * minute + 3

-- +1 to spread the job across all ticks
-- execute all job on designated tick
GlobalConfig.ONE_MINUTE_CRON = minute + 1
GlobalConfig.FIFTEEN_SECONDS_CRON = 15 * second + 1
GlobalConfig.TWO_SECONDS_CRON = 2 * second + 1

-- execute one job on designated tick
GlobalConfig.TEN_SECONDS_CRON = 10 * second + 1
GlobalConfig.ONE_SECOND_CRON = second + 1
GlobalConfig.QUICK_CRON = 11

-- Run garbage collection and statistics on each nauvis day
GlobalConfig.GC_AND_STATS = 25000



GlobalConfig.EVENT_FLUSH_GLOBAL = "erm_flush_global"
GlobalConfig.EVENT_ADJUST_ATTACK_METER = "erm_adjust_attack_meter"
GlobalConfig.EVENT_ADJUST_ACCUMULATED_ATTACK_METER = "erm_adjust_accumulated_attack_meter"

--- Group command management
GlobalConfig.EVENT_BASE_BUILT = "erm_base_built"
GlobalConfig.EVENT_INTERPLANETARY_ATTACK_SCAN = "erm_interplanetary_attack_scan"
GlobalConfig.EVENT_REQUEST_PATH = "erm_request_path"
GlobalConfig.EVENT_REQUEST_BASE_BUILD = "erm_request_base_build"
GlobalConfig.EVENT_INTERPLANETARY_ATTACK_EXEC = "erm_interplanatary_attack_exec"

-- How to use event erm_race_setting_updated
-- Check race exists
-- update settings
GlobalConfig.RACE_SETTING_UPDATE = "erm_race_setting_update"
GlobalConfig.PREPARE_WORLD = "erm_prepare_world"

--- Store script.generate_event_name() IDs
GlobalConfig.custom_event_handlers = {}

--- Quality system attributes
GlobalConfig.MAX_LEVELS = 5
GlobalConfig.MAX_BY_EPIC = 1
GlobalConfig.MAX_BY_RARE = 2
GlobalConfig.BASE_QUALITY_MULITPLIER = 0.5
GlobalConfig.QUALITY_MAPPING = {
    {"quality_mapping.normal"},
    {"quality_mapping.great"},
    {"quality_mapping.exceptional"},
    {"quality_mapping.epic"},
    {"quality_mapping.legendary"},
}

GlobalConfig.BOSS_MAX_TIERS = 5
-- 5 Tiers of boss and their properties
GlobalConfig.BOSS_DESPAWN_TIMER = { 60, 75, 90, 105, 120 }

local boss_difficulty = {
    [BOSS_NORMAL] = { 25, 30, 36, 42, 50 },
    [BOSS_HARD] = { 36, 42, 51, 62, 75 },
    [BOSS_GODLIKE] = { 51, 62, 74, 86, 99 }
}
GlobalConfig.BOSS_LEVELS = boss_difficulty[settings.startup["enemyracemanager-boss-difficulty"].value]

local boss_spawn_size = {
    [BOSS_SPAWN_SQUAD] = 5,
    [BOSS_SPAWN_PATROL] = 10,
    [BOSS_SPAWN_PLATOON] = 20,
}
GlobalConfig.boss_spawn_size = boss_spawn_size[settings.startup["enemyracemanager-attacks-unit-spawn-size"].value]
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


GlobalConfig.IS_FFA = settings.startup["enemyracemanager-free-for-all"].value
GlobalConfig.FFA_MULTIPLIER = settings.startup["enemyracemanager-free-for-all-multiplier"].value

GlobalConfig.MAX_TIME_TO_LIVE_UNIT = 800
GlobalConfig.TIME_TO_LIVE_UNIT_BATCH = 64
GlobalConfig.OVERFLOW_TIME_TO_LIVE_UNIT_BATCH = 320

local refreshable_settings = {
    startup = {
        "enemyracemanager-max-attack-range",
    },
    global = {
        "enemyracemanager-max-gathering-groups",
        "enemyracemanager-max-group-size",
        "enemyracemanager-difficulty",
        "enemyracemanager-advancement",
        "enemyracemanager-build-style",
        "enemyracemanager-build-formation",
        "enemyracemanager-attack-point-spawner-kills-deduction",
        "enemyracemanager-attack-meter-threshold",
        "enemyracemanager-attack-meter-threshold-deviation",
        "enemyracemanager-attack-meter-collector-multiplier",
        "enemyracemanager-rocket-attack-point-enable",
        "enemyracemanager-rocket-attack-point",
        "enemyracemanager-super-weapon-attack-point-enable",
        "enemyracemanager-super-weapon-attack-point",
        "enemyracemanager-super-weapon-counter-attack-enable",
        "enemyracemanager-flying-squad-enable",
        "enemyracemanager-flying-squad-chance",
        "enemyracemanager-dropship-squad-enable",
        "enemyracemanager-dropship-squad-chance",
        "enemyracemanager-featured-squad-chance",
        "enemyracemanager-elite-squad-enable",
        "enemyracemanager-elite-squad-attack-points",
        "enemyracemanager-precision-strike-flying-unit-enable",
        "enemyracemanager-precision-strike-flying-unit-chance",
        "enemyracemanager-precision-strike-warning",
        "enemyracemanager-time-based-enable",
        "enemyracemanager-time-based-points",
    }
}

local get_global_setting_value = function(setting_name)
    local setting_value = storage.settings[setting_name]
    if setting_value == nil then
        setting_value = settings.global[setting_name].value
        storage.settings[setting_name] = setting_value
    end
    return setting_value
end

local global_setting_exists = function()
    return storage and storage.settings
end

local check_register_erm_race = function(mod_name)
    mod_name = string.gsub(mod_name,"enemy_","")

    if remote.interfaces[mod_name] and
       remote.interfaces[mod_name]["register_new_enemy_race"]
    then
        return remote.call(mod_name, "register_new_enemy_race")
    end
    return nil
end

function GlobalConfig.is_cache_expired(last_tick, length)
    return (game.tick + length) > last_tick
end

function GlobalConfig.refresh_config()
    for _, setting_name in pairs(refreshable_settings.startup) do

        if setting_name == "enemyracemanager-max-attack-range" then
            storage.settings[setting_name] = settings.startup[setting_name].value
        else
            storage.settings[setting_name] = settings.startup[setting_name].value
        end
    end

    for _, setting_name in pairs(refreshable_settings.global) do
        storage.settings[setting_name] = settings.global[setting_name].value
    end
end

function GlobalConfig.get_max_level()
    return GlobalConfig.MAX_LEVELS
end

function GlobalConfig.get_max_attack_range()
    local current_range
    if global_setting_exists() then
        current_range = storage.settings["enemyracemanager-max-attack-range"]
    end

    if current_range == nil then
        current_range = settings.startup["enemyracemanager-max-attack-range"].value

        if global_setting_exists() then
            storage.settings["enemyracemanager-max-attack-range"] = current_range
        end
    end
    return current_range
end

function GlobalConfig.get_max_projectile_range(multiplier)
    multiplier = multiplier or 1
    return 64 * multiplier
end

function GlobalConfig.build_style()
    return get_global_setting_value("enemyracemanager-build-style")
end

function GlobalConfig.build_formation()
    return get_global_setting_value("enemyracemanager-build-formation")
end

function GlobalConfig.attack_meter_threshold()
    return get_global_setting_value("enemyracemanager-attack-meter-threshold")
end

function GlobalConfig.attack_meter_deviation()
    return get_global_setting_value("enemyracemanager-attack-meter-threshold-deviation")
end

function GlobalConfig.attack_meter_collector_multiplier()
    return get_global_setting_value("enemyracemanager-attack-meter-collector-multiplier")
end

function GlobalConfig.flying_squad_enabled()
    return get_global_setting_value("enemyracemanager-flying-squad-enable")
end

function GlobalConfig.flying_squad_chance()
    return get_global_setting_value("enemyracemanager-flying-squad-chance")
end

function GlobalConfig.dropship_enabled()
    return get_global_setting_value("enemyracemanager-dropship-squad-enable")
end

function GlobalConfig.dropship_chance()
    return get_global_setting_value("enemyracemanager-dropship-squad-chance")
end

function GlobalConfig.featured_squad_chance()
    return get_global_setting_value("enemyracemanager-featured-squad-chance")
end

function GlobalConfig.elite_squad_enable()
    return get_global_setting_value("enemyracemanager-elite-squad-enable")
end

function GlobalConfig.elite_squad_attack_points()
    return get_global_setting_value("enemyracemanager-elite-squad-attack-points")
end

function GlobalConfig.flying_squad_precision_enabled()
    return get_global_setting_value("enemyracemanager-precision-strike-flying-unit-enable")
end

function GlobalConfig.flying_squad_precision_chance()
    return get_global_setting_value("enemyracemanager-precision-strike-flying-unit-chance")
end

function GlobalConfig.precision_strike_warning()
    return get_global_setting_value("enemyracemanager-precision-strike-warning")
end

function GlobalConfig.max_group_size()
    return get_global_setting_value("enemyracemanager-max-group-size")
end

function GlobalConfig.time_base_attack_enabled()
    return get_global_setting_value("enemyracemanager-time-based-enable")
end

function GlobalConfig.time_base_attack_points()
    return get_global_setting_value("enemyracemanager-time-based-points")
end

function GlobalConfig.rocket_attack_point_enable()
    return get_global_setting_value("enemyracemanager-rocket-attack-point-enable")
end

function GlobalConfig.rocket_attack_points()
    return get_global_setting_value("enemyracemanager-rocket-attack-point")
end

function GlobalConfig.super_weapon_attack_points_enable()
    return get_global_setting_value("enemyracemanager-super-weapon-attack-point-enable")
end

function GlobalConfig.super_weapon_attack_points()
    return get_global_setting_value("enemyracemanager-super-weapon-attack-point")
end

function GlobalConfig.super_weapon_counter_attack_enable()
    return get_global_setting_value("enemyracemanager-super-weapon-counter-attack-enable")
end

function GlobalConfig.spawner_kills_deduct_evolution_points()
    return get_global_setting_value("enemyracemanager-attack-point-spawner-kills-deduction")
end

function GlobalConfig.initialize_races_data()
    storage.installed_races = { [MOD_NAME] = true }
    storage.active_races = { [MOD_NAME] = true }


    for name, _ in pairs(script.active_mods) do
        local register_id = check_register_erm_race(name)
        if register_id then
            storage.active_races[register_id] = true
        end
    end

    for name, _ in pairs(script.active_mods) do
        local register_id = check_register_erm_race(name)
        if register_id then
            storage.installed_races[register_id] = true
        end
    end

    storage.active_races_num = table_size(storage.active_races)

    for key, _ in pairs(storage.active_races) do
        table.insert(storage.active_races_names, key)
    end
end

function GlobalConfig.get_enemy_races()
    return storage.active_races_names
end

function GlobalConfig.get_enemy_races_total()
    return storage.active_races_num
end

function GlobalConfig.race_is_active(force_name)
    return storage.active_races[force_name] == true
end

function GlobalConfig.get_installed_races()
    return storage.installed_races
end

function GlobalConfig.format_daytime(start_tick, end_tick)
    local difference = end_tick - start_tick
    local lday = math.floor(difference / day)
    local hour_difference = difference - (lday * day)
    local lhour = math.floor(hour_difference / hour)
    local minute_difference = difference - (lday * day) - (lhour * hour)
    local lminute = math.floor(minute_difference / minute)
    local second_difference = difference - (lday * day) - (lhour * hour) - (lminute * minute)
    local lsecond = math.floor(second_difference / second)
    return lday, lhour, lminute, lsecond
end

function GlobalConfig.format_daytime_string(start_tick, end_tick)
    local day, hour, minute, second = GlobalConfig.format_daytime(start_tick, end_tick)
    local datetime_str = ""
    if day > 0 then
        datetime_str = datetime_str .. string.format("%02d D ", day)
    end

    datetime_str = datetime_str .. string.format("%02d:%02d:%02d", hour, minute, second)

    return datetime_str;
end

function GlobalConfig.add_attack_group_attackable_entity(name)
    local data_table = prototypes.get_entity_filtered({{ filter = "name", name = name }})
    if data_table[name] then
        local name_exists = false
        for _, value in pairs(storage.attack_group_attackable_entity_names) do
            if value == name then
                name_exists = true
                break;
            end
        end

        if not name_exists then
            table.insert(storage.attack_group_attackable_entity_names, name)
        end
    end
end

--- Unit group must be valid when this runs. If it doesn't, it likely other mods mess it up.
function GlobalConfig.check_unit_group_for_mod_incompatibility(group)
    if not group.valid and
        storage.compatibility_warnings == false
    then
        storage.compatibility_warnings = true
        game.print({"gui.compatibility_warning"})
        return true
    end
    return false
end

return GlobalConfig