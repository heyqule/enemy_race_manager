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

local MapProcessor = {}

local chunk_queue = {}

local getNameToken = function(name)
    if not String.find(name, '/') then
        return {'erm_vanilla', name, '1'}
    end
    return String.split(name, '/')
end

local level_up_enemy_structures = function(surface, entity, race_settings)
    local nameToken = getNameToken(entity.name)
    local force_name = entity.force.name
    local position = entity.position
    local race_name = ErmForceHelper.extract_race_name_from(force_name)

    -- Don't update vanilla enemy if enhenced vanilla biters has disabled
    if entity.force.name == 'enemy' and settings.startup['enemyracemanager-enable-bitters'].value == false then
        return
    end

    if not race_settings[race_name] then
        return
    end

    if race_settings[race_name].level == tonumber(nameToken[3]) and String.find(entity.name, '/') then
        return
    end

    local name = nameToken[1]..'/'..nameToken[2]..'/'..race_settings[race_name].level
    entity.destroy()
    surface.create_entity({name = name, force = force_name, position = position})
end

local process_enemy_level = function(surface, area, race_settings)
    local spawners = Table.filter(surface.find_entities_filtered({area = area, type = 'unit-spawner'}), Game.VALID_FILTER)
    local spawners_size = Table.size(spawners)
    if spawners_size > 0 then
        Table.each(spawners, function(entity)
            level_up_enemy_structures(surface, entity, race_settings)
        end)
    end

    local turrets = Table.filter(surface.find_entities_filtered({area = area, type = 'turret'}), Game.VALID_FILTER)
    local turret_size = Table.size(turrets)
    if turret_size > 0 then
        Table.each(turrets, function(entity)
            level_up_enemy_structures(surface, entity, race_settings)
        end)
    end

    local units = Table.filter(surface.find_entities_filtered({area = area, type = 'unit'}), Game.VALID_FILTER)
    if turret_size > 0 then
        Table.each(units, function(entity)
            entity.destroy()
        end)
    end
end

function MapProcessor.queue_chunks(surface, area)
    if not area then
        return
    end
    if not chunk_queue[surface.name] then
        chunk_queue[surface.name] = Queue()
    end

    local spawners_size = Table.size(
        Table.filter(surface.find_entities_filtered({area = area, type = 'unit-spawner'}), Game.VALID_FILTER)
    )
    local turret_size = Table.size(
        Table.filter(surface.find_entities_filtered({area = area, type = 'turret'}), Game.VALID_FILTER)
    )
    if spawners_size > 0 or turret_size > 0 then
        chunk_queue[surface.name](area)
    end
end

function MapProcessor.process_chunks(surface, race_settings)
    local process_count = ErmConfig.MAP_PROCESS_CHUNK_BATCH

    if table_size(chunk_queue) == 0 then
        return
    end

    if Queue.is_empty(chunk_queue[surface.name]) then
        return
    end

    if chunk_queue[surface.name] then
        for i=1, process_count do
            area = chunk_queue[surface.name]()
            if area then
                process_enemy_level(surface, area, race_settings)
            end
        end
    end
end

function MapProcessor.cleanQueue()
    for k, queue in pairs(chunk_queue) do
        chunk_queue[k] = Queue()
    end
end

function MapProcessor.rebuildMap(game)
    MapProcessor.cleanQueue()
    for i,surface in pairs(game.surfaces) do
        for chunk in surface.get_chunks() do
            MapProcessor.queue_chunks(surface, chunk.area)
        end
    end
end

return MapProcessor