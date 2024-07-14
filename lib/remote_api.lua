--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/20/2020
-- Time: 5:36 PM
-- To change this template use File | Settings | File Templates.
--

local Event = require('__stdlib__/stdlib/event/event')

local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local RaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local AttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')
local BossGroupProcessor = require('__enemyracemanager__/lib/boss_group_processor')
local ArmyPopulationProcessor = require('__enemyracemanager__/lib/army_population_processor')
local ArmyTeleportationProcessor = require('__enemyracemanager__/lib/army_teleportation_processor')
local ArmyDeploymentProcessor = require('__enemyracemanager__/lib/army_deployment_processor')

local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')

local ERM_RemoteAPI = {}

--- Create or update race setting
--- Usage: remote.call('enemyracemanager', 'register_race', {settings...})
function ERM_RemoteAPI.register_race(race_settings)
    if global and global.race_settings then
        global.race_settings[race_settings.race] = race_settings
        RaceSettingsHelper.process_unit_spawn_rate_cache(race_settings)
        RaceSettingsHelper.refresh_current_tier(race_settings.race)
    end
end

--- Return race setting
--- Usage: remote.call('enemyracemanager', 'get_race', 'erm_zerg')
function ERM_RemoteAPI.get_race(race)
    if global and global.race_settings and global.race_settings[race] then
        return global.race_settings[race]
    end
    return nil
end

--- Return race tier
--- Usage: remote.call('enemyracemanager', 'get_race_tier', 'erm_zerg')
function ERM_RemoteAPI.get_race_tier(race)
    if global and global.race_settings and
            global.race_settings[race] and global.race_settings[race].tier then

        return global.race_settings[race].tier
    end
    return 1
end

--- Return race level
--- Usage: remote.call('enemyracemanager', 'get_race_level', 'erm_zerg')
function ERM_RemoteAPI.get_race_level(race)
    if global.race_settings and
            global.race_settings[race] and
            global.race_settings[race].level then

        return global.race_settings[race].level
    end
    return 1
end

function ERM_RemoteAPI.get_boss_data()
    if global.boss and global.boss.entity then
        return global.boss
    end
    return nil
end

--- Add points to attack meter of a race
--- Usage: remote.call('enemyracemanager', 'add_points_to_attack_meter', 'erm_zerg', 5000)
function ERM_RemoteAPI.add_points_to_attack_meter(race, value)
    local races = GlobalConfig.get_enemy_races()
    race = race or races[math.random(1, GlobalConfig.get_enemy_races_total())]

    if global.race_settings and
            global.race_settings[race]
    then
        RaceSettingsHelper.add_to_attack_meter(race, value)
    end

end

--- Proper way to update race_setting in enemy mods ---
--- 1. local race_settings =  remote.call('enemyracemanager', 'get_race', MOD_NAME)
--- 2. make change to race_settings
--- 3. remote.call('enemyracemanager', 'update_race_setting', race_settings)
function ERM_RemoteAPI.update_race_setting(race_setting)
    if global and global.race_settings and global.race_settings[race_setting.race] then
        global.race_settings[race_setting.race] = race_setting
        RaceSettingsHelper.refresh_current_tier(race_setting.race)
    end
end

--- Generate a mixed attack group
--- Usage: remote.call('enemyracemanager', 'generate_attack_group', 'erm_zerg', 100)
function ERM_RemoteAPI.generate_attack_group(race_name, units_number)
    local force_name = ForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    units_number = tonumber(units_number)

    if force and units_number > 0 then
        AttackGroupProcessor.generate_group(race_name, force, units_number)
    end
end

--- Generate a flying attack group
--- Usage: remote.call('enemyracemanager', 'generate_flying_group', 'erm_zerg', 100)
function ERM_RemoteAPI.generate_flying_group(race_name, units_number)
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
--- Usage: remote.call('enemyracemanager', 'generate_dropship_group', 'erm_zerg', 100)
function ERM_RemoteAPI.generate_dropship_group(race_name, units_number)
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

--- Usage: remote.call('enemyracemanager', 'generate_featured_group', 'erm_zerg', 100, 1)
function ERM_RemoteAPI.generate_featured_group(race_name, size, squad_id)
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

--- Usage: remote.call('enemyracemanager', 'generate_featured_flying_group', 'erm_zerg', 50, 1)
function ERM_RemoteAPI.generate_featured_flying_group(race_name, size, squad_id)
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

--- Usage: remote.call('enemyracemanager', 'generate_elite_featured_group', 'erm_zerg', 100, 1)
function ERM_RemoteAPI.generate_elite_featured_group(race_name, size, squad_id)
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

--- Usage: remote.call('enemyracemanager', 'generate_elite_featured_flying_group', 'erm_zerg', 50, 1)
function ERM_RemoteAPI.generate_elite_featured_flying_group(race_name, size, squad_id)
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

function ERM_RemoteAPI.add_boss_attack_group(group)
    if group.valid and next(group.members) then
        local group_data = BossGroupProcessor.get_default_data()
        group_data['group'] = group
        group_data['group_number'] = group.group_number
        group_data['total_units'] = table_size(group.members)
        table.insert(global.boss_attack_groups, group_data)
    end
end

function ERM_RemoteAPI.add_erm_attack_group(group, target_force)
    if group.valid and next(group.members) then
        global.erm_unit_groups[group.group_number] = {
            group = group,
            start_position = group.position,
            nearby_retry = 0,
            attack_force = target_force,
            created = game.tick
        }
    end
end

function ERM_RemoteAPI.override_strategy(strategy_id)
    global.override_strategy = strategy_id
end

function ERM_RemoteAPI.milestones_preset_addons()
    if settings.startup['enemyracemanager-enable-bitters'].value then
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

    return {}
end

--- remote.call('enemyracemanager', 'get_event_name', GlobalConfig.EVENT_TIER_WENT_UP)
--- Doesn't work lol... Events will need to redone in 2.0 without stdlib.
function ERM_RemoteAPI.get_event_name(event_name)
    return Event.get_event_name(event_name)
end

--- ForceHelper
ERM_RemoteAPI.force_data_reindex = ForceHelper.refresh_all_enemy_forces

ERM_RemoteAPI.is_enemy_force = ForceHelper.is_enemy_force

--- ArmyPopulationProcessor
ERM_RemoteAPI.army_units_register = ArmyPopulationProcessor.register_unit
ERM_RemoteAPI.army_reindex = ArmyPopulationProcessor.index

--- ArmyTeleportationProcessor
ERM_RemoteAPI.army_command_center_register = ArmyTeleportationProcessor.register_building

--- ArmyDeploymentProcessor
ERM_RemoteAPI.army_deployer_register = ArmyDeploymentProcessor.register_building

--- AttackGroupBeaconProcessor
ERM_RemoteAPI.init_beacon_control_globals = AttackGroupBeaconProcessor.init_control_globals

return ERM_RemoteAPI
