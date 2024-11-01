---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/17/2021 1:51 PM
---



local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")
local DebugHelper = require("__enemyracemanager__/lib/debug_helper")

local AttackGroupProcessor = require("__enemyracemanager__/lib/attack_group_processor")

local Cron = require("__enemyracemanager__/lib/cron_processor")

local AttackMeterProcessor = {}

AttackMeterProcessor.SEGMENT_UNIT_POINTS = 1000;
AttackMeterProcessor.SPIDER_UNIT_POINTS = 10;
AttackMeterProcessor.SPAWNER_POINTS = 50;
AttackMeterProcessor.TURRET_POINTS = 10;
AttackMeterProcessor.UNIT_POINTS = 1;

local unit_point_map = {
    ['unit'] = AttackMeterProcessor.UNIT_POINTS,
    ['unit-spawner'] = AttackMeterProcessor.SPAWNER_POINTS,
    ['turret'] = AttackMeterProcessor.TURRET_POINTS,
    ['spider-unit'] = AttackMeterProcessor.SPIDER_UNIT_POINTS,
    ['segment-unit'] = AttackMeterProcessor.SEGMENT_UNIT_POINTS
}

local unit_map = {
    ['unit'] = true,
    ['spider-unit'] = true,
    ['segment-unit'] = true,
}
local structure_map = {
    ['unit-spawner'] = true,
    ['turret'] = true,
}

local custom_units_points = {

}

local calculateNextThreshold = function(race_name)
    local threshold = GlobalConfig.attack_meter_threshold() * GlobalConfig.max_group_size() * AttackGroupProcessor.MIXED_UNIT_POINTS
    local derivative = GlobalConfig.attack_meter_deviation()
    RaceSettingsHelper.set_next_attack_threshold(
            race_name,
            threshold + threshold * (math.random(derivative * -1, derivative) / 100)
    )
end

function AttackMeterProcessor.add_form_group_cron()
    if GlobalConfig.attack_meter_enabled() == false then
        return
    end

    local force_names = ForceHelper.get_enemy_forces()

    for _, force_name in pairs(force_names) do
        local force = game.forces[force_name]
        local race_name = ForceHelper.extract_race_name_from(force_name)
        if GlobalConfig.race_is_active(race_name) then
            Cron.add_10_sec_queue("AttackMeterProcessor.form_group", race_name, force)
        end
    end
end

function AttackMeterProcessor.calculate_points(entity)
    local force = entity.force
    local entity_type = entity.type
    local entity_name = entity.name
    local force = entity.force
    local surface = entity.surface
    local race_name = ForceHelper.extract_race_name_from(force.name)
    local attack_meter_points = unit_point_map[entity_type]
    if not GlobalConfig.race_is_active(race_name) or not attack_meter_points then
        return
    end

    if custom_units_points[entity_name] then
        local custom_points = tonumber(custom_units_points[entity_name])
        if custom_points > 0 then
            attack_meter_points = custom_points
        end
    end

    if unit_map[entity_type] then
        RaceSettingsHelper.add_killed_units_count(race_name, 1)
    end

    if structure_map[entity_type] then
        RaceSettingsHelper.add_killed_structure_count(race_name, 1)
    end

    attack_meter_points = attack_meter_points * GlobalConfig.attack_meter_collector_multiplier()

    if GlobalConfig.spawner_kills_deduct_evolution_points() then
        if unit_map[entity_type] then
            attack_meter_points = attack_meter_points * 2
        else
            local deduction_attack_meter_points = attack_meter_points * -6
            RaceSettingsHelper.add_to_attack_meter(race_name, deduction_attack_meter_points)
            RaceSettingsHelper.add_accumulated_attack_meter(race_name, deduction_attack_meter_points)
        end
    end

    RaceSettingsHelper.add_to_attack_meter(race_name, math.floor(attack_meter_points))
end

-- Calculate every minutes
function AttackMeterProcessor.calculated_time_attack()
    for _, force in pairs(game.forces) do
        if ForceHelper.is_enemy_force(force) then
            local race_name = ForceHelper.extract_race_name_from(force.name)
            for _, planet in pairs(game.planets) do
                if GlobalConfig.time_base_attack_enabled() and planet.surface and force.get_evolution_factor(planet.surface) > 0.5 then
                    local extra_points = RaceSettingsHelper.get_next_attack_threshold(race_name) * (GlobalConfig.time_base_attack_points() / 100)
                    RaceSettingsHelper.add_to_attack_meter(race_name, math.floor(extra_points))
                    break
                end
            end
        end
    end
end

function AttackMeterProcessor.form_group(race_name, force)
    if not GlobalConfig.race_is_active(race_name) then
        return
    end

    local next_attack_threshold = RaceSettingsHelper.get_next_attack_threshold(race_name)
    if next_attack_threshold == 0 then
        calculateNextThreshold(race_name)
        return
    end

    local current_attack_value = RaceSettingsHelper.get_attack_meter(race_name)
    -- Process attack point group
    if current_attack_value > next_attack_threshold then
        local elite_attack_point_threshold = GlobalConfig.elite_squad_attack_points()
        local accumulated_attack_meter = RaceSettingsHelper.get_accumulated_attack_meter(race_name)
        local last_accumulated_attack_meter = RaceSettingsHelper.get_last_accumulated_attack_meter(race_name) or 0
        if GlobalConfig.elite_squad_enable() and RaceSettingsHelper.get_tier(race_name) == 3 and (accumulated_attack_meter - last_accumulated_attack_meter) > elite_attack_point_threshold then
            AttackGroupProcessor.exec_elite_group(race_name, force, next_attack_threshold)
        else
            AttackGroupProcessor.exec(race_name, force, next_attack_threshold)
        end
    end
end

function AttackMeterProcessor.adjust_attack_meter(race_name)
    RaceSettingsHelper.add_to_attack_meter(race_name, RaceSettingsHelper.get_next_attack_threshold(race_name) * -1)
    calculateNextThreshold(race_name)
end

function AttackMeterProcessor.adjust_last_accumulated_attack_meter(race_name)
    RaceSettingsHelper.set_last_accumulated_attack_meter(race_name, RaceSettingsHelper.get_last_accumulated_attack_meter(race_name))
end

function AttackMeterProcessor.transfer_attack_points(race_name, friend_race_name)
    RaceSettingsHelper.add_to_attack_meter(race_name, RaceSettingsHelper.get_next_attack_threshold(friend_race_name))
    RaceSettingsHelper.add_to_attack_meter(race_name, RaceSettingsHelper.get_next_attack_threshold(race_name) * -1)
    calculateNextThreshold(race_name)
end

return AttackMeterProcessor