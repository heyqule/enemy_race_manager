--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/15/2020
-- Time: 9:59 PM
-- To change this template use File | Settings | File Templates.
-- require('__enemyracemanager__/lib/rig/unit_helper')
--
local ERM_UnitHelper = {}
local Math = require('__stdlib__/stdlib/utils/math')
require('__stdlib__/stdlib/utils/defines/time')
local ErmConfig = require('__enemyracemanager__/lib/global_config')

-- Resistance cap, 95% diablo style lol.  But uranium bullets tear them like butter anyway.
local max_resistance_percentage = 95
-- Attack speed cap @ 15 ticks, 0.25s / hit
local max_attack_speed = 15

local get_damage_multiplier = function()
    return settings.startup['enemyracemanager-damage-multipliers'].value
end

local get_strength_multiplier = function()
    return settings.startup['enemyracemanager-level-multipliers'].value
end

local get_strength_percentage = function(level, multiplier, proper)
    if proper then
        return Math.min(100, level * multiplier) / 100
    end
    return level * multiplier / 100
end

-- Unit Health
function ERM_UnitHelper.get_health(base_health, incremental_health, level)
    if level == 1 then
        return base_health
    end
    local internal_multiplier = math.log(level) / 2.3965 * get_strength_percentage(level, get_strength_multiplier())

    local extra_health = 0
    if level <= 5 then
        extra_health = level * 10 * level * 0.8
    elseif level <= 10 then
        extra_health = level * 40 - level * 40 * (level * 3 / 100)
    elseif level <= 15 then
        extra_health = level * 35 - level * 35 * (level * 4 / 100)
    elseif level < 20 then
        extra_health = level * 50 - level * 50 * (level * 5 / 100)
    end

    return Math.floor(base_health + (incremental_health * internal_multiplier) + extra_health)
end

-- Unit Health
function ERM_UnitHelper.get_building_health(base_health, incremental_health, level)
    if level == 1 then
        return base_health
    end
    return Math.floor(base_health + (incremental_health * get_strength_percentage(level, get_strength_multiplier())))
end


-- Percentage Based Resistance
-- base_resistance + incremental_resistance is the maximum resistance
function ERM_UnitHelper.get_resistance(base_resistance, incremental_resistance, level)
    if level == 1 then
        return base_resistance
    end
    return Math.min(Math.floor(base_resistance + (incremental_resistance * (level * get_strength_multiplier() * 1.75 / 100))), base_resistance + incremental_resistance, max_resistance_percentage)
end

-- Attack Damage
function ERM_UnitHelper.get_damage(base_dmg, incremental_dmg, level)
    local damage = 0
    if level == 1 then
        damage = base_dmg
    else
        damage = (base_dmg + (incremental_dmg * get_strength_percentage(level, get_strength_multiplier())) * get_damage_multiplier())
    end
    
    if settings.startup['enemyracemanager-free-for-all'].value then
        damage = damage * ErmConfig.FFA_MULTIPLIER
    end
    return damage
end

-- Max speed 15 tick per attack, 4 attack  / second
function ERM_UnitHelper.get_attack_speed(base_speed, incremental_speed, level)
    if level == 1 then
        return base_speed
    end
    return Math.max(base_speed - (incremental_speed * get_strength_percentage(level, get_strength_multiplier(), true)), max_attack_speed)
end

-- Movement Speed
function ERM_UnitHelper.get_movement_speed(base_speed, incremental_speed, level)
    if level == 1 then
        return base_speed
    end
    return base_speed + (incremental_speed *  get_strength_percentage(level, get_strength_multiplier(), true)) * settings.startup['enemyracemanager-running-speed-multipliers'].value
end

-- unit healing (full heal in 120s)
function ERM_UnitHelper.get_healing(base_health, max_hitpoint_multiplier, level)
    return 0
    --return ERM_UnitHelper.get_health(base_health, base_health * max_hitpoint_multiplier, level) / (2 * defines.time.minute)
end

-- building healing (full heal in 300s)
function ERM_UnitHelper.get_building_healing(base_health, max_hitpoint_multiplier, level)
    return ERM_UnitHelper.get_health(base_health, base_health * max_hitpoint_multiplier, level) / (5 * defines.time.minute)
end

function ERM_UnitHelper.modify_biter_damage(biter, level)
    if biter['attack_parameters']['damage_modifier'] == nil then
        biter['attack_parameters']['damage_modifier'] = 1
    end

    biter['attack_parameters']['damage_modifier'] = ERM_UnitHelper.get_damage(biter['attack_parameters']['damage_modifier'], biter['attack_parameters']['damage_modifier'], level)

    if settings.startup['enemyracemanager-free-for-all'].value then
        biter['attack_parameters']['damage_modifier'] = biter['attack_parameters']['damage_modifier'] * (ErmConfig.FFA_MULTIPLIER / 7.5)
    end
end

function ERM_UnitHelper.get_pollution_attack(value, level)
    local setting_value = settings.startup['enemyracemanager-pollution-to-attack-multipliers'].value
    if level == 1 or setting_value == 0 then
        return value
    end

    return value * (1 + level * setting_value)
end

return ERM_UnitHelper