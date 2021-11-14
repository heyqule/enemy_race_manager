--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/17/2020
-- Time: 11:29 AM
-- To change this template use File | Settings | File Templates.
--

-- Imports
local String = require('__stdlib__/stdlib/utils/string')
local config = require('__stdlib__/stdlib/config')
config.skip_script_protections = true

local Event = require('__stdlib__/stdlib/event/event')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmMapProcessor = require('__enemyracemanager__/lib/map_processor')
local ErmLevelProcessor = require('__enemyracemanager__/lib/level_processor')
local ErmReplacementProcessor = require('__enemyracemanager__/lib/replacement_processor')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmSurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local ErmBaseBuildProcessor = require('__enemyracemanager__/lib/base_build_processor')
local ErmCommandProcessor = require('__enemyracemanager__/lib/command_processor')

local ErmAttackMeterProcessor = require('__enemyracemanager__/lib/attack_meter_processor')
local ErmAttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')
local ErmAttackGroupChunkProcessor = require('__enemyracemanager__/lib/attack_group_chunk_processor')
local ErmAttackGroupSurfaceProcessor = require('__enemyracemanager__/lib/attack_group_surface_processor')
local ErmCron = require('__enemyracemanager__/lib/cron_processor')

local ErmGui = require('__enemyracemanager__/gui/main')

local CustomAttacks = require('__enemyracemanager__/prototypes/base-units/custom_attacks')

-- Compatibility Events
local ErmCompat_NewGamePlus = require('__enemyracemanager__/lib/compatibility/new_game_plus')

require('prototypes/compatibility/controls')

local ErmRemoteApi = require('__enemyracemanager__/lib/remote_api')
remote.add_interface("enemy_race_manager", ErmRemoteApi)

local ErmDebugRemoteApi = require('__enemyracemanager__/lib/debug_remote_api')
remote.add_interface("enemy_race_manager_debug", ErmDebugRemoteApi)

cron_switch = {
    ['AttackGroupProcessor.add_to_group'] = function(args)
        ErmAttackGroupProcessor.add_to_group_cron(args)
    end,
    ['BaseBuildProcessor.build'] = function(args)
        ErmBaseBuildProcessor.build_cron(args)
    end,
    ['LevelProcessor.calculateMultipleLevels'] = function(args)
        ErmLevelProcessor.calculateMultipleLevels()
    end,
    ['ForceHelper.refresh_all_enemy_forces'] = function(args)
        ErmForceHelper.refresh_all_enemy_forces()
    end,
    ['AttackMeterProcessor.calculate_points'] = function(args)
        ErmAttackMeterProcessor.calculate_points(args[1])
    end,
    ['AttackMeterProcessor.form_group'] = function(args)
        ErmAttackMeterProcessor.form_group(args[1], args[2])
    end,
    ['AttackGroupSurfaceProcessor.exec'] = function(args)
        ErmAttackGroupSurfaceProcessor.exec(args[1])
    end
}

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
    local tmp = {}
    for _, group in pairs(target_table) do
        if group.valid and #group.members > 0 then
            tmp[group.group_number] = group
        end
    end
    target_table = tmp

    return target_table
end

local onAiCompleted = function(event)
    if global.erm_unit_groups[event.unit_number] then
        local group = global.erm_unit_groups[event.unit_number]
        if group.valid then
            group.set_autonomous()
        end

        local group_count = table_size(global.erm_unit_groups)
        if group_count > ErmConfig.CONFIG_CACHE_SIZE then
            global.erm_unit_groups = globalCacheTableCleanup(global.erm_unit_groups)
        end
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
            { 'medium-spitter', 'medium-biter', 'defender' },
            { 'big-spitter', 'big-biter', 'distractor', 'logistic-robot' },
            { 'behemoth-spitter', 'behemoth-biter', 'destroyer', 'construction-robot' },
        },
        current_units_tier = {},
        turrets = {
            { 'medium-worm-turret' },
            { 'big-worm-turret' },
            { 'behemoth-worm-turret' },
        },
        current_turrets_tier = {},
        command_centers = {
            { 'spitter-spawner', 'biter-spawner' },
            { 'roboport' },
            {}
        },
        current_command_centers_tier = {},
        support_structures = {
            { 'spitter-spawner', 'biter-spawner' },
            { 'roboport' },
            {},
        },
        current_support_structures_tier = {},
        flying_units = {
            {'defender'},
            {'distractor', 'logistic-robot'},
            {'destroyer', 'construction-robot'},
        },
        dropship = 'logistic-robot'
    }

    race_settings.current_units_tier = race_settings.units[1]
    race_settings.current_turrets_tier = race_settings.turrets[1]
    race_settings.current_command_centers_tier = race_settings.command_centers[1]
    race_settings.current_support_structures_tier = race_settings.support_structures[1]

    remote.call('enemy_race_manager', 'register_race', race_settings)
