--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/15/2020
-- Time: 9:59 PM
-- To change this template use File | Settings | File Templates.
-- require("__enemyracemanager__/lib/rig/unit_helper")
--
local ERM_UnitHelper = {}


require('util')
local String = require('__erm_libs__/stdlib/string')
local GlobalConfig = require("__enemyracemanager__/lib/global_config")

-- Resistance cap, 95% diablo style lol.  But uranium bullets tear them like butter anyway.
local max_resistance_percentage = 95
-- Attack speed cap @ 15 ticks, 0.25s / hit
local max_attack_speed = 15

-- New tier in percentage
local multipliers = {15, 35, 65, 100}
local get_damage_multiplier = function(incremental_damage, level)
    return (multipliers[level-1] / 100) * incremental_damage * settings.startup["enemyracemanager-damage-multipliers"].value
end

local get_quality_multiplier = function(level)
    return (1 + GlobalConfig.BASE_QUALITY_MULITPLIER * level)
end

local get_health_mutiplier = function( incremental_health, level)
    return (multipliers[level-1] / 100) * incremental_health
end

-- Unit Health
function ERM_UnitHelper.get_health(base_health, incremental_health, level)
    if level == 1 then
        return base_health
    end
    local multiplier = get_health_mutiplier(incremental_health, level)
    local final_health = math.floor(base_health * multiplier)
    if feature_flags.quality and not DEBUG_BY_PASS_QUALITY then
        final_health = final_health * (multipliers[level-1] / 100) * get_quality_multiplier(level)
    end
    return final_health
end

-- Unit Health
function ERM_UnitHelper.get_building_health(base_health, incremental_health, level, reduce_effect)
    if level == 1 then
        return base_health
    end
    --- Spawner has evolution based health increase, turrets don't
    local reduce_effect_value = 1
    if reduce_effect then
        reduce_effect_value = 2
    end
    local multiplier = math.max(get_health_mutiplier(incremental_health, level) / reduce_effect_value, 2)
    local final_health = math.floor(base_health * multiplier)
    if feature_flags.quality and not DEBUG_BY_PASS_QUALITY then
        final_health = final_health * (multipliers[level-1] / 100) * get_quality_multiplier(level)
    end
    return final_health
end


-- Percentage Based Resistance
-- base_resistance + incremental_resistance is the maximum resistance, reach max by epic tier.
function ERM_UnitHelper.get_resistance(base_resistance, incremental_resistance , level, bypass_max_resist)
    if level == 1 then
        return base_resistance
    end
    local max_resist = bypass_max_resist or max_resistance_percentage
    return math.min(math.floor(base_resistance + (incremental_resistance * (level / (GlobalConfig.MAX_LEVELS - GlobalConfig.MAX_BY_EPIC)))), base_resistance + incremental_resistance, max_resistance_percentage)
end

-- Attack Damage
function ERM_UnitHelper.get_damage(base_dmg, incremental_damage, level)
    local damage = 0
    if level == 1 then
        damage = base_dmg
    else
        damage = base_dmg * get_damage_multiplier(incremental_damage, level)
    end

    if settings.startup["enemyracemanager-free-for-all"].value then
        damage = damage * GlobalConfig.FFA_MULTIPLIER
    end

    if feature_flags.quality and not DEBUG_BY_PASS_QUALITY then
        damage = damage * get_quality_multiplier(level)
    end

    return damage
end

-- Max speed 15 tick per attack, 4 attack  / second
function ERM_UnitHelper.get_attack_speed(base_speed, incremental_speed, level)
    if level == 1 then
        return base_speed
    end
    return math.max(base_speed - (incremental_speed * (level / (GlobalConfig.MAX_LEVELS - GlobalConfig.MAX_BY_EPIC))), max_attack_speed)
end

-- Movement Speed, reach max at rare tier
function ERM_UnitHelper.get_movement_speed(base_speed, incremental_speed, level)
    if level == 1 then
        return base_speed
    end
    return base_speed + (incremental_speed * (level / (GlobalConfig.MAX_LEVELS - GlobalConfig.MAX_BY_RARE)))
end

-- unit healing (full heal in 120s)
function ERM_UnitHelper.get_healing(base_health, max_hitpoint_multiplier, level)
    return 0
    --return ERM_UnitHelper.get_health(base_health, max_hitpoint_multiplier, level) / (2 * minute)
end

-- building healing (full heal in 300s)
function ERM_UnitHelper.get_building_healing(base_health, max_hitpoint_multiplier, level)
    return ERM_UnitHelper.get_health(base_health, max_hitpoint_multiplier, level) / (5 * minute)
end

function ERM_UnitHelper.modify_biter_damage(biter, level)
    if biter["attack_parameters"]["damage_modifier"] == nil then
        biter["attack_parameters"]["damage_modifier"] = 1
    end

    biter["attack_parameters"]["damage_modifier"] = ERM_UnitHelper.get_damage(biter["attack_parameters"]["damage_modifier"], biter["attack_parameters"]["damage_modifier"], level)

    if settings.startup["enemyracemanager-free-for-all"].value then
        biter["attack_parameters"]["damage_modifier"] = biter["attack_parameters"]["damage_modifier"] * (GlobalConfig.FFA_MULTIPLIER / 10)
    end
end

function ERM_UnitHelper.get_pollution_attack(value, level)
    local setting_value = settings.startup["enemyracemanager-pollution-to-attack-multipliers"].value
    if level == 1 or setting_value == 0 then
        return value
    end

    return value * (1 + level * setting_value)
end

function ERM_UnitHelper.get_vision_distance(attack_range)
    if (attack_range <= 24) then
        return 32
    end

    return attack_range + 8
end

--- Reach max attack range by rare tier.
function ERM_UnitHelper.get_attack_range(level, ratio)
    ratio = ratio or 1
    local attack_range = GlobalConfig.get_max_attack_range()
    if level < GlobalConfig.MAX_LEVELS - GlobalConfig.MAX_BY_RARE then
        attack_range = 14 + (attack_range - 14) * (level - 1) * 0.25
    end

    if feature_flags.quality then
        attack_range = attack_range + level
    end

    return math.ceil(attack_range * ratio)
end

function ERM_UnitHelper.format_map_color(color)
    color = util.table.deepcopy(color)
    return color
end

function ERM_UnitHelper.format_team_color(color, tint_strength)
    tint_strength = tint_strength or 4
    color = util.table.deepcopy(color)

    --- Blend Additive (Alpha 0), Alpha 25%, Alpha 50%, Alpha 66%, Alpha 75%, Alpha 90%
    local tint_alpha_options_as_dec = { 0, 0.25, 0.5, 0.66, 0.75, 0.9 }
    local tint_alpha_options_as_int = { 0, 64, 128, 170, 192, 230 }

    if color.b > 1 or color.g > 1 or color.r > 1 then
        color.a = tint_alpha_options_as_int[tint_strength]
    else
        color.a = tint_alpha_options_as_dec[tint_strength]
    end

    return color
end

function ERM_UnitHelper.is_erm_unit(dataItem)
    local nameToken = String.split(dataItem.name, "--")
    return (data.erm_registered_race and data.erm_registered_race[nameToken[1]]) or false
end

function ERM_UnitHelper.make_unit_melee_ammo_type(damage_value)
    return
    {
        target_type = "entity",
        action =
        {
            type = "direct",
            action_delivery =
            {
                type = "instant",
                target_effects =
                {
                    type = "damage",
                    damage = { amount = damage_value , type = "physical"}
                }
            }
        }
    }
end

return ERM_UnitHelper