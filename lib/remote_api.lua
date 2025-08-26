--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/20/2020
-- Time: 5:36 PM
-- To change this template use File | Settings | File Templates.
--

local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")
local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local AttackGroupProcessor = require("__enemyracemanager__/lib/attack_group_processor")
local AttackMeterProcessor = require("__enemyracemanager__/lib/attack_meter_processor")

local ArmyPopulationProcessor = require("__enemyracemanager__/lib/army_population_processor")
local ArmyTeleportationProcessor = require("__enemyracemanager__/lib/army_teleportation_processor")
local ArmyDeploymentProcessor = require("__enemyracemanager__/lib/army_deployment_processor")
local QualityProcessor = require("__enemyracemanager__/lib/quality_processor")
local BaseBuildProcessor = require("__enemyracemanager__/lib/base_build_processor")

local EnvironmentalAttacks = require("__enemyracemanager__/lib/environmental_attacks")
local InterplanetaryAttacks = require("__enemyracemanager__/lib/interplanetary_attacks")


local RemoteAPI = {}

--- Create or update race setting
--- Usage: remote.call("enemyracemanager", "register_race", {settings...})
function RemoteAPI.register_race(race_settings)
    if storage and storage.race_settings then
        storage.race_settings[race_settings.race] = race_settings
        RaceSettingsHelper.process_unit_spawn_rate_cache(race_settings)
        RaceSettingsHelper.refresh_current_tier(race_settings.race)
    end
end

--- Return race setting
--- Usage: remote.call("enemyracemanager", "get_race", "erm_zerg")
function RemoteAPI.get_race(race)
    if storage and storage.race_settings and storage.race_settings[race] then
        return storage.race_settings[race]
    end
    return nil
end

--- Return race tier
--- Usage: remote.call("enemyracemanager", "get_race_tier", "erm_zerg")
function RemoteAPI.get_race_tier(race)
    if storage and storage.race_settings and
            storage.race_settings[race] and storage.race_settings[race].tier then

        return storage.race_settings[race].tier
    end
    return 1
end

function RemoteAPI.get_boss_data()
    if storage.boss and storage.boss.entity then
        return storage.boss
    end
    return nil
end

--- Add points to attack meter of a race
--- Usage: remote.call("enemyracemanager", "add_points_to_attack_meter", "enemy_erm_zerg", 5000)
function RemoteAPI.add_points_to_attack_meter(race, value)
    local races = GlobalConfig.get_enemy_races()
    race = race or races[math.random(1, GlobalConfig.get_enemy_races_total())]

    if storage.race_settings and
            storage.race_settings[race]
    then
        RaceSettingsHelper.add_to_attack_meter(race, value)

        return true
    end

    return false
end

--- Proper way to update race_setting in enemy mods ---
--- 1. local race_settings = remote.call("enemyracemanager", "get_race", MOD_NAME)
--- 2. make change to race_settings
--- 3. remote.call("enemyracemanager", "update_race_setting", race_settings)
function RemoteAPI.update_race_setting(race_setting)
    if storage and storage.race_settings and storage.race_settings[race_setting.race] then
        storage.race_settings[race_setting.race] = race_setting
        RaceSettingsHelper.refresh_current_tier(race_setting.race)

        return true
    end

    return false
end

--- Generate a mixed attack group
--- Usage: remote.call("enemyracemanager", "generate_attack_group", "enemy_erm_zerg", 100?, options?)
function RemoteAPI.generate_attack_group(force_name, units_number, options)
    local force = game.forces[force_name]
    units_number = tonumber(units_number) or GlobalConfig.max_group_size()
    options = options or {}
    options.group_type =  AttackGroupProcessor.GROUP_TYPE_MIXED

    if force and units_number > 0 then
        AttackGroupProcessor.generate_group(force, units_number,options)
    end
end

--- Generate a flying attack group
--- Usage: remote.call("enemyracemanager", "generate_flying_group", "enemy_erm_zerg", 100?, options?)
function RemoteAPI.generate_flying_group(force_name, units_number, options)
    local force = game.forces[force_name]
    local flying_enabled = GlobalConfig.flying_squad_enabled() and RaceSettingsHelper.has_flying_unit(force_name)
    units_number = tonumber(units_number) or (GlobalConfig.max_group_size() / 2)
    options = options or {}
    options.group_type =  AttackGroupProcessor.GROUP_TYPE_FLYING

    if force and flying_enabled and units_number > 0 then
        AttackGroupProcessor.generate_group(force, units_number, options)
    end
