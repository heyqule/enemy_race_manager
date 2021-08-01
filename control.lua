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

local Table = require('__stdlib__/stdlib/utils/table')
local Game = require('__stdlib__/stdlib/game')
local Event = require('__stdlib__/stdlib/event/event')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmMapProcessor = require('__enemyracemanager__/lib/map_processor')
local ErmLevelProcessor = require('__enemyracemanager__/lib/level_processor')
local ErmReplacementProcessor = require('__enemyracemanager__/lib/replacement_processor')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmSurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local ErmBaseBuildProcessor = require('__enemyracemanager__/lib/base_build_processor')
local ErmCommandProcessor = require('__enemyracemanager__/lib/command_processor')

local ErmAttackMeterProcessor = require('__enemyracemanager__/lib/attack_meter_processor')
local ErmCron = require('__enemyracemanager__/lib/cron_processor')

local ErmMainWindow = require('__enemyracemanager__/gui/main_window')

require('prototypes/compatibility/controls')

local ErmRemoteApi = require('__enemyracemanager__/lib/remote_api')
remote.add_interface("enemy_race_manager", ErmRemoteApi)

local ErmDebugRemoteApi = require('__enemyracemanager__/lib/debug_remote_api')
remote.add_interface("enemy_race_manager_debug", ErmDebugRemoteApi)

local onBiterBaseBuilt = function(event)
    local entity = event.entity
    if entity.valid then
        local replaced_entity = ErmReplacementProcessor.replace_entity(entity.surface, entity, global.race_settings, entity.force.name)
        ErmBaseBuildProcessor.exec(replaced_entity)
    end
end


local onUnitFinishGathering = function(event)
    local group = event.group
    local max_settler = global.settings.enemy_expansion_max_settler
    
    if max_settler == nil then
        max_settler = math.min(50, game.map_settings.enemy_expansion.settler_group_max_size)
        global.settings.enemy_expansion_max_settler = max_settler
    end

    if group.command and group.command.type == defines.command.build_base and table_size(group.members) > max_settler then
        local build_group = group.surface.create_unit_group {
            position = group.position,
            force= group.force
        }
        for i, unit in pairs(group.members) do
            if i <= max_settler then
                build_group.add_member(unit)
            end
        end
        build_group.set_command {
            type = defines.command.build_base,
            destination = group.command.destination
        }
        build_group.start_moving()
        global.erm_unit_groups[build_group.group_number] = build_group

        group.set_autonomous()
    end
end

local globalCacheTableCleanup = function(target_table)
    local group_count = table_size(target_table)
    if(group_count > ErmConfig.CONFIG_CACHE_SIZE) then
        local tmp = {}
        for _, group in pairs(target_table) do
            if group.valid and #group.members > 0 then
                tmp[group.group_number] = group
            end
        end
        target_table = tmp
    end
end

local onAiCompleted = function(event)
    if global.erm_unit_groups[event.unit_number] then
        local group = global.erm_unit_groups[event.unit_number]
        if group.valid then
            group.set_autonomous()
        end

        globalCacheTableCleanup(global.erm_unit_groups)
    end
end


local addRaceSettings = function()
    if remote.call('enemy_race_manager', 'get_race', MOD_NAME) then
        return
    end
    local race_settings = {
        race = MOD_NAME,
        version = MOD_VERSION,
        level = 1, -- Race level
        tier = 1, -- Race tier
        evolution_point = 0,
        evolution_base_point = 0,
        attack_meter = 0, -- Build by killing their force (Spawner = 50, turrets = 10, unit = 1)
        next_attack_threshold = 0, -- Used by system to calculate next move
        units = {
            { 'small-spitter', 'small-biter', 'medium-spitter', 'medium-biter' },
            { 'big-spitter', 'big-biter' },
            { 'behemoth-spitter', 'behemoth-biter' },
        },
        current_units_tier = {},
        turrets = {
            { 'small-worm-turret', 'medium-worm-turret' },
            { 'big-worm-turret' },
            { 'behemoth-worm-turret' },
        },
        current_turrets_tier = {},
        command_centers = {
            { 'spitter-spawner', 'biter-spawner' },
            {},
            {}
        },
        current_command_centers_tier = {},
        support_structures = {
            { 'spitter-spawner', 'biter-spawner' },
            {},
            {},
        },
        current_support_structures_tier = {}
    }

    race_settings.current_units_tier = race_settings.units[1]
    race_settings.current_turrets_tier = race_settings.turrets[1]
    race_settings.current_command_centers_tier = race_settings.command_centers[1]
    race_settings.current_support_structures_tier = race_settings.support_structures[1]

    remote.call('enemy_race_manager', 'register_race', race_settings)
end

local prepare_world = function()
    -- Calculate Biter Level
    if table_size(global.race_settings) > 0 then
        ErmLevelProcessor.calculateMultipleLevels()
    end

    -- Game map settings
    local max_group_size = settings.startup["enemyracemanager-max-group-size"].value
    local max_groups = settings.startup["enemyracemanager-max-gathering-groups"].value
    game.map_settings.unit_group.min_group_gathering_time =  max_group_size * 6 * defines.time.second -- 10 mins/100units
    game.map_settings.unit_group.max_group_gathering_time = max_group_size * 9 * defines.time.second -- 15 mins/100units
    game.map_settings.unit_group.max_gathering_unit_groups = max_groups
    game.map_settings.unit_group.max_unit_group_size = max_group_size

    -- Mod Compatibility Upgrade for race settings
    Event.dispatch({
        name = Event.get_event_name(ErmConfig.RACE_SETTING_UPDATE), affected_race = MOD_NAME })

    -- Race Cleanup
    ErmRaceSettingsHelper.clean_up_race()
    ErmSurfaceProcessor.rebuild_race(global.race_settings)
