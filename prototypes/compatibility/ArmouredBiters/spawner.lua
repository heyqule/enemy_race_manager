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
local base_acid_resistance = 25
local incremental_acid_resistance = 55
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 80
-- Handles fire and explosive resistance
local base_fire_resistance = 10
local incremental_fire_resistance = 70
-- Handles laser and electric resistance
local base_electric_resistance = 0
local incremental_electric_resistance = 80
-- Handles cold resistance
local base_cold_resistance = 25
local incremental_cold_resistance = 55

local setting_utils = require("__ArmouredBiters__/setting-utils")
local s_r = setting_utils.getPositivePercentageOf("ab-small-armoured-biter-spawn-probability")
local m_r = setting_utils.getPositivePercentageOf("ab-medium-armoured-biter-spawn-probability")
local b_r = setting_utils.getPositivePercentageOf("ab-big-armoured-biter-spawn-probability")
local bb_r = setting_utils.getPositivePercentageOf("ab-behemoth-armoured-biter-spawn-probability")
local l_r = setting_utils.getPositivePercentageOf("ab-leviathan-armoured-biter-spawn-probability")

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
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, level) }
    }
    spawner["healing_per_tick"] = ERM_UnitHelper.get_building_healing(original_hitpoint, max_hitpoint_multiplier, level)
    spawner["spawning_cooldown"] = { 600, 300 }

    local result_units = {
        { MOD_NAME .. "--small-armoured-biter--" .. level, { { 0.0, 0.3 * s_r }, { 0.6, 0.0 } } },
        { MOD_NAME .. "--medium-armoured-biter--" .. level, { { 0.2, 0.0 }, { 0.6, 0.3 * m_r }, { 0.8, 0 } } },
        { MOD_NAME .. "--big-armoured-biter--" .. level, { { 0.5, 0.0 }, { 1.0, 0.55 * b_r } } },
        { MOD_NAME .. "--behemoth-armoured-biter--" .. level, { { 0.85, 0.0 }, { 1.0, 0.35 * bb_r } } }
    }
    if l_r > 0 then
        table.insert(result_units, { MOD_NAME .. "--leviathan-armoured-biter--" .. level, { { 0.825, 0.0 }, { 1.0, 0.05 * l_r } } })
    end

    spawner["result_units"] = result_units
    spawner["autoplace"] = enemy_autoplace.enemy_spawner_autoplace({
        probability_expression = "enemy_autoplace_base(0, 90003)",
        force = FORCE_NAME,
    })
    spawner["map_color"] = ERM_UnitHelper.format_map_color(settings.startup["enemyracemanager-armoured_biter_map_color"].value)

    return spawner
end

local max_level = GlobalConfig.MAX_LEVELS

for i = 1, max_level do
    if settings.startup["ab-enable-nest"].value then
        data:extend({ makeLevelSpawners(i, "armoured-biter-spawner") })
    else
        local biterSpawner = data.raw["unit-spawner"][MOD_NAME .. "--biter-spawner--" .. i]
        if biterSpawner then
            local unitSet = biterSpawner["result_units"]
            unitSet[#unitSet + 1] = { MOD_NAME .. "--small-armoured-biter--" .. i, { { 0.0, 0.3 * s_r }, { 0.6, 0.0 } } }
            unitSet[#unitSet + 1] = { MOD_NAME .. "--medium-armoured-biter--" .. i, { { 0.2, 0.0 }, { 0.6, 0.3 * m_r }, { 0.7, 0.0 } } }
            unitSet[#unitSet + 1] = { MOD_NAME .. "--big-armoured-biter--" .. i, { { 0.5, 0.0 }, { 1.0, 0.55 * b_r } } }
            unitSet[#unitSet + 1] = { MOD_NAME .. "--behemoth-armoured-biter--" .. i, { { 0.75, 0.0 }, { 1.0, 0.35 * bb_r } } }

            if l_r > 0 then
                unitSet[#unitSet + 1] = { MOD_NAME .. "--leviathan-armoured-biter--" .. i, { { 0.8, 0.0 }, { 1.0, 0.05 * l_r } } }
            end
        end
    end
end

--if  settings.startup["ab-enable-moisture-check"].value == true then
--    -- This set of data is used for set up default autoplace calculation.
--    data.erm_spawn_specs = data.erm_spawn_specs or {}
--    table.insert(data.erm_spawn_specs, {
--        mod_name = MOD_NAME,
--        force_name = FORCE_NAME,
--        moisture = 1, -- 1 = Dry and 2 = Wet
--        aux = 1, -- 1 = red desert, 2 = sand
--        elevation = 3, --1,2,3 (1 low elevation, 2. medium, 3 high elavation)
--        temperature = 2, --1,2,3 (1 cold, 2. normal, 3 hot)
--        entity_filter = "armoured",
--    })
--end