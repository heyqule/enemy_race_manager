---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/31/2020 1:56 PM
---

local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ERM_UnitHelper = require("__enemyracemanager__/lib/rig/unit_helper")

require("util")


require("__enemyracemanager__/global")

local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value / 2


-- Handles acid and poison resistance
local base_acid_resistance = 0
local incremental_acid_resistance = 80
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 95
-- Handles fire and explosive resistance
local base_fire_resistance = 0
local incremental_fire_resistance = 90
-- Handles laser and electric resistance
local base_electric_resistance = -50
local incremental_electric_resistance = 100
-- Handles cold resistance
local base_cold_resistance = -50
local incremental_cold_resistance = 100

function makeLevelEnemy(level, type, health_cut_ratio)
    health_cut_ratio = health_cut_ratio or 1
    local biter = util.table.deepcopy(data.raw["unit"][type])
    local original_hitpoint = biter["max_health"]

    biter["localised_name"] = { "entity-name." .. MOD_NAME .. "--" .. biter["name"], tostring(level) }
    biter["name"] = MOD_NAME .. "--" .. biter["name"] .. "--" .. level
    biter["max_health"] = ERM_UnitHelper.get_health(original_hitpoint / health_cut_ratio, max_hitpoint_multiplier, level)
    biter["resistances"] = {
        { type = "acid", percent = 95 },
        { type = "poison", percent = 95 },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, level) }
    }
    biter["healing_per_tick"] = 0

    if string.find(type, "spitter") then
        biter["attack_parameters"]["damage_modifier"] = 0.35 * biter["attack_parameters"]["damage_modifier"]
        local attack_range = ERM_UnitHelper.get_attack_range(level)
        local vision_distance = ERM_UnitHelper.get_vision_distance(attack_range)
        biter["attack_parameters"]["range"] = attack_range
        biter["attack_parameters"]["vision_distance"] = vision_distance
        biter["attack_parameters"]["min_attack_distance"] = attack_range - 4
    end

    ERM_UnitHelper.modify_biter_damage(biter, level)
    biter["movement_speed"] = ERM_UnitHelper.get_movement_speed(biter["movement_speed"], biter["movement_speed"], level)

    biter["absorptions_to_join_attack"] = {
        pollution= ERM_UnitHelper.get_pollution_attack(biter.absorptions_to_join_attack.pollution, level)
    }
    biter["map_color"] = ERM_UnitHelper.format_map_color(settings.startup["enemyracemanager-toxic_biter_map_color"].value)

    return biter
end

local max_level = GlobalConfig.MAX_LEVELS

for i = 1, max_level do
    -- (org: 15)
    data:extend({ makeLevelEnemy(i, "small-toxic-biter") })
    -- (org: 10)
    data:extend({ makeLevelEnemy(i, "small-toxic-spitter") })
    -- (org: 75)
    data:extend({ makeLevelEnemy(i, "medium-toxic-biter") })
    -- (org: 50)
    data:extend({ makeLevelEnemy(i, "medium-toxic-spitter") })
    -- (org: 375)
    data:extend({ makeLevelEnemy(i, "big-toxic-biter") })
    -- (org: 200)
    data:extend({ makeLevelEnemy(i, "big-toxic-spitter") })
    -- 1, 3000 - 10, 10500  - 20, 18000 (org: 3000)
    data:extend({ makeLevelEnemy(i, "behemoth-toxic-biter") })
    -- 1, 1500 - 10, 5250 - 20, 9000 (org: 1500)
    data:extend({ makeLevelEnemy(i, "behemoth-toxic-spitter") })
    -- 1, 20000 - 10, 70000 - 20, 120000 (org: 80000)
    data:extend({ makeLevelEnemy(i, "leviathan-toxic-biter", 5) })
    -- 1, 12500 - 10, 43750 - 20, 75000 (org: 50000)
    data:extend({ makeLevelEnemy(i, "leviathan-toxic-spitter", 5) })

    if not settings.startup["tb-disable-mother"].value then
        -- 1, 33333 - 10, 116666 - 20, 200000 (org: 100000)
        data:extend({ makeLevelEnemy(i, "mother-toxic-spitter", 3) })
    end
end