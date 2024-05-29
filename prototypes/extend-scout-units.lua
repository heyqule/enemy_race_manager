---
--- Generated scouting unit for each race.
--- Created by heyqule.
--- DateTime: 12/10/2023 3:16 PM
---
require('util')

local ERM_UnitHelper = require('__enemyracemanager__/lib/rig/unit_helper')

local LAND_SCOUT = '/land_scout/'
local AERIAL_SCOUT = '/aerial_scout/'

local land_scout_script = {
    type = "script",
    effect_id = LAND_SCOUT_BEACON
}


local aerial_scout_script = {
    type = "script",
    effect_id = AERIAL_SCOUT_BEACON
}

local land_original_health = 50
local aerial_original_health = 40
local max_hitpoint_multiplier = settings.startup["enemyracemanager-max-hitpoint-multipliers"].value

for level = 1, 20 ,1 do
    for mod_name, unit_name in pairs(data.erm_land_scout) do
        local target_unit = mod_name .. '/' .. unit_name .. '/1'
        local unit = util.table.deepcopy(data.raw['unit'][target_unit])
        unit['name'] = mod_name .. LAND_SCOUT .. level
        unit['max_health'] = ERM_UnitHelper.get_health(land_original_health, land_original_health * max_hitpoint_multiplier, level)
        unit['resistances'] = {}
        unit['movement_speed'] = ERM_UnitHelper.get_movement_speed(0.2, 0.1, level)
        unit['ai_settings'] = {
            destroy_when_commands_fail = true,
            allow_try_return_to_spawner = false
        }
        if unit['dying_trigger_effect'] == nil then
            unit['dying_trigger_effect'] = {}
        end
        table.insert(unit['dying_trigger_effect'], land_scout_script)
        data:extend({unit})
    end

    for mod_name, unit_name in pairs(data.erm_aerial_scout) do
        local target_unit = mod_name .. '/' .. unit_name .. '/1'
        local unit = util.table.deepcopy(data.raw['unit'][target_unit])
        unit['name'] = mod_name .. AERIAL_SCOUT .. level
        unit['max_health'] = ERM_UnitHelper.get_health(aerial_original_health, aerial_original_health * max_hitpoint_multiplier, level)
        unit['resistances'] = {}
        unit['movement_speed'] = ERM_UnitHelper.get_movement_speed(0.3, 0.15, level)
        unit['ai_settings'] = {
            destroy_when_commands_fail = true,
            allow_try_return_to_spawner = false
        }
        if unit['dying_trigger_effect'] == nil then
            unit['dying_trigger_effect'] = {}
        end
        table.insert(unit['dying_trigger_effect'], aerial_scout_script)
        data:extend({unit})
    end
end
