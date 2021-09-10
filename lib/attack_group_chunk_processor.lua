---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 9/6/2021 1:34 AM
---
local Table = require('__stdlib__/stdlib/utils/table')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')

local AttackGroupChunkProcessor = {}

AttackGroupChunkProcessor.CHUNK_SEARCH_RADIUS = 5
AttackGroupChunkProcessor.CHUNK_SIZE = 32
AttackGroupChunkProcessor.CHUNK_CENTER_POINT_RADIUS = AttackGroupChunkProcessor.CHUNK_SEARCH_RADIUS * 2
AttackGroupChunkProcessor.CHUNK_SEARCH_AREA = AttackGroupChunkProcessor.CHUNK_SEARCH_RADIUS * AttackGroupChunkProcessor.CHUNK_SIZE

AttackGroupChunkProcessor.MINIMUM_SPAWNABLE = 10

AttackGroupChunkProcessor.DIRECTION_CURSOR = {'northwest', 'northeast', 'southeast', 'southwest'}

AttackGroupChunkProcessor.NORMAL_PRECISION_TARGET_TYPES = {
    'mining-drill',
    'rocket-silo',
    'artillery-turret',
}

AttackGroupChunkProcessor.HARDCORE_PRECISION_TARGET_TYPES = {
    'lab',
    'furnace',
}

AttackGroupChunkProcessor.EXTREME_PRECISION_TARGET_TYPES = {
    'assembling-machine',
    'generator',
    'solar-panel',
    'accumulator',
}

local create_race_cursor_node = function()
    return {
        current_direction = 1, -- corresponding to DIRECTION_CURSOR
        rotatable_directions = {1, 2, 3, 4},
        current_node_name = {
            northwest = '',
            northeast = '',
            southeast = '',
            southwest = '',
        }
    }
end

local get_chunk_node_list = function()
    return {
        chunks = {},
        head_node_name = nil,
        new_node_name = nil,
    }
end

local get_spawn_area = function(position)
    local distance = AttackGroupChunkProcessor.CHUNK_SEARCH_AREA
    local area = {
        {position.x - distance, position.y - distance},
        {position.x + distance, position.y + distance}
    }
    return area
end

local set_up_rotatable_direction = function()

end

local init_spawnable_chunk = function(surface, forced_init)
    if global.attack_group_spawnable_chunk[surface.name] == nil or forced_init then
        global.attack_group_spawnable_chunk[surface.name] = {
            northwest = get_chunk_node_list(),
            northeast = get_chunk_node_list(),
            southeast = get_chunk_node_list(),
            southwest = get_chunk_node_list(),
            race_cursors = { },
        }

        for _, race in pairs(ErmConfig.get_enemy_races()) do
            global.attack_group_spawnable_chunk[surface.name].race_cursors[race] = create_race_cursor_node()
            set_up_rotatable_direction(global.attack_group_spawnable_chunk[surface.name].race_cursors[race])
        end
    end
end

local is_cachable_spawn_position = function(position)
    return position.x % AttackGroupChunkProcessor.CHUNK_CENTER_POINT_RADIUS == 0 and
            position.y % AttackGroupChunkProcessor.CHUNK_CENTER_POINT_RADIUS == 0
end

--- Weird ass Double Linked List LOL
local create_spawnable_node = function(x, y)
    return {
        x = x,
        y = y,
        next_node_name = nil,
        prev_node_name = nil,
    }
end

local get_spawn_location_name = function(x, y)
    return tostring(x)..'/'..tostring(y)
end

local append_chunk = function(chunk_data, x, y)
    local node_name = get_spawn_location_name(x,y)
    if chunk_data.chunks[node_name] then
        return
    end

    local node = create_spawnable_node(x, y)
    local prev_name = nil

    if chunk_data.head_node_name == nil then
        chunk_data.head_node_name = node_name
    else
        prev_name = chunk_data.new_node_name
        node.prev_node_name = chunk_data.new_node_name
    end

    if chunk_data.chunks[prev_name] then
        chunk_data.chunks[prev_name].next_node_name = node_name
    end

    chunk_data.chunks[node_name] = node
    chunk_data.new_node_name = node_name
end

