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

function SurfaceProcessor.assign_race(surface_index)
    local max_num = Table.size(ErmConfig.get_enemy_races())
    if max_num == 0 then
        return
    end

    local races = ErmConfig.get_enemy_races()
    global.enemy_surfaces[surface_index] = races[math.random(1, max_num)]
    ErmDebugHelper.print("[SurfaceProcessor] Assigned to: "..global.enemy_surfaces[surface_index])
end

function SurfaceProcessor.remove_race(surface_index)
    ErmDebugHelper.print('[SurfaceProcessor] Removing...')
    if global.enemy_surfaces[surface_index] ~= nil then
        ErmDebugHelper.print('[SurfaceProcessor] Removed...')
        Table.remove(global.enemy_surfaces, surface_index)
    end
end

function SurfaceProcessor.rebuild_race()
    for surface_index, race in pairs(global.enemy_surfaces) do
        ErmDebugHelper.print("[SurfaceProcessor] Checking for removal "..tostring(game.surfaces[surface_index].name))
        ErmDebugHelper.print("[SurfaceProcessor] Active? "..race..'/'..tostring(game.active_mods[race]))
        if game.surfaces[surface_index] == nil or (race ~= MOD_NAME and game.active_mods[race] == nil) then
            SurfaceProcessor.remove_race(surface_index)
        end
    end

    for surface_index, surface in pairs(game.surfaces) do
        ErmDebugHelper.print("[SurfaceProcessor] Checking for assignment "..surface.name)
        if global.enemy_surfaces[surface.index] == nil then
            SurfaceProcessor.assign_race(surface.index)
        end
    end
end

return SurfaceProcessor