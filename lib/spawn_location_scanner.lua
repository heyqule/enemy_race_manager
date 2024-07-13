---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/6/2024 4:02 PM
---
--- Spawn location scanner, pick an area far from player entity.
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local UtilHelper = require('__enemyracemanager__/lib/helper/util_helper')

local SpawnLocationScanner = {}

local distance = 10 --chunks
local chunk_size = 32
local radius = distance * chunk_size
local angle_division = 15

local reference_unit_name = 'erm_vanilla/behemoth-biter/1'

local floor = math.floor
local rad = math.rad

local directions =
{
    [defines.direction.north] = {0, -1},
    [defines.direction.northeast] = {1, -1},
    [defines.direction.east] = {1, 0},
    [defines.direction.southeast] = {1, 1},
    [defines.direction.south] = {0, 1},
    [defines.direction.southwest] = {-1, 1},
    [defines.direction.west] = {-1, 0},
    [defines.direction.northwest] = {-1, -1},
}

--- 90 degree divisions
local directions_degrees = {
    [defines.direction.north] = {315, 45},
    [defines.direction.northeast] = {0, 90},
    [defines.direction.east] = {45, 135},
    [defines.direction.southeast] = {90, 180},
    [defines.direction.south] = {135, 225},
    [defines.direction.southwest] = {180, 270},
    [defines.direction.west] = {225, 315},
    [defines.direction.northwest] = {270, 360},
}

local init_surface_globals = function(surface_index)
    if global.spawn_locations_tracker[surface_index] == nil then
        global.spawn_locations_tracker[surface_index] = {
            direction = defines.direction.north,
            last_chunk_position = {
                [defines.direction.north] = {x=0,y=0}
            }
        }
        global.spawn_locations[surface_index] = {}
    end
end

local random_point_on_circumference = function (radius, angle_start, angle_end)
    local angle_start_rad = rad(angle_start)
    local angle_end_rad = rad(angle_end)

    if angle_end < angle_start then
        angle_end_rad = angle_end_rad + 2 * math.pi
    end

    local theta = angle_start_rad + math.random() * (angle_end_rad - angle_start_rad)

    return {x = radius * math.cos(theta), y = radius * math.sin(theta)}
end
---
--- for storing scanner chunks
---
function SpawnLocationScanner.init_globals()
    --- global.spawn_locations[surface_index] = {
    ---      [defines.direction.north] = {
    ---         trunk = {x,y} //trunk position
    ---         updated = tick //tick this was updated
    ---         can_spawn = true //whether things can spawn on this trunk
    ---      }
    --- }
    global.spawn_locations = global.spawn_locations or {}
    --- global.spawn_locations_tracker[surface_index] = {
    ---    direction = defines.direction.north,
    ---    last_chunk_position = {
    ---        [defines.direction.north] = {x,y}
    ---    }
    --- }
    global.spawn_locations_tracker = global.spawn_locations_tracker or {}
end

local is_larger_than_planet_radius = function(position, max_planet_radius)
    if max_planet_radius == nil then
        return false
    end

    return (position.x >= max_planet_radius or
            position.y >= max_planet_radius or
            position.x <= max_planet_radius * -1 or
            position.y <= max_planet_radius * -1
    )
end

