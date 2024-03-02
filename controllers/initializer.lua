---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 10:00 PM
---

local Event = require('__stdlib__/stdlib/event/event')
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmMapProcessor = require('__enemyracemanager__/lib/map_processor')
local ErmLevelProcessor = require('__enemyracemanager__/lib/level_processor')

local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmSurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')

local ErmAttackMeterProcessor = require('__enemyracemanager__/lib/attack_meter_processor')

local ErmAttackGroupChunkProcessor = require('__enemyracemanager__/lib/attack_group_chunk_processor')
local ErmAttackGroupSurfaceProcessor = require('__enemyracemanager__/lib/attack_group_surface_processor')
local ErmCron = require('__enemyracemanager__/lib/cron_processor')

local ErmBossProcessor = require('__enemyracemanager__/lib/boss_processor')
local ErmArmyPopulationProcessor = require('__enemyracemanager__/lib/army_population_processor')
local ArmyTeleportationProcessor = require('__enemyracemanager__/lib/army_teleportation_processor')
local ArmyDeploymentProcessor = require('__enemyracemanager__/lib/army_deployment_processor')

local ErmGui = require('__enemyracemanager__/gui/main')

local ErmCompat_NewGamePlus = require('__enemyracemanager__/lib/compatibility/new_game_plus')

local addRaceSettings = function()
    local race_settings = remote.call('enemyracemanager', 'get_race', MOD_NAME)
    if race_settings == nil then
        race_settings = {}
    end

    race_settings.race = race_settings.race or MOD_NAME
    race_settings.label = { 'gui.label-biters' }
    race_settings.level = race_settings.level or 1
    race_settings.tier = race_settings.tier or 1
    race_settings.evolution_point = race_settings.evolution_point or 0
    race_settings.evolution_base_point = race_settings.evolution_base_point or 0
    race_settings.attack_meter = race_settings.attack_meter or 0
    race_settings.attack_meter_total = race_settings.attack_meter_total or 0
    race_settings.next_attack_threshold = race_settings.next_attack_threshold or 0

    race_settings.units = {
        { 'medium-spitter', 'medium-biter', 'defender' },
        { 'big-spitter', 'big-biter', 'distractor', 'logistic-robot' },
        { 'behemoth-spitter', 'behemoth-biter', 'destroyer', 'construction-robot' },
    }
    race_settings.turrets = {
        { 'medium-worm-turret' },
        { 'big-worm-turret' },
        { 'behemoth-worm-turret' },
    }
    race_settings.command_centers = {
        { 'spitter-spawner', 'biter-spawner' },
        { 'roboport' },
        {}
    }
    race_settings.support_structures = {
        { 'spitter-spawner', 'biter-spawner' },
        { 'roboport' },
        {},
    }
    race_settings.flying_units = {
        { 'defender' },
        { 'distractor', 'logistic-robot' },
        { 'destroyer' },
    }
    race_settings.dropship = 'logistic-robot'
    race_settings.droppable_units = {
        { { 'medium-spitter', 'medium-biter', 'defender' }, { 1, 2, 1 } },
        { { 'big-spitter', 'big-biter', 'defender', 'distractor' }, { 2, 3, 1, 1 } },
        { { 'behemoth-spitter', 'behemoth-biter', 'distractor', 'destroyer' }, { 2, 3, 1, 1 } },
    }
    race_settings.construction_buildings = {
        { { 'biter-spawner', 'spitter-spawner' }, { 1, 1 } },
        { { 'biter-spawner', 'spitter-spawner', 'short-range-big-worm-turret' }, { 1, 1, 1 } },
        { { 'biter-spawner', 'spitter-spawner', 'roboport', 'short-range-big-worm-turret' }, { 1, 1, 1, 2 } }
    }
    race_settings.featured_groups = {
        --Unit list, spawn percentage, unit_cost
        { { 'behemoth-biter', 'behemoth-spitter' }, { 5, 2 }, 30 },
        { { 'behemoth-spitter', 'behemoth-biter' }, { 5, 2 }, 30 },
        { { 'big-spitter', 'big-biter', 'behemoth-spitter', 'behemoth-biter' }, { 2, 1, 2, 1 }, 20 },
        { { 'big-spitter', 'big-biter', 'behemoth-spitter', 'behemoth-biter' }, { 1, 2, 1, 2 }, 20 },
        { { 'defender', 'distractor', 'destroyer', 'behemoth-spitter', 'behemoth-biter' }, { 2, 1, 1, 2, 2 }, 25 },
    }
    race_settings.featured_flying_groups = {
        { { 'distractor', 'destroyer' }, { 1, 1 }, 75 },
        { { 'defender', 'distractor', 'destroyer' }, { 3, 1, 1 }, 75 },
        { { 'logistic-robot', 'defender', 'distractor', 'destroyer' }, { 1, 2, 2, 1 }, 75 },
    }

    if script.active_mods['Krastorio2'] then
        race_settings.enable_k2_creep = settings.startup['enemyracemanager-vanilla-k2-creep'].value
    end

    ErmRaceSettingsHelper.process_unit_spawn_rate_cache(race_settings)

    remote.call('enemyracemanager', 'register_race', race_settings)

    Event.dispatch({
        name = Event.get_event_name(ErmConfig.RACE_SETTING_UPDATE), affected_race = MOD_NAME })
