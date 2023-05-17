---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/1/2021 1:27 PM
---
local noise = require("noise")
local String = require('__stdlib__/stdlib/utils/string')
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

require('__enemyracemanager__/global')
require('__enemyracemanager__/setting-constants')
local AutoplaceHelper = require('__enemyracemanager__/lib/helper/autoplace_helper')
local AutoplaceUtil = require('__enemyracemanager__/lib/enemy-autoplace-utils')

local SPLIT_POINT = settings.startup['enemyracemanager-2way-group-split-point'].value
-- Add 4 chunks gap between races
local SPLIT_GAP = 64

local FOUR_WAY_X_SPLIT_POINT = settings.startup['enemyracemanager-4way-x-axis'].value
local FOUR_WAY_Y_SPLIT_POINT = settings.startup['enemyracemanager-4way-y-axis'].value

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
    autoplace.probability_expression = noise.less_or_equal(SPLIT_POINT + SPLIT_GAP, noise.var("y")) * autoplace.probability_expression
    return autoplace
end

local y_axis_negative_probability_expression = function(autoplace)
    ErmDebugHelper.print('Using Y-')
    autoplace.probability_expression = noise.less_or_equal(noise.var("y"), SPLIT_POINT - SPLIT_GAP) * autoplace.probability_expression
    return autoplace
end

local x_axis_positive_probability_expression = function(autoplace)
    ErmDebugHelper.print('Using X+')
    autoplace.probability_expression = noise.less_or_equal(SPLIT_POINT + SPLIT_GAP, noise.var("x")) * autoplace.probability_expression
    return autoplace
end

local x_axis_negative_probability_expression = function(autoplace)
    ErmDebugHelper.print('Using X-')
    autoplace.probability_expression = noise.less_or_equal(noise.var("x"), SPLIT_POINT - SPLIT_GAP) * autoplace.probability_expression
    return autoplace
end

local process_x_axis_unit = function(v)
    local onPositive = String.find(v.name, ErmConfig.positive_axis_race(), 1, true)
    local onNegative = String.find(v.name, ErmConfig.negative_axis_race(), 1, true)

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
    local onPositive = String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-positive'].value, 1, true)
    local onNegative = String.find(v.name, settings.startup['enemyracemanager-2way-group-enemy-negative'].value, 1, true)

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
    for _, v in pairs(data.raw["unit-spawner"]) do
        -- spawners
        ErmDebugHelper.print('Processing:' .. v.name)
        process_y_axis_unit(v)
    end

    for _, v in pairs(data.raw["turret"]) do
        -- turret
        ErmDebugHelper.print('Processing:' .. v.name)
        process_y_axis_unit(v)
    end
end

local process_4_ways_unit = function(v)
    local topleft = String.find(v.name, settings.startup['enemyracemanager-4way-top-left'].value, 1, true)
    local topright = String.find(v.name, settings.startup['enemyracemanager-4way-top-right'].value, 1, true)
    local bottomright = String.find(v.name, settings.startup['enemyracemanager-4way-bottom-right'].value, 1, true)
    local bottomleft = String.find(v.name, settings.startup['enemyracemanager-4way-bottom-left'].value, 1, true)

    if topleft and v.autoplace then
        v.autoplace.probability_expression =
            noise.less_or_equal(noise.var("y"), FOUR_WAY_Y_SPLIT_POINT - SPLIT_GAP) *
            noise.less_or_equal(noise.var("x"), FOUR_WAY_X_SPLIT_POINT - SPLIT_GAP) *
            v.autoplace.probability_expression
    elseif topright and v.autoplace then
        v.autoplace.probability_expression =
            noise.less_or_equal(noise.var("y"), FOUR_WAY_Y_SPLIT_POINT - SPLIT_GAP) *
            noise.less_or_equal(FOUR_WAY_X_SPLIT_POINT + SPLIT_GAP, noise.var("x")) *
            v.autoplace.probability_expression
    elseif bottomright and v.autoplace then
        v.autoplace.probability_expression =
            noise.less_or_equal(FOUR_WAY_Y_SPLIT_POINT + SPLIT_GAP, noise.var("y")) *
            noise.less_or_equal(FOUR_WAY_X_SPLIT_POINT + SPLIT_GAP, noise.var("x")) *
            v.autoplace.probability_expression
    elseif bottomleft and v.autoplace then
        v.autoplace.probability_expression =
            noise.less_or_equal(FOUR_WAY_Y_SPLIT_POINT + SPLIT_GAP, noise.var("y")) *
            noise.less_or_equal(noise.var("x"), FOUR_WAY_X_SPLIT_POINT - SPLIT_GAP) *
            v.autoplace.probability_expression
    else
        v.autoplace = zero_probability_expression()
    end
