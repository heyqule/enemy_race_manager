--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/15/2020
-- Time: 9:59 PM
-- To change this template use File | Settings | File Templates.
--
local ERM_UnitHelper = {}
local Math = require('__stdlib__/stdlib/utils/Math')
require('__stdlib__/stdlib/utils/defines/time')

-- Resistance cap, 95% diablo style lol.
local max_resistance_percentage = 95
-- Attack speed cap @ 15 ticks, 0.25s / hit
local max_attack_speed = 15

-- Unit Health
function ERM_UnitHelper.get_health(base_health, incremental_health, multiplier, level)
    if level == 1 then
        return base_health
    end
    return base_health + ( incremental_health * (level * multiplier / 100))
end

-- Percentage Based Resistance
-- base_resistance + incremental_resistance is the maximum resistance
function ERM_UnitHelper.get_resistance(base_resistance, incremental_resistance, multiplier, level)
    if level == 1 then
        return base_resistance
    end
    return Math.min(base_resistance + ( incremental_resistance * (level * multiplier * 2 / 100)), base_resistance + incremental_resistance, max_resistance_percentage)
end

-- Attack Damage
function ERM_UnitHelper.get_damage(base_dmg, incremental_dmg, multiplier, level)
    if level == 1 then
        return base_dmg
    end
    return base_dmg + ( incremental_dmg * (level  * multiplier / 100))
end

-- Max speed 15 tick per attack, 4 attack  / second
function ERM_UnitHelper.get_attack_speed(base_speed, incremental_speed, multiplier, level)
    if level == 1 then
        return base_speed
    end
    return Math.max(base_speed - ( incremental_speed * (level * multiplier / 100)), max_attack_speed)
end

-- Movement Speed
function ERM_UnitHelper.get_movement_speed(base_speed, incremental_speed, multiplier, level)
    if level == 1 then
        return base_speed
    end
    return base_speed + ( incremental_speed * (level  * multiplier / 100))
end

-- healing
function ERM_UnitHelper.get_healing(base_heatlh, max_hitpoint_mutiplier, multiplier, level)
    if level == 1 then
        return base_heatlh / defines.time.minute
    end
    local heal_amount = Math.max(base_heatlh + (base_heatlh * max_hitpoint_mutiplier / 10) * (multiplier * level / 100), 600)
    return heal_amount / defines.time.minute
end


return ERM_UnitHelper