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


local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value


-- Handles acid and poison resistance
local base_acid_resistance = 10
local incremental_acid_resistance = 80
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 95
-- Handles fire and explosive resistance
local base_fire_resistance = 10
local incremental_fire_resistance = 80
-- Handles laser and electric resistance
local base_electric_resistance = 0
local incremental_electric_resistance = 90
-- Handles cold resistance
local base_cold_resistance = 10
local incremental_cold_resistance = 80

function makeLevelEnemy(level, type, health_cut_ratio)
    health_cut_ratio = health_cut_ratio or 1
    local biter = util.table.deepcopy(data.raw['unit'][type])
    local original_health = biter['max_health']

    biter['localised_name'] = { 'entity-name.' .. MOD_NAME .. '/' .. biter['name'], level }
    biter['name'] = MOD_NAME .. '/' .. biter['name'] .. '/' .. level
    biter['max_health'] = ERM_UnitHelper.get_health(original_health, original_health * max_hitpoint_multiplier / health_cut_ratio,  level)
    biter['resistances'] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance,  level) },
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance,  level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance,  level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance,  level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance,  level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance,  level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance,  level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance,  level) }
    }
    biter['healing_per_tick'] = 0
    ERM_UnitHelper.modify_biter_damage(biter, type, level)
    biter['movement_speed'] = ERM_UnitHelper.get_movement_speed(biter['movement_speed'], biter['movement_speed'], settings.startup["enemyracemanager-level-multipliers"].value, level)

    return biter
end

local max_level = ErmConfig.MAX_LEVELS

for i = 1, max_level do
    -- 15 - 158
    data:extend({ makeLevelEnemy(i, 'small-biter') })
    -- 10 - 105
    data:extend({ makeLevelEnemy(i, 'small-spitter') })
    -- 75 - 1900
    data:extend({ makeLevelEnemy(i, 'medium-biter', 0.33 ) })
    -- 50 - 1300
    data:extend({ makeLevelEnemy(i, 'medium-spitter', 0.33) })
    -- 375 - 5000
    data:extend({ makeLevelEnemy(i, 'big-biter') })
    -- 200 - 2700
    data:extend({ makeLevelEnemy(i, 'big-spitter') })
    -- 3000 - 7700
    data:extend({ makeLevelEnemy(i, 'behemoth-biter', 8) })
    -- 1500 - 3800
    data:extend({ makeLevelEnemy(i, 'behemoth-spitter', 8) })
end

-- Add Elite biters
for i = ErmConfig.MAX_LEVELS, ErmConfig.MAX_LEVELS + ErmConfig.MAX_ELITE_LEVELS do

    data:extend({ makeLevelEnemy(i, 'behemoth-biter', 8) })

    data:extend({ makeLevelEnemy(i, 'behemoth-spitter', 8) })
end