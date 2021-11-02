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

-- Resistance cap, 95% diablo style lol.  But uranium bullets tear them like butter anyway.
local max_resistance_percentage = 95
-- Attack speed cap @ 15 ticks, 0.25s / hit
local max_attack_speed = 15

local get_damage_multiplier = function()
    return settings.startup['enemyracemanager-damage-multipliers'].value
end

-- Unit Health
function ERM_UnitHelper.get_health(base_health, incremental_health, multiplier, level)
    if level == 1 then
        return base_health
    end
    return Math.floor(base_health + (incremental_health * 1.25 * (level * multiplier / 100)))
end

-- Unit Health
function ERM_UnitHelper.get_building_health(base_health, incremental_health, multiplier, level)
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
        return base_dmg * get_damage_multiplier()
    end
    return (base_dmg + (incremental_dmg * (level * multiplier / 100))) * get_damage_multiplier()
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
    return base_speed + (incremental_speed * (level * multiplier / 100)) * settings.startup['enemyracemanager-running-speed-multipliers'].value
end

-- unit healing (full heal in 120s)
function ERM_UnitHelper.get_healing(base_health, max_hitpoint_multiplier, multiplier, level)
    return 0
    --return ERM_UnitHelper.get_health(base_health, base_health * max_hitpoint_multiplier, multiplier, level) / (2 * defines.time.minute)
end

-- building healing (full heal in 300s)
function ERM_UnitHelper.get_building_healing(base_health, max_hitpoint_multiplier, multiplier, level)
    return ERM_UnitHelper.get_health(base_health, base_health * max_hitpoint_multiplier, multiplier, level) / (5 * defines.time.minute)
end

function ERM_UnitHelper.modify_biter_damage(biter, biter_type, level)
    if biter['attack_parameters']['damage_modifier'] == nil then
        biter['attack_parameters']['damage_modifier'] = 1
    end

    if string.find(biter_type,'spitter') then
        biter['attack_parameters']['damage_modifier'] = 0.25 * biter['attack_parameters']['damage_modifier']
    end

    biter['attack_parameters']['damage_modifier'] = ERM_UnitHelper.get_damage(biter['attack_parameters']['damage_modifier'], biter['attack_parameters']['damage_modifier'], settings.startup["enemyracemanager-level-multipliers"].value, level)
end

function ERM_UnitHelper.modify_worm_damage(worm, level)
    worm['attack_parameters']['damage_modifier'] = 0.25 * ERM_UnitHelper.get_damage(worm['attack_parameters']['damage_modifier'], worm['attack_parameters']['damage_modifier'], settings.startup["enemyracemanager-level-multipliers"].value, level)
end

return ERM_UnitHelper