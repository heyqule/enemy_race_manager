---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 9:56 PM
---
local Event = require('__stdlib__/stdlib/event/event')
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local ReplacementProcessor = require('__enemyracemanager__/lib/replacement_processor')
local BaseBuildProcessor = require('__enemyracemanager__/lib/base_build_processor')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local RaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local AttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')
local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local AttackGroupPathingProcessor = require('__enemyracemanager__/lib/attack_group_pathing_processor')
local AttackGroupHeatProcessor = require('__enemyracemanager__/lib/attack_group_heat_processor')

local Config = require('__enemyracemanager__/lib/global_config')
local Cron = require('__enemyracemanager__/lib/cron_processor')

local DEBUG_BEHAVIOUR_RESULTS = {
    [defines.behavior_result.in_progress] = 'defines.behavior_result.in_progress',
    [defines.behavior_result.fail] = 'defines.behavior_result.fail',
    [defines.behavior_result.success] = 'defines.behavior_result.success',
    [defines.behavior_result.deleted] = 'defines.behavior_result.deleted'
}

local DEBUG_GROUP_STATES = {
    [defines.group_state.gathering] = 'defines.group_state.gathering',
    [defines.group_state.moving] = 'defines.group_state.moving',
    [defines.group_state.attacking_distraction] = 'defines.group_state.attacking_distraction',
    [defines.group_state.attacking_target] = 'defines.group_state.attacking_target',
    [defines.group_state.finished] = 'defines.group_state.finished',
    [defines.group_state.pathfinding] = 'defines.group_state.pathfinding',
    [defines.group_state.wander_in_group] = 'defines.group_state.wander_in_group'
}

local onBiterBaseBuilt = function(event)
    local entity = event.entity
    if entity and entity.valid then
        local race_name = ForceHelper.extract_race_name_from(entity.force.name)
        if Config.race_is_active(race_name) then
            local replaced_entity = ReplacementProcessor.replace_entity(entity.surface, entity, global.race_settings, entity.force.name)
            if replaced_entity and replaced_entity.valid then
                BaseBuildProcessor.exec(replaced_entity)
            end
        end

        AttackGroupBeaconProcessor.create_spawn_beacon(entity)
    end
end

local onUnitGroupCreated = function(event)
    local group = event.group
    local force = group.force
    if ForceHelper.is_enemy_force(force) then
        local surface = group.surface
        local racename = ForceHelper.extract_race_name_from(force.name)
        local scout_unit_name
        if global.group_tracker and global.group_tracker[racename] then
            if AttackGroupProcessor.FLYING_GROUPS[global.group_tracker[racename].group_type] then
                scout_unit_name = racename..AttackGroupBeaconProcessor.AERIAL_SCOUT
            else
                scout_unit_name = racename..AttackGroupBeaconProcessor.LAND_SCOUT
            end
        elseif RaceSettingsHelper.can_spawn(33) then
            scout_unit_name = racename..AttackGroupBeaconProcessor.LAND_SCOUT
        end

        if scout_unit_name then
            local scout = surface.create_entity({
                position =  group.position,
                surface = surface,
                force = force,
                name = scout_unit_name,
                count = 1
            })
            group.add_member(scout);
        end
    end
end

local onUnitFinishGathering = function(event)

end

---
--- Destroy group members and refund them as attack points.
---
local destroyMembers = function(group)
    local members = group.members
    local refundPoints = 0
    for _, member in pairs(members) do
        member.destroy()
        refundPoints = refundPoints + AttackGroupProcessor.MIXED_UNIT_POINTS
    end

    group.destroy()
    return refundPoints
end

local isErmUnitGroup = function(unit_number)
    local erm_unit_groups = global.erm_unit_groups
    return erm_unit_groups[unit_number] and erm_unit_groups[unit_number].group and erm_unit_groups[unit_number].group.valid
end