end

local prepare_world = function()
    -- Game map settings
    local max_group_size = settings.startup["enemyracemanager-max-group-size"].value
    local max_groups = settings.startup["enemyracemanager-max-gathering-groups"].value
    game.map_settings.unit_group.max_gathering_unit_groups = max_groups
    game.map_settings.unit_group.max_unit_group_size = max_group_size

    -- Mod Compatibility Upgrade for race settings
    Event.dispatch({
        name = Event.get_event_name(ErmConfig.RACE_SETTING_UPDATE), affected_race = MOD_NAME })

    -- Race Cleanup
    ErmRaceSettingsHelper.clean_up_race()
    ErmSurfaceProcessor.numeric_to_name_conversion()
    ErmSurfaceProcessor.rebuild_race(global.race_settings)

    -- Calculate Biter Level
    if table_size(global.race_settings) > 0 then
        ErmLevelProcessor.calculateMultipleLevels()
    end

    ErmAttackGroupChunkProcessor.init_index()
    ErmSurfaceProcessor.wander_unit_clean_up()

    ErmCron.add_1_sec_queue('ForceHelper.refresh_all_enemy_forces', true)
end

local init_globals = function()
    -- ID by mod name, each mod should have it own statistic out side of what force tracks.
    global.race_settings = global.race_settings or {}

    -- Track all unit group created by ERM
    global.erm_unit_groups = global.erm_unit_groups or {}

    -- Move all cache to this to resolve desync issues.
    -- https://wiki.factorio.com/Desynchronization
    -- https://wiki.factorio.com/Tutorial:Modding_tutorial/Gangsir#Multiplayer_and_desyncs
    global.settings = global.settings or {}

    ErmSurfaceProcessor.init_globals()
    ErmAttackMeterProcessor.init_globals()
    ErmMapProcessor.init_globals()
    ErmForceHelper.init_globals()
    ErmCron.init_globals()
    ErmAttackGroupChunkProcessor.init_globals()
    ErmAttackGroupSurfaceProcessor.init_globals()
end

--- GUIs
local onGuiClick = function(event)
    ErmGui.main_window.open_detail_window(event)

    ErmGui.detail_window.replace_enemy(event)
    ErmGui.detail_window.confirm(event)

    ErmGui.main_window.reset_default(event)
    ErmGui.main_window.kill_idle_units(event)
    -- Close event must handle the last
    ErmGui.main_window.toggle_main_window(event)
    ErmGui.main_window.toggle_close(event)
    ErmGui.detail_window.toggle_close(event)

    if ErmGui.main_window.require_update_all then
        ErmGui.main_window.update_all()
    end
end

Event.register(defines.events.on_gui_click, onGuiClick)

Event.register(defines.events.on_player_created, function(event)
    ErmGui.main_window.update_overhead_button(event.player_index)
end)

local gui_close_switch = {
    [ErmGui.main_window.root_name] = function(owner)
        ErmGui.main_window.hide(owner)
    end,
    [ErmGui.detail_window.root_name] = function(owner)
        ErmGui.detail_window.hide(owner)
    end
}

local onGuiClose = function(event)
    local owner = game.players[event.player_index]
    if owner and event.element and event.element.valid then
        local name = event.element.name
        if gui_close_switch[name] then
            gui_close_switch[name](owner)
        end
    end
end

Event.register(defines.events.on_gui_closed, onGuiClose)

local gui_value_change_switch = {
    [ErmGui.detail_window.levelup_silder_name] = function(event)
        ErmGui.detail_window.update_slider_text(event)
    end,
}

local onGuiValueChange = function(event)
    if event.element and event.element.valid then
        local nameToken = String.split(event.element.name, '/')
        if gui_value_change_switch[nameToken[2]] then
            gui_value_change_switch[nameToken[2]](event)
        end
    end
end

Event.register(defines.events.on_gui_value_changed, onGuiValueChange)

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
    ErmAttackGroupChunkProcessor.add_spawnable_chunk(event.surface, event.position)
end)

--- ERM Events
Event.register(Event.generate_event_name(ErmConfig.EVENT_TIER_WENT_UP), function(event)
end)

