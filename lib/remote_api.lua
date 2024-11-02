--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/20/2020
-- Time: 5:36 PM
-- To change this template use File | Settings | File Templates.
--

local Event = require("__stdlib__/stdlib/event/event")

local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")
local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local AttackGroupProcessor = require("__enemyracemanager__/lib/attack_group_processor")
local BossGroupProcessor = require("__enemyracemanager__/lib/boss_group_processor")
local ArmyPopulationProcessor = require("__enemyracemanager__/lib/army_population_processor")
local ArmyTeleportationProcessor = require("__enemyracemanager__/lib/army_teleportation_processor")
local ArmyDeploymentProcessor = require("__enemyracemanager__/lib/army_deployment_processor")

local EnvironmentalAttack = require("__enemyracemanager__/lib/environmental_attacks")
local InterplanetaryAttack = require("__enemyracemanager__/lib/interplanetary_attacks")

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

--- Return race level
--- Usage: remote.call("enemyracemanager", "get_race_level", "erm_zerg")
function RemoteAPI.get_race_level(race)
    if storage.race_settings and
            storage.race_settings[race] and
            storage.race_settings[race].level then

        return storage.race_settings[race].level
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
--- Usage: remote.call("enemyracemanager", "add_points_to_attack_meter", "erm_zerg", 5000)
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
--- Usage: remote.call("enemyracemanager", "generate_attack_group", "erm_zerg", 100?)
function RemoteAPI.generate_attack_group(race_name, units_number)
    local force_name = ForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    units_number = tonumber(units_number)

    if force and units_number > 0 then
        AttackGroupProcessor.generate_group(race_name, force, units_number)
    end
end

--- Generate a flying attack group
--- Usage: remote.call("enemyracemanager", "generate_flying_group", "erm_zerg", 100?)
function RemoteAPI.generate_flying_group(race_name, units_number)
    local force_name = ForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    local flying_enabled = GlobalConfig.flying_squad_enabled() and RaceSettingsHelper.has_flying_unit(race_name)
    units_number = tonumber(units_number) or (GlobalConfig.max_group_size() / 2)

    if force and flying_enabled and units_number > 0 then
        AttackGroupProcessor.generate_group(
            race_name, force, units_number,
            {group_type = AttackGroupProcessor.GROUP_TYPE_FLYING}
        )
    end
end

--- Generate a dropship attack group
--- Usage: remote.call("enemyracemanager", "generate_dropship_group", "erm_zerg", 100?)
function RemoteAPI.generate_dropship_group(race_name, units_number)
    local force_name = ForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    local dropship_enabled = GlobalConfig.dropship_enabled() and RaceSettingsHelper.has_dropship_unit(race_name)
    units_number = tonumber(units_number) or (GlobalConfig.max_group_size() / 5)

    if force and dropship_enabled and units_number > 0 then
        AttackGroupProcessor.generate_group(
                race_name, force, units_number,
                {group_type = AttackGroupProcessor.GROUP_TYPE_DROPSHIP}
        )
    end
end

local is_valid_featured_squad = function(race_name, squad_id)
    return RaceSettingsHelper.has_featured_squad(race_name) and
            RaceSettingsHelper.get_total_featured_squads(race_name) > 0 and
            squad_id < RaceSettingsHelper.get_total_featured_squads(race_name)
end

local is_valid_featured_flying_squad = function(race_name, squad_id)
    return RaceSettingsHelper.has_featured_squad(race_name) and
            RaceSettingsHelper.get_total_featured_squads(race_name) > 0 and
            squad_id < RaceSettingsHelper.get_total_featured_squads(race_name)
end

--- Usage: remote.call("enemyracemanager", "generate_featured_group", "erm_zerg", 100?, 1?)
function RemoteAPI.generate_featured_group(race_name, size, squad_id)
    local force_name = ForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    squad_id = squad_id or RaceSettingsHelper.get_featured_flying_squad_id(race_name)
    if force and is_valid_featured_squad(race_name, squad_id) then
        size = size or GlobalConfig.max_group_size()
        AttackGroupProcessor.generate_group(
                race_name,
                game.forces[ForceHelper.get_force_name_from(race_name)],
                size,
                {
                    group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED,
                    featured_group_id = squad_id
                }
        )
    end
end