---
--- Destroy group if the group doesn't have a valid path
---
local destroyInvalidGroup = function(erm_unit_groups, unit_number)
    local erm_group = erm_unit_groups[unit_number]
    local group = erm_group.group
    local start_position = erm_unit_groups[unit_number].start_position

    if group.valid and
            group.is_script_driven and
            group.command == nil and
            (start_position.x == group.position.x and start_position.y == group.position.y) and
            ForceHelper.is_enemy_force(group.force)
    then
        local group_size = table_size(group.members)
        local group_force = group.force
        local race_name = ForceHelper.extract_race_name_from(group_force.name)
        local refund_points = destroyMembers(group)

        --- Hardcoded chance to spawn flyer group
        if (RaceSettingsHelper.can_spawn(25) and group_size >= 50) or TEST_MODE then
            local race_name = ForceHelper.extract_race_name_from(group_force.name)
            local group_type = AttackGroupProcessor.GROUP_TYPE_FLYING
            local target_force =  AttackGroupHeatProcessor.pick_target(race_name)
            local surface =  AttackGroupHeatProcessor.pick_surface(race_name, target_force)

            Cron.add_2_sec_queue('AttackGroupProcessor.generate_group',
                    race_name, group_force, (group_size / 2), group_type, nil,
                    false, target_force, surface)
        elseif Config.race_is_active(race_name) then
                RaceSettingsHelper.add_to_attack_meter(race_name, refund_points)
        end
    end
end

local onAiCompleted = function(event)
    local unit_number = event.unit_number

    -- Hmm... Unit group doesn't call AI complete when all its units die.  its unit triggers behaviour fails tho.
    -- print('onAiCompleted '..event.unit_number..'/'..DEBUG_BEHAVIOUR_RESULTS[event.result]..'/'..tostring(event.was_distracted))


    if isErmUnitGroup(unit_number) then
        local erm_unit_groups = global.erm_unit_groups
        local group = erm_unit_groups[unit_number].group

        destroyInvalidGroup(erm_unit_groups, unit_number)

        if group.valid == false then
            erm_unit_groups[unit_number] = nil
            return
        end

        if group.command == nil and
            group.state == defines.group_state.finished
        then
            if erm_unit_groups.always_angry and erm_unit_groups.always_angry == true then
                AttackGroupProcessor.process_attack_position(group, defines.distraction.by_anything, true)
            else
                AttackGroupProcessor.process_attack_position(group, nil, true)
            end
        end

        if event.result == defines.behavior_result.success then
            AttackGroupProcessor.process_attack_position(group, nil)
        end
    end
end

--- Path finding
Event.register(defines.events.on_script_path_request_finished, function(event)
    AttackGroupPathingProcessor.on_script_path_request_finished(event.id, event.path, event.try_again_later)
end)

--- Initial path finder
Event.register(Event.generate_event_name(Config.REQUEST_PATH), function(event)
    AttackGroupPathingProcessor.request_path(event.surface, event.source_force, event.start, event.goal, event.is_aerial)
end)

--- Unit processing events
Event.register(defines.events.on_biter_base_built, onBiterBaseBuilt)

Event.register(defines.events.on_unit_group_created, onUnitGroupCreated)

Event.register(defines.events.on_unit_group_finished_gathering, onUnitFinishGathering)

Event.register(defines.events.on_ai_command_completed, onAiCompleted)

--- @TODO 2.0 handle this with per planet statistic?
local function is_unit_spawner(event)
    return event.entity.type == 'unit-spawner' and not ForceHelper.is_enemy_force(event.force)
end

local function handle_unit_spawner(event)
    local dead_spawner = event.entity
    local surface = dead_spawner.surface.index
    local target_force = event.force.index
    AttackGroupHeatProcessor.calculate_heat(ForceHelper.extract_race_name_from(dead_spawner.force.name), surface, target_force)
end

Event.register(defines.events.on_entity_died, handle_unit_spawner , is_unit_spawner)