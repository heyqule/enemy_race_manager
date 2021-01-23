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

local ErmGui = require('__enemyracemanager__/scripts/gui')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

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
        ErmMapProcessor.level_up_unit_built_base(entity, race_settings)
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

local addRaceSettings = function()
    if remote.call('enemy_race_manager','get_race', MOD_NAME) then
        return
    end
    local race_settings = {
        race = MOD_NAME,
        version = MOD_VERSION,
        level = 1, -- Race level
        tier = 1, -- Race tier
        evolution_point = 0,
        evolution_base_point = 0,
        angry_meter = 0, -- Build by killing their force (unit = 1, building = 10)
        send_attack_threshold = 2000, -- When threshold reach, sends attack to the base
        send_attack_threshold_deviation = 0.2,
        next_attack_threshold = 0, -- Used by system to calculate next move
        units = {
            {'small-spitter','small-biter','medium-spitter','medium-biter'},
            {'large-spitter','large-biter'},
            {'behemoth-spitter','behemoth-biter'},
        },
        current_units_tier = {},
        turrets = {
            {'small-worm-turret','medium-worm-turret'},
            {'big-worm-turret'},
            {'behemoth-worm-turret'},
        },
        current_turrets_tier = {},
        command_centers = {
            {'spitter-spawner','biter-spawner'},
            {},
            {}
        },
        current_command_centers_tier = {},
        support_structures = {
            {'spitter-spawner','biter-spawner'},
            {},
            {},
        },
        current_support_structures_tier = {},
    }

    race_settings.current_units_tier = race_settings.units[1]
    race_settings.current_turrets_tier = race_settings.turrets[1]
    race_settings.current_command_centers_tier = race_settings.command_centers[1]
    race_settings.current_support_structures_tier = race_settings.support_structures[1]

    remote.call('enemy_race_manager','register_race', race_settings)
end


local prepare_world = function()
    -- Calculate Biter Level
    if table_size(race_settings) > 0 then
       ErmLevelProcessor.calculateMultipleLevel(race_settings, game.forces, settings)
    end

    -- Game map settings
    game.map_settings.unit_group.max_gathering_unit_groups = settings.startup["enemyracemanager-max-gathering-groups"].value
    game.map_settings.unit_group.max_unit_group_size = settings.startup["enemyracemanager-max-group-size"].value
end

local onGuiClick = function(event)
    ErmGui.sync_with_enemy(event)
    ErmGui.replace_enemy(event)
    ErmGui.reset_default(event)
    -- Close event must handle the last
    ErmGui.toggle_main_window(event)
    ErmGui.toggle_close(event)

    if ErmGui.require_update_all then
        ErmGui.update_all()
    end
end

Event.register(defines.events.on_player_created, function(event)
    ErmGui.update_overhead_button(event.player_index)
end)

Event.register(defines.events.on_gui_click, onGuiClick)

--Event.register(defines.events.on_entity_spawned, onEntitySpawned)
--
--Event.register(defines.events.on_build_base_arrived, onBuildBaseArrived)

Event.register(defines.events.on_biter_base_built, onBiterBaseBuilt)

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
    ErmMapProcessor.rebuild_map(game)
end)

Event.on_init(function(event)
    -- ID by mod name, each mod should have it own statistic out side of what force tracks.
    global.race_settings = {}
    -- Track what type of enemies on a surface
    global.enemy_surfaces = {}

    race_settings = global.race_settings
    enemy_surfaces = global.enemy_surfaces

    addRaceSettings()
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
    for _, player in pairs(game.connected_players) do
        ErmGui.update_overhead_button(player.index)
    end
end)

commands.add_command("ERM_GetRaceSettings",
        {"description.command-regenerate-enemy"},
        function ()
    game.print(game.table_to_json(race_settings))
end)

commands.add_command("ERM_LevelUpWithTech",
        {"description.command-level-up-with-tech"},
        function ()
            ErmLevelProcessor.level_up_from_tech(race_settings, game.forces, false)
end)