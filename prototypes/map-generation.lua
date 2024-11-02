---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/1/2021 1:27 PM
---
local String = require('__erm_libs__/stdlib/string')
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local DebugHelper = require("__enemyracemanager__/lib/debug_helper")

require("__enemyracemanager__/global")
require("__enemyracemanager__/setting-constants")

-- Start Enemy Base Autoplace functions --
local zero_probability_expression = function(probability)
    DebugHelper.print("Using zero_probability_expression")
    return
    {
        control = "enemy-base",
        order = "b[enemy]-misc",
        force = "enemy",
        probability_expression = "0",
        richness_expression = "1"
    }
end

local nil_expression = function()
    DebugHelper.print("Using nil_expression")
    return nil
end

local disable_vanilla_force = function(type)
    for name, entity in pairs(data.raw[type]) do
        if string.find(name, MOD_NAME) then
            entity["autoplace"] = nil_expression()
        end
    end
end

local disable_level_spawners = function()
    disable_vanilla_force("unit-spawner")
    disable_vanilla_force("turret")
end

local disable_normal_biters = function()
    DebugHelper.print("Disabling Vanilla Spawners...")
    data.raw["unit-spawner"]["biter-spawner"]["autoplace"] = zero_probability_expression(0)
    data.raw["unit-spawner"]["spitter-spawner"]["autoplace"] = zero_probability_expression(0)
    data.raw["turret"]["behemoth-worm-turret"]["autoplace"] = zero_probability_expression(0)
    data.raw["turret"]["big-worm-turret"]["autoplace"] = zero_probability_expression(0)
    data.raw["turret"]["medium-worm-turret"]["autoplace"] = zero_probability_expression(0)
    data.raw["turret"]["small-worm-turret"]["autoplace"] = zero_probability_expression(0)
end

-- END Enemy Base Autoplace functions --
disable_normal_biters()


--- Disable all leveled spawners / turret autoplace which are higher than level 1.
--- Let map processor handle the level.
--- Free up the number of autoplace entities.  Large number of autoplace entities lags the game when exploring new chunks
DebugHelper.print("Disabling high level spawners autoplace and hide in factoriopedia:")


for _, v in pairs(data.raw["unit-spawner"]) do
    if string.find(v.name, "--", 1, true) then
        local nameToken = String.split(v.name, "--")
        local level = tonumber(nameToken[3])
        if level and level > 1 then
            DebugHelper.print("Disabling:" .. v.name)
            data.raw["unit-spawner"][v.name]["autoplace"] = nil_expression()
        end
    end
end

for _, v in pairs(data.raw["turret"]) do
    if string.find(v.name, "--", 1, true) then
        local nameToken = String.split(v.name, "--")
        table.insert(v.flags, "get-by-unit-number")
        local level = tonumber(nameToken  [3])
        if level and level > 1 then
            DebugHelper.print("Disabling:" .. v.name)
            data.raw["turret"][v.name]["autoplace"] = nil_expression()
        end
    end
end

for _, v in pairs(data.raw["unit"]) do
    if string.find(v.name, "--", 1, true) then
        local nameToken = String.split(v.name, "--")
        table.insert(v.flags, "get-by-unit-number")
        local level = tonumber(nameToken[3])
        if level and level > 1 then
            DebugHelper.print("Hiding:" .. v.name)
            data.raw["unit"][v.name]["hidden_in_factoriopedia"] = true
        end
    end
end


--- Handle 2 way and 4 way split.  To be refactor

