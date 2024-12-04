---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 03/16/2020 1:56 PM
---

local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ERM_UnitHelper = require("__enemyracemanager__/lib/rig/unit_helper")
local ERM_DebugHelper = require("__enemyracemanager__/lib/debug_helper")
local enemy_autoplace = require ("prototypes.enemy-autoplace")

require("util")


require("__enemyracemanager__/global")

local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value


-- Handles acid and poison resistance
local base_acid_resistance = 0
local incremental_acid_resistance = 80
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 85
-- Handles fire and explosive resistance
local base_fire_resistance = -100
local incremental_fire_resistance = 0
-- Handles laser and electric resistance
local base_electric_resistance = -50
local incremental_electric_resistance = 100

function makeLevelTurrets(level, type, distance)
    local turret = util.table.deepcopy(data.raw["turret"][type])

    local original_hitpoint = turret["max_health"]

    turret["localised_name"] = { "entity-name." .. MOD_NAME .. "--" .. turret["name"], GlobalConfig.QUALITY_MAPPING[level] }
    turret["name"] = MOD_NAME .. "--" .. turret["name"] .. "--" .. level;
    turret["max_health"] = ERM_UnitHelper.get_building_health(original_hitpoint, max_hitpoint_multiplier, level, true)
    turret["resistances"] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "cold", percent = 95 }
    }
    turret["healing_per_tick"] = ERM_UnitHelper.get_building_healing(original_hitpoint, max_hitpoint_multiplier, level)

    turret["attack_parameters"]["damage_modifier"] = 0.33

    ERM_UnitHelper.modify_biter_damage(turret, level)

    turret["autoplace"] = enemy_autoplace.enemy_worm_autoplace( {
        probability_expression = "enemy_autoplace_base("..distance..", 90002)",
        force = FORCE_NAME,
    })
    turret["map_color"] = ERM_UnitHelper.format_map_color(settings.startup["enemyracemanager-cold_biter_map_color"].value)

    return turret
end

if settings.startup["cb-disable-worms"].value then
    return
end

local max_level = GlobalConfig.MAX_LEVELS

for i = 1, max_level do
    data:extend({ makeLevelTurrets(i, "small-cold-worm-turret", 0) })
    data:extend({ makeLevelTurrets(i, "medium-cold-worm-turret", 2) })
    data:extend({ makeLevelTurrets(i, "big-cold-worm-turret", 5) })
    data:extend({ makeLevelTurrets(i, "behemoth-cold-worm-turret", 8) })
    data:extend({ makeLevelTurrets(i, "leviathan-cold-worm-turret", 14) })

    if not settings.startup["cb-disable-mother"].value then
        data:extend({ makeLevelTurrets(i, "mother-cold-worm-turret", 14) })
    end
end
data.raw["turret"]["small-cold-worm-turret"].autoplace = nil
data.raw["turret"]["medium-cold-worm-turret"].autoplace = nil
data.raw["turret"]["big-cold-worm-turret"].autoplace = nil
data.raw["turret"]["behemoth-cold-worm-turret"].autoplace = nil
data.raw["turret"]["leviathan-cold-worm-turret"].autoplace = nil
data.raw["turret"]["mother-cold-worm-turret"].autoplace = nil