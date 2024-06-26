---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/6/2024 6:34 PM
---

local Queue = require('__stdlib__/stdlib/misc/queue')

local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local LevelManager = require('__enemyracemanager__/lib/level_processor')

local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local AttackGroupHeatProcessor = require('__enemyracemanager__/lib/attack_group_heat_processor')

local TestShared = {}

function TestShared.prepare_the_factory()
    local surface = game.surfaces[1]

    for key, _ in pairs(game.forces) do
        local entities = surface.find_entities_filtered({ force = game.forces[key] })
        for _, entity in pairs(entities) do
            entity.destroy({raise_destroy=true})
        end
    end

    LevelManager.reset_all_progress()
    AttackGroupBeaconProcessor.reset_globals()
    AttackGroupHeatProcessor.reset_globals()
    TestShared.reset_attack_meter()
    TestShared.CleanCron()
end

function TestShared.reset_the_factory()
    local surface = game.surfaces[1]
    for key, _ in pairs(game.forces) do
        local entities = surface.find_entities_filtered({ force = game.forces[key] })
        for _, entity in pairs(entities) do
            entity.destroy({raise_destroy=true})
        end
    end

    LevelManager.reset_all_progress()
    AttackGroupBeaconProcessor.reset_globals()
    AttackGroupHeatProcessor.reset_globals()
    TestShared.reset_attack_meter()
    TestShared.CleanCron()
end
--- Clear cron and its trackers
function TestShared.CleanCron()
    global.one_minute_cron = Queue()
    global.fifteen_seconds_cron = Queue()
    global.ten_seconds_cron = Queue()
    global.two_seconds_cron = Queue()
    global.one_second_cron = Queue()

    -- Conditional Crons
    global.quick_cron = Queue()  -- Spawn
    global.teleport_cron = {}

    global.erm_unit_group = {}
    global.group_tracker = {}
    global.scout_tracker = {}
    global.scout_by_unit_number = {}
    global.scout_scanner = false
    global.quick_cron_is_running = false
    global.army_teleporter_event_running = false
end

function TestShared.reset_attack_meter()
    for key, force in pairs(game.forces) do
        local force_name = force.name
        local race_name = ForceHelper.extract_race_name_from(force_name)
        if race_name then
            global.race_settings[race_name].attack_meter = 0
            global.race_settings[race_name].attack_meter_total = 0
        end
    end
end

function TestShared.reset_surfaces()
    for key, surface in pairs(game.surfaces) do
        if string.find(surface.name,'test') then
            game.delete_surface(surface)
        end
    end
end

function TestShared.reset_forces()
    for key, force in pairs(game.forces) do
        if string.find(force.name,'test') then
            game.merge_forces(force, game.forces[1])
        end
    end
end

function TestShared.reset_lab_tile(radius)
    local surface = game.surfaces[1]
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