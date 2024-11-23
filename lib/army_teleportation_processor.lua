---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/15/2022 10:25 PM
---

--- It can teleport registered army units and base-game character
local util = require("util")
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local Cron = require("__enemyracemanager__/lib/cron_processor")
local ArmyFunctions = require("__enemyracemanager__/lib/army_functions")
local ArmyPopulationProcessor = require("__enemyracemanager__/lib/army_population_processor")

local ArmyTeleportationProcessor = {}

-- Disable link if cc is idle.
local MAX_RETRY = settings.startup["enemyracemanager-unit-deployer-timeout"].value * 4;

local BOX_WIDTH = 48;
local DOUBLE_BOX_WIDTH = 64;

local unset_indicator = function(teleport)
    if teleport and teleport.indicator then
        teleport.indicator.destroy()
    end
end

local process_teleport_queue = function()
    Cron.process_teleport_queue()
end

function ArmyTeleportationProcessor.start_event(reload)
    if storage.army_teleporter_event_running == false or reload then
        if not reload then
            ArmyTeleportationProcessor.scan_units()
            storage.army_teleporter_event_running = true
        end
        script.on_nth_tick(GlobalConfig.TELEPORT_QUEUE_CRON, process_teleport_queue)
    end
end

local can_stop_event = function()
    local stopped = 0
    local teleporters = storage.army_entrance_teleporters
    for _, teleporter in pairs(teleporters) do
        if teleporter.idle_retry == nil then
            stopped = stopped + 1
        end
    end
    return stopped == table_size(teleporters)
end

local stop_event = function()
    if storage.army_teleporter_event_running == true then
        script.on_nth_tick(GlobalConfig.TELEPORT_QUEUE_CRON, nil)
        storage.army_teleporter_event_running = false
    end
end

function ArmyTeleportationProcessor.init_globals()
    storage.army_entrance_teleporters = storage.army_entrance_teleporters or {}
    storage.army_exit_teleporters = storage.army_exit_teleporters or {}
    storage.army_built_teleporters = storage.army_built_teleporters or {}
    storage.army_teleporters_name_mapping = storage.army_teleporters_name_mapping or {}
    storage.army_registered_command_centers = storage.army_registered_command_centers or {}
    storage.army_teleporter_event_running = storage.army_teleporter_event_running or false
end

function ArmyTeleportationProcessor.register_building(name)
    if storage.army_registered_command_centers == nil then
        storage.army_registered_command_centers = {}
    end
    storage.army_registered_command_centers[name] = true
end

function ArmyTeleportationProcessor.add_entity(entity)
    local army_built_teleporters = storage.army_built_teleporters
    local force = entity.force
    local surface = entity.surface
    local position = entity.position
    local unit_number = entity.unit_number

    if army_built_teleporters[force.index] == nil then
        storage.army_built_teleporters[force.index] = {}
    end

    if army_built_teleporters[force.index][surface.index] == nil then
        storage.army_built_teleporters[force.index][surface.index] = {}
    end

    local surface_name = ''
    if surface.planet then
        surface_name = surface.planet.name
    elseif surface.platform then
        surface_name = surface.platform.name
    else
        surface_name = surface.name
    end

    local name =  surface_name .. ", X:" .. position.x .. ", Y:" .. position.y
    entity.backer_name = name
    storage.army_built_teleporters[force.index][surface.index][unit_number] = {
        entity = entity,
        -- @Todo support rally points
        rally_point = nil
    }
    storage.army_teleporters_name_mapping[name] = {
        force_id = force.index,
        surface_id = surface.index,
        unit_number = unit_number
    }
end

function ArmyTeleportationProcessor.get_object_by_name(backer_name)
    local name_map = storage.army_teleporters_name_mapping[backer_name]
    if name_map then
        return storage.army_built_teleporters[name_map.force_id][name_map.surface_id][name_map.unit_number]
    end
end

function ArmyTeleportationProcessor.getEntityByName(backer_name)
    local teleport_object = ArmyTeleportationProcessor.get_object_by_name(backer_name)
    if teleport_object then
        return teleport_object.entity
    end
end

function ArmyTeleportationProcessor.remove_entity(entity)
    local force = entity.force
    storage.army_built_teleporters[force.index][entity.surface.index][entity.unit_number] = nil
    storage.army_teleporters_name_mapping[entity.backer_name] = nil

    local entrance = storage.army_entrance_teleporters[force.index]
    local exit = storage.army_exit_teleporters[force.index]

    if (entrance and entrance.entity == entity) or
            (exit and exit.entity == entity) then
        unset_indicator(entrance)
        unset_indicator(exit)
        storage.army_entrance_teleporters[force.index] = nil
        storage.army_exit_teleporters[force.index] = nil
    end
end

