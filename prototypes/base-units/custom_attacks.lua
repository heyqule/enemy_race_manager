---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/23/2020 8:27 PM
---

local String = require('__stdlib__/stdlib/utils/string')
local Math = require('__stdlib__/stdlib/utils/math')
local Table = require('__stdlib__/stdlib/utils/table')

local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local CustomAttackHelper = require('__enemyracemanager__/lib/helper/custom_attack_helper')

local droppable_unit_names = {
    { 'medium-spitter', 'medium-biter', 'defender'},
    { 'medium-spitter', 'medium-biter', 'big-spitter', 'big-biter', 'defender', 'distractor'},
    { 'big-spitter', 'big-biter', 'behemoth-spitter', 'behemoth-biter', 'defender', 'distractor', 'destroyer'},
}
local get_droppable_unit = function()
    return CustomAttackHelper.get_unit(droppable_unit_names, MOD_NAME)
end

local construction_building_name = {
    { 'biter-spawner', 'spitter-spawner' },
    { 'biter-spawner', 'spitter-spawner', 'big-worm-turret'},
    { 'biter-spawner', 'spitter-spawner', 'roboport', 'big-worm-turret' },
}
local get_construction_building_name = function()
    return CustomAttackHelper.get_unit(construction_building_name, MOD_NAME)
end

local CustomAttacks = {}

CustomAttacks.valid = CustomAttackHelper.valid

function CustomAttacks.process_logistic(event)
    CustomAttackHelper.drop_unit(event, MOD_NAME, get_droppable_unit())
end

function CustomAttacks.process_constructor(event)
    CustomAttackHelper.drop_unit(event, MOD_NAME, get_construction_building_name())
    event.source_entity.die('neutral')
end

return CustomAttacks