end

local prepare_world = function()
    ErmConfig.initialize_races_data()

    -- Game map settings
    game.map_settings.unit_group.max_gathering_unit_groups = settings.global["enemyracemanager-max-gathering-groups"].value
    game.map_settings.unit_group.max_unit_group_size = settings.global["enemyracemanager-max-group-size"].value
    game.map_settings.unit_group.max_member_speedup_when_behind = 2
    game.map_settings.unit_group.max_member_slowdown_when_ahead = 1
    game.map_settings.unit_group.max_group_slowdown_factor = 1
    -- One to two nauvis day of gathering time.
    game.map_settings.unit_group.min_group_gathering_time = 7 * 3600
    game.map_settings.unit_group.max_group_gathering_time = 14 * 3600
    -- Fresh technology effects
    for _, force in pairs(game.forces) do
        force.reset_technology_effects()
    end

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
    -- See zerm_postprocess for additional post-process after race_mods loaded
end

local conditional_events = function()
    if remote.interfaces["newgameplus"] then
        Event.register(remote.call("newgameplus", "get_on_post_new_game_plus_event"), function(event)
            ErmCompat_NewGamePlus.exec(event)
        end)
    end

    if global.army_teleporter_event_running then
        ArmyTeleportationProcessor.start_event(true)
    end

    if global.army_deployer_event_running then
        ArmyDeploymentProcessor.start_event(true)
    end

    if global.quick_cron_is_running then
        Event.on_nth_tick(ErmConfig.QUICK_CRON, ErmCron.process_quick_queue)
    end

    if global.boss and global.boss.entity then
        Event.on_nth_tick(ErmConfig.BOSS_QUEUE_CRON, ErmCron.process_boss_queue)
    end
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
    global.tick = global.tick or 0

    global.installed_races = {}
    global.active_races = {}
    global.active_races_names = {}
    global.active_races_num = 1

    ErmSurfaceProcessor.init_globals()
    ErmAttackMeterProcessor.init_globals()
    ErmMapProcessor.init_globals()
    ErmForceHelper.init_globals()
    ErmCron.init_globals()
    ErmAttackGroupChunkProcessor.init_globals()
    ErmAttackGroupSurfaceProcessor.init_globals()
    ErmBossProcessor.init_globals()
    ErmArmyPopulationProcessor.init_globals()
    ArmyTeleportationProcessor.init_globals()
    ArmyDeploymentProcessor.init_globals()
    ErmGui.init_globals()

    --- Wipe this cache due to cache pollution from previous version.
    global.force_race_name_cache = {}

    Event.dispatch({
        name = Event.get_event_name(ErmConfig.FLUSH_GLOBAL)})
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
    addRaceSettings()
    prepare_world()
    for _, player in pairs(game.connected_players) do
        ErmGui.main_window.update_overhead_button(player.index)
    end
end)

---Custom setting processors
local setting_functions = {
    ['enemyracemanager-max-gathering-groups'] = function(event)
        game.map_settings.unit_group.max_gathering_unit_groups = global.settings[event.setting]
    end,
    ['enemyracemanager-max-group-size'] = function(event)
        game.map_settings.unit_group.max_unit_group_size = global.settings[event.setting]
    end,
    ['enemyracemanager-army-limit-multiplier'] = function(event)
        for _, force in pairs(game.forces) do
            if ErmArmyPopulationProcessor.has_army_data(force) then
                ErmArmyPopulationProcessor.calculate_max_units(force)
            end
        end
    end
}
Event.register(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting_type == 'runtime-global' and
            string.find(event.setting, 'enemyracemanager', 1, true)
    then
        global.settings[event.setting] = settings.global[event.setting].value

        if setting_functions[event.setting] then
            setting_functions[event.setting](event)
        end
    end
end)