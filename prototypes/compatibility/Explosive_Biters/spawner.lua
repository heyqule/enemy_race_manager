---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 03/16/2020 1:56 PM
---

local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ERM_UnitHelper = require("__enemyracemanager__/lib/rig/unit_helper")

require("util")
local enemy_autoplace = require ("prototypes.enemy-autoplace")

require("__enemyracemanager__/global")

local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value


-- Handles acid and poison resistance
local base_acid_resistance = 0
local incremental_acid_resistance = 50
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 55
-- Handles laser and electric resistance
local base_electric_resistance = -50
local incremental_electric_resistance = 100
-- Handles Cold resistance
local base_cold_resistance = -100
local incremental_cold_resistance = 0

function makeLevelSpawners(level, type)
    local spawner = util.table.deepcopy(data.raw["unit-spawner"][type])

    local original_hitpoint = spawner["max_health"]

    spawner["localised_name"] = { "entity-name." .. MOD_NAME .. "--" .. spawner["name"], GlobalConfig.QUALITY_MAPPING[level] }
    spawner["name"] = MOD_NAME .. "--" .. spawner["name"] .. "--" .. level;
    spawner["max_health"] = ERM_UnitHelper.get_building_health(original_hitpoint, max_hitpoint_multiplier, level)
    spawner["resistances"] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, level) },
        { type = "fire", percent = 95 },
        { type = "explosion", percent = 95 },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, level) }
    }
    spawner["healing_per_tick"] = ERM_UnitHelper.get_building_healing(original_hitpoint, max_hitpoint_multiplier, level)
    spawner["spawning_cooldown"] = { 600, 300 }

    local result_units = (function()
        local res = {}
        res[1] = { MOD_NAME .. "--small-explosive-biter--" .. level, { { 0.0, 0.3 }, { 0.6, 0.0 } } }
        res[3] = { MOD_NAME .. "--small-explosive-spitter--" .. level, { { 0.25, 0.0 }, { 0.5, 0.3 }, { 0.7, 0.0 } } }
        res[2] = { MOD_NAME .. "--medium-explosive-biter--" .. level, { { 0.2, 0.0 }, { 0.6, 0.3 }, { 0.7, 0.0 } } }
        res[4] = { MOD_NAME .. "--medium-explosive-spitter--" .. level, { { 0.4, 0.0 }, { 0.7, 0.3 }, { 0.9, 0.0 } } }
        res[5] = { MOD_NAME .. "--big-explosive-biter--" .. level, { { 0.5, 0.0 }, { 1.0, 0.4 } } }
        res[6] = { MOD_NAME .. "--big-explosive-spitter--" .. level, { { 0.5, 0.0 }, { 1.0, 0.4 } } }
        res[7] = { MOD_NAME .. "--behemoth-explosive-biter--" .. level, { { 0.85, 0.0 }, { 1.0, 0.3 } } }
        res[8] = { MOD_NAME .. "--behemoth-explosive-spitter--" .. level, { { 0.85, 0.0 }, { 1.0, 0.3 } } }
        res[9] = { "explosive-leviathan-biter", { { 0.9, 0.0 }, { 1.0, 0.03 } } }
        res[10] = { "leviathan-explosive-spitter", { { 0.9, 0.0 }, { 1.0, 0.03 } } }
        if not settings.startup["eb-disable-mother"].value then
            res[11] = { "mother-explosive-spitter", { { 0.925, 0.0 }, { 1.0, 0.02 } } }
        end
        return res
    end)()

    spawner["result_units"] = result_units
    spawner["autoplace"] = enemy_autoplace.enemy_spawner_autoplace({
        probability_expression = "enemy_autoplace_base(0, 90005)",
        force = FORCE_NAME,
        control = AUTOCONTROL_NAME
    })
    spawner["map_color"] = ERM_UnitHelper.format_map_color(settings.startup["enemyracemanager-explosive_biter_map_color"].value)
    return spawner
end

local max_level = GlobalConfig.MAX_LEVELS

for i = 1, max_level do
    data:extend({ makeLevelSpawners(i, "explosive-biter-spawner") })
end
data.raw["unit-spawner"]["explosive-biter-spawner"].autoplace = nil

if  settings.startup["eb-disable-temperature-check"].value == false then
    -- This set of data is used for set up default autoplace calculation.
    data.erm_spawn_specs = data.erm_spawn_specs or {}
    table.insert(data.erm_spawn_specs, {
        mod_name = MOD_NAME,
        force_name = FORCE_NAME,
        moisture = 1, -- 1 = Dry and 2 = Wet
        aux = 1, -- 1 = red desert, 2 = sand
        elevation = 2, --1,2,3 (1 low elevation, 2. medium, 3 high elavation)
        temperature = 3, --1,2,3 (1 cold, 2. normal, 3 hot)
        entity_filter = "explosive",
    })
end