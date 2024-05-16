---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/5/2024 9:03 PM
---
local Position = require('__stdlib__/stdlib/area/position')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local RaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local Cron = require('__enemyracemanager__/lib/cron_processor')
local DebugHelper =  require('__enemyracemanager__/lib/debug_helper')

local can_spawn = RaceSettingsHelper.can_spawn

local AttackGroupPathingProcessor = {}

local BEACON_RADIUS = 64
local CHUNK_SIZE = 32
local TRANSLATE_RANGE = CHUNK_SIZE * 10
local GC_TICK = 24000

--- lowest defense beacon score
AttackGroupPathingProcessor.STRATEGY_BF = 1
--- left side
AttackGroupPathingProcessor.STRATEGY_LT = 2
--- right side
AttackGroupPathingProcessor.STRATEGY_RT = 3

--- {strategy_id, spawn_chance}
AttackGroupPathingProcessor.CUSTOM_STRATEGIES = {
    {AttackGroupPathingProcessor.STRATEGY_LT, 20},
    {AttackGroupPathingProcessor.STRATEGY_RT, 20}
}

-- Lowest health first
local function get_sorted_beacons(entities)
    table.sort(entities, function(a, b)
        return a.health < b.health
    end)

    return entities
end

local function get_command_chain()
    return {
        type = defines.command.compound,
        structure_type = defines.compound_command.return_last,
        commands = {}
    }
end

local BUFFER_MULTIPLIER = 2
local compute_beacon_buffer_position = {
    [defines.direction.north] = function(x, y)
        return {x=x,y=y + CHUNK_SIZE * BUFFER_MULTIPLIER}
    end,
    [defines.direction.east] = function(x, y)
        return {x=x - CHUNK_SIZE * BUFFER_MULTIPLIER,y=y}
    end,
    [defines.direction.south] = function(x, y)
        return {x=x, y=y - CHUNK_SIZE * BUFFER_MULTIPLIER}
    end,
    [defines.direction.west] = function(x, y)
        return {x=x + CHUNK_SIZE * BUFFER_MULTIPLIER, y=y}
    end,
}



function AttackGroupPathingProcessor.init_globals()
    global.request_path = global.request_path or {}
    global.request_path_link = global.request_path_link or {}
end

function AttackGroupPathingProcessor.reset_globals()
    global.request_path = {}
    global.request_path_link = {}
end

function AttackGroupPathingProcessor.request_path(surface, source_force, start, goal, is_aerial)

    local bounding_box, collision_mask
    local race_name = ForceHelper.extract_race_name_from(source_force.name)
    collision_mask = {"not-colliding-with-itself"}

    if is_aerial then
        local scout_unit = game.entity_prototypes[race_name..AttackGroupBeaconProcessor.AERIAL_SCOUT]
        bounding_box = scout_unit.collision_box
    else
        local scout_unit = game.entity_prototypes[race_name..AttackGroupBeaconProcessor.LAND_SCOUT]
        bounding_box = scout_unit.collision_box
    end

    local request_id = surface.request_path({
        bounding_box = bounding_box,
        collision_mask = collision_mask,
        start = start,
        goal = goal,
        force = source_force,
        path_resolution_modifier = -6 ---64 tiles resolution
    })

    if request_id then
        if global.request_path_link[surface.index] == nil then
            global.request_path_link[surface.index] = {}
        end

        AttackGroupPathingProcessor.remove_node(surface.index,start,goal)

        global.request_path[request_id] = {
            surface = surface,
            source_force = source_force,
            start = start,
            goal = goal,
            is_aerial = is_aerial,
            tick = game.tick,
            commands = {}
        }


        global.request_path_link[surface.index][Position.to_key(start)..Position.to_key(goal)] = request_id
    end
end

