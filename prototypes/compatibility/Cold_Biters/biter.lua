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
local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value / 2

local resistance_mutiplier = settings.startup["enemyracemanager-level-multipliers"].value
-- Handles acid and poison resistance
local base_acid_resistance = 0
local incremental_acid_resistance = 50
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 75
-- Handles fire and explosive resistance
local base_fire_resistance = -100
local incremental_fire_resistance = 50
-- Handles laser and electric resistance
local base_electric_resistance = -50
local incremental_electric_resistance = 75
-- Handles cold resistance
local base_cold_resistance = 100
local incremental_cold_resistance = 0

function makeLevelEnemy(level, type, health_cut_ratio)
    health_cut_ratio = health_cut_ratio or 1
    local biter = util.table.deepcopy(data.raw['unit'][type])
    local original_hitpoint = biter['max_health']

    biter['localised_name'] = { 'entity-name.' .. MOD_NAME .. '/' .. biter['name'], level }
    biter['name'] = MOD_NAME .. '/' .. biter['name'] .. '/' .. level
    biter['max_health'] = ERM_UnitHelper.get_health(original_hitpoint / health_cut_ratio, original_hitpoint * max_hitpoint_multiplier / health_cut_ratio, health_multiplier, level)
    biter['resistances'] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, resistance_mutiplier, level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level) },
        { type = "cold", percent = 95 }
    }
    biter['healing_per_tick'] = 0

    return biter
end

local level = ErmConfig.MAX_LEVELS

for i = 1, level do
    -- (org: 15)
    data:extend({ makeLevelEnemy(i, 'small-cold-biter') })
    -- (org: 10)
    data:extend({ makeLevelEnemy(i, 'small-cold-spitter') })
    -- (org: 75)
    data:extend({ makeLevelEnemy(i, 'medium-cold-biter') })
    -- (org: 50)
    data:extend({ makeLevelEnemy(i, 'medium-cold-spitter') })
    -- (org: 375)
    data:extend({ makeLevelEnemy(i, 'big-cold-biter') })
    -- (org: 200)
    data:extend({ makeLevelEnemy(i, 'big-cold-spitter') })
    -- 1, 3000 - 10, 10500  - 20, 18000 (org: 3000)
    data:extend({ makeLevelEnemy(i, 'behemoth-cold-biter') })
    -- 1, 1500 - 10, 5250 - 20, 9000 (org: 1500)
    data:extend({ makeLevelEnemy(i, 'behemoth-cold-spitter') })
    -- 1, 20000 - 10, 70000 - 20, 120000 (org: 80000)
    data:extend({ makeLevelEnemy(i, 'leviathan-cold-biter', 5) })
    -- 1, 12500 - 10, 43750 - 20, 75000 (org: 50000)
    data:extend({ makeLevelEnemy(i, 'leviathan-cold-spitter', 5) })

    if not settings.startup["cb-disable-mother"].value then
        -- 1, 33333 - 10, 116666 - 20, 200000 (org: 100000)
        data:extend({ makeLevelEnemy(i, 'mother-cold-spitter',3) })
    end
end