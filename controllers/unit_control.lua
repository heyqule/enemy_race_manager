---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 9:56 PM
---
local Event = require('__stdlib__/stdlib/event/event')
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')
require('util')

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

local CHUNK_SIZE = 32

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
    local racename = ForceHelper.extract_race_name_from(force.name)
    local is_erm_group = global.group_tracker and global.group_tracker[racename]
    if ForceHelper.is_enemy_force(force) then
        local scout_unit_name
        if is_erm_group then
            if AttackGroupProcessor.FLYING_GROUPS[global.group_tracker[racename].group_type] then
                scout_unit_name = 2
            else
                scout_unit_name = 1
            end
        elseif (RaceSettingsHelper.can_spawn(75) or TEST_MODE) then
            scout_unit_name = 1
        end

        if scout_unit_name then
            global.scout_unit_name[group.group_number] = {
                entity = group,
                scout_type = scout_unit_name
            }
        end
    end
end

local scout_type = {
    AttackGroupBeaconProcessor.LAND_SCOUT,
    AttackGroupBeaconProcessor.AERIAL_SCOUT
}

local checking_state = {
    [defines.group_state.gathering] = true,
    [defines.group_state.wander_in_group] = true,
    [defines.group_state.finished] = true
}

local onUnitFinishGathering = function(event)
    local group = event.group
    if not group.valid then
        return
    end
    local is_erm_group = AttackGroupProcessor.is_erm_unit_group(group.group_number)
    local group_force = group.force

    if ForceHelper.is_enemy_force(group_force) and
        not is_erm_group and
        group.is_script_driven and
        group.command == nil and
        checking_state[group.state] and
        #group.members > 10
    then
        local race_name = ForceHelper.extract_race_name_from(group_force.name)
        local target = AttackGroupHeatProcessor.pick_target(race_name)
        AttackGroupProcessor.process_attack_position(group, nil, nil, target)
        global.erm_unit_groups[group.group_number] = {
            group = group,
            start_position = group.position,
            always_angry = false,
            nearby_retry = 0,
            attack_force = target,
            created = game.tick,
            is_aerial = false
        }
    end


    if  ForceHelper.is_enemy_force(group_force) and
            (group.is_script_driven == false or is_erm_group) and
            global.scout_unit_name[group.group_number]
    then
        local surface = group.surface
        local race_name = ForceHelper.extract_race_name_from(group_force.name)
        local scout = surface.create_entity({
            position =  group.position,
            surface = surface,
            force = group_force,
            name = AttackGroupBeaconProcessor.get_scout_name(race_name, scout_type[global.scout_unit_name[group.group_number].scout_type]),
            count = 1
        })
        group.add_member(scout);
    end

    if global.scout_unit_name[group.group_number] then
        global.scout_unit_name[group.group_number] = nil
    end
end

--- handle scouts under ai complete
local handle_scouts = function(scout_unit_data)
    if scout_unit_data and
            scout_unit_data.can_repath and
            scout_unit_data.entity.valid then
        local tracker = global.scout_tracker[scout_unit_data.race_name]
        if tracker then
            local entity = tracker.entity
            if util.distance(tracker.final_destination, entity.position) < CHUNK_SIZE then
                AttackGroupBeaconProcessor.create_attack_entity_beacon(entity)
                local target_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(
                        entity.surface,
                        entity.force,
                        tracker.target_force,
                        true
                )

                if target_beacon then
                    if util.distance(tracker.final_destination, target_beacon.position) < CHUNK_SIZE then
                        scout_unit_data.can_repath = false
                        return
                    end

                    global.scout_tracker[scout_unit_data.race_name]['final_destination'] = target_beacon.position
                    global.scout_tracker[scout_unit_data.race_name]['update_tick'] = game.tick
                    scout_unit_data.entity.set_command({
                        type = defines.command.go_to_location,
                        destination = target_beacon.position,
                        radius = 16,
                        distraction = defines.distraction.none
                    })
                end
            end
        end
    end
end

--- handle ERM groups under ai complete
local handle_erm_groups = function(unit_number, event_result)
    if AttackGroupProcessor.is_erm_unit_group(unit_number) then
        local erm_unit_group = global.erm_unit_groups[unit_number]
        local group = erm_unit_group.group

        AttackGroupProcessor.destroy_invalid_group(erm_unit_group.group, erm_unit_group.start_position)

        if group.valid == false then
            global.erm_unit_groups[unit_number] = nil
            return
        end

        if event_result == defines.behavior_result.failure or
                erm_unit_group.nearby_retry >= 3
        then
            if erm_unit_group.always_angry and erm_unit_group.always_angry == true then
                AttackGroupProcessor.process_attack_position(group, defines.distraction.by_anything, nil, erm_unit_group.attack_force, true)
            else
                AttackGroupProcessor.process_attack_position(group, nil, nil, erm_unit_group.attack_force, true)
            end
            erm_unit_group.nearby_retry = 0
        elseif
            group.command == nil or
            group.state == defines.group_state.finished or
            event_result == defines.behavior_result.success
        then
            if erm_unit_group.always_angry and erm_unit_group.always_angry == true then
                AttackGroupProcessor.process_attack_position(group, defines.distraction.by_anything, true, erm_unit_group.attack_force)
            else
                AttackGroupProcessor.process_attack_position(group, nil, true, erm_unit_group.attack_force)
            end
            erm_unit_group.nearby_retry = erm_unit_group.nearby_retry + 1
        end
    end
end

local onAiCompleted = function(event)
    local unit_number = event.unit_number
    local event_result = event.result

    -- Hmm... Unit group doesn't call AI complete when all its units die.  its unit triggers behaviour fails tho.
    -- print('onAiCompleted '..event.unit_number..'/'..DEBUG_BEHAVIOUR_RESULTS[event.result]..'/'..tostring(event.was_distracted))
    handle_erm_groups(unit_number, event_result)

    local scout_unit_data = global.scout_by_unit_number[unit_number]
    handle_scouts(scout_unit_data)
end

--- Path finding
Event.register(defines.events.on_script_path_request_finished, function(event)
    AttackGroupPathingProcessor.on_script_path_request_finished(event.id, event.path, event.try_again_later)
end)

--- Initial path finder
Event.register(Event.generate_event_name(Config.REQUEST_PATH), function(event)
    AttackGroupPathingProcessor.request_path(event.surface, event.source_force, event.start, event.goal, event.is_aerial, event.group_number)
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