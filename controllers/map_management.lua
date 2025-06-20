---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 10:29 PM
---
require("__enemyracemanager__/global")

local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local SurfaceProcessor = require("__enemyracemanager__/lib/surface_processor")
local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local AttackGroupHeatProcessor = require("__enemyracemanager__/lib/attack_group_heat_processor")
local InterplanetaryAttacks = require("__enemyracemanager__/lib/interplanetary_attacks")
local SpawnLocationScanner = require("__enemyracemanager__/lib/spawn_location_scanner")
local QualityProcessor = require("__enemyracemanager__/lib/quality_processor")

local MapManagement = {}

local cache_time = 10 * minute

MapManagement.events = {
    [defines.events.on_chunk_generated] = function(event)
        AttackGroupBeaconProcessor.create_spawn_beacon_from_trunk(event.surface, event.area)
        AttackGroupBeaconProcessor.create_resource_beacon_from_trunk(event.surface, event.area)
    end,
    [defines.events.on_surface_created] = function(event)
        SurfaceProcessor.assign_race(game.surfaces[event.surface_index])
        AttackGroupBeaconProcessor.init_globals_on_surface(game.surfaces[event.surface_index])
        QualityProcessor.calculate_quality_points()
        InterplanetaryAttacks.determine_planet_details(event.surface_index)
    end,
    [defines.events.on_pre_surface_deleted] = function(event)
        SurfaceProcessor.remove_race(game.surfaces[event.surface_index])
        AttackGroupBeaconProcessor.remove_beacons_on_surface(event.surface_index)
        AttackGroupHeatProcessor.remove_surface(event.surface_index)
        AttackGroupHeatProcessor.remove_surface(event.surface_index)
        InterplanetaryAttacks.remove_surface(event.surface_index)
        SpawnLocationScanner.remove_surface(event.surface_index)
        QualityProcessor.remove_surface(game.surfaces[event.surface_index].name)
    end,
    [defines.events.on_pre_surface_cleared] = function(event)
        AttackGroupBeaconProcessor.remove_beacons_on_surface(event.surface_index)
        AttackGroupBeaconProcessor.init_globals_on_surface(game.surfaces[event.surface_index])
        InterplanetaryAttacks.remove_surface(event.surface_index)
        SpawnLocationScanner.remove_surface(event.surface_index)
    end,
    [GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_INTERPLANETARY_ATTACK_SCAN]] = function(event)
        local surface = event.surface
        local intel = event.intel
        if surface and intel and
            tonumber(intel.updated) + cache_time < event.tick
        then
            InterplanetaryAttacks.determine_planet_details(surface.index)
        end
    end
}

return MapManagement