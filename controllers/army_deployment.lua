---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/21/2022 11:48 PM
---

local Event = require('__stdlib__/stdlib/event/event')
require('__stdlib__/stdlib/utils/defines/time')

local ArmyDeploymentProcessor = require('__enemyracemanager__/lib/army_deployment_processor')
local ErmArmyControlUI = require('__enemyracemanager__/gui/army_control_window')

local add_deployer = function(event)
    local entity = event.created_entity or event.entity
    ArmyDeploymentProcessor.add_entity(entity)
    ErmArmyControlUI.update_deployers()
end

local remove_deployer = function(event)
    local entity = event.created_entity or event.entity
    ArmyDeploymentProcessor.remove_entity(entity.force.index, entity.unit_number)
    ErmArmyControlUI.update_deployers()
end


local is_valid_deployer = function(event)
    local entity = event.created_entity or event.entity
    if entity and entity.valid and global.army_registered_deployers then
        return global.army_registered_deployers[entity.name]
    end
    return nil
end

Event.register(defines.events.script_raised_revive, add_deployer, is_valid_deployer)
Event.register(defines.events.script_raised_built, add_deployer, is_valid_deployer)
Event.register(defines.events.on_built_entity, add_deployer, is_valid_deployer)
Event.register(defines.events.on_robot_built_entity, add_deployer, is_valid_deployer)

Event.register(defines.events.on_entity_died, remove_deployer, is_valid_deployer)
Event.register(defines.events.script_raised_destroy, remove_deployer, is_valid_deployer)
Event.register(defines.events.on_player_mined_entity, remove_deployer, is_valid_deployer)
Event.register(defines.events.on_robot_mined_entity, remove_deployer, is_valid_deployer)