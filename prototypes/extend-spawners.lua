---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/31/2020 1:56 PM
---

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ERM_UnitHelper = require('__enemyracemanager__/lib/unit_helper')
local ERM_DebugHelper = require('__enemyracemanager__/lib/debug_helper')

local Table = require('__stdlib__/stdlib/utils/table')
local String = require('__stdlib__/stdlib/utils/string')
require('util')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local health_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value

local max_worm_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value

local resistance_mutiplier = settings.startup["enemyracemanager-level-multipliers"].value
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


-- Add new spawners
function makeLevelSpawners(level, type, health_cut_ratio)
    health_cut_ratio = health_cut_ratio or 1
    local spawner = util.table.deepcopy(data.raw['unit-spawner'][type])
    local original_hitpoint = spawner['max_health']

    spawner['localised_name'] = { 'entity-name.' .. MOD_NAME .. '/' .. spawner['name'], level }
    spawner['name'] = MOD_NAME .. '/' .. spawner['name'] .. '/' .. level;
    spawner['max_health'] = ERM_UnitHelper.get_health(original_hitpoint, original_hitpoint * max_hitpoint_multiplier / health_cut_ratio, health_multiplier, level)
    spawner['resistances'] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, resistance_mutiplier, level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, resistance_mutiplier, level) }
    }
    spawner['healing_per_tick'] = ERM_UnitHelper.get_building_healing(original_hitpoint, max_hitpoint_multiplier, health_multiplier, level)

    if String.find(type, 'spitter', 1, true) then
        spawner['result_units'] = (function()
            local res = {}
            res[1] = { MOD_NAME .. '/small-spitter/' .. level, { { 0.0, 0.3 }, { 0.6, 0.0 } } }
            if not data.is_demo then
                -- from evolution_factor 0.3 the weight for medium-biter is linearly rising from 0 to 0.3
                -- this means for example that when the evolution_factor is 0.45 the probability of spawning
                -- a small biter is 66% while probability for medium biter is 33%.
                res[2] = { MOD_NAME .. '/medium-spitter/' .. level, { { 0.2, 0.0 }, { 0.6, 0.3 }, { 0.7, 0.0 } } }
                -- for evolution factor of 1 the spawning probabilities are: small-biter 0%, medium-biter 1/8, big-biter 4/8, behemoth biter 3/8
                res[3] = { MOD_NAME .. '/big-spitter/' .. level, { { 0.5, 0.0 }, { 1.0, 0.6 } } }
                res[4] = { MOD_NAME .. '/behemoth-spitter/' .. level, { { 0.9, 0.0 }, { 1.0, 0.4 } } }
            end
            return res
        end)()
    else
        spawner['result_units'] = (function()
            local res = {}
            res[1] = { MOD_NAME .. '/small-biter/' .. level, { { 0.0, 0.3 }, { 0.6, 0.0 } } }
            if not data.is_demo then
                -- from evolution_factor 0.3 the weight for medium-biter is linearly rising from 0 to 0.3
                -- this means for example that when the evolution_factor is 0.45 the probability of spawning
                -- a small biter is 66% while probability for medium biter is 33%.
                res[2] = { MOD_NAME .. '/medium-biter/' .. level, { { 0.2, 0.0 }, { 0.6, 0.3 }, { 0.7, 0.0 } } }
                -- for evolution factor of 1 the spawning probabilities are: small-biter 0%, medium-biter 1/8, big-biter 4/8, behemoth biter 3/8
                res[3] = { MOD_NAME .. '/big-biter/' .. level, { { 0.5, 0.0 }, { 1.0, 0.5 } } }
                res[4] = { MOD_NAME .. '/behemoth-biter/' .. level, { { 0.8, 0.05 }, { 1.0, 0.3 } } }
            end
            return res
        end)()
    end

    return spawner
end

function makeLevelWorm(level, type, health_cut_ratio)
    health_cut_ratio = health_cut_ratio or 1
    local worm = util.table.deepcopy(data.raw['turret'][type])
    local original_hitpoint = worm['max_health']

    worm['localised_name'] = { 'entity-name.' .. MOD_NAME .. '/' .. worm['name'], level }
    worm['name'] = MOD_NAME .. '/' .. worm['name'] .. '/' .. level;
    worm['max_health'] = ERM_UnitHelper.get_health(original_hitpoint, original_hitpoint * max_worm_hitpoint_multiplier / health_cut_ratio, health_multiplier, level)
    worm['resistances'] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, resistance_mutiplier, level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, resistance_mutiplier, level) }
    }
    worm['healing_per_tick'] = ERM_UnitHelper.get_building_healing(original_hitpoint, max_hitpoint_multiplier, health_multiplier, level)
    ERM_UnitHelper.modify_worm_damage(worm, level)

    return worm
end

local level = ErmConfig.MAX_LEVELS

for i = 1, level do
    -- 350 - 5017
    data:extend({ makeLevelSpawners(i, 'biter-spawner', 0.75) })
    data:extend({ makeLevelSpawners(i, 'spitter-spawner', 0.75) })

    data:extend({ makeLevelWorm(i, 'small-worm-turret', 2) })
    data:extend({ makeLevelWorm(i, 'medium-worm-turret') })
    data:extend({ makeLevelWorm(i, 'big-worm-turret', 2) })
    data:extend({ makeLevelWorm(i, 'behemoth-worm-turret') })
end
