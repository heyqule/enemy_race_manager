---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/31/2020 1:56 PM
---

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ERM_UnitHelper = require('__enemyracemanager__/lib/rig/unit_helper')
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
local base_acid_resistance = 10
local incremental_acid_resistance = 70
-- Handles physical resistance
local base_physical_resistance = 20
local incremental_physical_resistance = 75
-- Handles fire and explosive resistance
local base_fire_resistance = 10
local incremental_fire_resistance = 70
-- Handles laser and electric resistance
local base_electric_resistance = 0
local incremental_electric_resistance = 80
-- Handles cold resistance
local base_cold_resistance = 10
local incremental_cold_resistance = 70

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
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, resistance_mutiplier, level) }
    }
    biter['healing_per_tick'] = 0
    ERM_UnitHelper.modify_biter_damage(biter, type, level)
    biter['movement_speed'] = ERM_UnitHelper.get_movement_speed(biter['movement_speed'], biter['movement_speed'], settings.startup["enemyracemanager-level-multipliers"].value, level)

    return biter
end

local level = ErmConfig.MAX_LEVELS

for i = 1, level do
    -- 1, 50 - 10, 175 - 20, 275 (org: 50)
    data:extend({ makeLevelEnemy(i, 'small-armoured-biter') })
    -- 1, 100 - 10, 350 - 20, 600 (org: 200)
    data:extend({ makeLevelEnemy(i, 'medium-armoured-biter', 2) })
    -- 1, 400 - 10, 1400 - 20, 2400 (org: 800)
    data:extend({ makeLevelEnemy(i, 'big-armoured-biter', 2) })
    -- 1, 2000 - 10, 7000 - 20, 12000 (org: 6000)
    data:extend({ makeLevelEnemy(i, 'behemoth-armoured-biter', 3) })
    -- 1, 4500 - 10, 15750 - 20, 27000 (org: 18000)
    data:extend({ makeLevelEnemy(i, 'leviathan-armoured-biter', 4) })
end