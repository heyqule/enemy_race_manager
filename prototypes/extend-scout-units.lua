---
--- Generated scouting unit for each race.
--- Created by heyqule.
--- DateTime: 12/10/2023 3:16 PM
---
require('util')


local land_scout_script = {
    type = "script",
    effect_id = LAND_SCOUT_BEACON
}


local aerial_scout_script = {
    type = "script",
    effect_id = AERIAL_SCOUT_BEACON
}

local land_action_delivery = {
    {
        type = 'instant',
        source_effects = land_scout_script
    }
}

local aerial_action_delivery = {
    {
        type = 'instant',
        source_effects = aerial_scout_script
    }
}


for mod_name, unit_name in pairs(data.erm_land_scout) do
    local target_unit = mod_name .. '/' .. unit_name .. '/1'
    print(serpent.block(data.raw['unit'][target_unit]))
    local unit = util.table.deepcopy(data.raw['unit'][target_unit])
    unit['name'] = mod_name .. '/land-scout'
    unit['localised_name'] = { 'entity-name.' .. mod_name .. '/land-scout' }
    unit['max_health'] = 100
    unit['resistances'] = {}
    unit['movement_speed'] = 0.225
    unit['attack_parameters']['range'] = 1
    unit['attack_parameters']['min_attack_distance'] = nil
    unit['attack_parameters']['warmup'] = 0
    unit['attack_parameters']['ammo_type']['category'] = 'melee'
    unit['attack_parameters']['ammo_type']['action_delivery'] = land_action_delivery
    unit['dying_trigger_effect'] = land_action_delivery
    data:extend({unit})
end

for mod_name, unit_name in pairs(data.erm_aerial_scout) do
    local target_unit = mod_name .. '/' .. unit_name .. '/1'
    local unit = util.table.deepcopy(data.raw['unit'][target_unit])
    print(serpent.block(data.raw['unit'][target_unit]))
    unit['name'] = mod_name .. '/aerial-scout'
    unit['localised_name'] = { 'entity-name.' .. mod_name .. '/aerial-scout' }
    unit['max_health'] = 100
    unit['resistances'] = {}
    unit['movement_speed'] = 0.35
    unit['attack_parameters']['range'] = 1
    unit['attack_parameters']['min_attack_distance'] = nil
    unit['attack_parameters']['warmup'] = 0
    unit['attack_parameters']['ammo_type']['category'] = 'melee'
    unit['attack_parameters']['ammo_type']['action_delivery'] = aerial_action_delivery
    unit['dying_trigger_effect'] = aerial_action_delivery
    data:extend({unit})
end