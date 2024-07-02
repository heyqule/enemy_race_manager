---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 9:47 PM
---
local Event = require('__stdlib__/stdlib/event/event')
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local Config = require('__enemyracemanager__/lib/global_config')
local RaceSettingHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local SurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local AttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')

local CustomAttacks = require('__enemyracemanager__/prototypes/base-units/custom_attacks')
local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local EnvironmentalAttacks = require('__enemyracemanager__/lib/environmental_attacks')
local ArmyPopulation = require('__enemyracemanager__/lib/army_population_processor')
local ArmyControlUI = require('__enemyracemanager__/gui/army_control_window')

local ArmyDeployer = require('__enemyracemanager__/lib/army_deployment_processor')
local RallyPointUI = require('__enemyracemanager__/gui/deployer_attachment')

-- Player super weapon attacks functions
local process_attack_point_event = function(event, attack_point)
    local race_name = SurfaceProcessor.get_enemy_on(game.surfaces[event.surface_index].name)
    if race_name then
        RaceSettingHelper.add_to_attack_meter(race_name, attack_point)
    end
end

local process_counter_attack_event = function(event, radius)
    AttackGroupProcessor.generate_nuked_group(game.surfaces[event.surface_index], event.target_position, radius, event.source_entity)
end

local is_valid_attack_for_attack_point = function(event)
    return Config.super_weapon_attack_points_enable() and game.surfaces[event.surface_index].valid
end

local is_valid_attack_for_counter_attack = function(event)
    return Config.super_weapon_counter_attack_enable() and game.surfaces[event.surface_index].valid
end

local script_functions = {

    --- Biter attacks
    [CONSTRUCTION_ATTACK] = function(args)
        if CustomAttacks.valid(args, MOD_NAME) then
            CustomAttacks.process_constructor(args)
        end
    end,
    [LOGISTIC_ATTACK] = function(args)
        if CustomAttacks.valid(args, MOD_NAME) then
            CustomAttacks.process_logistic(args)
        end
    end,

    --- Player super weapon attacks
    [PLAYER_SUPER_WEAPON_ATTACK] = function(event)
        if is_valid_attack_for_attack_point(event) then
            process_attack_point_event(event, Config.super_weapon_attack_points())
        end
    end,
    [PLAYER_PLANET_PURIFIER_ATTACK] = function(event)
        if is_valid_attack_for_attack_point(event) then
            process_attack_point_event(event, Config.super_weapon_attack_points() * 200)
        end
    end,
    [PLAYER_SUPER_WEAPON_COUNTER_ATTACK] = function(event)
        if is_valid_attack_for_counter_attack(event) then
            process_counter_attack_event(event, 48)
        end
    end,
    [PLAYER_PLANET_PURIFIER_COUNTER_ATTACK] = function(event)
        if is_valid_attack_for_counter_attack(event) then
            process_counter_attack_event(event, 96)
        end
    end,

    --- Boss related
    [TRIGGER_BOSS_DIES] = function(args)
        global.boss.victory = true
    end,

    --- Attack group beacons
    [LAND_SCOUT_BEACON] = function(event)
        AttackGroupBeaconProcessor.create_defense_beacon(event.source_entity, AttackGroupBeaconProcessor.LAND_BEACON)
        AttackGroupBeaconProcessor.create_attack_entity_beacon(event.source_entity)
    end,
    [AERIAL_SCOUT_BEACON] = function(event)
        AttackGroupBeaconProcessor.create_defense_beacon(event.source_entity, AttackGroupBeaconProcessor.AERIAL_BEACON)
        AttackGroupBeaconProcessor.create_attack_entity_beacon(event.source_entity)
    end,

    --- Army Population
    [ARMY_POPULATION_INCREASE] = function(event)
        local unit = event.source_entity
        if unit and unit.valid and ArmyPopulation.can_place_unit(unit) then
            ArmyPopulation.add_unit_count(unit)
        else
            if unit.last_user then
                unit.last_user.print('You need additional Follower Count Research!')
                unit.last_user.insert { name = unit.name, count = 1 }
                unit.last_user.play_sound({ path = 'erm-army-full-population' })
            end
            unit.destroy()
            ArmyControlUI.update_army_stats()
        end
    end,
    [ARMY_POPULATION_DECREASE] = function(event)
        local unit = event.source_entity
        if unit and unit.valid then
            ArmyPopulation.remove_unit_count(unit)
            unit.force.play_sound({ path = 'erm-army-force-under-attack-by-chance' })
            ArmyControlUI.update_army_stats()
        end
    end,

    [ARMY_RALLYPOINT_DEPLOY] = function(event)
        local rallypoint = event.source_entity
        if rallypoint and rallypoint.valid then
            rallypoint.destructible = false
            local player = event.source_entity.last_user
            local ui = player.gui.relative[RallyPointUI.root_name]
            if ui then
                ArmyDeployer.add_rallypoint(rallypoint, ui.tags.unit_number)
                rallypoint.destroy()
                player.game_view_settings.show_entity_info = true
                RallyPointUI.show(player, ui.tags.unit_number)
            end
        end
    end,

    [ENVIRONMENTAL_ATTACK] = function(event)
        local surface = game.surfaces[event.surface_index]
        local target_position = event.target_position

        local force_spawn, force_spawn_home
        if TEST_MODE then
            force_spawn = RaceSettingHelper.can_spawn(Config.environmental_attack_raid_chance())
            if global.test_environmental_attack_can_spawn == 1 then
                force_spawn = true
            elseif global.test_environmental_attack_can_spawn == -1 then
                force_spawn = false
            end

            if global.test_environmental_attack_spawn_home == 1 then
                force_spawn_home = true
            elseif global.test_environmental_attack_spawn_home == -1 then
                force_spawn_home = false
            end
        end
        
        EnvironmentalAttacks.exec(surface, target_position, force_spawn, force_spawn_home)
    end
}
Event.register(defines.events.on_script_trigger_effect, function(event)
    if script_functions[event.effect_id] then
        script_functions[event.effect_id](event)
    end
end)