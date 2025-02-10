---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/6/2024 6:34 PM
---

local Queue = require("__erm_libs__/stdlib/queue")

local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")


local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local AttackGroupHeatProcessor = require("__enemyracemanager__/lib/attack_group_heat_processor")
local QualityProcessor = require("__enemyracemanager__/lib/quality_processor")
local InterplanetaryAttacks = require("__enemyracemanager__/lib/interplanetary_attacks")

local TestShared = {}

function TestShared.prepare_the_factory()
    local surface = game.surfaces[1]

    for key, _ in pairs(game.forces) do
        local entities = surface.find_entities_filtered({ force = game.forces[key] })
        for _, entity in pairs(entities) do
            entity.destroy({raise_destroy=true})
        end
    end

    QualityProcessor.reset_all_progress()
    AttackGroupBeaconProcessor.reset_globals()
    AttackGroupHeatProcessor.reset_globals()
    QualityProcessor.reset_globals()
    QualityProcessor.calculate_quality_points()
    InterplanetaryAttacks.reset_globals()
    TestShared.reset_attack_meter()
    TestShared.CleanCron()
    TestShared.reset_forces()
end

function TestShared.reset_the_factory()
    local surface = game.surfaces[1]
    for key, _ in pairs(game.forces) do
        local entities = surface.find_entities_filtered({ force = game.forces[key] })
        for _, entity in pairs(entities) do
            entity.destroy({raise_destroy=true})
        end
    end

    for key, surface in pairs(game.surfaces) do
        game.delete_surface(surface)
    end

    QualityProcessor.reset_all_progress()
    AttackGroupBeaconProcessor.reset_globals()
    AttackGroupHeatProcessor.reset_globals()
    QualityProcessor.reset_globals()
    InterplanetaryAttacks.reset_globals()
    TestShared.reset_attack_meter()
    TestShared.CleanCron()
end
--- Clear cron and its trackers
function TestShared.CleanCron()
    storage.one_minute_cron = Queue()
    storage.fifteen_seconds_cron = Queue()
    storage.ten_seconds_cron = Queue()
    storage.two_seconds_cron = Queue()
    storage.one_second_cron = Queue()

    -- Conditional Crons
    storage.quick_cron = Queue()  -- Spawn
    storage.teleport_cron = {}

    storage.erm_unit_group = {}
    storage.group_tracker = {}
    storage.scout_tracker = {}
    storage.scout_by_unit_number = {}
    storage.scout_scanner = false
    storage.quick_cron_is_running = false
    storage.army_teleporter_event_running = false
end

function TestShared.reset_attack_meter()
    for key, force in pairs(game.forces) do
        local force_name = force.name
        if ForceHelper.is_enemy_force(force) then
            storage.race_settings[force_name].attack_meter = 0
            storage.race_settings[force_name].attack_meter_total = 0
        end
    end
end

function TestShared.reset_surfaces()
    for key, surface in pairs(game.surfaces) do
        if not string.find(surface.name,"nauvis") then
            game.delete_surface(surface)
        end
    end
end

function TestShared.reset_forces()
    for key, force in pairs(game.forces) do
        if string.find(force.name,"test") then
            game.merge_forces(force, game.forces[1])
        end
        for key, surface in pairs(game.surfaces) do
            force.set_evolution_factor(0, surface)
        end
    end
end

function TestShared.reset_lab_tile(radius, surface)
    local surface = game.surfaces[1] or game.surfaces[surface]
    local tile_types = { "lab-dark-2","lab-dark-1" }
    local tiles = {}
    local radius = radius or 320
    for x = (radius * -1), radius, 1 do
        for y = (radius * -1), radius, 1 do
            local odd = ((x + y) % 2)
            if odd <= 0 then
                odd = odd + 2
            end
            table.insert(tiles, { name = tile_types[odd], position = { x, y } })
        end
    end
    surface.set_tiles(tiles, true, true, true, true)
end

function TestShared.get_command_chain()
    return {
        type = defines.command.compound,
        structure_type = defines.compound_command.return_last,
        commands = {}
    }
end

return TestShared