end

--- Generate a dropship attack group
--- Usage: remote.call("enemyracemanager", "generate_dropship_group", "enemy_erm_zerg", 100?, options?)
function RemoteAPI.generate_dropship_group(force_name, units_number, options)
    local force = game.forces[force_name]
    local dropship_enabled = GlobalConfig.dropship_enabled() and RaceSettingsHelper.has_dropship_unit(force_name)
    units_number = tonumber(units_number) or (GlobalConfig.max_group_size() / 5)
    options = options or {}
    options.group_type =  AttackGroupProcessor.GROUP_TYPE_DROPSHIP

    if force and dropship_enabled and units_number > 0 then
        AttackGroupProcessor.generate_group(force, units_number, options)
    end
end

local is_valid_featured_squad = function(force_name, squad_id)
    return RaceSettingsHelper.has_featured_squad(force_name) and
            RaceSettingsHelper.get_total_featured_squads(force_name) > 0 and
            squad_id <= RaceSettingsHelper.get_total_featured_squads(force_name)
end

local is_valid_featured_flying_squad = function(force_name, squad_id)
    return RaceSettingsHelper.has_featured_squad(force_name) and
            RaceSettingsHelper.get_total_featured_squads(force_name) > 0 and
            squad_id <= RaceSettingsHelper.get_total_featured_squads(force_name)
end

--- Usage: remote.call("enemyracemanager", "generate_featured_group", "enemy_erm_zerg", 100?, 1?)
function RemoteAPI.generate_featured_group(force_name, size, squad_id)
    local force = game.forces[force_name]
    squad_id = squad_id or RaceSettingsHelper.get_featured_flying_squad_id(force_name)
    if force and is_valid_featured_squad(force_name, squad_id) then
        size = size or GlobalConfig.max_group_size()
        AttackGroupProcessor.generate_group(
                game.forces[force_name],
                size,
                {
                    group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED,
                    featured_group_id = squad_id
                }
        )
    end
end

--- Usage: remote.call("enemyracemanager", "generate_featured_flying_group", "enemy_erm_zerg", 50?, 1?)
function RemoteAPI.generate_featured_flying_group(force_name, size, squad_id)
    local force = game.forces[force_name]
    squad_id = squad_id or RaceSettingsHelper.get_featured_flying_squad_id(force_name)
    if force and is_valid_featured_flying_squad(force_name, squad_id) then
        size = size or (GlobalConfig.max_group_size() / 2)
        AttackGroupProcessor.generate_group(
                game.forces[force_name],
                size,
                {
                    group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
                    featured_group_id = squad_id
                }
        )
    end
end

--- Usage: remote.call("enemyracemanager", "generate_elite_featured_group", "enemy_erm_zerg", 100?, 1?)
function RemoteAPI.generate_elite_featured_group(force_name, size, squad_id)
    local force = game.forces[force_name]
    squad_id = squad_id or RaceSettingsHelper.get_featured_flying_squad_id(force_name)
    if force and GlobalConfig.elite_squad_enable() and
            is_valid_featured_squad(force_name, squad_id)
    then
        size = size or GlobalConfig.max_group_size()
        AttackGroupProcessor.generate_group(
                game.forces[force_name],
                size,
                {
                    group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED,
                    featured_group_id = squad_id,
                    is_elite_attack = true
                }
        )
    end
end

--- Usage: remote.call("enemyracemanager", "generate_elite_featured_flying_group", "enemy_erm_zerg", 50?, 1?)
function RemoteAPI.generate_elite_featured_flying_group(force_name, size, squad_id)
    local force = game.forces[force_name]
    squad_id = squad_id or RaceSettingsHelper.get_featured_flying_squad_id(force_name)
    if force and GlobalConfig.elite_squad_enable() and
            is_valid_featured_flying_squad(force_name, squad_id)
    then
        size = size or (GlobalConfig.max_group_size() / 2)
        AttackGroupProcessor.generate_group(
                game.forces[force_name],
                size,
                {
                    group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
                    featured_group_id = squad_id,
                    is_elite_attack = true
                }
        )
    end
