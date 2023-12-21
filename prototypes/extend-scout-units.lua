---
--- Generated scouting unit for each race.
--- Created by heyqule.
--- DateTime: 12/10/2023 3:16 PM
---
require('util')

local AttackGroupBeaconProcessor = require('lib/attack_group_beacon_processor')


local land_scout_script = {
    type = "script",
    effect_id = LAND_SCOUT_BEACON
}


local aerial_scout_script = {
    type = "script",
    effect_id = AERIAL_SCOUT_BEACON
}

local scout_pathfinding_script =
{
    type = "direct",
    action_delivery =
        {
        type = "instant",
            source_effects =
            {
                type = "script",
                effect_id = SCOUT_PATHFINDING
            }
        }
}

for mod_name, unit_name in pairs(data.erm_land_scout) do
    local target_unit = mod_name .. '/' .. unit_name .. '/1'
    local unit = util.table.deepcopy(data.raw['unit'][target_unit])
    unit['name'] = mod_name .. AttackGroupBeaconProcessor.LAND_SCOUT
    unit['localised_name'] = { 'entity-name.' .. mod_name .. AttackGroupBeaconProcessor.LAND_SCOUT }
    unit['max_health'] = 100
    unit['resistances'] = {}
    unit['movement_speed'] = 0.225
    unit['created_effect'] = scout_pathfinding_script
    if unit['dying_trigger_effect'] == nil then
        unit['dying_trigger_effect'] = {}
    end
    table.insert(unit['dying_trigger_effect'], land_scout_script)
    data:extend({unit})
end

for mod_name, unit_name in pairs(data.erm_aerial_scout) do
    local target_unit = mod_name .. '/' .. unit_name .. '/1'
    local unit = util.table.deepcopy(data.raw['unit'][target_unit])
    unit['name'] = mod_name .. AttackGroupBeaconProcessor.AERIAL_SCOUT
    unit['localised_name'] = { 'entity-name.' .. mod_name .. AttackGroupBeaconProcessor.AERIAL_SCOUT }
    unit['max_health'] = 100
    unit['resistances'] = {}
    unit['movement_speed'] = 0.35
    unit['created_effect'] = scout_pathfinding_script
    if unit['dying_trigger_effect'] == nil then
        unit['dying_trigger_effect'] = {}
    end
    table.insert(unit['dying_trigger_effect'], aerial_scout_script)
    data:extend({unit})
end