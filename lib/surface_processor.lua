---
--- Created by heyqule.
--- DateTime: 03/27/2021 3:16 PM
--- require('__enemyracemanager__/lib/global_config')
---

local Table = require('__stdlib__/stdlib/utils/table')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmMapProcessor = require('__enemyracemanager__/lib/map_processor')

local SurfaceProcessor = {}

function SurfaceProcessor.assign_race(surface_index, race_name)
    local races = ErmConfig.get_enemy_races()
    local max_num = Table.size(races)
    if max_num == 0 then
        return
    end

    if global.enemy_surfaces == nil then
        global.enemy_surfaces = {}
    end

    local race = nil
    if race_name then
        for k, v in pairs(races) do
            if v == race_name then
                race = v
                break
            end
        end
    else
        race = races[math.random(1, max_num)]
    end

    global.enemy_surfaces[surface_index] = race
end

function SurfaceProcessor.remove_race(surface_index)
    if global.enemy_surfaces[surface_index] ~= nil then
        Table.remove(global.enemy_surfaces, surface_index)
    end
end

function SurfaceProcessor.rebuild_race()
    if global.enemy_surfaces == nil then
        return
    end

    for surface_index, race in pairs(global.enemy_surfaces) do
        if game.surfaces[surface_index] == nil or (race ~= MOD_NAME and game.active_mods[race] == nil) then
            SurfaceProcessor.remove_race(surface_index)
        end
    end

    for surface_index, surface in pairs(game.surfaces) do
        if global.enemy_surfaces[surface.index] == nil then
            SurfaceProcessor.assign_race(surface.index)
        end
    end
end

return SurfaceProcessor