---
--- Remove chunk that is no longer have spawner on it.  But it preserve at least 5 blocks to track enemy expansions.
---
local remove_spawnable_chunk = function(surface, direction, position)
    local chunk_set = global.attack_group_spawnable_chunk[surface.name][direction]
    local node_name = get_spawn_location_name(position.x, position.y)

    local node_length = Table.count_keys(chunk_set.chunks)

    local node = chunk_set.chunks[node_name]
    if node == nil and node_length < AttackGroupChunkProcessor.MINIMUM_SPAWNABLE then
        return
    end

    local next_node_name = node.next_node_name
    local prev_node_name = node.prev_node_name

    if node_name == chunk_set.head_node_name then
        --- Reset Head and the next node to be head
        chunk_set.head_node_name = next_node_name
        if chunk_set.chunks[next_node_name] then
            chunk_set.chunks[next_node_name].prev_node_name = nil
        end
    elseif node.next_node_name == nil then
        --- Change Last node
        if chunk_set.chunks[prev_node_name] then
            chunk_set.chunks[prev_node_name].next_node_name = nil
        end
    else
        --- Rewire next/prev in middle node
        local prev_node = chunk_set.chunks[prev_node_name]
        local next_node = chunk_set.chunks[next_node_name]
        if prev_node then
            chunk_set.chunks[prev_node_name].next_node_name =
                get_spawn_location_name(next_node.x, next_node.y)
        end
        if next_node then
            chunk_set.chunks[next_node_name].prev_node_name =
                get_spawn_location_name(prev_node.x, prev_node.y)
        end
    end
    chunk_set.chunks[node_name] = nil

    local node_length = Table.count_keys(chunk_set.chunks)

    if node_length == 0 then
        chunk_set.head_node_name = nil
        chunk_set.new_node_name = nil
    end
end

local add_spawnable_chunk_to_list = function(surface, x, y)
    if y < 0 then
        if x < 0 then
            append_chunk(global.attack_group_spawnable_chunk[surface.name].northwest, x, y)
        else
            append_chunk(global.attack_group_spawnable_chunk[surface.name].northeast, x, y)
        end
    else
        if x < 0 then
            append_chunk(global.attack_group_spawnable_chunk[surface.name].southwest, x, y)
        else
            append_chunk(global.attack_group_spawnable_chunk[surface.name].southeast, x, y)
        end
    end
end

local add_spawnable_chunk = function(surface, chunk)
    local position = {
        x = chunk.x * AttackGroupChunkProcessor.CHUNK_SIZE,
        y = chunk.y * AttackGroupChunkProcessor.CHUNK_SIZE
    }
    local spawner = surface.find_entities_filtered
    ({
        area = get_spawn_area(position),
        type = 'unit-spawner',
        limit = 1
    })
    local total_spawner = #spawner

    if total_spawner > 0 then
        add_spawnable_chunk_to_list(surface, position.x, position.y)
        return true
    end

    return false
end

local remove_chunk_without_spawner = function(surface, position, race_name)
    local spawner = surface.find_entities_filtered
    ({
        area = get_spawn_area(position),
        force = ErmForceHelper.get_all_enemy_forces(),
        type = 'unit-spawner',
        limit = 1
    })
    if #spawner == 0 then
        local race_cursor = global.attack_group_spawnable_chunk[surface.name].race_cursors[race_name]
        local current_direction = AttackGroupChunkProcessor.DIRECTION_CURSOR[
            race_cursor.rotatable_directions[race_cursor.current_direction]
        ]
        remove_spawnable_chunk(surface, current_direction, position)
    end
end

local find_spawn_position = function(surface, race_name)
    local position = nil
    local position_node = nil
    local retry = 0

    local race_cursor = global.attack_group_spawnable_chunk[surface.name].race_cursors[race_name]
    local total_rotatable_directions = #race_cursor.rotatable_directions

    repeat
        --- Swap spawn direction
        local rotatable_direction = race_cursor.current_direction % total_rotatable_directions + 1
        race_cursor.current_direction = race_cursor.rotatable_directions[rotatable_direction]
        local current_direction = AttackGroupChunkProcessor.DIRECTION_CURSOR[
            race_cursor.rotatable_directions[race_cursor.current_direction]
        ]
        local current_chunk_list = global.attack_group_spawnable_chunk[surface.name][current_direction]
        local current_race_cursor_name = race_cursor.current_node_name[current_direction]
        if current_race_cursor_name == '' and current_chunk_list.head_node_name ~= nil then
            --- Pick head node
            race_cursor.current_node_name[current_direction] = current_chunk_list.head_node_name
            position_node = current_chunk_list.chunks[current_race_cursor_name]
        elseif current_race_cursor_name ~= '' and current_chunk_list.head_node_name ~= nil then
            position_node = current_chunk_list.chunks[current_race_cursor_name]
            --- Pick Next node until the end, then pick head and start again
            if position_node and position_node.next_node_name then
                race_cursor.current_node_name[current_direction] = position_node.next_node_name
            elseif position_node then
                race_cursor.current_node_name[current_direction] = current_chunk_list.head_node_name
            end
        end
        retry = retry + 1
    until position_node or retry == 5

    if position_node then
        position = {x = position_node.x, y = position_node.y}
        return position
    end

    return nil
