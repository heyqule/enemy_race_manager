--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/17/2020
-- Time: 11:29 AM
-- To change this template use File | Settings | File Templates.
--

-- Imports
local Position = require '__stdlib__/stdlib/area/position'
local Area = require '__stdlib__/stdlib/area/area'
local EventLog = require('__stdlib__/stdlib/misc/logger').new('Event')

local Table = require('__stdlib__/stdlib/utils/table')
local Game = require('__stdlib__/stdlib/game')
local Event = require('__stdlib__/stdlib/event/event')

local ErmConfig =  require('__enemyracemanager__/lib/global_config')
local ErmMapProcessor = require('__enemyracemanager__/lib/map_processor')
local ErmLevelProcessor = require('__enemyracemanager__/lib/level_processor')
local ErmReplacementProcessor = require('__enemyracemanager__/lib/replacement_processor')

require('__stdlib__/stdlib/utils/defines/time')

local ErmRemoteApi = require('__enemyracemanager__/lib/remote_api')
remote.add_interface("enemy_race_manager", ErmRemoteApi)

-- local variables
local race_settings -- track race settings
local enemy_surfaces -- track which race are on a surface
ERM_DEBUG = false

local onBuildBaseArrived = function(event)
    local group = event.group;
    if not ( group and group.valid) then
        local unit = event.unit;
        EventLog.log('on_build_base_arrived, Group '..unit.name)
    else
        EventLog.log('on_build_base_arrived, Unit '..group.name)
    end
end

local onBiterBaseBuilt = function(event)
    local entity = event.entity
    if entity.valid then
        EventLog.log('on_build_base_built, Entity '..entity.name)
    end
end

local onUnitGroupCreated = function(event)
    local group = event.group
    EventLog.log('on_unit_group_created, Group '..group.group_number)
end

local onUnitAddToGroup = function(event)
    local group = event.group
    EventLog.log('on_unit_added_to_group, Group '..group.group_number)
end

local onUnitFinishGathering = function(event)
    local group = event.group
    EventLog.log('on_unit_group_finished_gathering, Group '..group.group_number)
end

local onUnitRemovedFromGroup = function(event)
    local group = event.group
    EventLog.log('on_unit_removed_from_group, Group '..group.group_number)
end

local onEntitySpawned = function(event)

end


local prepare_world = function()
    -- Forces checks

    -- Calculate Biter Level
    if table_size(race_settings) > 0 then
        ErmLevelProcessor.level_up_from_tech(race_settings, game.forces, false)
    end
    -- Queue Chunk to process
end

--Event.register(defines.events.on_entity_spawned, onEntitySpawned)
--
--Event.register(defines.events.on_build_base_arrived, onBuildBaseArrived)
--
--Event.register(defines.events.on_biter_base_built, onBiterBaseBuilt)
--
--Event.register(defines.events.on_unit_group_created, onUnitGroupCreated)
--
--Event.register(defines.events.on_unit_group_finished_gathering, onUnitFinishGathering)
--
--Event.register(defines.events.on_unit_added_to_group, onUnitAddToGroup)
--
--Event.register(defines.events.on_unit_removed_from_group, onUnitRemovedFromGroup)

Event.on_nth_tick(ErmConfig.LEVEL_PROCESS_INTERVAL, function(event)
    ErmLevelProcessor.calculateLevel(race_settings, game.forces, settings)
end)

Event.on_nth_tick(ErmConfig.CHUNK_QUEUE_PROCESS_INTERVAL, function(event)
    local player = game.players[math.random(1, #game.players)]
    ErmMapProcessor.process_chunks(player.surface, race_settings)
end)

Event.register(defines.events.on_chunk_generated,function(event)
    ErmMapProcessor.queue_chunks(event.surface, event.area)
end)

Event.register(Event.generate_event_name(ErmConfig.EVENT_TIER_WENT_UP), function(event)
end)

Event.register(Event.generate_event_name(ErmConfig.EVENT_LEVEL_WENT_UP), function(event)
    ErmMapProcessor.rebuildMap(game)
end)

Event.on_init(function(event)
    -- ID by mod name, each mod should have it own statistic out side of what force tracks.
    global.race_settings = {}
    -- Track what type of enemies on a surface
    global.enemy_surfaces = {}

    race_settings = global.race_settings
    enemy_surfaces = global.enemy_surfaces

    prepare_world()
end)

Event.on_load(function(event)
    enemy_surfaces = global.enemy_surfaces
    race_settings = global.race_settings
end)

Event.on_configuration_changed(function(event)
    race_settings = global.race_settings or {}
    enemy_surfaces = global.enemy_surfaces or {}

    prepare_world()
end)

commands.add_command("ERM_RegenerateEnemy",
    {"description.command-regenerate-enemy"},
    function (event)
    ErmLevelProcessor.level_up_from_tech(race_settings, game.forces, false)
    game.forces['enemy'].kill_all_units()
    ErmReplacementProcessor.rebuildMap(game, race_settings)
end)

commands.add_command("ERM_ResetEnemyLevel",
        {"description.command-regenerate-enemy"},
        function (event)
            ErmMapProcessor.rebuildMap(game)
        end)

commands.add_command("ERM_GetRaceSettings",
        {"description.command-regenerate-enemy"},
        function (event)
    ErmLevelProcessor.level_up_from_tech(race_settings, game.forces, false)
    game.print(game.table_to_json(race_settings))
end)