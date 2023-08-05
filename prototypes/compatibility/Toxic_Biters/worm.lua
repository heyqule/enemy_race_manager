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
require('util')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')


local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value


-- Handles acid and poison resistance
local base_acid_resistance = 0
local incremental_acid_resistance = 80
-- Handles physical resistance
local base_physical_resistance = 0
local incremental_physical_resistance = 85
-- Handles fire and explosive resistance
local base_fire_resistance = 0
local incremental_fire_resistance = 80
-- Handles laser and electric resistance
local base_electric_resistance = -50
local incremental_electric_resistance = 100
-- Handles cold resistance
local base_cold_resistance = -50
local incremental_cold_resistance = 100

function makeLevelTurrets(level, type, distance)
    data.raw['turret'][type]['autoplace']  = nil
    local turret = util.table.deepcopy(data.raw['turret'][type])

    local original_hitpoint = turret['max_health']

    turret['localised_name'] = { 'entity-name.' .. MOD_NAME .. '/' .. turret['name'], level }
    turret['name'] = MOD_NAME .. '/' .. turret['name'] .. '/' .. level;
    turret['max_health'] = ERM_UnitHelper.get_building_health(original_hitpoint, original_hitpoint * max_hitpoint_multiplier,  level)
    turret['resistances'] = {
        { type = "acid", percent = 95 },
        { type = "poison", percent = 95 },
        { type = "physical", percent = ERM_UnitHelper.get_resistance(base_physical_resistance, incremental_physical_resistance,  level) },
        { type = "fire", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance,  level) },
        { type = "explosion", percent = ERM_UnitHelper.get_resistance(base_fire_resistance, incremental_fire_resistance,  level) },
        { type = "laser", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance,  level) },
        { type = "electric", percent = ERM_UnitHelper.get_resistance(base_electric_resistance, incremental_electric_resistance,  level) },
        { type = "cold", percent = ERM_UnitHelper.get_resistance(base_cold_resistance, incremental_cold_resistance,  level) }
    }
    turret['healing_per_tick'] = ERM_UnitHelper.get_building_healing(original_hitpoint, max_hitpoint_multiplier,  level)
    turret['attack_parameters']['damage_modifier'] = 0.33

    ERM_UnitHelper.modify_biter_damage(turret, level)
    turret['autoplace'] = enemy_autoplace.enemy_worm_autoplace(distance, FORCE_NAME)

    return turret
end

if settings.startup['tb-disable-worms'].value then
    return
end

local max_level = ErmConfig.MAX_LEVELS

for i = 1, max_level do
    data:extend({ makeLevelTurrets(i, 'small-toxic-worm-turret',0)})
    data:extend({ makeLevelTurrets(i, 'medium-toxic-worm-turret',2) })
    data:extend({ makeLevelTurrets(i, 'big-toxic-worm-turret',5) })
    data:extend({ makeLevelTurrets(i, 'behemoth-toxic-worm-turret',8) })
    data:extend({ makeLevelTurrets(i, 'leviathan-toxic-worm-turret',14) })

    if not settings.startup["tb-disable-mother"].value then
        data:extend({ makeLevelTurrets(i, 'mother-toxic-worm-turret',14) })
    end
end