end

local onGuiClick = function(event)
    ErmMainWindow.replace_enemy(event)
    ErmMainWindow.reset_default(event)
    ErmMainWindow.nuke_biters(event)
    -- Close event must handle the last
    ErmMainWindow.toggle_main_window(event)
    ErmMainWindow.toggle_close(event)

    if ErmMainWindow.require_update_all then
        ErmMainWindow.update_all()
    end
end

Event.register(defines.events.on_player_created, function(event)
    ErmMainWindow.update_overhead_button(event.player_index)
end)
--- GUIs

Event.register(defines.events.on_gui_click, onGuiClick)

--- Unit processing events
Event.register(defines.events.on_biter_base_built, onBiterBaseBuilt)

Event.register(defines.events.on_unit_group_finished_gathering, onUnitFinishGathering)

Event.register(defines.events.on_ai_command_completed, onAiCompleted)


--- Level Processing Events
Event.on_nth_tick(ErmConfig.LEVEL_PROCESS_INTERVAL, function(event)
    ErmLevelProcessor.calculateLevels()
end)

--- Map Processing Events
Event.on_nth_tick(ErmConfig.CHUNK_QUEUE_PROCESS_INTERVAL, function(event)
    ErmMapProcessor.process_chunks(game.surfaces, global.race_settings)
end)

Event.register(defines.events.on_chunk_generated, function(event)
    ErmMapProcessor.queue_chunks(event.surface, event.area)
end)

--- ERM Events
Event.register(Event.generate_event_name(ErmConfig.EVENT_TIER_WENT_UP), function(event)
end)

Event.register(Event.generate_event_name(ErmConfig.EVENT_LEVEL_WENT_UP), function(event)
    ErmMapProcessor.rebuild_map(game)
end)

--- Surface Management
Event.register(defines.events.on_surface_created, function(event)
    ErmSurfaceProcessor.assign_race(event.surface_index)
end)
Event.register(defines.events.on_surface_deleted, function(event)
    ErmSurfaceProcessor.remove_race(event.surface_index)
end)

--- Attack Meter Management
Event.on_nth_tick(ErmConfig.ONE_MINUTE_CRON, function(event)
    ErmAttackMeterProcessor.add_point_calculation_to_cron()
end)

Event.on_nth_tick(ErmConfig.ATTACK_GROUP_GATHERING_CRON, function(event)
    ErmAttackMeterProcessor.add_form_group_cron()
end)


--- CRON Events
Event.on_nth_tick(ErmConfig.TEN_MINUTES_CRON, function(event)
    ErmCron.process_10_min_queue()
end)

Event.on_nth_tick(ErmConfig.ONE_MINUTE_CRON, function(event)
    ErmCron.process_1_min_queue()
end)

Event.on_nth_tick(ErmConfig.TEN_SECONDS_CRON, function(event)
    ErmCron.process_10_sec_queue()
end)

Event.on_nth_tick(ErmConfig.ONE_SECOND_CRON, function(event)
    ErmCron.process_1_sec_queue()
end)

local init_globals = function()
    -- ID by mod name, each mod should have it own statistic out side of what force tracks.
    if global.race_settings == nil then
        global.race_settings = {}
    end

    -- Track all unit group created by ERM
    if global.erm_unit_groups == nil then
        global.erm_unit_groups = {}
    end

    -- Move all cache to this to resolve desync issues.
    -- https://wiki.factorio.com/Desynchronization
    -- https://wiki.factorio.com/Tutorial:Modding_tutorial/Gangsir#Multiplayer_and_desyncs
    if global.settings == nil then
        global.settings = {}
    end

    ErmSurfaceProcessor.init_globals()
    ErmAttackMeterProcessor.init_globals()
    ErmMapProcessor.init_globals()
    ErmCron.init_globals()
end
--- Init events
Event.on_init(function(event)
    init_globals()
    ErmConfig.refresh_config()
    addRaceSettings()
    prepare_world()
end)

Event.on_load(function(event)
end)

Event.on_configuration_changed(function(event)
    init_globals()
    ErmConfig.refresh_config()
    prepare_world()
    for _, player in pairs(game.connected_players) do
        ErmMainWindow.update_overhead_button(player.index)
    end
end)

Event.register(defines.events.on_runtime_mod_setting_changed,function(event)
    if event.setting_type == 'runtime-global' and
            string.find(event.setting, 'enemyracemanager', 1, true)
    then
        global.settings[event.setting] = settings.global[event.setting].value
    end
end)

Event.register(Event.generate_event_name(ErmConfig.RACE_SETTING_UPDATE), function(event)
    local race_setting = remote.call('enemy_race_manager', 'get_race', MOD_NAME)
    if (event.affected_race == MOD_NAME) and race_setting then
        if race_setting.version < MOD_VERSION then
            if race_setting.version < 101 then
                race_setting.angry_meter = nil
                race_setting.send_attack_threshold = nil
                race_setting.send_attack_threshold_deviation = nil
                race_setting.attack_meter = 0
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 2, 'big-biter')
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 2, 'big-spitter')
                ErmRaceSettingsHelper.remove_unit_from_tier(race_setting, 2, 'large-biter')
                ErmRaceSettingsHelper.remove_unit_from_tier(race_setting, 2, 'large-spitter')
            end
            race_setting.version = MOD_VERSION
        end
        remote.call('enemy_race_manager', 'update_race_setting', race_setting)
    end
end)

-- Commands
commands.add_command("ERM_GetRaceSettings",
        { "description.command-regenerate-enemy" },
        function()
            game.print(game.table_to_json(global.race_settings))
        end)

commands.add_command("ERM_levelup",
        { "description.command-level-up-race" },
        function(command)
            ErmCommandProcessor.levelup(command)
        end)