function ArmyTeleportationProcessor.link(from, to)
    if not (from.entity and from.entity.valid) or not (to.entity and to.entity.valid) then
        return
    end

    local force = from.entity.force
    local entrance = storage.army_entrance_teleporters[force.index]
    if entrance then
        unset_indicator(entrance)
    end

    local exit = storage.army_exit_teleporters[force.index]
    if exit then
        unset_indicator(exit)
    end

    storage.army_entrance_teleporters[force.index] = from
    storage.army_entrance_teleporters[force.index].idle_retry = 0
    storage.army_exit_teleporters[force.index] = to

    entrance = storage.army_entrance_teleporters[force.index]
    exit = storage.army_exit_teleporters[force.index]

    if entrance and (entrance.indicator == nil or entrance.indicator.valid == false) then
        local from_entity = from.entity
        local from_position = from_entity.position
        entrance.indicator = rendering.draw_rectangle({
            color = { g = 0.8, a = 0.05 },
            left_top = { from_position.x - BOX_WIDTH, from_position.y - BOX_WIDTH },
            right_bottom = { from_position.x + BOX_WIDTH, from_position.y + BOX_WIDTH },
            surface = from_entity.surface.index,
            forces = { from_entity.force.name },
            filled = false,
            draw_on_ground = true,
            width = 8,
            only_in_alt_mode = true,
        })
    end

    if exit and (exit.indicator == nil or exit.indicator.valid == false) then
        local to_entity = to.entity
        local to_position = to_entity.position
        exit.indicator = rendering.draw_rectangle({
            color = { r = 0.8, a = 0.05 },
            left_top = { to_position.x - BOX_WIDTH, to_position.y - BOX_WIDTH },
            right_bottom = { to_position.x + BOX_WIDTH, to_position.y + BOX_WIDTH },
            surface = to_entity.surface.index,
            forces = { to_entity.force.name },
            filled = false,
            draw_on_ground = true,
            width = 8,
            only_in_alt_mode = true,
        })
    end

    ArmyTeleportationProcessor.start_event()
end

function ArmyTeleportationProcessor.unlink(force)
    local entrance = storage.army_entrance_teleporters[force.index]
    local exit = storage.army_exit_teleporters[force.index]
    if entrance or exit then
        unset_indicator(entrance)
        unset_indicator(exit)
        --- @todo render CC light overlay on entrance
        storage.army_entrance_teleporters[force.index] = nil
        storage.army_exit_teleporters[force.index] = nil
    end

    if can_stop_event() then
        stop_event()
    end
end

function ArmyTeleportationProcessor.get_linked_entities(force)
    if storage.army_entrance_teleporters[force.index] then
        return storage.army_entrance_teleporters[force.index].entity, storage.army_exit_teleporters[force.index].entity
    end
end

local can_teleport = function(force_index)
    local from = storage.army_entrance_teleporters[force_index].entity
    local to = storage.army_exit_teleporters[force_index].entity
    return from and from.valid and from.status == defines.entity_status.working and
            to and to.valid and to.status == defines.entity_status.working
end

local unit_close_to_entrance = function(unit, target_entity)
    local distance = util.distance(unit.position, target_entity.position)
    return distance <= DOUBLE_BOX_WIDTH
end

function ArmyTeleportationProcessor.scan_units()
    for force_index, teleporter in pairs(storage.army_entrance_teleporters) do
        if can_teleport(force_index) then
            local from_entity = teleporter.entity
            local to_entity = storage.army_exit_teleporters[force_index].entity
            local surface = from_entity.surface
            local position = from_entity.position
            local units = surface.find_entities_filtered {
                area = {
                    left_top = { position.x - BOX_WIDTH, position.y - BOX_WIDTH },
                    right_bottom = { position.x + BOX_WIDTH, position.y + BOX_WIDTH }
                },
                force = from_entity.force,
                type = "unit",
                limit = 24
            }

            if next(units) then
                ArmyTeleportationProcessor.queue_units(units, from_entity, to_entity)
                teleporter.idle_retry = 0
            else
                teleporter.idle_retry = teleporter.idle_retry + 1
            end
        else
            teleporter.idle_retry = teleporter.idle_retry + 1
        end

        if teleporter and teleporter.idle_retry > MAX_RETRY and teleporter.entity.valid then
            ArmyTeleportationProcessor.unlink(teleporter.entity.force)
        end
    end

    if can_stop_event() then
        stop_event()
    else
        Cron.add_15_sec_queue("ArmyTeleportationProcessor.scan_units")
    end
end

function ArmyTeleportationProcessor.queue_units(units, from_entity, exit_entity)
    for _, unit in pairs(units) do
        Cron.add_teleport_queue("ArmyTeleportationProcessor.teleport", unit, from_entity, exit_entity)
    end
end

function ArmyTeleportationProcessor.teleport(unit, from_entity, exit_entity)
    if not (unit and unit.valid) or
      not (from_entity and from_entity.valid) or
      not (exit_entity and exit_entity.valid)
    then
        return
    end

    if can_teleport(unit.force.index) and unit_close_to_entrance(unit, from_entity) then
        local position = ArmyFunctions.get_position(unit.name, exit_entity, exit_entity.position)

        if position then
            if unit.surface == exit_entity.surface then
                unit.teleport(position)
                ArmyFunctions.assign_wander_command(unit)
            else
                local spawned_entity = unit.clone({position=position,surface=exit_entity.surface})
                if spawned_entity and spawned_entity.valid then
                    ArmyPopulationProcessor.remove_unit_count(spawned_entity)
                    --- @todo render Recall effect on entrance position
                    unit.destroy()
                    ArmyFunctions.assign_wander_command(spawned_entity)
                end
            end
        end
    end
end

return ArmyTeleportationProcessor