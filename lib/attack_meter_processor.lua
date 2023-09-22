---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/17/2021 1:51 PM
---

local String = require('__stdlib__/stdlib/utils/string')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local ErmAttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')

local ErmCron = require('__enemyracemanager__/lib/cron_processor')

local AttackMeterProcessor = {}

AttackMeterProcessor.SPAWNER_POINTS = 50;
AttackMeterProcessor.TURRET_POINTS = 10;
AttackMeterProcessor.UNIT_POINTS = 1;

local get_statistic_cache = function(race_name, force)
    if global.kill_count_statistics_cache[race_name] == nil then
        global.kill_count_statistics_cache[race_name] = force.kill_count_statistics
    end
    return global.kill_count_statistics_cache[race_name]
end

local calculatePoints = function(race_name, statistic,
                                 entity_names, level, interval)
    local points = 0
    for _, name in pairs(entity_names) do
        local count = statistic.get_flow_count {
            name = race_name .. '/' .. name .. '/' .. level,
            input = false,
            precision_index = interval
        }
        points = points + count
    end

    return points
end

local calculateNextThreshold = function(race_name)
    local threshold = ErmConfig.attack_meter_threshold() * ErmConfig.max_group_size() * ErmAttackGroupProcessor.MIXED_UNIT_POINTS
    local derivative = ErmConfig.attack_meter_deviation()
    ErmRaceSettingsHelper.set_next_attack_threshold(
            race_name,
            threshold + threshold * (math.random(derivative * -1, derivative) / 100)
    )
end

function AttackMeterProcessor.init_globals()
    global.kill_count_statistics_cache = global.kill_count_statistics_cache or {}
end

function AttackMeterProcessor.exec()
    if ErmConfig.attack_meter_enabled() == false then
        return
    end

    local force_names = ErmForceHelper.get_all_enemy_forces()

    for _, name in pairs(force_names) do
        AttackMeterProcessor.calculate_points(name)
    end
end

function AttackMeterProcessor.add_form_group_cron()
    if ErmConfig.attack_meter_enabled() == false then
        return
    end

    local force_names = ErmForceHelper.get_all_enemy_forces()

    for _, force_name in pairs(force_names) do
        local force = game.forces[force_name]
        local race_name = ErmForceHelper.extract_race_name_from(force_name)
        if ErmConfig.race_is_active(race_name) then
            ErmCron.add_10_sec_queue('AttackMeterProcessor.form_group', race_name, force)
        end
    end
end

function AttackMeterProcessor.calculate_points(force_name)
    local interval = defines.flow_precision_index.one_minute

    local force = game.forces[force_name]
    local race_name = ErmForceHelper.extract_race_name_from(force_name)
    if not ErmConfig.race_is_active(race_name) then
        return
    end

    local statistic_cache = get_statistic_cache(race_name, force)
    if statistic_cache == nil then
        return
    end

    local level = ErmRaceSettingsHelper.get_level(race_name)

    local units = ErmRaceSettingsHelper.get_current_unit_tier(race_name)
    local unit_points = calculatePoints(race_name, statistic_cache, units, level, interval)

    local buildings = ErmRaceSettingsHelper.get_current_building_tier(race_name)
    local building_points = calculatePoints(race_name, statistic_cache, buildings, level, interval)

    local turrets = ErmRaceSettingsHelper.get_current_turret_tier(race_name)
    local turret_points = calculatePoints(race_name, statistic_cache, turrets, level, interval)

    local attack_meter_points = unit_points * AttackMeterProcessor.UNIT_POINTS +
            building_points * AttackMeterProcessor.SPAWNER_POINTS +
            turret_points * AttackMeterProcessor.TURRET_POINTS

    ErmRaceSettingsHelper.add_killed_units_count(race_name, unit_points)
    ErmRaceSettingsHelper.add_killed_structure_count(race_name, building_points + turret_points)

    attack_meter_points = attack_meter_points * ErmConfig.attack_meter_collector_multiplier()

    if ErmConfig.time_base_attack_enabled() and level > 2 then
        local extra_points = ErmRaceSettingsHelper.get_next_attack_threshold(race_name) * (ErmConfig.time_base_attack_points() / 100)
        attack_meter_points = attack_meter_points + extra_points
    end

    ErmRaceSettingsHelper.add_to_attack_meter(race_name, math.floor(attack_meter_points))

    local spawner_destroy_factor = game.map_settings.enemy_evolution.destroy_factor
    local unit_evolution_points = unit_points * 0.02 * spawner_destroy_factor
    local turret_evolution_points = turret_points * 0.1 * spawner_destroy_factor
    local spawner_evolution_points = 0

    if ErmConfig.spawner_kills_deduct_evolution_points() then
        unit_evolution_points = unit_evolution_points * 1.03
        turret_evolution_points = turret_evolution_points * -0.2
        spawner_evolution_points = building_points * spawner_destroy_factor * -1.33
    end

    global.race_settings[race_name].evolution_base_point = global.race_settings[race_name].evolution_base_point + unit_evolution_points + turret_evolution_points + spawner_evolution_points

end

function AttackMeterProcessor.form_group(race_name, force)
    if not ErmConfig.race_is_active(race_name) then
        return
    end

    local next_attack_threshold = ErmRaceSettingsHelper.get_next_attack_threshold(race_name)
    if next_attack_threshold == 0 then
        calculateNextThreshold(race_name)
        return
    end

    local current_attack_value = ErmRaceSettingsHelper.get_attack_meter(race_name)
    -- Process attack point group
    if current_attack_value > next_attack_threshold then
        local group_created = false
        local elite_attack_point_threshold = ErmConfig.elite_squad_attack_points()
        local accumulated_attack_meter = ErmRaceSettingsHelper.get_accumulated_attack_meter(race_name)
        local last_accumulated_attack_meter = ErmRaceSettingsHelper.get_last_accumulated_attack_meter(race_name) or 0
        if ErmConfig.elite_squad_enable() and ErmRaceSettingsHelper.get_tier(race_name) == 3 and (accumulated_attack_meter - last_accumulated_attack_meter) > elite_attack_point_threshold then
            group_created = ErmAttackGroupProcessor.exec_elite_group(race_name, force, next_attack_threshold)
            if group_created then
                ErmRaceSettingsHelper.set_last_accumulated_attack_meter(race_name, accumulated_attack_meter)
            end
        else
            group_created = ErmAttackGroupProcessor.exec(race_name, force, next_attack_threshold)
        end

        if group_created then
            ErmRaceSettingsHelper.add_to_attack_meter(race_name, next_attack_threshold * -1)
            calculateNextThreshold(race_name)
        end
    end
end

return AttackMeterProcessor