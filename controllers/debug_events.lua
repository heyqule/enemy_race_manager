---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/5/2023 12:09 AM
---
local Event = require('__stdlib__/stdlib/event/event')

local max_min = {}
local max_min_by_tile = {}
local runs = 0;

local print_chunk_tile_details = function(event)
    local player = game.players[1]
    local surface = player.surface

    local tiles = {}
    for i = event.area.left_top.x, event.area.right_bottom.x do
        for j = event.area.left_top.y, event.area.right_bottom.y do
            table.insert(tiles, {x=i,y=j})
        end
    end

    local results = surface.calculate_tile_properties({
        'elevation',
        'temperature',
        'moisture',
        'aux',
        'enemy_base_probability'
    }, tiles)

    local tile_entity
    for index, tile in pairs(tiles) do
        tile_entity = surface.get_tile(tile.x, tile.y)
        for name, result in pairs(results) do
            if max_min[name] == nil then
                max_min[name] = {}
                max_min[name].min = result[index]
                max_min[name].max = result[index]
            end

            if(result[index] < max_min[name].min) then
                max_min[name].min = result[index]
            end

            if(result[index] > max_min[name].max) then
                max_min[name].max = result[index]
            end

            if max_min_by_tile[tile_entity.name] == nil then
                max_min_by_tile[tile_entity.name] = {}
            end

            if max_min_by_tile[tile_entity.name][name] == nil then
                max_min_by_tile[tile_entity.name][name] = {}
                max_min_by_tile[tile_entity.name][name].min = result[index]
                max_min_by_tile[tile_entity.name][name].max = result[index]
            end

            if(result[index] < max_min_by_tile[tile_entity.name][name].min) then
                max_min_by_tile[tile_entity.name][name].min = result[index]
            end

            if(result[index] > max_min_by_tile[tile_entity.name][name].max) then
                max_min_by_tile[tile_entity.name][name].max = result[index]
            end
        end
    end

    runs = runs + 1

    --if runs % 1000 == 0 then
    --    print('saving to disk...')
    --    table.sort(max_min_by_tile)
    --    game.write_file('enemyracemanager/erm-tiles-data.lua','tile = '..serpent.block(max_min_by_tile))
    --    game.write_file('enemyracemanager/erm-world-data.lua','world = '..serpent.block(max_min))
    --end
end

local print_chunk_player_details =  function (event)
    local player = game.players[1]
    local surface = player.surface
    local tile_pos = {x=player.position.x, y=player.position.y}
    local results = surface.calculate_tile_properties({
        'elevation',
        'temperature',
        'moisture',
        'aux',
        'enemy_base_probability'
    }, {tile_pos})

    local tile_entity = surface.get_tile(tile_pos.x, tile_pos.y)

    print(tile_entity.name .. ' -- ' .. tile_entity.position.x .. ' -- ' .. tile_entity.position.y)
    for name, result in pairs(results) do
        print('name: '..name..'/'..result[1])
    end
end

if DEBUG_MODE then
    --Event.register(defines.events.on_chunk_generated, function(event)
    --    print_chunk_tile_details(event)
    --end)

    --Event.on_nth_tick(61, function(event)
    --    print_chunk_player_details(event)
    --end)
end