end

--- Usage  remote.call("enemyracemanager", "spawn_environmental_attack", "nauvis", {x=100,y=200}, false?, false?, 5?, 50?)
function RemoteAPI.spawn_environmental_attack(surface, target_position, force_spawn, force_spawn_base, spawn_count, spawn_chance)
    local surface_obj = game.surfaces[surface]
    if not surface then
        error("Surface name is required")
    end
    if not target_position then
       error("Target Position is required")
    end
    force_spawn = force_spawn or false
    force_spawn_base = force_spawn_base or false
    spawn_count = spawn_count or 5
    spawn_chance = spawn_chance or 5
    EnvironmentalAttacks.exec({
        surface = surface_obj,
        target_position = target_position,
        force_spawn = force_spawn,
        force_spawn_home = force_spawn_base,
        spawn_count = spawn_count,
        spawn_chance = spawn_chance
    })
end

--- Usage  remote.call("enemyracemanager", "spawn_interplanetary_attack", "enemy_erm_zerg", "players", {x=100,y=200})
function RemoteAPI.spawn_interplanetary_attack(force_name, target_force, drop_location)
    local race_settings = storage.race_settings[force_name]
    if not race_settings then
        error("Race name is required / invalid")
    end
    local force = game.forces[target_force]
    if not force then
        error("Target Force is required")
    end
    InterplanetaryAttacks.exec(race_settings.race, force, drop_location)
end

--- Usage: remote.call("enemyracemanager", "add_erm_attack_group", group, target_force)
--- Assign unit group to ERM attack group, which manage by ERM group logics
function RemoteAPI.add_erm_attack_group(group, target_force)
    if group.valid and next(group.members) then
        storage.erm_unit_groups[group.unique_id] = {
            group = group,
            start_position = group.position,
            nearby_retry = 0,
            attack_force = target_force,
            created = game.tick
        }
    end
end

--- Usage: remote.call("enemyracemanager", "is_erm_group")
--- Check whether the group is managed by ERM.
function RemoteAPI.is_erm_group(group)
    if group.valid then
        if storage.erm_unit_groups[group.unique_id] then
            return true
        end

        if storage.group_tracker[group.force.name] and
           storage.group_tracker[group.force.name]["unique_id"] == group.unique_id then
            return true
        end 
    end
    
    return false
end

--- Overriding certain control variables
function RemoteAPI.override_attack_strategy(strategy_id)
    if strategy_id < 1 or strategy_id > 3 then
        error("ERMAPI.override_attack_strategy: Invalid Attack Strategy. Choose 1. Smart BrutalForce, 2. Route to left, 3. Route to right")
    end
    storage.override_attack_strategy = strategy_id
end

function RemoteAPI.milestones_preset_addons()
    return {
        ["enemyracemanager"] = {
            required_mods = { "enemyracemanager" },
            milestones = {
                { type = "group", name = "Kills" },
                { type = "kill", name = "enemy--biter-spawner--1", quantity = 1 },
                { type = "kill", name = "enemy--biter-spawner--2", quantity = 1 },
                { type = "kill", name = "enemy--biter-spawner--3", quantity = 1 },
                { type = "kill", name = "enemy--biter-spawner--4", quantity = 1 },
                { type = "kill", name = "enemy--biter-spawner--5", quantity = 1, next = "x10" },
            }
        }
    }
end

