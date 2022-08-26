---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 10/29/2021 1:22 AM
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


local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value


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


local laser_modifier = 1
local incremental_laser_modifier = 3

-- Handles Attack Speed

local base_attack_speed = 2700
local incremental_attack_speed = 900

local attack_range = 3


local base_movement_speed = 0.15
local incremental_movement_speed = 0.125

-- Misc Settings
local vision_distance = 35
local pollution_to_join_attack = 200
local distraction_cooldown = 300

local collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
local selection_box = {{-0.5, -0.5}, {0.5, 0.5}}

local robot_animations = {}
robot_animations["logistic-robot"] =
{
    in_motion =
    {
        filename = "__base__/graphics/entity/logistic-robot/logistic-robot.png",
        priority = "high",
        line_length = 16,
        width = 41,
        height = 42,
        frame_count = 1,
        shift = util.by_pixel(0, -3),
        direction_count = 16,
        tint = {r=0.5,g=0,b=1,a=1},
        y = 126,
        hr_version =
        {
            filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot.png",
            priority = "high",
            line_length = 16,
            width = 80,
            height = 84,
            frame_count = 1,
            shift = util.by_pixel(0, -3),
            direction_count = 16,
            tint = {r=0.5,g=0,b=1,a=1},
            y = 252,
            scale = 0.5
        }
    },
    shadow_in_motion =
    {
        filename = "__base__/graphics/entity/logistic-robot/logistic-robot-shadow.png",
        priority = "high",
        line_length = 16,
        width = 58,
        height = 29,
        frame_count = 1,
        shift = util.by_pixel(32, 19.5),
        direction_count = 16,
        y = 29,
        draw_as_shadow = true,
        hr_version =
        {
            filename = "__base__/graphics/entity/logistic-robot/hr-logistic-robot-shadow.png",
            priority = "high",
            line_length = 16,
            width = 115,
            height = 57,
            frame_count = 1,
            shift = util.by_pixel(31.75, 19.75),
            direction_count = 16,
            y = 57*3,
            scale = 0.5,
            draw_as_shadow = true
        }
    }
}

function makeLogisticRobot(level)
    local type = "logistic-robot"
    local robot = util.table.deepcopy(data.raw[type][type])
    local original_health = robot['max_health'] * 3

    robot['type'] = 'unit'
    robot['localised_name'] = { 'entity-name.' .. MOD_NAME .. '/' .. robot['name'], level }
    robot['name'] = MOD_NAME .. '/' .. robot['name'] .. '/' .. level
    robot["subgroup"] = "erm-dropship-enemies"
    robot['has_belt_immunity'] = true
    robot['max_health'] = ERM_UnitHelper.get_health(original_health, original_health * max_hitpoint_multiplier,  level)
    robot['resistances'] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance,  level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance,  level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance,  level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance,  level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance,  level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance,  level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance,  level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance,  level) }
    }
    robot['healing_per_tick'] = 0
    robot['attack_parameters'] = {
        type = "projectile",
        range = attack_range,
        min_attack_distance = attack_range - 4,
        warmup = 10,
        cooldown = ERM_UnitHelper.get_attack_speed(base_attack_speed, incremental_attack_speed,  level),
        ammo_type = {
            category = "melee",
            target_type = "direction",
            action = {
                type = "direct",
                action_delivery = {
                    type = 'instant',
                    source_effects = {
                        {
                            type = "script",
                            effect_id = LOGISTIC_ATTACK,
                        }
                    }
                }
            }
        },
        animation = {
            layers = {
                robot_animations[type].in_motion,
                robot_animations[type].shadow_in_motion,
            }
        }
    }
    robot['run_animation'] = {
        layers = {
            robot_animations[type].in_motion,
            robot_animations[type].shadow_in_motion,
        }
    }
    robot['distance_per_frame'] = 0.17
    robot['movement_speed'] = ERM_UnitHelper.get_movement_speed(base_movement_speed, incremental_movement_speed,  level)
    robot['vision_distance'] = vision_distance
    robot['pollution_to_join_attack'] = pollution_to_join_attack
    robot['distraction_cooldown'] = distraction_cooldown
    robot['collision_mask'] = ERM_DataHelper.getFlyingCollisionMask()
    robot['collision_box'] = collision_box
    robot['selection_box'] = selection_box
    robot['flags'] = { "placeable-player", "placeable-enemy", "not-flammable" }

    return robot
end

local max_level = ErmConfig.MAX_LEVELS

for i = 1, max_level do
    data:extend({ makeLogisticRobot(i) })
end