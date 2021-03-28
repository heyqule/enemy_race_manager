local noise = require("noise")
local Table = require('__stdlib__/stdlib/utils/table')
local String = require('__stdlib__/stdlib/utils/string')
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')
require('__enemyracemanager__/global')

require('prototypes/compatibility/data-updates.lua')

-- Start Enemy Base Autoplace functions --
local zero_probability_expression = function()
    ErmDebugHelper.print('Using 0')
    local probability = noise.var("enemy_base_probability")
    return
    {
        control = 'enemy-base',
        order = 'b[enemy]-misc',
        force = "enemy",
        probability_expression = noise.min(probability, 0),
        richness_expression = noise.to_noise_expression(1)
    }
end

local y_axis_positive_probability_expression = function(autoplace)
    ErmDebugHelper.print('Using Y+')
    autoplace.probability_expression = noise.less_or_equal(noise.var("y"), 0) * autoplace.probability_expression
    return autoplace
end

local y_axis_negative_probability_expression = function(autoplace)
    ErmDebugHelper.print('Using Y-')
    autoplace.probability_expression = noise.less_or_equal(0, noise.var("y")) * autoplace.probability_expression
    return autoplace
end

local x_axis_positive_probability_expression = function(autoplace)
    ErmDebugHelper.print('Using X+')
    autoplace.probability_expression = noise.less_or_equal(noise.var("x"), 0) * autoplace.probability_expression
    return autoplace
end

local x_axis_negative_probability_expression = function(autoplace)
    ErmDebugHelper.print('Using X-')
    autoplace.probability_expression = noise.less_or_equal(0, noise.var("x")) * autoplace.probability_expression
    return autoplace
end

local process_x_axis_unit = function(v)
    local onPositive = String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-positive'].value)
    local onNegative = String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-negative'].value)

    if onPositive and onNegative and v.autoplace then
        ErmDebugHelper.print('Do nothing')
    elseif onPositive and v.autoplace then
        v.autoplace = x_axis_positive_probability_expression(v.autoplace)
    elseif onNegative and v.autoplace then
        v.autoplace = x_axis_negative_probability_expression(v.autoplace)
    else
        v.autoplace = zero_probability_expression()
    end
end

local process_x_axis = function()
    for k, v in pairs(data.raw["unit-spawner"]) do
        -- spawners
        ErmDebugHelper.print('Processing:' .. v.name)
        process_x_axis_unit(v)
    end

    for k, v in pairs(data.raw["turret"]) do
        -- turret
        ErmDebugHelper.print('Processing:' .. v.name)
        process_x_axis_unit(v)
    end
end

local process_y_axis_unit = function(v)
    local onPositive = String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-positive'].value)
    local onNegative = String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-negative'].value)

    if onPositive and onNegative and v.autoplace then
        ErmDebugHelper.print('Do nothing')
    elseif onPositive and v.autoplace then
        v.autoplace = y_axis_positive_probability_expression(v.autoplace)
    elseif onNegative and v.autoplace then
        v.autoplace = y_axis_negative_probability_expression(v.autoplace)
    else
        v.autoplace = zero_probability_expression()
    end
end

local process_y_axis = function()
    for k, v in pairs(data.raw["unit-spawner"]) do
        -- spawners
        ErmDebugHelper.print('Processing:' .. v.name)
        process_y_axis_unit(v)
    end

    for k, v in pairs(data.raw["turret"]) do
        -- turret
        ErmDebugHelper.print('Processing:' .. v.name)
        process_y_axis_unit(v)
    end
end

local disable_level_spawner = function(type, name, level)
    data.raw[type][MOD_NAME .. '/' .. name .. '/' .. level]['autoplace'] = zero_probability_expression()
end

local disable_level_spawners = function()
    local level = ErmConfig.MAX_LEVELS

    for i = 1, level do
        disable_level_spawner('unit-spawner', 'biter-spawner', i)
        disable_level_spawner('unit-spawner', 'spitter-spawner', i)
        disable_level_spawner('turret', 'behemoth-worm-turret', i)
        disable_level_spawner('turret', 'big-worm-turret', i)
        disable_level_spawner('turret', 'medium-worm-turret', i)
        disable_level_spawner('turret', 'small-worm-turret', i)
    end
end

local disable_normal_biters = function()
    ErmDebugHelper.print('Disabling Vanilla Spawners...')
    data.raw['unit-spawner']['biter-spawner']['autoplace'] = zero_probability_expression()
    data.raw['unit-spawner']['spitter-spawner']['autoplace'] = zero_probability_expression()
    data.raw['turret']['behemoth-worm-turret']['autoplace'] = zero_probability_expression()
    data.raw['turret']['big-worm-turret']['autoplace'] = zero_probability_expression()
    data.raw['turret']['medium-worm-turret']['autoplace'] = zero_probability_expression()
    data.raw['turret']['small-worm-turret']['autoplace'] = zero_probability_expression()
end

-- END Enemy Base Autoplace functions --


-- Remove Vanilla Bitter
if settings.startup['enemyracemanager-enable-bitters'].value == false then
    disable_normal_biters()
    disable_level_spawners()
end

-- 2 Ways Race handler
if settings.startup['enemyracemanager-enable-2way-group-enemy'].value == true and settings.startup['enemyracemanager-2way-group-enemy-orientation'].value == 'x-axis' then
    disable_normal_biters()
    process_x_axis()
elseif settings.startup['enemyracemanager-enable-2way-group-enemy'].value == true and settings.startup['enemyracemanager-2way-group-enemy-orientation'].value == 'y-axis' then
    disable_normal_biters()
    process_y_axis()
