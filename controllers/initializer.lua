---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 10:00 PM
---


require("__enemyracemanager__/global")

local GlobalConfig = require("__enemyracemanager__/lib/global_config")

local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")
local SurfaceProcessor = require("__enemyracemanager__/lib/surface_processor")

local QualityProcessor = require("__enemyracemanager__/lib/quality_processor")
local AttackGroupProcessor = require("__enemyracemanager__/lib/attack_group_processor")
local AttackGroupHeatProcessor = require("__enemyracemanager__/lib/attack_group_heat_processor")
local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local AttackGroupPathingProcessor = require("__enemyracemanager__/lib/attack_group_pathing_processor")
local InterplanetaryAttacks = require("__enemyracemanager__/lib/interplanetary_attacks")
local SpawnLocationScanner = require("__enemyracemanager__/lib/spawn_location_scanner")

local Cron = require("__enemyracemanager__/lib/cron_processor")

local BossProcessor = require("__enemyracemanager__/lib/boss_processor")
local ArmyPopulationProcessor = require("__enemyracemanager__/lib/army_population_processor")
local ArmyTeleportationProcessor = require("__enemyracemanager__/lib/army_teleportation_processor")
local ArmyDeploymentProcessor = require("__enemyracemanager__/lib/army_deployment_processor")

local GuiContainer = require("__enemyracemanager__/gui/main")

local addRaceSettings = function()
    local race_settings = remote.call("enemyracemanager", "get_race", MOD_NAME)
    if race_settings == nil then
        race_settings = {}
    end

    race_settings.race = race_settings.race or MOD_NAME
    race_settings.label = { "gui.label-biters" }
    race_settings.level = race_settings.level or 1
    race_settings.tier = race_settings.tier or 1
    race_settings.evolution_point = race_settings.evolution_point or 0
    race_settings.evolution_base_point = race_settings.evolution_base_point or 0
    race_settings.attack_meter = race_settings.attack_meter or 0
    race_settings.attack_meter_total = race_settings.attack_meter_total or 0
    race_settings.next_attack_threshold = race_settings.next_attack_threshold or 0

    race_settings.units = {
        { "small-spitter", "small-biter", "medium-biter", "defender" },
        { "medium-spitter", "big-biter", "big-spitter", "distractor", "logistic-robot" },
        { "behemoth-spitter", "behemoth-biter", "destroyer", "construction-robot" },
    }
    race_settings.turrets = {
        { "medium-worm-turret" },
        { "big-worm-turret" },
        { "behemoth-worm-turret" },
    }
    race_settings.command_centers = {
        { "spitter-spawner", "biter-spawner" },
        { "roboport" },
        {}
    }
    race_settings.support_structures = {
        { "spitter-spawner", "biter-spawner" },
        { "roboport" },
        {},
    }
    race_settings.flying_units = {
        { "defender" },
        { "distractor", "logistic-robot" },
        { "destroyer" },
    }
    race_settings.dropship = "logistic-robot"
    race_settings.droppable_units = {
        { {  "medium-spitter", "medium-biter", "defender" }, { 1, 2, 1 } },
        { { "big-spitter", "big-biter", "defender", "distractor" }, { 2, 3, 1, 1 } },
        { { "behemoth-spitter", "behemoth-biter", "distractor", "destroyer" }, { 2, 3, 1, 1 } },
    }
    race_settings.construction_buildings = {
        { { "biter-spawner", "spitter-spawner" }, { 1, 1 } },
        { { "biter-spawner", "spitter-spawner", "short-range-big-worm-turret" }, { 1, 1, 1 } },
        { { "biter-spawner", "spitter-spawner", "roboport", "short-range-big-worm-turret" }, { 1, 1, 1, 2 } }
    }
    race_settings.featured_groups = {
        --Unit list, spawn percentage, unit_cost
        { { "behemoth-biter", "behemoth-spitter" }, { 5, 2 }, 30 },
        { { "behemoth-spitter", "behemoth-biter" }, { 5, 2 }, 30 },
        { { "big-spitter", "big-biter", "behemoth-spitter", "behemoth-biter" }, { 2, 1, 2, 1 }, 20 },
        { { "big-spitter", "big-biter", "behemoth-spitter", "behemoth-biter" }, { 1, 2, 1, 2 }, 20 },
        { { "defender", "distractor", "destroyer", "behemoth-spitter", "behemoth-biter" }, { 2, 1, 1, 2, 2 }, 25 },
    }
    race_settings.featured_flying_groups = {
        { { "distractor", "destroyer" }, { 1, 1 }, 75 },
        { { "defender", "distractor", "destroyer" }, { 3, 1, 1 }, 75 },
        { { "logistic-robot", "defender", "distractor", "destroyer" }, { 1, 2, 2, 1 }, 75 },
    }


    RaceSettingsHelper.process_unit_spawn_rate_cache(race_settings)

    remote.call("enemyracemanager", "register_race", race_settings)

    script.raise_event(
            GlobalConfig.custom_event_handlers[GlobalConfig.RACE_SETTING_UPDATE],
            {affected_race = MOD_NAME }
    )
end

