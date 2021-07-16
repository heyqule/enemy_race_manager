---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/21/2020 4:55 PM
---
--- Reference:
--- https://lua-api.factorio.com/latest/LuaSurface.html
--- https://lua-api.factorio.com/latest/Concepts.html#ChunkPositionAndArea
---

local Table = require('__stdlib__/stdlib/utils/table')
local String = require('__stdlib__/stdlib/utils/string')
local Queue = require('__stdlib__/stdlib/misc/queue')
local Game = require('__stdlib__/stdlib/game')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

require('__enemyracemanager__/setting-constants')

local MapProcessor = {}

local chunk_queue = {}

local process_one_race_per_surface_mapping = function(surface, entity, nameToken)
    if ErmConfig.get_mapping_method() == MAP_GEN_1_RACE_PER_SURFACE then
        if global.enemy_surfaces[surface.index] and nameToken[1] ~= global.enemy_surfaces[surface.index] then
            nameToken[1] = global.enemy_surfaces[surface.index]
            if entity.type == 'turret' then
                nameToken[2] = ErmRaceSettingHelper.pick_a_turret(global.enemy_surfaces[surface.index])
            else
                nameToken[2] = ErmRaceSettingHelper.pick_a_spawner(global.enemy_surfaces[surface.index])
            end
        end
    end

    return nameToken
end

local surfaces_cache = {}

local get_surface_by_name = function(surfaces, name) 
    if surfaces_cache[name] == nil then
        for k, surface in pairs(surfaces) do
            if surface.name == name then
                surfaces_cache[name] = surface
                break
            end                
        end
    end
    return surfaces_cache[name]
end

local level_up_enemy_structures = function(surface, entity, race_settings)
    local nameToken = ErmForceHelper.getNameToken(entity.name)

    nameToken = process_one_race_per_surface_mapping(surface, entity, nameToken)

    local force_name = entity.force.name
    local position = entity.position
    local race_name = ErmForceHelper.extract_race_name_from(force_name)

    if not race_settings[race_name] then
        return
    end

    if race_name == nameToken[1] and race_settings[nameToken[1]].level == tonumber(nameToken[3]) then
        return
    end

    local name = nameToken[1] .. '/' .. nameToken[2] .. '/' .. race_settings[nameToken[1]].level

    local new_force_name = entity.force.name
    if nameToken[1] ~= race_name then
        new_force_name = ErmForceHelper.get_force_name_from(nameToken[1])
    end

    entity.destroy()
    if not surface.can_place_entity({ name = name, force = new_force_name, position = position }) then
        position = surface.find_non_colliding_position(name, position, 32, 2, true)
    end

    if position then
        surface.create_entity({ name = name, force = new_force_name, position = position })
    end
end

local process_enemy_level = function(surface, area, race_settings)
    local building = surface.find_entities_filtered({ area = area, type = {'unit-spawner','turret'}, force = ErmForceHelper.getAllEnemyForces()})
    if Table.size(building) > 0 then
        for k, entity in pairs(building) do
            level_up_enemy_structures(surface, entity, race_settings)            
        end            
    end
end

function MapProcessor.queue_chunks(surface, area)
    if not area then
        return
    end

    if chunk_queue[surface.name] == nil then
        chunk_queue[surface.name] = Queue()
    end        

    local unit_size = Table.size(surface.find_entities_filtered({ area = area, type = {'unit-spawner','turret','unit'}, force = ErmForceHelper.getAllEnemyForces(), limit = 1}))
    if unit_size > 0 then
        chunk_queue[surface.name](area)
    end
end

function MapProcessor.process_chunks(surfaces, race_settings)
    local count = 1;

    for k, queue in pairs(chunk_queue) do
        if queue == nil then
            goto process_chunks_continue
        end

        if Queue.is_empty(queue) then
            chunk_queue[k] = nil
            goto process_chunks_continue
        end            
    
        for i = 1, ErmConfig.MAP_PROCESS_CHUNK_BATCH do
            area = queue()
            if area == nil then
                break
            end
            process_enemy_level(get_surface_by_name(surfaces, k), area, race_settings)
            count = count + 1
        end

        if count > ErmConfig.MAP_PROCESS_CHUNK_BATCH then
            break
        end            
        
        ::process_chunks_continue::
    end    
end

function MapProcessor.clean_queue()
    chunk_queue = {}
end

function MapProcessor.rebuild_map(game)
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