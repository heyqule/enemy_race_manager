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

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')


local health_multiplier = settings.startup["enemyracemanager-level-multipliers"].value
local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value / 4  -- Double original health

local resistance_mutiplier = settings.startup["enemyracemanager-level-multipliers"].value
-- Handles acid and poison resistance
local base_acid_resistance = 25
local incremental_acid_resistance = 50
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 75
-- Handles fire and explosive resistance
local base_fire_resistance = 10
local incremental_fire_resistance = 65
-- Handles laser and electric resistance
local base_electric_resistance = 0
local incremental_electric_resistance = 75
-- Handles cold resistance
local base_cold_resistance = 25
local incremental_cold_resistance = 50

function makeLevelEnemy(level, type)
    local biter = Table.deepcopy(data.raw['unit'][type])

    if DEBUG_MODE then
        ERM_DebugHelper.print_translate_to_console(MOD_NAME, biter['name'], level)
    end

    biter['name'] = MOD_NAME..'/'..biter['name'].. '/' .. level
    biter['max_health'] = ERM_UnitHelper.get_health(biter['max_health'], biter['max_health'] * max_hitpoint_multiplier, health_multiplier, level)
    biter['resistances'] = {
        { type = "acid", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level)},
        { type = "poison", percent = ERM_UnitHelper.get_resistance(base_acid_resistance, incremental_acid_resistance, resistance_mutiplier, level) },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance, resistance_mutiplier, level)},
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level)},
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance, resistance_mutiplier, level)},
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level)},
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance, resistance_mutiplier, level)},
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance, resistance_mutiplier, level)}
    }

    return biter
end


local level = ErmConfig.get_max_level(settings)

for i=1,level do
    data:extend({makeLevelEnemy(i, 'big-biter')})
    data:extend({makeLevelEnemy(i, 'big-spitter')})
    data:extend({makeLevelEnemy(i, 'behemoth-biter')})
    data:extend({makeLevelEnemy(i, 'behemoth-spitter')})
end