local prepare_world = function()
    GlobalConfig.initialize_races_data()

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
    RaceSettingsHelper.clean_up_race()
    SurfaceProcessor.rebuild_race()

    -- Calculate Biter Level
    --if table_size(storage.race_settings) > 0 then
    --    LevelProcessor.calculate_multiple_levels()
    --end

    AttackGroupBeaconProcessor.init_index()
    SurfaceProcessor.wander_unit_clean_up()
    -- See zerm_postprocess for additional post-process after race_mods loaded

    script.raise_event(
            GlobalConfig.custom_event_handlers[GlobalConfig.PREPARE_WORLD], {}
    )
end

local conditional_events = function()
    if storage.army_teleporter_event_running then
        ArmyTeleportationProcessor.start_event(true)
    end

    if storage.army_deployer_event_running then
        ArmyDeploymentProcessor.start_event(true)
    end

    if storage.quick_cron_is_running then
        script.on_nth_tick(GlobalConfig.QUICK_CRON, Cron.process_quick_queue)
    end

    if storage.boss and storage.boss.entity then
        script.on_nth_tick(GlobalConfig.BOSS_QUEUE_CRON, Cron.process_boss_queue)
    end
end

local init_globals = function()
    -- ID by mod name, each mod should have it own statistic out side of what force tracks.
    storage.race_settings = storage.race_settings or {}

    -- Move all cache to this to resolve desync issues.
    -- https://wiki.factorio.com/Desynchronization
    -- https://wiki.factorio.com/Tutorial:Modding_tutorial/Gangsir#Multiplayer_and_desyncs
    storage.settings = storage.settings or {}

    -- Use for decorative removal when building dies
    storage.decorative_cache = storage.decorative_cache or {}

    storage.installed_races = {}
    storage.active_races = {}
    storage.active_races_names = {}
    storage.active_races_num = 1
    storage.is_multi_planets_game = false

    --- SE or Space Age
    if script.active_mods["space-exploration"] or script.active_mods['space-age'] then
        storage.is_multi_planets_game = true
    end

    if script.active_mods['quality'] then
        storage.is_using_quality = true
    end

    SurfaceProcessor.init_globals()
    --MapProcessor.init_globals()
    ForceHelper.init_globals()
    Cron.init_globals()
    AttackGroupProcessor.init_globals()
    AttackGroupBeaconProcessor.init_globals()
    AttackGroupPathingProcessor.init_globals()
    AttackGroupHeatProcessor.init_globals()
    BossProcessor.init_globals()
    ArmyPopulationProcessor.init_globals()
    ArmyTeleportationProcessor.init_globals()
    ArmyDeploymentProcessor.init_globals()
    GuiContainer.init_globals()
    SpawnLocationScanner.init_globals()
    InterplanetaryAttacks.init_globals()
    QualityProcessor.on_init()


    --- Wipe this cache due to cache pollution from previous version.
    storage.force_race_name_cache = {}

    script.raise_event(
        GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_FLUSH_GLOBAL], {}
    )
end

--- Init events
local on_init = function(event)
    init_globals()
    GlobalConfig.refresh_config()
    addRaceSettings()
    prepare_world()
    conditional_events()
end

local on_load = function(event)
    Cron.rebuild_queue()
    conditional_events()
end

local on_configuration_changed = function(event)
    init_globals()
    GlobalConfig.refresh_config()
    addRaceSettings()
    prepare_world()
end

---Custom setting processors
local setting_functions = {
    ["enemyracemanager-max-gathering-groups"] = function(event)
        game.map_settings.unit_group.max_gathering_unit_groups = storage.settings[event.setting]
    end,
    ["enemyracemanager-max-group-size"] = function(event)
        game.map_settings.unit_group.max_unit_group_size = storage.settings[event.setting]
    end,
    ["enemyracemanager-army-limit-multiplier"] = function(event)
        for _, force in pairs(game.forces) do
            if ArmyPopulationProcessor.has_army_data(force) then
                ArmyPopulationProcessor.calculate_max_units(force)
            end
        end
    end
}
local on_runtime_mod_setting_changed = function(event)
    if event.setting_type == "runtime-global" and
            string.find(event.setting, "enemyracemanager", 1, true)
    then
        storage.settings[event.setting] = settings.global[event.setting].value

        if setting_functions[event.setting] then
            setting_functions[event.setting](event)
        end
    end
end

--- Initialize event names
GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_FLUSH_GLOBAL] = script.generate_event_name()
GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_ADJUST_ATTACK_METER] = script.generate_event_name()
GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_ADJUST_ACCUMULATED_ATTACK_METER] = script.generate_event_name()
GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_BASE_BUILT] = script.generate_event_name()
GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_INTERPLANETARY_ATTACK_SCAN] = script.generate_event_name()
GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_REQUEST_PATH] = script.generate_event_name()
GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_REQUEST_BASE_BUILD] = script.generate_event_name()
GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_INTERPLANETARY_ATTACK_EXEC] = script.generate_event_name()
GlobalConfig.custom_event_handlers[GlobalConfig.RACE_SETTING_UPDATE] = script.generate_event_name()
GlobalConfig.custom_event_handlers[GlobalConfig.PREPARE_WORLD] = script.generate_event_name()


local InitController = {}

InitController.events =
{
    [defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed
}

InitController.on_configuration_changed = on_configuration_changed

InitController.on_load = on_load

InitController.on_init = on_init

return InitController