Event.register(Event.generate_event_name(ErmConfig.EVENT_LEVEL_WENT_UP), function(event)
    ErmMapProcessor.rebuild_map(game)
end)

--- Surface Management
Event.register(defines.events.on_surface_created, function(event)
    ErmSurfaceProcessor.assign_race(game.surfaces[event.surface_index])

end)
Event.register(defines.events.on_pre_surface_deleted, function(event)
    ErmSurfaceProcessor.remove_race(game.surfaces[event.surface_index])
    ErmAttackGroupChunkProcessor.remove_surface(game.surfaces[event.surface_index].name)
end)

--- Attack Meter Management
Event.on_nth_tick(ErmConfig.ATTACK_POINT_CALCULATION, function(event)
    ErmAttackMeterProcessor.exec()
end)

Event.on_nth_tick(ErmConfig.ATTACK_GROUP_GATHERING_CRON, function(event)
    ErmAttackMeterProcessor.add_form_group_cron()
end)


--- CRON Events
Event.on_nth_tick(ErmConfig.THIRTY_SECONDS_CRON, function(event)
    ErmCron.process_30_sec_queue()
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
--- Native Event Handlers
script.on_event(defines.events.on_built_entity, function(event)
    if event.created_entity and event.created_entity.valid then
        ErmAttackGroupChunkProcessor.add_attackable_chunk_by_entity(event.created_entity)
    end
end, ErmAttackGroupChunkProcessor.get_built_entity_event_filter())

script.on_event(defines.events.on_robot_built_entity, function(event)
    if event.created_entity and event.created_entity.valid then
        ErmAttackGroupChunkProcessor.add_attackable_chunk_by_entity(event.created_entity)
    end
end, ErmAttackGroupChunkProcessor.get_built_entity_event_filter())

--- Hook Up Conditional Events
local conditional_events = function()
    if remote.interfaces["newgameplus"] then
        Event.register(remote.call("newgameplus", "get_on_post_new_game_plus_event"), function(event)
            ErmCompat_NewGamePlus.exec(event)
        end)
    end
end

--- Init events
Event.on_init(function(event)
    init_globals()
    ErmConfig.refresh_config()
    addRaceSettings()
    prepare_world()
    conditional_events()
end)

Event.on_load(function(event)
    ErmMapProcessor.rebuild_queue()
    ErmCron.rebuild_queue()
    conditional_events()
end)

Event.on_configuration_changed(function(event)
    init_globals()
    ErmConfig.refresh_config()
    prepare_world()
    for _, player in pairs(game.connected_players) do
        ErmGui.main_window.update_overhead_button(player.index)
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

            if race_setting.version < 102 then
                ErmRaceSettingsHelper.add_structure_to_tier(race_setting, 2, 'roboport')
                ErmRaceSettingsHelper.add_command_center_from_tier(race_setting, 2, 'roboport')
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 1, 'defender')
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 2, 'distractor')
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 2, 'logistic-robot')
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 3, 'destroyer')
                ErmRaceSettingsHelper.add_unit_to_tier(race_setting, 3, 'construction-robot')
                ErmRaceSettingsHelper.remove_unit_from_tier(race_setting, 1, 'small-biter')
                ErmRaceSettingsHelper.remove_unit_from_tier(race_setting, 1, 'small-spitter')
                ErmRaceSettingsHelper.remove_turret_from_tier(race_setting, 1, 'small-worm-turret')
                race_setting.flying_units = {
                    {'defender'},
                    {'distractor', 'logistic-robot'},
                    {'destroyer', 'construction-robot'},
                }
                race_setting.dropship = 'logistic-robot'
            end
            race_setting.version = MOD_VERSION
        end
        remote.call('enemy_race_manager', 'update_race_setting', race_setting)
    end
end)

Event.register(defines.events.on_script_trigger_effect, function(event)
    if not event.source_entity or
            String.find(event.source_entity.name, MOD_NAME, 1, true) == nil
    then
        return
    end

    if event.effect_id == CONSTRUCTION_ATTACK then
        CustomAttacks.process_constructor(event)
    elseif event.effect_id == LOGISTIC_ATTACK then
        CustomAttacks.process_logistic(event)
    end
end)

-- Commands
commands.add_command("ERM_GetRaceSettings",
        { "description.command-regenerate-enemy" },
        function()
            game.print(game.table_to_json(global.race_settings))
        end)

commands.add_command("ERM_FFA",
        { "description.command-ffa" },
        function(command)
            ErmCommandProcessor.freeforall(command)
        end)

-- Compatibility Events
require('__enemyracemanager__/lib/compatibility_events/k2')