--local SPLIT_POINT = settings.startup["enemyracemanager-2way-group-split-point"].value
---- Add 4 chunks gap between races
--local SPLIT_GAP = 64
--
--local FOUR_WAY_X_SPLIT_POINT = settings.startup["enemyracemanager-4way-x-axis"].value
--local FOUR_WAY_Y_SPLIT_POINT = settings.startup["enemyracemanager-4way-y-axis"].value
--
--
--local y_axis_positive_probability_expression = function(autoplace)
--    DebugHelper.print("Using Y+")
--    autoplace.probability_expression = noise.less_or_equal(SPLIT_POINT + SPLIT_GAP, noise.var("y")) * autoplace.probability_expression
--    return autoplace
--end
--
--local y_axis_negative_probability_expression = function(autoplace)
--    DebugHelper.print("Using Y-")
--    autoplace.probability_expression = noise.less_or_equal(noise.var("y"), SPLIT_POINT - SPLIT_GAP) * autoplace.probability_expression
--    return autoplace
--end
--
--local x_axis_positive_probability_expression = function(autoplace)
--    DebugHelper.print("Using X+")
--    autoplace.probability_expression = noise.less_or_equal(SPLIT_POINT + SPLIT_GAP, noise.var("x")) * autoplace.probability_expression
--    return autoplace
--end
--
--local x_axis_negative_probability_expression = function(autoplace)
--    DebugHelper.print("Using X-")
--    autoplace.probability_expression = noise.less_or_equal(noise.var("x"), SPLIT_POINT - SPLIT_GAP) * autoplace.probability_expression
--    return autoplace
--end
--
--local process_x_axis_unit = function(v)
--    local nameToken = String.split(v.name, "--")
--    local onPositive = nameToken[1] == GlobalConfig.positive_axis_race()
--    local onNegative = nameToken[1] == GlobalConfig.negative_axis_race()
--
--    if onPositive and onNegative and v.autoplace then
--        DebugHelper.print("Do nothing")
--    elseif onPositive and v.autoplace then
--        v.autoplace = x_axis_positive_probability_expression(v.autoplace)
--    elseif onNegative and v.autoplace then
--        v.autoplace = x_axis_negative_probability_expression(v.autoplace)
--    else
--        v.autoplace = nil_expression()
--    end
--end
--
--local process_x_axis = function()
--    for k, v in pairs(data.raw["unit-spawner"]) do
--        -- spawners
--        DebugHelper.print("Processing:" .. v.name)
--        process_x_axis_unit(v)
--    end
--
--    for k, v in pairs(data.raw["turret"]) do
--        -- turret
--        DebugHelper.print("Processing:" .. v.name)
--        process_x_axis_unit(v)
--    end
--end
--
--local process_y_axis_unit = function(v)
--    local nameToken = String.split(v.name, "--")
--    local onPositive = nameToken[1] == GlobalConfig.positive_axis_race()
--    local onNegative = nameToken[1] == GlobalConfig.negative_axis_race()
--
--    if onPositive and onNegative and v.autoplace then
--        DebugHelper.print("Do nothing")
--    elseif onPositive and v.autoplace then
--        v.autoplace = y_axis_positive_probability_expression(v.autoplace)
--    elseif onNegative and v.autoplace then
--        v.autoplace = y_axis_negative_probability_expression(v.autoplace)
--    else
--        v.autoplace = nil_expression()
--    end
--end
--
--local process_y_axis = function()
--    for _, v in pairs(data.raw["unit-spawner"]) do
--        -- spawners
--        DebugHelper.print("Processing:" .. v.name)
--        process_y_axis_unit(v)
--    end
--
--    for _, v in pairs(data.raw["turret"]) do
--        -- turret
--        DebugHelper.print("Processing:" .. v.name)
--        process_y_axis_unit(v)
--    end
--end
--
--local process_4_ways_unit = function(v)
--    local nameToken = String.split(v.name, "--")
--    local topleft = nameToken[1] == settings.startup["enemyracemanager-4way-top-left"].value
--    local topright = nameToken[1] == settings.startup["enemyracemanager-4way-top-right"].value
--    local bottomright = nameToken[1] == settings.startup["enemyracemanager-4way-bottom-right"].value
--    local bottomleft = nameToken[1] == settings.startup["enemyracemanager-4way-bottom-left"].value
--
--    if topleft and v.autoplace then
--        DebugHelper.print("topleft:" .. tostring(topleft))
--        v.autoplace.probability_expression = noise.less_or_equal(noise.var("y"), FOUR_WAY_Y_SPLIT_POINT - SPLIT_GAP) *
--                noise.less_or_equal(noise.var("x"), FOUR_WAY_X_SPLIT_POINT - SPLIT_GAP) *
--                v.autoplace.probability_expression
--    elseif topright and v.autoplace then
--        DebugHelper.print("topright:" .. tostring(topright))
--        v.autoplace.probability_expression = noise.less_or_equal(noise.var("y"), FOUR_WAY_Y_SPLIT_POINT - SPLIT_GAP) *
--                noise.less_or_equal(FOUR_WAY_X_SPLIT_POINT + SPLIT_GAP, noise.var("x")) *
--                v.autoplace.probability_expression
--    elseif bottomright and v.autoplace then
--        DebugHelper.print("bottomright:" .. tostring(bottomright))
--        v.autoplace.probability_expression = noise.less_or_equal(FOUR_WAY_Y_SPLIT_POINT + SPLIT_GAP, noise.var("y")) *
--                noise.less_or_equal(FOUR_WAY_X_SPLIT_POINT + SPLIT_GAP, noise.var("x")) *
--                v.autoplace.probability_expression
--    elseif bottomleft and v.autoplace then
--        DebugHelper.print("bottomleft:" .. tostring(bottomleft))
--        v.autoplace.probability_expression = noise.less_or_equal(FOUR_WAY_Y_SPLIT_POINT + SPLIT_GAP, noise.var("y")) *
--                noise.less_or_equal(noise.var("x"), FOUR_WAY_X_SPLIT_POINT - SPLIT_GAP) *
--                v.autoplace.probability_expression
--    else
--        v.autoplace = nil_expression()
--    end
--end
--
--local process_4_ways = function()
--    for _, v in pairs(data.raw["unit-spawner"]) do
--        -- spawners
--        DebugHelper.print("Processing:" .. v.name)
--        process_4_ways_unit(v)
--    end
--
--    for _, v in pairs(data.raw["turret"]) do
--        -- turret
--        DebugHelper.print("Processing:" .. v.name)
--        process_4_ways_unit(v)
--    end
--end
--
--
---- 2 Ways Race handler
--if GlobalConfig.mapgen_is_2_races_split() and settings.startup["enemyracemanager-2way-group-enemy-orientation"].value == X_AXIS then
--    process_x_axis()
--elseif GlobalConfig.mapgen_is_2_races_split() and settings.startup["enemyracemanager-2way-group-enemy-orientation"].value == Y_AXIS then
--    process_y_axis()
--end
--
--if GlobalConfig.mapgen_is_4_races_split() then
--    process_4_ways()
--end