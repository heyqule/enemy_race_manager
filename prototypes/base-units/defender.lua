---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 10/29/2021 12:46 AM
---
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ERM_UnitHelper = require('__enemyracemanager__/lib/rig/unit_helper')
local ERM_DebugHelper = require('__enemyracemanager__/lib/debug_helper')
local ERM_DataHelper = require('__enemyracemanager__/lib/rig/data_helper')

local Table = require('__stdlib__/stdlib/utils/table')
local String = require('__stdlib__/stdlib/utils/string')
require('util')


require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local health_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value * 1.5

local resistance_mutiplier = settings.startup["enemyracemanager-level-multipliers"].value
-- Handles acid and poison resistance
local base_acid_resistance = 10
local incremental_acid_resistance = 75
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 95
-- Handles fire and explosive resistance
local base_fire_resistance = 10
local incremental_fire_resistance = 80
-- Handles laser and electric resistance
local base_electric_resistance = 0
local incremental_electric_resistance = 90
-- Handles cold resistance
local base_cold_resistance = 10
local incremental_cold_resistance = 75

local damage_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local physical_modifier = 3
local incremental_physical_modifier = 3

-- Handles Attack Speed
local attack_speed_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local base_attack_speed = 60
local incremental_attack_speed = 45

local attack_range = 12

local movement_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local base_movement_speed = 0.2
local incremental_movement_speed = 0.15

-- Misc Settings
local vision_distance = 32
local pollution_to_join_attack = 50
local distraction_cooldown = 20

local collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
local selection_box = {{-0.5, -0.5}, {0.5, 0.5}}

local unit_scale = 1

local robot_animations = {}

robot_animations.defender =
{
    in_motion =
    {
        layers =
        {
            {
                filename = "__base__/graphics/entity/defender-robot/defender-robot.png",
                priority = "high",
                line_length = 16,
                width = 32,
                height = 33,
                frame_count = 1,
                animation_speed = 1,
                direction_count = 16,
                shift = util.by_pixel(0, 0.25),
                y = 33,
                hr_version =
                {
                    filename = "__base__/graphics/entity/defender-robot/hr-defender-robot.png",
                    priority = "high",
                    line_length = 16,
                    width = 56,
                    height = 59,
                    frame_count = 1,
                    animation_speed = 1,
                    direction_count = 16,
                    shift = util.by_pixel(0, 0.25),
                    y = 59,
                    scale = 0.5
                }
            },
            {
                filename = "__base__/graphics/entity/defender-robot/defender-robot-mask.png",
                priority = "high",
                line_length = 16,
                width = 18,
                height = 16,
                frame_count = 1,
                animation_speed = 1,
                direction_count = 16,
                shift = util.by_pixel(0, -4.75),
                tint = {r=0.5,g=0,b=1,a=1},
                y = 16,
                hr_version =
                {
                    filename = "__base__/graphics/entity/defender-robot/hr-defender-robot-mask.png",
                    priority = "high",
                    line_length = 16,
                    width = 28,
                    height = 21,
                    frame_count = 1,
                    animation_speed = 1,
                    direction_count = 16,
                    shift = util.by_pixel(0, -4.75),
                    tint = {r=0.5,g=0,b=1,a=1},
                    y = 21,
                    scale = 0.5
                }
            }
        }
    },
    shadow_in_motion =
    {
        filename = "__base__/graphics/entity/defender-robot/defender-robot-shadow.png",
        priority = "high",
        line_length = 16,
        width = 45,
        height = 26,
        frame_count = 1,
        animation_speed = 1,
        direction_count = 16,
        shift = util.by_pixel(25.5, 19),
        draw_as_shadow = true,
        hr_version =
        {
            filename = "__base__/graphics/entity/defender-robot/hr-defender-robot-shadow.png",
            priority = "high",
            line_length = 16,
            width = 88,
            height = 50,
            frame_count = 1,
            animation_speed = 1,
            direction_count = 16,
            shift = util.by_pixel(25.5, 19),
            scale = 0.5,
            draw_as_shadow = true
        }
    }
}

function makeLevelCombatRobots(level, type, health_cut_ratio)
    health_cut_ratio = health_cut_ratio or 1
    local robot = util.table.deepcopy(data.raw["combat-robot"][type])
    local original_health = robot['max_health'] * 3

    robot['type'] = 'unit'
    robot['localised_name'] = { 'entity-name.' .. MOD_NAME .. '/' .. robot['name'], level }
    robot['name'] = MOD_NAME .. '/' .. robot['name'] .. '/' .. level
    robot["subgroup"] = "erm-flying-enemies"
    robot['has_belt_immunity'] = true
    robot['max_health'] = ERM_UnitHelper.get_health(original_health, original_health * max_hitpoint_multiplier / health_cut_ratio, health_multiplier, level)
    robot['resistances'] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, resistance_mutiplier, level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, resistance_mutiplier, level) }
    }
    robot['healing_per_tick'] = 0
    robot['run_animation'] = {
        layers = {
            robot_animations[type].in_motion,
            robot_animations[type].shadow_in_motion,
        }
    }
    robot['attack_parameters']['cooldown'] = ERM_UnitHelper.get_attack_speed(base_attack_speed, incremental_attack_speed, attack_speed_multiplier, level)
    robot['attack_parameters']['damage_modifier'] = ERM_UnitHelper.get_damage(physical_modifier, incremental_physical_modifier, damage_multiplier, level)
    robot['attack_parameters']['range'] = attack_range
    robot['attack_parameters']['min_attack_distance'] = attack_range - 4
    robot['attack_parameters']['animation'] = robot['run_animation']
    robot['attack_parameters']['ammo_type']['category'] = 'erm-biter-damage'
    robot['distance_per_frame'] = 0.17
    robot['movement_speed'] = ERM_UnitHelper.get_movement_speed(base_movement_speed, incremental_movement_speed, movement_multiplier, level)
    robot['vision_distance'] = vision_distance
    robot['pollution_to_join_attack'] = pollution_to_join_attack
    robot['distraction_cooldown'] = distraction_cooldown
    robot['collision_mask'] = ERM_DataHelper.getFlyingCollisionMask()
    robot['collision_box'] = collision_box
    robot['selection_box'] = selection_box
    robot['flags'] = { "placeable-player", "placeable-enemy", "not-flammable" }

    return robot
end

local level = ErmConfig.MAX_LEVELS

for i = 1, level do
    data:extend({ makeLevelCombatRobots(i, 'defender') })
end
