---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/21/2020 4:55 PM
---
--- Reference:
--- https://lua-api.factorio.com/latest/LuaSurface.html
--- https://lua-api.factorio.com/latest/Concepts.html#ChunkPositionAndArea
---

local Queue = require("__stdlib__/stdlib/misc/queue")

local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local RaceSettingHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")


require("__enemyracemanager__/setting-constants")

local MapProcessor = {}

local vanilla_structures = {
    ["biter-spawner"] = true,
    ["spitter-spawner"] = true,
    ["small-worm-turret"] = true,
    ["medium-worm-turret"] = true,
    ["big-worm-turret"] = true,
    ["behemoth-worm-turret"] = true,

    ["armoured-biter-spawner"] = true,
    ["explosive-biter-spawner"] = true,
    ["cb-cold-spawner"] = true,
    ["toxic-biter-spawner"] = true,
}

local process_one_race_per_surface_mapping = function(surface, entity, nameToken)
    if GlobalConfig.get_mapping_method() == MAP_GEN_1_RACE_PER_SURFACE then
        local enemy_surface = storage.enemy_surfaces[surface.name]
        if enemy_surface and nameToken[1] ~= enemy_surface then
            nameToken[1] = enemy_surface
            if entity.type == "turret" then
                nameToken[2] = RaceSettingHelper.pick_a_turret(enemy_surface)
            else
                nameToken[2] = RaceSettingHelper.pick_a_spawner(enemy_surface)
            end
        end
    end

    return nameToken
end

local get_surface_by_name = function(surfaces, name)
    local surface_cache = storage.mapproc_surfaces_cache[name]
    if surface_cache == nil or surface_cache.valid == false then
        for k, surface in pairs(surfaces) do
            if surface.name == name then
                surface_cache = surface
                storage.mapproc_surfaces_cache[name] = surface_cache
                break
            end
        end
    end
    return surface_cache
end

local level_up_enemy_structures = function(surface, entity, race_settings)
    if ForceHelper.is_erm_unit(entity) == false and vanilla_structures[entity.name] == nil then
        return
    end

    local force_name = entity.force.name
    local race_name = ForceHelper.extract_race_name_from(force_name)

    if not GlobalConfig.race_is_active(race_name) then
        return
    end

    local nameToken = ForceHelper.get_name_token(entity.name)

    nameToken = process_one_race_per_surface_mapping(surface, entity, nameToken)
    local position = entity.position

    if race_name == nameToken[1] and tonumber(nameToken[3]) >= race_settings[nameToken[1]].level then
        return
    end

    local name = nameToken[1] .. "--" .. nameToken[2] .. "--" .. race_settings[nameToken[1]].level

    local new_force_name = entity.force.name
    if nameToken[1] ~= race_name then
        new_force_name = ForceHelper.get_force_name_from(nameToken[1])
    end

    entity.destroy()
    if not surface.can_place_entity({ name = name, force = new_force_name, position = position }) then
        position = surface.find_non_colliding_position(name, position, 32, 8, true)
    end

    if position then
        surface.create_entity({ name = name, force = new_force_name, position = position, spawn_decorations = true })
    end
end

local process_enemy_level = function(surface, area, race_settings)
    local building = surface.find_entities_filtered({ area = area, type = { "unit-spawner", "turret" }, force = ForceHelper.get_enemy_forces() })
    if table_size(building) > 0 then
        for k, entity in pairs(building) do
            level_up_enemy_structures(surface, entity, race_settings)
        end
    end

    --- Check for potential high level units over the border of the chunk.
    local larger_radius = 8
    local larger_area = {
        top_left = { area.left_top.x - larger_radius, area.left_top.y - larger_radius },
        bottom_right = { area.right_bottom.x + larger_radius, area.right_bottom.y + larger_radius },
    }
    local units = surface.find_entities_filtered({ area = larger_area, type = { "unit" }, force = ForceHelper.get_enemy_forces() })
    if table_size(units) > 0 then
        for _, entity in pairs(units) do
            local entity_command = entity.commandable
            if entity_command and not entity_command.is_unit_group then
                entity.destroy()
            end
        end
    end
end

function MapProcessor.init_globals()
    storage.mapproc_surfaces_cache = storage.mapproc_surfaces_cache or {}
    storage.mapproc_chunk_queue = storage.mapproc_chunk_queue or {} -- Need on_load metafix
end

function MapProcessor.queue_chunks(surface, area)
    if not ForceHelper.can_have_enemy_on(surface) or not area then
        return
    end

    if storage.mapproc_chunk_queue[surface.name] == nil then
        storage.mapproc_chunk_queue[surface.name] = Queue()
    end

    local unit_size = surface.count_entities_filtered({ area = area, type = { "unit-spawner", "turret", "unit" }, force = ForceHelper.get_enemy_forces(), limit = 1 })
    if unit_size > 0 then
        storage.mapproc_chunk_queue[surface.name](area)
    end
end

function MapProcessor.process_chunks(surfaces, race_settings)
    local count = 1;

    for k, queue in pairs(storage.mapproc_chunk_queue) do
        if queue == nil then
            goto process_chunks_continue
        end

        if Queue.is_empty(queue) then
            storage.mapproc_chunk_queue[k] = nil
            goto process_chunks_continue
        end

        for i = 1, GlobalConfig.MAP_PROCESS_CHUNK_BATCH do
            local area = queue()
            if area == nil then
                break
            end

            local surface = get_surface_by_name(surfaces, k)
            if surface == nil or surface.valid == false then
                storage.mapproc_chunk_queue[k] = nil
                break
            end

            process_enemy_level(
                    surface,
                    area,
                    race_settings
            )
            count = count + 1
        end

        if count > GlobalConfig.MAP_PROCESS_CHUNK_BATCH then
            break
        end

        :: process_chunks_continue ::
    end
end

function MapProcessor.clean_queue()
    storage.mapproc_chunk_queue = {}
end

function MapProcessor.rebuild_queue()
    if storage.mapproc_chunk_queue ~= nil then
        for _, queue in pairs(storage.mapproc_chunk_queue) do
            Queue.load(storage.mapproc_chunk_queue[_])
        end
    end
end

function MapProcessor.rebuild_map()
    MapProcessor.clean_queue()
    for i, surface in pairs(game.surfaces) do
        for chunk in surface.get_chunks() do
            MapProcessor.queue_chunks(surface, chunk.area)
        end
    end
end

function MapProcessor.rebuild_surface(surface)
    for chunk in surface.get_chunks() do
        MapProcessor.queue_chunks(surface, chunk.area)
    end
end

function MapProcessor.level_up_unit_built_base(entity, race_settings)
    level_up_enemy_structures(entity.surface, entity, race_settings)
end

return MapProcessor