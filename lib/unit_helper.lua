--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/15/2020
-- Time: 9:59 PM
-- To change this template use File | Settings | File Templates.
-- require('__enemyracemanager__/lib/unit_helper')
--
local ERM_UnitHelper = {}
local Math = require('__stdlib__/stdlib/utils/math')
require('__stdlib__/stdlib/utils/defines/time')

-- Resistance cap, 95% diablo style lol.  But uranium bullets tear them like butter anyway.
local max_resistance_percentage = 95
-- Attack speed cap @ 15 ticks, 0.25s / hit
local max_attack_speed = 15

-- Unit Health
function ERM_UnitHelper.get_health(base_health, incremental_health, multiplier, level)
    if level == 1 then
        return base_health
    end
    return Math.floor(base_health + (incremental_health * (level * multiplier / 100)))
end

-- Percentage Based Resistance
-- base_resistance + incremental_resistance is the maximum resistance
function ERM_UnitHelper.get_resistance(base_resistance, incremental_resistance, multiplier, level)
    if level == 1 then
        return base_resistance
    end
    return Math.min(Math.floor(base_resistance + (incremental_resistance * (level * multiplier * 1.75 / 100))), base_resistance + incremental_resistance, max_resistance_percentage)
end

-- Attack Damage
function ERM_UnitHelper.get_damage(base_dmg, incremental_dmg, multiplier, level)
    if level == 1 then
        return base_dmg
    end
    return Math.floor(base_dmg + (incremental_dmg * (level * multiplier / 100)))
end

-- Max speed 15 tick per attack, 4 attack  / second
function ERM_UnitHelper.get_attack_speed(base_speed, incremental_speed, multiplier, level)
    if level == 1 then
        return base_speed
    end
    return Math.max(base_speed - (incremental_speed * (level * multiplier / 100)), max_attack_speed)
end

-- Movement Speed
function ERM_UnitHelper.get_movement_speed(base_speed, incremental_speed, multiplier, level)
    if level == 1 then
        return base_speed
    end
    return base_speed + (incremental_speed * (level * multiplier / 100))
end

-- unit healing (full heal in 120s)
function ERM_UnitHelper.get_healing(base_health, max_hitpoint_multiplier, multiplier, level)
    return ERM_UnitHelper.get_health(base_health, base_health * max_hitpoint_multiplier, multiplier, level) / (2 * defines.time.minute)
end

-- building healing (full heal in 300s)
function ERM_UnitHelper.get_building_healing(base_health, max_hitpoint_multiplier, multiplier, level)
    return ERM_UnitHelper.get_health(base_health, base_health * max_hitpoint_multiplier, multiplier, level) / (5 * defines.time.minute)
end

return ERM_UnitHelper