--- Each call goes from north, clockwise, with 8 directions.  It would requires 8 calls to complete a cycle
function SpawnLocationScanner.scan(surface, max_planet_radius)
    if not surface then
        return
    end
    local spawn_profiler = game.create_profiler()
    max_planet_radius = max_planet_radius or nil
    local surface_index = surface.index

    init_surface_globals(surface_index)

    -- pick a chunk
    local current_direction = global.spawn_locations_tracker[surface_index].direction or  1

    if global.spawn_locations[surface_index][current_direction] and
       next(global.spawn_locations[surface_index][current_direction])
    then
        --- assign cache position is still valid.
        global.spawn_locations_tracker[surface_index].direction = (current_direction + 1) % 8
        return
    end

    local direction_multipler = directions[current_direction]
    local chunk_position = global.spawn_locations_tracker[surface_index].last_chunk_position[current_direction] or {x=0,y=0}

    local new_chunk = {
        x = chunk_position.x + direction_multipler[1] * distance,
        y = chunk_position.y + direction_multipler[2] * distance
    }

    local tile_position = UtilHelper.from_chunk_position(new_chunk)
    local has_valid_chunk = false
    local using_max_radius = false

    local new_chunk_is_generated = surface.is_chunk_generated(new_chunk)
    if is_larger_than_planet_radius(tile_position, max_planet_radius) == false and
       new_chunk_is_generated and
       SpawnLocationScanner.is_valid_position(surface, tile_position)
    then
        global.spawn_locations[surface_index][current_direction] = tile_position
        has_valid_chunk = true
    end

    -- try a location near the edge
    if has_valid_chunk == false and
       max_planet_radius and
       is_larger_than_planet_radius(tile_position, max_planet_radius)
    then
        local directions_degree = directions_degrees[current_direction]
        local i = 0
        local r = 5

        local valid_position = false
        local cir_tile_position = {0, 0}
        repeat
            local start_deg = directions_degree[1] + angle_division * i % 360
            local end_deg = directions_degree[2] - angle_division * r % 360
            cir_tile_position = random_point_on_circumference(max_planet_radius - chunk_size, start_deg, end_deg)
            cir_tile_position.x = floor(cir_tile_position.x)
            cir_tile_position.y = floor(cir_tile_position.y)
            if surface.is_chunk_generated(UtilHelper.to_chunk_position(cir_tile_position)) then
                valid_position = SpawnLocationScanner.is_valid_position(surface, cir_tile_position)
            end
            i = i + 1
            r = r - 1
        until i == 6 or valid_position == true

        if valid_position then
            global.spawn_locations[surface_index][current_direction] = {x=cir_tile_position.x,y=cir_tile_position.y}
            has_valid_chunk = true
        end
        using_max_radius = true
    end

    local tracker_data = global.spawn_locations_tracker[surface_index]

    --- only track new trunk when it's not hitting the border, and the trunk is generated
    if not using_max_radius and new_chunk_is_generated then
        tracker_data.last_chunk_position[current_direction] = new_chunk
    elseif using_max_radius then
        --- restart scan from 320 tile, when using max_radius
        tracker_data.last_chunk_position[current_direction] = {
            x = direction_multipler[1] * distance,
            y = direction_multipler[2] * distance
        }
    end

    --- Change direction
    tracker_data.direction = (current_direction + 1) % 8

    spawn_profiler.stop()
    log({ '', 'SpawnLocationScanner.scan: '..surface.name..' ', spawn_profiler })
end

function SpawnLocationScanner.is_valid_position(surface, tile_position)
    local entities = surface.find_entities_filtered {
        force = ForceHelper.get_player_forces(),
        radius = radius,
        position = tile_position,
        limit = 1
    }

    if next(entities) then
        return false
    end

    local position = surface.find_non_colliding_position(reference_unit_name, tile_position, radius, 8)

    if position then
        return true
    end

    return false
end

function SpawnLocationScanner.get_spawn_location(surface)
    if not surface then
        return
    end

    local surface_index = surface.index
    local spawn_data = global.spawn_locations[surface_index]
    local spawn_tracker = global.spawn_locations_tracker[surface_index]

    if not spawn_data then
        return
    end

    local direction = 1
    if spawn_tracker and spawn_tracker.last_attack_direction then
        direction = spawn_tracker.last_attack_direction or 1
    end

    local stop = false
    local position
    local i = 0
    repeat
        position = spawn_data[direction]
        if position and SpawnLocationScanner.is_valid_position(surface,position) then
            stop = true
        elseif position then
            -- invalid old node
            global.spawn_locations[surface_index][direction] = nil
        end
        i = i + 1
    until stop == true or i == 7
    direction = (direction + 1) % 8
    spawn_tracker.last_attack_direction = direction
    return position
end

function SpawnLocationScanner.remove_surface(surface_id)
    global.spawn_locations[surface_id] = nil
    global.spawn_locations_tracker[surface_id] = nil
end


return SpawnLocationScanner