function RemoteAPI.advanced_target_priorities_register_section_data()
    local data = {
        {
            delimiter = '--',
            name = "biters",
            prefix = 'enemy',
            suffix = nil,
            --- 4 type of options 'size', 'unit_type', 'tier','variant'
            options = {
                {'small','medium','big','behemoth'},
                {'biter','spitter'},
                {1,2,3,4,5}
            },
            --- controls order of text concatenation
            option_titles = {
                'size', 'unit_type', 'tier'
            },
            option_delimiters = {
                '-'
            }
        },
        {
            delimiter = '--',
            name = "corrupt-robots",
            prefix = 'enemy',
            suffix = nil,
            options = {
                {'defender','distractor','destroyer','logistic-robot','construction-robot'},
                {1,2,3,4,5}
            },
            option_titles = {
                'unit_type', 'tier'
            },
            option_delimiters = {}
        },
    }
    

    if script.active_mods["Toxic_biters"] or script.active_mods["Cold_biters"] or 
       script.active_mods["ArmouredBiters"] or script.active_mods["Explosive_biters"] then
        data['leviathan_units'] = {
            delimiter = '-',
            name = "leviathan_units",
            prefix = nil,
            suffix = nil,
            options = {
                {'leviathan','mother'},
                {}
            },
            option_titles = {
                'size','unit_type' 
            },
            option_delimiters = {}
        }
        data["biter_variants"] = {
            delimiter = '--',
            name = "biter_variants",
            prefix = 'enemy',
            suffix = nil,
            options = {
                {'small','medium','big','behemoth'},
                {},
                {'biter','spitter'},
                {1,2,3,4,5}
            },
            option_titles = {
                'size', 'variant', 'unit_type', 'tier'
            },
            option_delimiters = {
                '-','-',
            }
        }
    end
    if script.active_mods["Toxic_biters"] then
        table.insert(data['biter_variants']['options'][2], 'toxic')
        table.insert(data['leviathan_units']['options'][2], 'toxic-biter')
        table.insert(data['leviathan_units']['options'][2], 'toxic-spitter')        
    end
    if script.active_mods["Cold_biters"] then
        table.insert(data['biter_variants']['options'][2], 'cold')
        table.insert(data['leviathan_units']['options'][2], 'cold-biter')
        table.insert(data['leviathan_units']['options'][2], 'cold-spitter')
    end
    if script.active_mods["Explosive_biters"] then
        table.insert(data['biter_variants']['options'][2], 'explosive')
        table.insert(data['leviathan_units']['options'][2], 'explosive-biter')
        table.insert(data['leviathan_units']['options'][2], 'explosive-spitter')
    end
    if script.active_mods["ArmouredBiters"] then
        table.insert(data['biter_variants']['options'][2], 'armoured')
        table.insert(data['leviathan_units']['options'][2], 'armoured-biter')
    end
    return data
end

--- Register native forces
function RemoteAPI.register_new_enemy_race()
    local data = { FORCE_NAME }

    if script.active_mods["space-age"] then
        table.insert(data, GLEBA_FORCE_NAME) 
    end

    return data
end

--- remote.call("enemyracemanager", "get_event_name", GlobalConfig.EVENT_TIER_WENT_UP)
--- script.on_event(event_name, function(event)
function RemoteAPI.get_event_name(event_name)
    return GlobalConfig.custom_event_handlers[event_name]
end

--- ForceHelper
RemoteAPI.force_data_reindex = ForceHelper.refresh_all_enemy_forces

RemoteAPI.is_enemy_force = ForceHelper.is_enemy_force

--- ArmyPopulationProcessor
RemoteAPI.army_units_register = ArmyPopulationProcessor.register_unit
RemoteAPI.army_reindex = ArmyPopulationProcessor.index

--- ArmyTeleportationProcessor
RemoteAPI.army_command_center_register = ArmyTeleportationProcessor.register_building

--- ArmyDeploymentProcessor
RemoteAPI.army_deployer_register = ArmyDeploymentProcessor.register_building

RemoteAPI.calculate_attack_points = AttackMeterProcessor.calculate_points

--- AttackGroupBeaconProcessor
RemoteAPI.init_beacon_control_globals = AttackGroupBeaconProcessor.init_control_globals

--- Base build processor
RemoteAPI.build_base_formation = BaseBuildProcessor.build_formation

--- Quality Points
RemoteAPI.calculate_quality_points = QualityProcessor.calculate_quality_points
RemoteAPI.get_quality_point = QualityProcessor.get_quality_point
RemoteAPI.roll_quality = QualityProcessor.roll_quality
RemoteAPI.skip_roll_quality = QualityProcessor.skip_roll_quality

--- AttackGroupProcessor
RemoteAPI.process_attack_position = AttackGroupProcessor.process_attack_position



return RemoteAPI
