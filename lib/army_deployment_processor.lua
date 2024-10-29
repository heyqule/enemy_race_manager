---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/7/2022 10:25 PM
---

local Event = require('__stdlib__/stdlib/event/event')
local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local ArmyFunctions = require('__enemyracemanager__/lib/army_functions')
local ArmyPopulationProcessor = require('__enemyracemanager__/lib/army_population_processor')

local ArmyDeploymentProcessor = {}
--- Internal unit spawn cooldown for each deployer (in tick)
local spawn_cooldown = 300
--- Internal retry before removing the deployer from active list
local retry_threshold = settings.startup['enemyracemanager-unit-framework-timeout'].value * 12

local start_with_auto_deploy = settings.startup['enemyracemanager-unit-framework-start-auto-deploy'].value

local process_deployer_queue = function(event)
    ArmyDeploymentProcessor.deploy()
end

local can_stop_event = function()
    local stop = 0
    for _, force_data in pairs(storage.army_active_deployers) do
        if force_data.total == 0 then
            stop = stop + 1
        end
    end
    return table_size(storage.army_active_deployers) == stop
end

local stop_event = function()
    if storage.army_deployer_event_running == true and can_stop_event() then
        Event.remove(GlobalConfig.AUTO_DEPLOY_CRON * -1, process_deployer_queue)
        storage.army_deployer_event_running = false
    end
end

local statistics = {}
local add_statistic = function(entity, item_name, count)
    local force = entity.force;
    if force then
        if statistics[force.name] == nil then
            statistics[force.name] = force.item_production_statistics
        end
        statistics[force.name].on_flow(item_name, count * -1)
    end
end

local spawn_unit = function(deployer_data)
    local entity = deployer_data.entity
    local surface = entity.surface
    local registered_units = storage.army_registered_units
    if entity and entity.valid and
            surface and surface.valid then
        local force = entity.force
        if entity.energy > entity.electric_buffer_size * 0.9 then
            local inventory = entity.get_inventory(defines.inventory.assembling_machine_output)
            local contents = inventory.get_contents()
            for unit_name, count in pairs(contents) do
                if registered_units[unit_name] and count > 0 and
                        ArmyPopulationProcessor.pop_count(force) + registered_units[unit_name] <= ArmyPopulationProcessor.max_pop(force) and
                        ArmyPopulationProcessor.is_under_max_auto_deploy(force, unit_name)
                then
                    local position = ArmyFunctions.get_position(unit_name, entity, entity.position)
                    local spawned_entity = ArmyFunctions.spawn_unit(entity, unit_name, position)
                    if deployer_data.rally_point then
                        ArmyFunctions.assign_goto_command(spawned_entity, deployer_data.rally_point)
                    else
                        ArmyFunctions.assign_wander_command(spawned_entity)
                    end
                    if spawned_entity then
                        inventory.remove({ name = unit_name, count = 1 })
                        add_statistic(entity, unit_name, count)
                        return true
                    end
                end
            end
        end
    end

    return false
end

local init_built_data = function(force)
    if storage.army_built_deployers[force.index] == nil then
        storage.army_built_deployers[force.index] = {}
    end
end

local init_active_data = function(force)
    if storage.army_active_deployers[force.index] == nil then
        storage.army_active_deployers[force.index] = {
            deployers = {},
            total = 0
        }
    end
end

local remove_rallypoint_drawing = function(data)
    if data.rally_draw_link and rendering.is_valid(data.rally_draw_link) then
        rendering.destroy(data.rally_draw_link)
        data.rally_draw_link = nil
    end
    if data.rally_draw_flag and rendering.is_valid(data.rally_draw_flag) then
        rendering.destroy(data.rally_draw_flag)
        data.rally_draw_flag = nil
    end
end

local draw_link = function(rallypoint, deployer)
    return rendering.draw_line({
        color = {r=0,g=1,b=0,a=0.5},
        from = deployer.position,
        to = rallypoint.position,
        width = 2,
        gap_length = 3,
        dash_length = 3,
        surface = deployer.surface,
        forces = {deployer.force},
        only_in_alt_mode = true,
        draw_on_ground = true
    })
end

local draw_flag = function(rallypoint)
    return rendering.draw_sprite({
        sprite = 'utility/spawn_flag',
        target = rallypoint.position,
        surface = rallypoint.surface,
        forces = {rallypoint.force},
        only_in_alt_mode = true,
        draw_on_ground = true
    })
end

function ArmyDeploymentProcessor.init_globals()
    storage.army_active_deployers = storage.army_active_deployers or {}
    storage.army_built_deployers = storage.army_built_deployers or {}
    storage.army_registered_deployers = storage.army_registered_deployers or {}
    storage.army_deployer_event_running = storage.army_deployer_event_running or false
end

function ArmyDeploymentProcessor.register_building(name)
    if storage.army_registered_deployers == nil then
        storage.army_registered_deployers = {}
    end
    storage.army_registered_deployers[name] = true
end

function ArmyDeploymentProcessor.start_event(reload)
    if storage.army_deployer_event_running == false or reload then
        if not reload then
            storage.army_deployer_event_running = true
        end
        Event.on_nth_tick(GlobalConfig.AUTO_DEPLOY_CRON, process_deployer_queue)
    end
end

local add_to_active_data = function(force, unit_number)
    storage.army_active_deployers[force.index]['deployers'][unit_number] = storage.army_built_deployers[force.index][unit_number]
    storage.army_active_deployers[force.index]['deployers'][unit_number]['idle_retry'] = 0
    storage.army_active_deployers[force.index]['deployers'][unit_number]['next_tick'] = game.tick + spawn_cooldown
    storage.army_active_deployers[force.index].total = storage.army_active_deployers[force.index].total + 1