--- Usage: remote.call("enemyracemanager", "generate_featured_flying_group", "erm_zerg", 50?, 1?)
function RemoteAPI.generate_featured_flying_group(race_name, size, squad_id)
    local force_name = ForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    squad_id = squad_id or RaceSettingsHelper.get_featured_flying_squad_id(race_name)
    if force and is_valid_featured_flying_squad(race_name, squad_id) then
        size = size or (GlobalConfig.max_group_size() / 2)
        AttackGroupProcessor.generate_group(
                race_name,
                game.forces[ForceHelper.get_force_name_from(race_name)],
                size,
                {
                    group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
                    featured_group_id = squad_id
                }
        )
    end
end

--- Usage: remote.call("enemyracemanager", "generate_elite_featured_group", "erm_zerg", 100?, 1?)
function RemoteAPI.generate_elite_featured_group(race_name, size, squad_id)
    local force_name = ForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    squad_id = squad_id or RaceSettingsHelper.get_featured_flying_squad_id(race_name)
    if force and GlobalConfig.elite_squad_enable() and
            is_valid_featured_squad(race_name, squad_id)
    then
        size = size or GlobalConfig.max_group_size()
        AttackGroupProcessor.generate_group(
                race_name,
                game.forces[ForceHelper.get_force_name_from(race_name)],
                size,
                {
                    group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED,
                    featured_group_id = squad_id,
                    is_elite_attack = true
                }
        )
    end
end

--- Usage: remote.call("enemyracemanager", "generate_elite_featured_flying_group", "erm_zerg", 50?, 1?)
function RemoteAPI.generate_elite_featured_flying_group(race_name, size, squad_id)
    local force_name = ForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    squad_id = squad_id or RaceSettingsHelper.get_featured_flying_squad_id(race_name)
    if force and GlobalConfig.elite_squad_enable() and
            is_valid_featured_flying_squad(race_name, squad_id)
    then
        size = size or (GlobalConfig.max_group_size() / 2)
        AttackGroupProcessor.generate_group(
                race_name,
                game.forces[ForceHelper.get_force_name_from(race_name)],
                size,
                {
                    group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
                    featured_group_id = squad_id,
                    is_elite_attack = true
                }
        )
    end
end

--- Usage  remote.call("enemyracemanager", "spawn_environmental_attack", "nauvis", {x=100,y=200}, false?, false?)
function RemoteAPI.spawn_environmental_attack(surface, target_position, force_spawn, force_spawn_base)
    local surface_obj = game.surfaces[surface]
    if not surface then
        error("Surface name is required")
    end
    if not target_position then
       error("Target Position is required")
    end
    force_spawn = force_spawn or false
    force_spawn_base = force_spawn_base or false
    EnvironmentalAttack.exec(surface_obj, target_position, force_spawn, force_spawn_base)
end

--- Usage  remote.call("enemyracemanager", "spawn_interplanetary_attack", "erm_zerg", "players", {x=100,y=200})
function RemoteAPI.spawn_interplanetary_attack(race_name, target_force, drop_location)
    local race_settings = storage.race_settings[race_name]
    if not race_settings then
        error("Race name is required / invalid")
    end
    local force = game.forces[target_force]
    if not force then
        error("Target Force is required")
    end
    EnvironmentalAttack.exec(race_settings.race, force, drop_location)
end

--- Usage: remote.call("enemyracemanager", "add_boss_attack_group")
--- Assign unit group to manage by boss group logics
function RemoteAPI.add_boss_attack_group(group)
    if group.valid and next(group.members) then
        local group_data = BossGroupProcessor.get_default_data()
        group_data["group"] = group
        group_data["unique_id"] = group.unique_id
        group_data["total_units"] = table_size(group.members)
        table.insert(storage.boss_attack_groups, group_data)
    end
end

--- Usage: remote.call("enemyracemanager", "add_boss_attack_group")
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
                { type = "kill", name = "erm_vanilla/biter-spawner/5", quantity = 1 },
                { type = "kill", name = "erm_vanilla/biter-spawner/10", quantity = 1 },
                { type = "kill", name = "erm_vanilla/biter-spawner/15", quantity = 1 },
                { type = "kill", name = "erm_vanilla/biter-spawner/20", quantity = 1, next = "x10" },
            }
        }
    }
end

--- remote.call("enemyracemanager", "get_event_name", GlobalConfig.EVENT_TIER_WENT_UP)
--- script.on_event(event_name, function(event)
function RemoteAPI.get_event_name(event_name)
    return GlobalConfig.custom_event_handler[event_name]
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

--- AttackGroupBeaconProcessor
RemoteAPI.init_beacon_control_globals = AttackGroupBeaconProcessor.init_control_globals

return RemoteAPI
