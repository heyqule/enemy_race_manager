---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/1/2021 1:23 PM
---
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
-- Change resistance values on vanilla armors
local armor_change_resistance = function(percentage_value, fixed_value)
    return {
        { type = "acid", percent = percentage_value, decrease = fixed_value },
        { type = "poison", percent = percentage_value, decrease = fixed_value },
        { type = "physical", percent = percentage_value, decrease = fixed_value },
        { type = "fire", percent = percentage_value, decrease = fixed_value },
        { type = "explosion", percent = percentage_value, decrease = fixed_value },
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
        { type = "explosion", percent = percentage_value, decrease = fixed_value },
        { type = "laser", percent = percentage_value, decrease = fixed_value },
        { type = "electric", percent = percentage_value, decrease = fixed_value },
        { type = "cold", percent = percentage_value, decrease = fixed_value },
        { type = "impact", percent = 90, decrease = 50 },
    }
end

local rails_change_resistance = function()
    return {
        { type = "acid", percent = 90 },
        { type = "poison", percent = 100 },
        { type = "physical", percent = 75 },
        { type = "fire", percent = 100 },
        { type = "explosion", percent = 75 },
        { type = "laser", percent = 75 },
        { type = "cold", percent = 90 },
        { type = "electric", percent = 90 }
    }
end

data.raw["ammo-turret"]["gun-turret"]["max_health"] = 800
data.raw["electric-turret"]["laser-turret"]["max_health"] = 1200
data.raw["construction-robot"]["construction-robot"]["max_health"] = 250
data.raw["logistic-robot"]["logistic-robot"]["max_health"] = 250

-- Enhance Vanilla Defenses
if settings.startup["enemyracemanager-enhance-defense"].value == true then
    -- Buff Armor
    data.raw["armor"]["light-armor"]["resistances"] = armor_change_resistance(25, 5)
    data.raw["armor"]["heavy-armor"]["resistances"] = armor_change_resistance(35, 10)
    data.raw["armor"]["modular-armor"]["resistances"] = armor_change_resistance(45, 15)
    data.raw["armor"]["power-armor"]["resistances"] = armor_change_resistance(60, 20)
    data.raw["armor"]["power-armor-mk2"]["resistances"] = armor_change_resistance(75, 20)

    if feature_flags.space_travel then
        data.raw["armor"]["mech-armor"]["resistances"] = armor_change_resistance(75, 20)
    end

    -- Buff vehicles
    data.raw["car"]["car"]["max_health"] = data.raw["car"]["car"]["max_health"] * 5
    data.raw["car"]["car"]["resistances"] = vehicle_change_resistance(50, 5)
    data.raw["car"]["tank"]["max_health"] = data.raw["car"]["tank"]["max_health"] * 4
    data.raw["car"]["tank"]["resistances"] = vehicle_change_resistance(66, 8)
    data.raw["spider-vehicle"]["spidertron"]["max_health"] = data.raw["spider-vehicle"]["spidertron"]["max_health"] * 3
    data.raw["spider-vehicle"]["spidertron"]["resistances"] = vehicle_change_resistance(66, 8)


    -- Buff vehicle gun
    data.raw["gun"]["vehicle-machine-gun"]["attack_parameters"]["damage_modifier"] = 2
    data.raw["gun"]["tank-machine-gun"]["attack_parameters"]["damage_modifier"] = 3
    --data.raw["gun"]["tank-flamethrower"]["attack_parameters"]["damage_modifier"] = 2
    --data.raw["gun"]["tank-cannon"]["attack_parameters"]["damage_modifier"] = 2
    --data.raw["gun"]["spidertron-rocket-launcher-1"]["attack_parameters"]["damage_modifier"] = 2
    --data.raw["gun"]["spidertron-rocket-launcher-2"]["attack_parameters"]["damage_modifier"] = 2
    --data.raw["gun"]["spidertron-rocket-launcher-3"]["attack_parameters"]["damage_modifier"] = 2
    --data.raw["gun"]["spidertron-rocket-launcher-4"]["attack_parameters"]["damage_modifier"] = 2

    -- Buff train
    data.raw["locomotive"]["locomotive"]["resistances"] = vehicle_change_resistance(75, 15)
    data.raw["cargo-wagon"]["cargo-wagon"]["resistances"] = vehicle_change_resistance(75, 15)
    data.raw["fluid-wagon"]["fluid-wagon"]["resistances"] = vehicle_change_resistance(75, 15)
    data.raw["artillery-wagon"]["artillery-wagon"]["resistances"] = vehicle_change_resistance(75, 15)

    --- Add additional rails
    local rail_type = {
        "straight-rail",
        "half-diagonal-rail",
        "curved-rail-a",
        "curved-rail-b",
        "elevated-straight-rail",
        "elevated-half-diagonal-rail",
        "elevated-curved-rail-a",
        "elevated-curved-rail-b",
        "rail-support",
        "rail-ramp",
        "rail-signal",
        "rail-chain-signal"
    }
    for _, rail_type in pairs(rail_type) do
        if data.raw[rail_type][rail_type] then
            data.raw[rail_type][rail_type]["resistances"] = rails_change_resistance()
        end
    end

    -- Buff Walls & Gates
    local walls = data.raw["wall"]
    for _, entity in pairs(walls) do
        entity["max_health"] = entity["max_health"] * 2
        entity["resistances"] = {
            { type = "acid", percent = 40, decrease = 0 },
            { type = "poison", percent = 100, decrease = 0 },
            { type = "physical", percent = 40, decrease = 0 },
            { type = "fire", percent = 100, decrease = 0 },
            { type = "explosion", percent = 40, decrease = 10 },
            { type = "impact", percent = 40, decrease = 45 },
            { type = "laser", percent = 40, decrease = 0 },
            { type = "electric", percent = 40, decrease = 0 },
            { type = "cold", percent = 40, decrease = 0 }
        }
    end

    local gates = data.raw["gate"]
    for _, entity in pairs(gates) do
        entity["max_health"] = entity["max_health"] * 2
        entity["resistances"] = {
            { type = "acid", percent = 40, decrease = 0 },
            { type = "poison", percent = 100, decrease = 0 },
            { type = "physical", percent = 40, decrease = 0 },
            { type = "fire", percent = 100, decrease = 0 },
            { type = "explosion", percent = 40, decrease = 10 },
            { type = "impact", percent = 40, decrease = 45 },
            { type = "laser", percent = 40, decrease = 0 },
            { type = "electric", percent = 40, decrease = 0 },
            { type = "cold", percent = 40, decrease = 0 }
        }
    end
end

-- Buff Robots, immune fire, bump all other resist to 75
-- Construction bots are no longer repairable to preserve construction bot queue. They repair themselves in roboport
for name, entity in pairs(data.raw["construction-robot"]) do
    data.raw["construction-robot"][name]["max_health"] = entity.max_health * 2
    table.insert(data.raw["construction-robot"][name]["flags"], "not-repairable")
end

data.raw["construction-robot"]["construction-robot"]["resistances"] = armor_change_resistance(75, 0)
data.raw["construction-robot"]["construction-robot"]["resistances"][4]["percent"] = 100
data.raw["logistic-robot"]["logistic-robot"]["resistances"] = armor_change_resistance(75, 0)
data.raw["logistic-robot"]["logistic-robot"]["resistances"][4]["percent"] = 100

if feature_flags.space_travel then
    data.raw["ammo-turret"]["rocket-turret"]["max_health"] = 800
end