end

local process_4_ways = function()
    for _, v in pairs(data.raw["unit-spawner"]) do
        -- spawners
        ErmDebugHelper.print('Processing:' .. v.name)
        process_4_ways_unit(v)
    end

    for _, v in pairs(data.raw["turret"]) do
        -- turret
        ErmDebugHelper.print('Processing:' .. v.name)
        process_4_ways_unit(v)
    end
end

local disable_vanilla_force = function(type)
    for name, entity in pairs(data.raw[type]) do
        if String.find(name, MOD_NAME) then
            entity['autoplace'] = zero_probability_expression()
        end
    end
end

local disable_level_spawners = function()
    disable_vanilla_force('unit-spawner')
    disable_vanilla_force('turret')
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


disable_normal_biters()
-- Remove Vanilla Bitter
if settings.startup['enemyracemanager-enable-bitters'].value == false then
    disable_level_spawners()
end

-- 2 Ways Race handler
if ErmConfig.mapgen_is_2_races_split() and settings.startup['enemyracemanager-2way-group-enemy-orientation'].value == X_AXIS then
    process_x_axis()
elseif ErmConfig.mapgen_is_2_races_split() and settings.startup['enemyracemanager-2way-group-enemy-orientation'].value == Y_AXIS then
    process_y_axis()
end

if ErmConfig.mapgen_is_4_races_split() then
    process_4_ways()
end

-- Set autoplace to zero for any high level spawner/turret which are higher than max_level setting
local max_level = ErmConfig.get_max_level()
if not max_level == ErmConfig.max_level then
    ErmDebugHelper.print('Disabling high level spawners autoplace:')
    for _, v in pairs(data.raw["unit-spawner"]) do
        if String.find( v.name, '/', 1, true) then
            local nameToken = String.split( v.name, '/')
            if tonumber(nameToken[3]) > max_level then
                ErmDebugHelper.print('Disabling:' .. v.name)
                data.raw['unit-spawner'][v.name]['autoplace'] = zero_probability_expression()
            end
        end
    end

    for _, v in pairs(data.raw["turret"]) do
        if String.find( v.name, '/', 1, true) then
            local nameToken = String.split( v.name, '/')
            if tonumber(nameToken[3]) > max_level then
                ErmDebugHelper.print('Disabling:' .. v.name)
                data.raw['turret'][v.name]['autoplace'] = zero_probability_expression()
            end
        end
    end
end


local distances = {
    medium = 2,
    big = 5,
    behemoth = 8,
    leviathan = 16,
    mother = 32
}

local tune_autoplace = function(v, is_turret, volume)
    if String.find( v.name, MOD_NAME, 1, true) and v.autoplace then
        if is_turret then
            local distance = 0
            for name, d in pairs(distances) do
                if String.find( v.name, name, 1, true) then
                    distance = d
                end
            end
            v.autoplace = AutoplaceUtil.enemy_worm_autoplace(distance, FORCE_NAME, volume)
        else
            v.autoplace = AutoplaceUtil.enemy_spawner_autoplace(0, FORCE_NAME, volume)
        end

    end
end


if ErmConfig.mapgen_is_mixed() then
    local volume = nil
    local erm_races = AutoplaceHelper.get_erm_races()
    local active_races = table_size(erm_races)
    if settings.startup['enemyracemanager-enable-bitters'].value and  active_races >= 2  then
        volume = {
            aux_min = 0,
            aux_max = 0.16,
        }
    elseif settings.startup['enemyracemanager-enable-bitters'].value and active_races == 1 then
        if erm_races['erm_toss'] or erm_races['erm_redarmy'] then
            volume = {
                water_min = 0,
                water_max = 0.51,
            }
        else
            volume = {
                water_min = 0.49,
                water_max = 1,
            }
        end
    end

    if volume then
        for _, v in pairs(data.raw["unit-spawner"]) do
            tune_autoplace(v, false, volume)
        end

        for _, v in pairs(data.raw["turret"]) do
            tune_autoplace(v, true, volume)
        end
    end
end
