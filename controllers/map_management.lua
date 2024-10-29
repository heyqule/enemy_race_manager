---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 10:29 PM
---
local Event = require("__stdlib__/stdlib/event/event")


require("__enemyracemanager__/global")

local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local MapProcessor = require("__enemyracemanager__/lib/map_processor")
local SurfaceProcessor = require("__enemyracemanager__/lib/surface_processor")
local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local AttackGroupPathingProcessor = require("__enemyracemanager__/lib/attack_group_pathing_processor")
local AttackGroupHeatProcessor = require("__enemyracemanager__/lib/attack_group_heat_processor")
local InterplanetaryAttacks = require("__enemyracemanager__/lib/interplanetary_attacks")
local SpawnLocationScanner = require("__enemyracemanager__/lib/spawn_location_scanner")

Event.on_nth_tick(GlobalConfig.CHUNK_QUEUE_PROCESS_INTERVAL, function(event)
    MapProcessor.process_chunks(game.surfaces, storage.race_settings)
end)

Event.register(defines.events.on_chunk_generated, function(event)
    MapProcessor.queue_chunks(event.surface, event.area)
    AttackGroupBeaconProcessor.create_spawn_beacon_from_trunk(event.surface, event.area)
    AttackGroupBeaconProcessor.create_resource_beacon_from_trunk(event.surface, event.area)
end)

--- Surface Management
Event.register(defines.events.on_surface_created, function(event)
    SurfaceProcessor.assign_race(game.surfaces[event.surface_index])
    AttackGroupBeaconProcessor.init_globals_on_surface(game.surfaces[event.surface_index])
end)

Event.register(defines.events.on_pre_surface_deleted, function(event)
    SurfaceProcessor.remove_race(game.surfaces[event.surface_index])
    AttackGroupBeaconProcessor.remove_beacons_on_surface(event.surface_index)
    AttackGroupHeatProcessor.remove_surface(event.surface_index)
    AttackGroupHeatProcessor.remove_surface(event.surface_index)
    InterplanetaryAttacks.remove_surface(event.surface_index)
    SpawnLocationScanner.remove_surface(event.surface_index)
end)

Event.register(defines.events.on_pre_surface_cleared, function(event)
    AttackGroupBeaconProcessor.remove_beacons_on_surface(event.surface_index)
    AttackGroupBeaconProcessor.init_globals_on_surface(game.surfaces[event.surface_index])
    InterplanetaryAttacks.remove_surface(event.surface_index)
    SpawnLocationScanner.remove_surface(event.surface_index)
end)

--Event.register(defines.events.on_surface_renamed, function(event)
--    AttackGroupBeaconProcessor.remove_beacons_on_surface(event.surface_index)
--end)