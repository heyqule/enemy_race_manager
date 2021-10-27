---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 10/4/2021 12:09 AM
---
local ErmAttackGroupChunkProcessor = require('__enemyracemanager__/lib/attack_group_chunk_processor')
local ErmCron = require('__enemyracemanager__/lib/cron_processor')

local AttackGroupSurfaceProcessor = {}

AttackGroupSurfaceProcessor.CYCLE_THRESHOLD = 6

if DEBUG_MODE then
    AttackGroupSurfaceProcessor.CYCLE_THRESHOLD = 2
end


local init_race = function(race_name)
    if global.attack_group_surface_data[race_name] == nil then
        global.attack_group_surface_data[race_name] = {
            current_planet_pointer = nil,
            current_planet_name = nil,
            current_cycle = 0
        }
    end
end

AttackGroupSurfaceProcessor.init_globals = function()
    global.attack_group_surface_data = global.attack_group_surface_data or {}
end

AttackGroupSurfaceProcessor.exec = function(race_name, retry_cron)
    init_race(race_name)
    local start_position = 0
    local surface_data = global.attack_group_surface_data[race_name]
    local surface = nil
    if surface_data.current_planet_pointer ~= nil and
       surface_data.current_planet_pointer.valid
    then
        if  surface_data.current_cycle < AttackGroupSurfaceProcessor.CYCLE_THRESHOLD then
            surface_data.current_cycle = surface_data.current_cycle + 1
            return surface_data.current_planet_pointer
        else
            for index, _ in pairs(global.attack_group_spawnable_chunk) do
                if index == surface_data.current_planet_name then
                    start_position = game.surfaces[index].index
                    break 
                end
            end
        end
    end

    for index, _ in pairs(global.attack_group_spawnable_chunk) do
        surface = game.surfaces[index]
        if surface and surface.index > start_position and
            global.enemy_surfaces[surface.name] == race_name and
            ErmAttackGroupChunkProcessor.can_attack(surface)
        then
            surface_data.current_planet_pointer = surface
            surface_data.current_planet_name = surface.name
            surface_data.current_cycle = 1
            return surface
        end
    end

    if start_position ~= 0 then
        -- set all planet data to nil to restart from head
        surface_data.current_planet_pointer = nil
        surface_data.current_planet_name = nil
        surface_data.current_cycle = 0
    end

    return nil
end

return AttackGroupSurfaceProcessor