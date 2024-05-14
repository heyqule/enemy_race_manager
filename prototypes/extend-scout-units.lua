---
--- Generated scouting unit for each race.
--- Created by heyqule.
--- DateTime: 12/10/2023 3:16 PM
---
require('util')


local LAND_SCOUT = '/land_scout'
local AERIAL_SCOUT = '/aerial_scout'


local land_scout_script = {
    type = "script",
    effect_id = LAND_SCOUT_BEACON
}


local aerial_scout_script = {
    type = "script",
    effect_id = AERIAL_SCOUT_BEACON
}


for mod_name, unit_name in pairs(data.erm_land_scout) do
    local target_unit = mod_name .. '/' .. unit_name .. '/1'
    local unit = util.table.deepcopy(data.raw['unit'][target_unit])
    unit['name'] = mod_name .. LAND_SCOUT
    unit['localised_name'] = { 'entity-name.' .. mod_name .. LAND_SCOUT }
    unit['max_health'] = 50
    unit['resistances'] = {}
    unit['movement_speed'] = 0.225
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
    unit['name'] = mod_name .. AERIAL_SCOUT
    unit['localised_name'] = { 'entity-name.' .. mod_name .. AERIAL_SCOUT }
    unit['max_health'] = 50
    unit['resistances'] = {}
    unit['movement_speed'] = 0.35
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