end

local init_attackable_chunk = function(surface, forced_init)
    if global.attack_group_attackable_chunk[surface.name] == nil or forced_init then
        global.attack_group_attackable_chunk[surface.name] = get_chunk_node_list()
        global.attack_group_attackable_chunk[surface.name].current_node_name = ''
        global.attack_group_attackable_chunk[surface.name].current_direction = 1
    end
end

local is_cachable_attack_position = function(surface, area)
    local entities = surface.find_entities_filtered
    ({
        area = area,
        type = AttackGroupChunkProcessor.NORMAL_PRECISION_TARGET_TYPES,
        limit = 1
    })

    if #entities > 0 then
        return true
    end

    return false
end

local add_attackable_chunk = function(surface, chunk)
    local position = {
        x = chunk.x * AttackGroupChunkProcessor.CHUNK_SIZE,
        y = chunk.y * AttackGroupChunkProcessor.CHUNK_SIZE
    }
    local node_name = get_spawn_location_name(position.x, position.y)

    if global.attack_group_attackable_chunk[surface.name].chunks[node_name] == nil then
        append_chunk(global.attack_group_attackable_chunk[surface.name], position.x, position.y)
        return true
    end

    return false
end


function AttackGroupChunkProcessor.init_globals()
    global.attack_group_spawnable_chunk = global.attack_group_spawnable_chunk or {}
    global.attack_group_attackable_chunk = global.attack_group_attackable_chunk or {}
    global.attack_group_chunk_max_retry = 0
end

function AttackGroupChunkProcessor.init_index()
    game.print('[ERM] Re-indexing Attack Group Chunks...')
    local surface = game.surfaces[1]
    init_spawnable_chunk(surface, true)
    init_attackable_chunk(surface, true)
    local profiler = game.create_profiler()
    local i = 0
    local j = 0

    for chunk in surface.get_chunks() do
        if is_cachable_spawn_position(chunk) then
            if add_spawnable_chunk(surface, chunk) then
                i = i + 1
            end
        end

        if is_cachable_attack_position(surface, chunk.area) then
            if add_attackable_chunk(surface, chunk) then
                j = j + 1
            end
        end
    end

    profiler.stop()
    game.print('[ERM] Total Cached Spawnable Chunks: '..tostring(i))
    game.print('[ERM] Total Cached Attackable Chunks: '..tostring(j))
    game.print({'', '[ERM] Attack Group Chunk Re-indexed: ', profiler})
end

--- on_robot_built_entity and on_built_entity
--- https://lua-api.factorio.com/latest/events.html#on_built_entity
--- https://lua-api.factorio.com/latest/events.html#on_robot_built_entity
function AttackGroupChunkProcessor.add_attackable_chunk_by_entity(entity)
    local surface = entity.surface
    local position = entity.position
    position = {
        x = math.floor(position.x / AttackGroupChunkProcessor.CHUNK_SIZE),
        y = math.floor(position.y / AttackGroupChunkProcessor.CHUNK_SIZE)
    }
    init_attackable_chunk(surface)
    add_attackable_chunk(surface, position)
end

function AttackGroupChunkProcessor.add_spawnable_chunk(surface, position)
    if is_cachable_spawn_position(position) then
        init_spawnable_chunk(surface)
        add_spawnable_chunk(surface, position)
    end
end

function AttackGroupChunkProcessor.get_built_entity_event_filter()
    local filter = {}
    for _, type in pairs(AttackGroupChunkProcessor.NORMAL_PRECISION_TARGET_TYPES) do
        table.insert(filter, {filter = "type", type = type})
    end
    return filter
end

function AttackGroupChunkProcessor.pick_spawn_location(surface, force)
    local race_name = ErmForceHelper.extract_race_name_from(force.name)

    local position = find_spawn_position(surface, race_name)

    if position == nil then
        return nil
    end

    local cc_entities = surface.find_entities_filtered
    ({
        area = get_spawn_area(position),
        force = force,
        type = 'unit-spawner',
        limit = 10
    })

    local total_cc = #cc_entities;

    if total_cc == 0 then
        remove_chunk_without_spawner(surface, position, race_name)
        return nil
    end

    return cc_entities[math.random(1, #cc_entities)]
end

function AttackGroupChunkProcessor.pick_attack_location(surface)
    local position = find_attack_position(surface)
end

return AttackGroupChunkProcessor