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

function SurfaceProcessor.init_globals()
    if global.enemy_surfaces == nil then
        global.enemy_surfaces = {}
    end
end

function SurfaceProcessor.assign_race(surface, race_name)
    local races = ErmConfig.get_enemy_races()
    local max_num = Table.size(races)
    if max_num == 0 then
        return
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

    global.enemy_surfaces[surface.name] = race
end

function SurfaceProcessor.remove_race(surface)
    if global.enemy_surfaces[surface.name] ~= nil then
        global.enemy_surfaces[surface.name] = nil
    end
end

function SurfaceProcessor.rebuild_race()
    if global.enemy_surfaces == nil then
        return
    end

    for surface_index, race in pairs(global.enemy_surfaces) do
        if game.surfaces[surface_index] == nil or (race ~= MOD_NAME and game.active_mods[race] == nil) then
            SurfaceProcessor.remove_race(game.surfaces[surface_index])
        end
    end

    for _, surface in pairs(game.surfaces) do
        if global.enemy_surfaces[surface.name] == nil then
            SurfaceProcessor.assign_race(game.surfaces[surface.index])
        end
    end
end

function SurfaceProcessor.numeric_to_name_conversion()
    local tmpSurfaces = {}
    for surface_index, race in pairs(global.enemy_surfaces) do
        tmpSurfaces[game.surfaces[surface_index].name] = race
    end
    global.enemy_surfaces = tmpSurfaces
end

return SurfaceProcessor