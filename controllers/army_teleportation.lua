---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/17/2022 10:19 PM
---
local Event = require('__stdlib__/stdlib/event/event')
require('__stdlib__/stdlib/utils/defines/time')

local ArmyTeleportationProcessor = require('__enemyracemanager__/lib/army_teleportation_processor')
local ErmArmyControlUI = require('__enemyracemanager__/gui/army_control_window')

local add_command_center = function(event)
    local entity = event.created_entity or event.entity
    ArmyTeleportationProcessor.add_entity(entity)
    ErmArmyControlUI.update_command_centers()
end

local remove_command_center = function(event)
    local entity = event.created_entity or event.entity
    ArmyTeleportationProcessor.remove_entity(entity)
    ErmArmyControlUI.update_command_centers()
end


local is_valid_command_center = function(event)
    local entity = event.created_entity or event.entity
    if entity and entity.valid and global.army_registered_command_centers then
        return global.army_registered_command_centers[entity.name]
    end
    return nil
end

Event.register(defines.events.script_raised_revive, add_command_center, is_valid_command_center)
Event.register(defines.events.script_raised_built, add_command_center, is_valid_command_center)
Event.register(defines.events.on_built_entity, add_command_center, is_valid_command_center)
Event.register(defines.events.on_robot_built_entity, add_command_center, is_valid_command_center)

Event.register(defines.events.on_entity_died, remove_command_center, is_valid_command_center)
Event.register(defines.events.script_raised_destroy, remove_command_center, is_valid_command_center)
Event.register(defines.events.on_player_mined_entity, remove_command_center, is_valid_command_center)
Event.register(defines.events.on_robot_mined_entity, remove_command_center, is_valid_command_center)
