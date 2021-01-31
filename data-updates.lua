local noise = require("noise")
local Table = require('__stdlib__/stdlib/utils/table')
local String = require('__stdlib__/stdlib/utils/string')
local enemy_autoplace = require ("__enemyracemanager__/lib/enemy-autoplace-utils")

local zero_probability_expression = function()
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
    autoplace.probability_expression = noise.less_or_equal(noise.var("y"), 0) * autoplace.probability_expression
    return autoplace
end

local y_axis_negative_probability_expression = function(autoplace)
    autoplace.probability_expression = noise.less_or_equal(0, noise.var("y")) * autoplace.probability_expression
    return autoplace
end

local x_axis_positive_probability_expression = function(autoplace)
    autoplace.probability_expression = noise.less_or_equal(noise.var("x"), 0) * autoplace.probability_expression
    return autoplace
end

local x_axis_negative_probability_expression = function(autoplace)
    autoplace.probability_expression = noise.less_or_equal(0, noise.var("x")) * autoplace.probability_expression
    return autoplace
end

local process_x_axis = function()
    for k,v in pairs(data.raw["unit-spawner"]) do -- spawners
        if String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-positive'].value) and v.autoplace and v.autoplace.probability_expression then
            v.autoplace = x_axis_positive_probability_expression(v.autoplace)
        elseif String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-negative'].value) and v.autoplace and v.autoplace.probability_expression then
            v.autoplace = x_axis_negative_probability_expression(v.autoplace)
        else
            v.autoplace = zero_probability_expression()
        end
    end

    for k,v in pairs(data.raw["turret"]) do -- turret
        if String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-positive'].value) and v.autoplace and v.autoplace.probability_expression then
            v.autoplace = x_axis_positive_probability_expression(v.autoplace)
        elseif String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-negative'].value) and v.autoplace and v.autoplace.probability_expression then
            v.autoplace = x_axis_negative_probability_expression(v.autoplace)
        else
            v.autoplace = zero_probability_expression()
        end
    end
end

local process_y_axis = function()
    for k,v in pairs(data.raw["unit-spawner"]) do -- spawners
        if String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-positive'].value) and v.autoplace and v.autoplace.probability_expression then
            v.autoplace = y_axis_positive_probability_expression(v.autoplace)
        elseif String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-negative'].value) and v.autoplace and v.autoplace.probability_expression then
            v.autoplace = y_axis_negative_probability_expression(v.autoplace)
        else
            v.autoplace = zero_probability_expression()
        end
    end

    for k,v in pairs(data.raw["turret"]) do -- turret
        if String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-positive'].value) and v.autoplace and v.autoplace.probability_expression then
            v.autoplace = y_axis_positive_probability_expression(v.autoplace)
        elseif String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-negative'].value) and v.autoplace and v.autoplace.probability_expression then
            v.autoplace = y_axis_negative_probability_expression(v.autoplace)
        else
            v.autoplace = zero_probability_expression()
        end
    end
end

local disable_normal_biters = function()
    data.raw['unit-spawner']['biter-spawner']['autoplace'] = zero_probability_expression()
    data.raw['unit-spawner']['spitter-spawner']['autoplace'] = zero_probability_expression()
    data.raw['turret']['behemoth-worm-turret']['autoplace'] = zero_probability_expression()
    data.raw['turret']['big-worm-turret']['autoplace'] = zero_probability_expression()
    data.raw['turret']['medium-worm-turret']['autoplace'] = zero_probability_expression()
    data.raw['turret']['small-worm-turret']['autoplace'] = zero_probability_expression()
end

-- Remove Vanilla Bitter
if settings.startup['enemyracemanager-enable-bitters'].value == false then
    disable_normal_biters()
end

if settings.startup['enemyracemanager-enable-2way-group-enemy'].value == true and settings.startup['enemyracemanager-2way-group-enemy-orientation'].value == 'x-axis' then
    disable_normal_biters()
    process_x_axis()
elseif settings.startup['enemyracemanager-enable-2way-group-enemy'].value == true and settings.startup['enemyracemanager-2way-group-enemy-orientation'].value == 'y-axis' then
    disable_normal_biters()
    process_y_axis()
end

Table.insert(data.raw['technology']['stronger-explosives-7']['effects'],
    {
        type = "ammo-damage",
        ammo_category = "artillery-shell",
        modifier = 0.2
    }
)