--- How does this work?
--- Once request path is valid, pick the closest beacon in the path.
--- If it's flier group, flier beacons get priority
--- Try alt path A using that beacon, save to cache,
--- Try alt path B using that beacon, save to cache,
--- Then try using beacon with lower health.
--- Once all options have tried and failed, unleash additional strategies or repeat existing strategies :)
function AttackGroupPathingProcessor.on_script_path_request_finished(path_id, path_nodes, tryagainlater)
    if global.request_path[path_id] == nil or path_nodes == nil then
        return nil
    end

    local request_path_data = global.request_path[path_id];

    if path_nodes then

        local source_force = request_path_data.source_force
        local surface = request_path_data.surface
        for key, path_node in pairs(path_nodes) do

            local search_beacons = {AttackGroupBeaconProcessor.LAND_BEACON, AttackGroupBeaconProcessor.AERIAL_BEACON}
            local beacons = surface.find_entities_filtered {
                name = search_beacons,
                force = source_force,
                radius = BEACON_RADIUS,
                position = path_node.position,
                limit = 1
            }
            if next(beacons) then

                local enemy = surface.find_nearest_enemy({
                    position = beacons[1].position,
                    max_distance = BEACON_RADIUS,
                    force = source_force
                })

                if enemy then
                    Cron.add_quick_queue('AttackGroupPathingProcessor.construct_brutal_force_commands',
                            path_id, beacons[1], enemy.position, search_beacons)

                    Cron.add_quick_queue('AttackGroupPathingProcessor.construct_side_attack_commands',
                            path_id, path_node, enemy.position, search_beacons)

                    Cron.add_quick_queue('AttackGroupPathingProcessor.construct_side_attack_commands',
                            path_id, path_node, enemy.position, search_beacons, true)
                end
                break
            end
        end

    end
end

--- Brutal Force attack using defense beacon data
function AttackGroupPathingProcessor.construct_brutal_force_commands(
        path_id, path_node, enemy_position, search_beacons
)

    local profiler = game.create_profiler()

    local request_path_data = global.request_path[path_id]

    local direction = Position.complex_direction_to(path_node.position, enemy_position)

    local left_top = {}
    local bottom_right = {}

    if direction == defines.direction.west or
        direction ==  defines.direction.east then
        left_top = {path_node.position.x - CHUNK_SIZE, path_node.position.y - TRANSLATE_RANGE}
        bottom_right = {path_node.position.x + CHUNK_SIZE, path_node.position.y + TRANSLATE_RANGE}
    else
        left_top = {path_node.position.x  - TRANSLATE_RANGE, path_node.position.y - CHUNK_SIZE}
        bottom_right = {path_node.position.x + TRANSLATE_RANGE, path_node.position.y + CHUNK_SIZE}
    end

    local beacons = request_path_data.surface.find_entities_filtered {
        name = search_beacons,
        force = request_path_data.source_force,
        area = {left_top, bottom_right}
    }

    if table_size(beacons) > 1 then
        beacons = get_sorted_beacons(beacons)
    end

    local scout_beacon = beacons[1]
    local buffer_zone = compute_beacon_buffer_position[direction](scout_beacon.position.x,scout_beacon.position.y)

    if scout_beacon then
        local commands_chain = get_command_chain()
        table.insert(commands_chain.commands, {
            type = defines.command.go_to_location,
            destination = buffer_zone,
            radius = CHUNK_SIZE
        })

        table.insert(commands_chain.commands, {
            type = defines.command.attack_area,
            destination = request_path_data.goal,
            radius = CHUNK_SIZE;
        })

        global.request_path[path_id].commands[AttackGroupPathingProcessor.STRATEGY_BF] = commands_chain
    end

    profiler.stop()
    log{"",'[ERM] AttackGroupPathingProcessor.construct_brutal_force_commands', profiler}
end