end

-- Change resistance values on vanilla armors
local armor_change_resistance = function(percentage_value, fixed_value)
    return {
        { type = "acid", percent = percentage_value, decrease = fixed_value },
        { type = "poison", percent = percentage_value, decrease = fixed_value },
        { type = "physical", percent = percentage_value, decrease = fixed_value },
        { type = "fire", percent = percentage_value, decrease = fixed_value },
        { type = "explosion", percent = percentage_value, decrease = fixed_value * 3 },
        { type = "laser", percent = percentage_value, decrease = fixed_value },
        { type = "electric", percent = percentage_value, decrease = fixed_value },
        { type = "cold", percent = percentage_value, decrease = fixed_value }
    }
end

local vehicle_change_resistance = function(percentage_value, fixed_value)
    return {
        { type = "acid", percent = percentage_value, decrease = fixed_value },
        { type = "poison", percent = percentage_value, decrease = fixed_value },
        { type = "physical", percent = percentage_value, decrease = fixed_value },
        { type = "fire", percent = percentage_value, decrease = fixed_value },
        { type = "explosion", percent = percentage_value, decrease = fixed_value * 5 },
        { type = "laser", percent = percentage_value, decrease = fixed_value },
        { type = "electric", percent = percentage_value, decrease = fixed_value },
        { type = "cold", percent = percentage_value, decrease = fixed_value },
        { type = "impact", percent = 90, decrease = 50 },
    }
end

-- Enhance Vanilla Defenses
if settings.startup['enemyracemanager-enhance-defense'].value == true then

    -- Buff Armor
    data.raw['armor']['light-armor']['resistances'] = armor_change_resistance(25, 5)
    data.raw['armor']['heavy-armor']['resistances'] = armor_change_resistance(30, 10)
    data.raw['armor']['modular-armor']['resistances'] = armor_change_resistance(40, 15)
    data.raw['armor']['power-armor']['resistances'] = armor_change_resistance(55, 20)
    data.raw['armor']['power-armor-mk2']['resistances'] = armor_change_resistance(75, 20)

    -- Buff gun turret HP
    data.raw['ammo-turret']['gun-turret']['max_health'] = 800

    -- Buff vehicles
    data.raw['car']['car']['max_health'] = 750
    data.raw['car']['car']['resistances'] = vehicle_change_resistance(50, 0)
    data.raw['car']['tank']['resistances'] = vehicle_change_resistance(75, 20)
    data.raw['spider-vehicle']['spidertron']['resistances'] = vehicle_change_resistance(75, 5)

    -- Buff vehicle machine-gun
    data.raw['gun']['vehicle-machine-gun']['attack_parameters']['damage_modifier'] = 1.5
    data.raw['gun']['tank-machine-gun']['attack_parameters']['damage_modifier'] = 2
    data.raw['gun']['tank-flamethrower']['attack_parameters']['damage_modifier'] = 2
    data.raw['gun']['tank-cannon']['attack_parameters']['damage_modifier'] = 2

    -- Buff train
    data.raw['locomotive']['locomotive']['resistances'] = vehicle_change_resistance(75, 15)
    data.raw['cargo-wagon']['cargo-wagon']['resistances'] = vehicle_change_resistance(75, 15)
    data.raw['fluid-wagon']['fluid-wagon']['resistances'] = vehicle_change_resistance(75, 15)
    data.raw['artillery-wagon']['artillery-wagon']['resistances'] = vehicle_change_resistance(75, 15)

    -- Buff Wall
    data.raw['wall']['stone-wall']['max_health'] = 500
    data.raw['wall']['stone-wall']['resistances'] = {
        { type = "acid", percent = 30, decrease = 0 },
        { type = "poison", percent = 100, decrease = 0 },
        { type = "physical", percent = 30, decrease = 0 },
        { type = "fire", percent = 100, decrease = 0 },
        { type = "explosion", percent = 60, decrease = 10 },
        { type = "impact", percent = 60, decrease = 45 },
        { type = "laser", percent = 30, decrease = 0 },
        { type = "electric", percent = 30, decrease = 0 },
        { type = "cold", percent = 100, decrease = 0 }
    }

    -- Buff Robots
    data.raw['construction-robot']['construction-robot']['max_health'] = 200
    data.raw['construction-robot']['construction-robot']['resistances'] = armor_change_resistance(75, 0)
    data.raw['logistic-robot']['logistic-robot']['max_health'] = 200
    data.raw['logistic-robot']['logistic-robot']['resistances'] = armor_change_resistance(75, 0)
end


-- Mandatory vanilla game changes --
-- Add artillery-shell damage bonus to stronger explosive
Table.insert(data.raw['technology']['stronger-explosives-7']['effects'],
        {
            type = "ammo-damage",
            ammo_category = "artillery-shell",
            modifier = 0.2
        }
)

-- Change rocket/cannon area explosives to hit all units
local ignore_collision_for_area_damage = function(target_effects)
    for i, effect in pairs(target_effects) do
        log(effect['type'])
        if effect['type'] == "nested-result" and effect['action']['type'] == 'area' then
            effect['action']['ignore_collision_condition'] = true
        end
    end
end
--data.raw['projectile']['explosive-cannon-projectile']['final_action']['action_delivery']['target_effects'][2]['action']['ignore_collision_condition'] = true
--data.raw['projectile']['explosive-uranium-cannon-projectile']['final_action']['action_delivery']['target_effects'][2]['action']['ignore_collision_condition'] = true
ignore_collision_for_area_damage(data.raw['projectile']['explosive-rocket']['action']['action_delivery']['target_effects'])


