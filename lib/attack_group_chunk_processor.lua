---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 9/6/2021 1:34 AM
---
local Table = require('__stdlib__/stdlib/utils/table')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')

local AttackGroupChunkProcessor = {}

AttackGroupChunkProcessor.CHUNK_SEARCH_RADIUS = 5
AttackGroupChunkProcessor.CHUNK_SIZE = 32
AttackGroupChunkProcessor.CHUNK_CENTER_POINT_RADIUS = AttackGroupChunkProcessor.CHUNK_SEARCH_RADIUS * 2
AttackGroupChunkProcessor.CHUNK_SEARCH_AREA = AttackGroupChunkProcessor.CHUNK_SEARCH_RADIUS * AttackGroupChunkProcessor.CHUNK_SIZE

AttackGroupChunkProcessor.MINIMUM_SPAWNABLE = 10

AttackGroupChunkProcessor.RETRY = 4

AttackGroupChunkProcessor.AREA_NORTH = {1,2}
AttackGroupChunkProcessor.AREA_SOUTH = {3,4}

AttackGroupChunkProcessor.AREA_WEST = {1,4}
AttackGroupChunkProcessor.AREA_EAST = {2,3}
AttackGroupChunkProcessor.AREA_ALL = {1, 2, 3, 4}

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
        rotatable_directions = AttackGroupChunkProcessor.AREA_ALL,
        current_node_name = {
            northwest = nil,
            northeast = nil,
            southeast = nil,
            southwest = nil,
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

local get_attack_area = function(position)
    local distance = 32
    local area = {
        {position.x, position.y},
        {position.x + distance, position.y + distance}
    }
    return area
end

local insert_rotatable_directions = function(race_cursor, directions) 
    for key, direction in pairs(directions) do
        table.insert(race_cursor.rotatable_directions, direction)
    end        
end

local set_up_rotatable_direction = function(race_cursor, race_name, surface)
    if ErmConfig.mapgen_is_2_races_split() then
        race_cursor.rotatable_directions = {}
        if ErmConfig.positive_axis_race() == ErmConfig.negative_axis_race() and ErmConfig.positive_axis_race() == race_name then
            race_cursor.rotatable_directions = AttackGroupChunkProcessor.AREA_ALL
        elseif settings.startup['enemyracemanager-2way-group-enemy-orientation'].value == X_AXIS then
            if ErmConfig.positive_axis_race() == race_name then
                insert_rotatable_directions(race_cursor, AttackGroupChunkProcessor.AREA_EAST)
            elseif ErmConfig.negative_axis_race() == race_name then
                insert_rotatable_directions(race_cursor, AttackGroupChunkProcessor.AREA_WEST)
            end
        else
            if ErmConfig.positive_axis_race() == race_name then
                insert_rotatable_directions(race_cursor, AttackGroupChunkProcessor.AREA_SOUTH)
            elseif ErmConfig.negative_axis_race() == race_name then
                insert_rotatable_directions(race_cursor, AttackGroupChunkProcessor.AREA_NORTH)
            end
        end   
    elseif ErmConfig.mapgen_is_4_races_split() then
        race_cursor.rotatable_directions = {}
        local directions = {
            ErmConfig.top_left_race(),
            ErmConfig.top_right_race(),
            ErmConfig.bottom_right_race(),
            ErmConfig.bottom_left_race()
        }

        for key, race in pairs(directions) do
            if race_name == race then
                table.insert(race_cursor.rotatable_directions, key)
            end
        end
    end
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
            set_up_rotatable_direction(global.attack_group_spawnable_chunk[surface.name].race_cursors[race], race, surface)
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

local get_location_name = function(x, y)
    return tostring(x)..'/'..tostring(y)
end

local append_chunk = function(chunk_data, x, y)
    local node_name = get_location_name(x,y)
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

local remove_chunk_from_list = function(chunk_set, node, node_name)
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
            get_location_name(next_node.x, next_node.y)
        end
        if next_node then
            chunk_set.chunks[next_node_name].prev_node_name =
            get_location_name(prev_node.x, prev_node.y)
        end
    end
    chunk_set.chunks[node_name] = nil

    local new_node_length = Table.count_keys(chunk_set.chunks)

    if new_node_length == 0 then
        chunk_set.head_node_name = nil
        chunk_set.new_node_name = nil
    end
end

----- Start Spawnable Chunk Private Functions -----

---
--- Remove chunk that is no longer have spawner on it.  But it preserve at least 5 blocks to track enemy expansions.
---
local remove_spawnable_chunk = function(surface, direction, position)
    local chunk_set = global.attack_group_spawnable_chunk[surface.name][direction]
    local node_name = get_location_name(position.x, position.y)

    local node_length = Table.count_keys(chunk_set.chunks)

    local node = chunk_set.chunks[node_name]
    if node == nil and node_length < AttackGroupChunkProcessor.MINIMUM_SPAWNABLE then
        return
    end

    remove_chunk_from_list(chunk_set, node, node_name)
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
    local surface_data = global.attack_group_spawnable_chunk[surface.name]
    if surface_data == nil then
        return nil
    end

    local race_cursor = surface_data.race_cursors[race_name]
    local total_rotatable_directions = #race_cursor.rotatable_directions

    if total_rotatable_directions == 0 then
        return nil
    end

    --- Swap spawn direction
    local rotatable_direction = race_cursor.current_direction % total_rotatable_directions + 1
    race_cursor.current_direction = rotatable_direction
    local current_direction = AttackGroupChunkProcessor.DIRECTION_CURSOR[
        race_cursor.rotatable_directions[race_cursor.current_direction]
    ]

    local current_chunk_list = surface_data[current_direction]
    local current_race_cursor_name = race_cursor.current_node_name[current_direction]
    if current_race_cursor_name == nil and current_chunk_list.head_node_name ~= nil then
        --- Pick head node
        race_cursor.current_node_name[current_direction] = current_chunk_list.head_node_name
        position_node = current_chunk_list.chunks[current_chunk_list.head_node_name]
    elseif current_race_cursor_name ~= '' and current_chunk_list.head_node_name ~= nil then
        position_node = current_chunk_list.chunks[current_race_cursor_name]
        --- Pick Next node until the end, then pick head and start again
        if position_node and position_node.next_node_name then
            race_cursor.current_node_name[current_direction] = position_node.next_node_name
        elseif position_node then
            race_cursor.current_node_name[current_direction] = current_chunk_list.head_node_name
        end
    end

    if position_node then
        position = {x = position_node.x, y = position_node.y}
        return position
    end

    return nil
end

----- End Spawnable Chunk Private Functions -----

----- Start Attackable Chunk Private Functions -----
local init_attackable_chunk = function(surface, forced_init)
    if global.attack_group_attackable_chunk[surface.name] == nil or forced_init then
        global.attack_group_attackable_chunk[surface.name] = get_chunk_node_list()
        global.attack_group_attackable_chunk[surface.name].current_node_name = nil
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

    if #entities ~= 0 then
        return true
    end

    return false
end

local add_attackable_chunk = function(surface, chunk)
    local position = {
        x = chunk.x * AttackGroupChunkProcessor.CHUNK_SIZE,
        y = chunk.y * AttackGroupChunkProcessor.CHUNK_SIZE
    }
    local node_name = get_location_name(position.x, position.y)

    if global.attack_group_attackable_chunk[surface.name].chunks[node_name] == nil then
        append_chunk(global.attack_group_attackable_chunk[surface.name], position.x, position.y)
        return true
    end

    return false
end

local find_attack_position = function(surface)
    local surface_data = global.attack_group_attackable_chunk[surface.name]
    if surface_data == nil then
        return nil
    end

    if surface_data.current_node_name == nil and surface_data.head_node_name then
        surface_data.current_node_name = surface_data.head_node_name

        return surface_data.chunks[surface_data.current_node_name]
    end

    if surface_data.current_node_name ~= nil then
        surface_data.current_node_name = surface_data.chunks[surface_data.current_node_name].next_node_name

        if surface_data.current_node_name == nil then
            surface_data.current_node_name = surface_data.head_node_name
        end

        return surface_data.chunks[surface_data.current_node_name]
    end

    return nil
end

local reindex_surface = function(surface)
    init_spawnable_chunk(surface, true)
    init_attackable_chunk(surface, true)
    local spawn_chunk = 0
    local attack_chunk = 0

    for chunk in surface.get_chunks() do
        if is_cachable_spawn_position(chunk) then
            if add_spawnable_chunk(surface, chunk) then
                spawn_chunk = spawn_chunk + 1
            end
        end

        if is_cachable_attack_position(surface, chunk.area) then
            if add_attackable_chunk(surface, chunk) then
                attack_chunk = attack_chunk + 1
            end
        end
    end

    if spawn_chunk == 0 then
        global.attack_group_spawnable_chunk[surface.name] = nil
        spawn_chunk = 0
    end

    if attack_chunk == 0 then
        global.attack_group_attackable_chunk[surface.name] = nil
        attack_chunk = 0
    end

    return spawn_chunk, attack_chunk
end
----- End Attackable Chunk Private Functions -----

function AttackGroupChunkProcessor.init_globals()
    global.attack_group_spawnable_chunk = global.attack_group_spawnable_chunk or {}
    global.attack_group_attackable_chunk = global.attack_group_attackable_chunk or {}
end

function AttackGroupChunkProcessor.init_index()
    game.print('[ERM] Re-indexing Attack Group Chunks...')
    local profiler = game.create_profiler()
    local spawn_chunk = 0
    local attack_chunk = 0
    local total_surfaces = 0
    for _, surface in pairs(game.surfaces) do
       if surface.valid then
           current_spawn_chunk, current_attack_chunk =  reindex_surface(surface)
           spawn_chunk = spawn_chunk + current_spawn_chunk
           attack_chunk = attack_chunk + current_attack_chunk
           total_surfaces = total_surfaces + 1
       end
    end

    profiler.stop()
    game.print('[ERM] Total Processed Surfaces: '..tostring(total_surfaces))
    game.print('[ERM] Total Cached Spawnable Chunks: '..tostring(spawn_chunk))
    game.print('[ERM] Total Cached Attackable Chunks: '..tostring(attack_chunk))
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

    local i = 0
    local entities = {}

    repeat
        local position = find_spawn_position(surface, race_name)
        if position then
            entities = surface.find_entities_filtered
                ({
                    area = get_spawn_area(position),
                    force = force,
                    type = 'unit-spawner',
                    limit = 10
                })
        end

        if position and next(entities) == nil then
            remove_chunk_without_spawner(surface, position, race_name)
        end
        i = i + 1
    until i == AttackGroupChunkProcessor.RETRY or next(entities) ~= nil
    if next(entities) == nil then
        return nil
    end
    local entity = entities[math.random(1, #entities)]
    return entity
end

function AttackGroupChunkProcessor.pick_attack_location(surface, group)
    local position_node = nil
    local retry = 0
    repeat
        local entities = nil
        position_node = find_attack_position(surface)
        if position_node then
            entities = surface.find_entities_filtered
            ({
                area = get_attack_area(position_node),
                type = AttackGroupChunkProcessor.NORMAL_PRECISION_TARGET_TYPES,
                limit = 1
            })
        end

        if position_node and next(entities) == nil then
            local surface_data = global.attack_group_attackable_chunk[surface.name]
            remove_chunk_from_list(surface_data, position_node, get_location_name(position_node.x, position_node.y))
            surface_data.current_node_name = nil
            position_node = nil
        end

        retry = retry + 1
    until position_node ~= nil or retry == AttackGroupChunkProcessor.RETRY

    if position_node then
        return {x = position_node.x, y = position_node.y}
    end

    return nil
end

AttackGroupChunkProcessor.can_attack = function(surface)
    if global.attack_group_spawnable_chunk[surface.name] ~= nil and global.attack_group_attackable_chunk[surface.name] ~= nil then
        return true
    end
    return false
end

AttackGroupChunkProcessor.remove_surface = function(surface_name)
    if global.attack_group_spawnable_chunk[surface_name] ~= nil then
        global.attack_group_spawnable_chunk[surface_name] = nil
    end

    if global.attack_group_attackable_chunk[surface_name] ~= nil then
        global.attack_group_attackable_chunk[surface_name] = nil
    end
end

return AttackGroupChunkProcessor