--- Side attacks to avoid defense
function AttackGroupPathingProcessor.construct_side_attack_commands(
    path_id, path_node, enemy_position, search_beacons, is_right_side
)
    local profiler = game.create_profiler()

    is_right_side = is_right_side or false

    local request_path_data = global.request_path[path_id]

    local direction = Position.complex_direction_to(path_node.position, enemy_position)


    local target_direction = math.abs(direction - 10 % 8)
    local side_key = AttackGroupPathingProcessor.STRATEGY_LT
    if is_right_side then
        target_direction = math.abs(direction + 10 % 8)
        side_key = AttackGroupPathingProcessor.STRATEGY_RT
    end
    local new_position = Position.translate(
            path_node.position,
            target_direction,
            math.random(TRANSLATE_RANGE-CHUNK_SIZE, TRANSLATE_RANGE+CHUNK_SIZE)
    )

    local area = request_path_data.surface.find_entities_filtered {
        name = search_beacons,
        force = request_path_data.source_force,
        radius = BEACON_RADIUS,
        position = {new_position.x, new_position.y},
        limit = 1
    }
    local area_size = table_size(area)


    if area_size == 0 then
        local commands_chain = get_command_chain()

        table.insert(commands_chain.commands, {
            type = defines.command.go_to_location,
            destination = {new_position.x, new_position.y},
            radius = CHUNK_SIZE
        })

        table.insert(commands_chain.commands, {
            type = defines.command.attack_area,
            destination = request_path_data.goal,
            radius = CHUNK_SIZE;
        })

        global.request_path[path_id].commands[side_key] = commands_chain
    end

    profiler.stop()
    log{"",'[ERM] AttackGroupPathingProcessor.construct_side_attack_commands', profiler}
end

local can_reroll = function(strategy, chance)
    return strategy == AttackGroupPathingProcessor.STRATEGY_BF and can_spawn(chance)
end

--- Get command based on coordinate and strategy
function AttackGroupPathingProcessor.get_command(surface_id, start, goal, strategy)
    if global.request_path_link[surface_id] == nil then
        return nil
    end

    strategy = strategy or AttackGroupPathingProcessor.STRATEGY_BF

    if global.override_attack_strategy then
        strategy = global.override_attack_strategy
        global.override_attack_strategy = nil
    else
        for _, data in pairs(AttackGroupPathingProcessor.CUSTOM_STRATEGIES) do
            if can_reroll(strategy, data[2]) then
                strategy = data[1]
                break
            end
        end
    end

    local request_id = global.request_path_link[surface_id][Position.to_key(start)..Position.to_key(goal)]

    if request_id then
        local request_path_data = global.request_path[request_id]
        if request_path_data and
           request_path_data.commands[strategy]
        then
            local rc_command = request_path_data.commands[strategy]
            AttackGroupPathingProcessor.remove_node(surface_id, start,goal)

            return rc_command
        end
    end

    return nil
end

--- Remove node based on coorindate
function AttackGroupPathingProcessor.remove_node(surface_id, start,goal)
    if global.request_path_link[surface_id] == nil then
        return
    end

    local request_id = global.request_path_link[surface_id][Position.to_key(start)..Position.to_key(goal)]

    if request_id then
        global.request_path[request_id] = nil
        global.request_path_link[surface_id][Position.to_key(start)..Position.to_key(goal)] = nil
    end
end

function AttackGroupPathingProcessor.remove_all_nodes(surface_id)
    if global.request_path_link[surface_id] == nil then
        return
    end

    for id, _ in pairs(global.request_path_link[surface_id]) do
        local request_id = global.request_path_link[surface_id][id]
        global.request_path[request_id] = nil
        global.request_path_link[surface_id][id] = nil
    end
end


function AttackGroupPathingProcessor.remove_old_nodes()
    for surface_id, _ in pairs(global.request_path_link) do
        for id, _ in pairs(global.request_path_link[surface_id]) do
            local request_id = global.request_path_link[surface_id][id]
            if request_id and
                game.tick > global.request_path[request_id].tick + GC_TICK
            then
                global.request_path[request_id] = nil
                global.request_path_link[surface_id][id] = nil
            end
        end
    end
end


return AttackGroupPathingProcessor