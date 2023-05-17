---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 03/16/2020 1:56 PM
---

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ERM_UnitHelper = require('__enemyracemanager__/lib/rig/unit_helper')
local ERM_DebugHelper = require('__enemyracemanager__/lib/debug_helper')
local enemy_autoplace = require("__enemyracemanager__/lib/enemy-autoplace-utils")
local Table = require('__stdlib__/stdlib/utils/table')
local String = require('__stdlib__/stdlib/utils/string')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')
require('util')


local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value


-- Handles acid and poison resistance
local base_acid_resistance = 0
local incremental_acid_resistance = 50
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 75
-- Handles fire and explosive resistance
local base_fire_resistance = -100
local incremental_fire_resistance = 0
-- Handles laser and electric resistance
local base_electric_resistance = -50
local incremental_electric_resistance = 100


function makeLevelSpawners(level, type)
    local spawner = util.table.deepcopy(data.raw['unit-spawner'][type])

    local original_hitpoint = spawner['max_health']

    spawner['localised_name'] = { 'entity-name.' .. MOD_NAME .. '/' .. spawner['name'], level }
    spawner['name'] = MOD_NAME .. '/' .. spawner['name'] .. '/' .. level;
    spawner['max_health'] = ERM_UnitHelper.get_building_health(original_hitpoint, original_hitpoint * max_hitpoint_multiplier,  level)
    spawner['resistances'] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance,  level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance,  level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance,  level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance,  level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance,  level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance,  level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance,  level) },
        { type = "cold", percent = 95 }
    }
    spawner['healing_per_tick'] = ERM_UnitHelper.get_building_healing(original_hitpoint, max_hitpoint_multiplier,  level)
    spawner['spawning_cooldown'] = {600, 300}

    local result_units = (function()
        local res = {}
        res[1] = {MOD_NAME .. "/small-cold-biter/" .. level, {{0.0, 0.3}, {0.6, 0.0}}}
        res[3] = {MOD_NAME .. "/small-cold-spitter/" .. level, {{0.25, 0.0}, {0.5, 0.3}, {0.7, 0.0}}}
        res[2] = {MOD_NAME .. "/medium-cold-biter/" .. level, {{0.2, 0.0}, {0.6, 0.3}, {0.7, 0.0}}}
        res[4] = {MOD_NAME .. "/medium-cold-spitter/" .. level, {{0.4, 0.0}, {0.7, 0.3}, {0.9, 0.0}}}
        res[5] = {MOD_NAME .. "/big-cold-biter/" .. level, {{0.5, 0.0}, {1.0, 0.4}}}
        res[6] = {MOD_NAME .. "/big-cold-spitter/" .. level, {{0.5, 0.0}, {1.0, 0.4}}}
        res[7] = {MOD_NAME .. "/behemoth-cold-biter/" .. level, {{0.8, 0.0}, {1.0, 0.3}}}
        res[8] = {MOD_NAME .. "/behemoth-cold-spitter/" .. level, {{0.85, 0.0}, {1.0, 0.3}}}
        res[9] = {MOD_NAME .. "/leviathan-cold-biter/" .. level, {{0.9, 0.0}, {1.0, 0.03}}}
        res[10]= {MOD_NAME .. "/leviathan-cold-spitter/" .. level, {{0.9, 0.0}, {1.0, 0.03}}}
        if not settings.startup["cb-disable-mother"].value then
            res[11]= {MOD_NAME .. "/mother-cold-spitter/" .. level, {{0.925, 0.0}, {1.0, 0.02}}}
        end
        return res
    end)()

    spawner['result_units'] = result_units
    spawner['autoplace'] = enemy_autoplace.enemy_spawner_autoplace(0, FORCE_NAME)

    return spawner
end

local max_level = ErmConfig.MAX_LEVELS

for i = 1, max_level do
    data:extend({ makeLevelSpawners(i, 'cb-cold-spawner') })
end