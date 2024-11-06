---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 10/29/2021 1:22 AM
---
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ERM_UnitHelper = require("__enemyracemanager__/lib/rig/unit_helper")
local ERM_DebugHelper = require("__enemyracemanager__/lib/debug_helper")
local ERM_DataHelper = require("__enemyracemanager__/lib/rig/data_helper")

require("util")


require("__enemyracemanager__/global")

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

local electric_modifier = 5
local incremental_electric_modifier = 10

-- Handles Attack Speed

local base_attack_speed = 90
local incremental_attack_speed = 30

local attack_range = 12

local base_movement_speed = 0.2
local incremental_movement_speed = 0.15

-- Misc Settings
local vision_distance = ERM_UnitHelper.get_vision_distance(attack_range)
local pollution_to_join_attack = 300
local distraction_cooldown = 300

local collision_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }
local selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }

local robot_animations = {}

robot_animations.destroyer = {
    in_motion = {
        layers = {
            {
                filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot.png",
                priority = "high",
                line_length = 32,
                width = 88,
                height = 77,
                frame_count = 1,
                direction_count = 32,
                shift = util.by_pixel(2.5, -1.25),
                scale = 0.5
            },
            {
                filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-mask.png",
                priority = "high",
                line_length = 32,
                width = 52,
                height = 42,
                frame_count = 1,
                direction_count = 32,
                shift = util.by_pixel(2.5, -7),
                tint = { r = 0.5, g = 0, b = 1, a = 0.5 },
                scale = 0.5
            }
        }
    },
    shadow_in_motion = {
        filename = "__base__/graphics/entity/destroyer-robot/destroyer-robot-shadow.png",
        priority = "high",
        line_length = 32,
        width = 108,
        height = 66,
        frame_count = 1,
        direction_count = 32,
        shift = util.by_pixel(23.5, 19),
        scale = 0.5,
        draw_as_shadow = true
    }
}

function makeLevelCombatRobots(level, type, health_cut_ratio)
    health_cut_ratio = health_cut_ratio or 1
    local robot = util.table.deepcopy(data.raw["combat-robot"][type])
    local original_health = robot["max_health"] * 3

    robot["type"] = "unit"
    robot["localised_name"] = { "entity-name." .. MOD_NAME .. "--" .. robot["name"], GlobalConfig.QUALITY_MAPPING[level] }
    robot["name"] = MOD_NAME .. "--" .. robot["name"] .. "--" .. level
    robot["max_health"] = ERM_UnitHelper.get_health(original_health, max_hitpoint_multiplier / health_cut_ratio, level)
    robot["subgroup"] = "erm-flying-enemies"
    robot["has_belt_immunity"] = true
    robot["resistances"] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, level) }
    }
    robot["healing_per_tick"] = 0
    robot["run_animation"] = {
        layers = {
            robot_animations[type].in_motion,
            robot_animations[type].shadow_in_motion,
        }
    }
    robot["attack_parameters"]["cooldown"] = ERM_UnitHelper.get_attack_speed(base_attack_speed, incremental_attack_speed, level)
    robot["attack_parameters"]["damage_modifier"] = ERM_UnitHelper.get_damage(electric_modifier, incremental_electric_modifier, level)
    robot["attack_parameters"]["range"] = attack_range
    robot["attack_parameters"]["min_attack_distance"] = attack_range - 4
    robot["attack_parameters"]["animation"] = robot["run_animation"]
    robot["attack_parameters"]["ammo_category"] = "erm-biter-damage"
    robot["distance_per_frame"] = 0.17
    robot["movement_speed"] = ERM_UnitHelper.get_movement_speed(base_movement_speed, incremental_movement_speed, level)
    robot["vision_distance"] = vision_distance
    robot["absorptions_to_join_attack"] = {
        pollution= ERM_UnitHelper.get_pollution_attack(pollution_to_join_attack, level)
    }
    robot["distraction_cooldown"] = distraction_cooldown
    robot["collision_mask"] = ERM_DataHelper.getFlyingCollisionMask()
    robot["collision_box"] = collision_box
    robot["selection_box"] = selection_box
    robot["flags"] = { "placeable-player", "placeable-enemy", "not-flammable" }
    robot["map_color"] = ERM_UnitHelper.format_map_color(settings.startup["erm_vanilla-map-color"].value)
    return robot
end

local max_level = GlobalConfig.MAX_LEVELS

for i = 1, max_level do
    data:extend({ makeLevelCombatRobots(i, "destroyer") })
end