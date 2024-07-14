---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/4/2024 12:25 AM
---
if not script.active_mods['space-exploration'] then
    return
end

local Event = require('__stdlib__/stdlib/event/event')
local Config = require('__enemyracemanager__/lib/global_config')
local UniverseRaw = require("__space-exploration__/scripts/universe-raw")
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local SurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local InterplanetaryAttacks = require('__enemyracemanager__/lib/interplanetary_attacks')

--- Pull from SE once every hour
local cache_time = defines.time.hour

local add_exclusion_surfaces = function(event)
    for _, node in pairs(UniverseRaw.universe.space_zones) do
        ForceHelper.add_surface_to_exclusion_list(node.name)
    end
    ForceHelper.add_surface_to_exclusion_list(UniverseRaw.universe.anomaly.name)
end

local update_attackable_zone_data = function(surface_name)
    local surface_profiler = game.create_profiler()
    local surface = game.surfaces[surface_name]
    local zone_data = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface.index})
    if surface and zone_data then
        local data = {}
        data.radius = math.floor(zone_data.radius)
        data.type = zone_data.type

        if zone_data.inhabited_chunks and next(zone_data.inhabited_chunks) then
            data.has_player_entities = true
        end

        local defense = 0

        if zone_data.meteor_defences then
            defense = table_size(zone_data.meteor_defences) * 2
        end

        if zone_data.meteor_point_defences then
            defense = defense + table_size(zone_data.meteor_point_defences)
        end

        if defense == 0 then
            data.defense = data.defense or 0
        elseif data.defense == nil then
            data.defense = defense
        else
            data.defense = data.defense + defense
        end

        data.updated = game.tick
        InterplanetaryAttacks.set_intel(surface.index, data)
    end
    surface_profiler.stop()
    log({ '', 'CTRL.COMP.SE.update_attackable_zone_data: '..surface_name, surface_profiler })
end

Event.register(Event.generate_event_name(Config.EVENT_FLUSH_GLOBAL), function(event)
    add_exclusion_surfaces(event)

    for surface_name, _ in pairs(SurfaceProcessor.get_attackable_surfaces()) do
        update_attackable_zone_data(surface_name)
    end
end)

Event.register(Event.generate_event_name(Config.EVENT_INTERPLANETARY_ATTACK_SCAN), function(event)
    local surface = event.surface
    local intel = event.intel
    if surface and intel and
            tonumber(intel.updated) + cache_time < event.tick
    then
        update_attackable_zone_data(surface.name)
        intel.updated = event.tick
    end
end)