end

function ArmyDeploymentProcessor.add_entity(entity)
    local force = entity.force
    local unit_number = entity.unit_number

    init_built_data(force)

    storage.army_built_deployers[force.index][unit_number] = {
        entity = entity,
        build_only = false,
        -- hold position
        rally_point = nil,
        -- holds draw_line ID, remove when unset
        rally_draw_link = nil,
        -- holds draw_sprite ID, remove when unset
        rally_draw_flag = nil
    }

    if start_with_auto_deploy then
        ArmyDeploymentProcessor.add_to_active(entity)
    end

    ArmyDeploymentProcessor.start_event()
end


function ArmyDeploymentProcessor.add_rallypoint(rallypoint, deployer_number)
    local force_id = rallypoint.force.index
    local deployer_data = ArmyDeploymentProcessor.get_deployer_data(force_id, deployer_number)
    if deployer_data == nil or deployer_data.entity.valid == false then
        ArmyDeploymentProcessor.remove_entity(force_id, deployer_number)
        return nil
    end

    if deployer_data.rally_point then
        remove_rallypoint_drawing(deployer_data)
    end
    local link_id = draw_link(rallypoint, deployer_data.entity)
    local flag_id = draw_flag(rallypoint)
    deployer_data.rally_point = rallypoint.position
    deployer_data.rally_draw_link = link_id
    deployer_data.rally_draw_flag = flag_id
end

function ArmyDeploymentProcessor.remove_rallypoint(force_id, deployer_number)
    local deployer_data = ArmyDeploymentProcessor.get_deployer_data(force_id, deployer_number)
    remove_rallypoint_drawing(deployer_data)
    deployer_data.rally_point = nil
end



function ArmyDeploymentProcessor.get_deployer_data(force_index, unit_number)
    if storage.army_built_deployers[force_index] and storage.army_built_deployers[force_index][unit_number] then
        return storage.army_built_deployers[force_index][unit_number]
    end

    return nil
end

function ArmyDeploymentProcessor.add_to_active(entity)
    local force = entity.force
    local unit_number = entity.unit_number

    init_active_data(force)

    add_to_active_data(force, unit_number)

    ArmyDeploymentProcessor.start_event()
end

function ArmyDeploymentProcessor.remove_from_active(force_index, unit_number)
    if storage.army_active_deployers[force_index] and storage.army_active_deployers[force_index]['deployers'][unit_number] then
        storage.army_active_deployers[force_index]['deployers'][unit_number] = nil
        storage.army_active_deployers[force_index].total = storage.army_active_deployers[force_index].total - 1
    end
end

function ArmyDeploymentProcessor.remove_entity(force_index, unit_number)
    if storage.army_built_deployers[force_index] and storage.army_built_deployers[force_index][unit_number] then
        remove_rallypoint_drawing(storage.army_built_deployers[force_index][unit_number])
        storage.army_built_deployers[force_index][unit_number] = nil
        ArmyDeploymentProcessor.remove_from_active(force_index, unit_number)
    end
end

function ArmyDeploymentProcessor.remove_data_by_force_index(force_index)
    storage.army_built_deployers[force_index] = nil
    storage.army_active_deployers[force_index] = nil
    stop_event()
end

function ArmyDeploymentProcessor.set_build_only(force_index, unit_number, build_only)
    unit_number = tonumber(unit_number)
    if storage.army_active_deployers[force_index] and storage.army_active_deployers[force_index]['deployers'][unit_number] then
        storage.army_active_deployers[force_index]['deployers'][unit_number]['build_only'] = build_only
    end

    if storage.army_built_deployers[force_index] and storage.army_built_deployers[force_index][unit_number] then
        storage.army_built_deployers[force_index][unit_number]['build_only'] = build_only
    end
end

function ArmyDeploymentProcessor.process_retry(force_index, unit_number)
    if (storage.army_active_deployers[force_index]['deployers'][unit_number].idle_retry == retry_threshold) then
        ArmyDeploymentProcessor.remove_from_active(force_index, unit_number)
    end
end

local stop_event_check = 2 * minute
local stop_event_check_modular = stop_event_check - GlobalConfig.AUTO_DEPLOY_CRON

function ArmyDeploymentProcessor.deploy()
    local current_tick = game.tick
    for force_index, force_data in pairs(storage.army_active_deployers) do
        if force_data.total > 0 then
            local force = game.forces[force_index]
            if force and force.valid then
                if ArmyPopulationProcessor.is_under_max_pop(force) then
                    for unit_number, deployer_data in pairs(force_data['deployers']) do
                        if deployer_data.entity and deployer_data.entity.valid then
                            if current_tick > deployer_data.next_tick then
                                local success = spawn_unit(deployer_data)
                                if success then
                                    deployer_data.idle_retry = 0
                                else
                                    deployer_data.idle_retry = deployer_data.idle_retry + 1
                                    ArmyDeploymentProcessor.process_retry(force_index, unit_number)
                                end
                                deployer_data.next_tick = current_tick + spawn_cooldown
                            end
                        else
                            ArmyDeploymentProcessor.remove_from_active(force_index, unit_number)
                        end
                    end
                else
                    for unit_number, deployer_data in pairs(force_data['deployers']) do
                        deployer_data.idle_retry = deployer_data.idle_retry + 1
                        deployer_data.next_tick = current_tick + spawn_cooldown
                        ArmyDeploymentProcessor.process_retry(force_index, unit_number)
                    end
                end
            else
                ArmyDeploymentProcessor.remove_data_by_force_index(force_index)
            end
        end
    end

    if current_tick % stop_event_check > stop_event_check_modular then
        stop_event()
    end
end

return ArmyDeploymentProcessor