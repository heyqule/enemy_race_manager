--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 03/26/2020
-- Time: 8:49 PM
-- To change this template use File | Settings | File Templates.
--
local util = require("util")

local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")

local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local AttackGroupHeatProcessor = require("__enemyracemanager__/lib/attack_group_heat_processor")
local AttackGroupProcessor = require("__enemyracemanager__/lib/attack_group_processor")
local QualityProcessor = require("__enemyracemanager__/lib/quality_processor")
local SurfaceProcessor = require("__enemyracemanager__/lib/surface_processor")
local BossProcessor = require("__enemyracemanager__/lib/boss_processor")
local InterplanetaryAttacks = require("__enemyracemanager__/lib/interplanetary_attacks")

local Debug_RemoteAPI = {}

--- Usage: remote.call("enemyracemanager_debug", "print_race_settings")
function Debug_RemoteAPI.print_race_settings()
    log(helpers.table_to_json(storage.race_settings))
end

--- Usage: remote.call("enemyracemanager_debug", "print_surface_races")
function Debug_RemoteAPI.print_surface_races()
    local value_table = {}
    for index, value in pairs(storage.enemy_surfaces) do
        value_table[game.surfaces[index].name] = value
    end
    log(helpers.table_to_json(value_table))
end

--- Usage: remote.call("enemyracemanager_debug", "print_forces")
function Debug_RemoteAPI.print_forces()
    log(helpers.table_to_json(game.forces))
end

--- Usage: remote.call("enemyracemanager_debug", "print_option_settings")
function Debug_RemoteAPI.print_option_settings()
    log(helpers.table_to_json(storage.settings))
end

--- Usage: remote.call("enemyracemanager_debug", "print_active_races")
function Debug_RemoteAPI.print_active_races()
    log(helpers.table_to_json(GlobalConfig.get_active_races()))
end

--- Usage: remote.call("enemyracemanager_debug", "print_enemy_races")
function Debug_RemoteAPI.print_enemy_races()
    log(helpers.table_to_json(GlobalConfig.get_enemy_races()))
end

--- Usage: remote.call("enemyracemanager_debug", "print_global")
function Debug_RemoteAPI.print_global()
    helpers.write_file("enemyracemanager/erm-storage.json", helpers.table_to_json(util.copy(storage)))

    for interface_name, functions in pairs(remote.interfaces) do
        if functions["print_global"] and interface_name ~= "enemyracemanager_debug" then
            remote.call(interface_name, "print_global")
        end
    end
end

--- Usage: remote.call("enemyracemanager_debug", "print_calculate_attack_points")
function Debug_RemoteAPI.print_calculate_attack_points()
    local table = {}
    for name, _ in pairs(storage.race_settings) do
        table[name] = {
            current_points = RaceSettingsHelper.get_attack_meter(name),
            next_threshold = RaceSettingsHelper.get_next_attack_threshold(name)
        }
    end
    log(helpers.table_to_json(table))
end

--- Usage: remote.call("enemyracemanager_debug", "exec_attack_group", "enemy_erm_zerg")
function Debug_RemoteAPI.exec_attack_group(force_name)
    AttackGroupProcessor.exec(
            force_name,
            game.forces[force_name],
            3000
    )
end

--- Usage: remote.call("enemyracemanager_debug", "exec_elite_group", "enemy_erm_zerg")
function Debug_RemoteAPI.exec_elite_group(force_name, attack_points)
    attack_points = attack_points or 3000
    AttackGroupProcessor.exec_elite_group(force_name, game.forces[force_name], attack_points)
end

--- Usage: remote.call("enemyracemanager_debug", "add_points_to_attack_meter", 500000)
function Debug_RemoteAPI.add_points_to_attack_meter(value)
    for name, settings in pairs(storage.race_settings) do
        if settings.attack_meter and not settings.is_primitive then
            RaceSettingsHelper.add_to_attack_meter(name, value)
        end            
    end
end

--- Usage: remote.call("enemyracemanager_debug", "set_accumulated_attack_meter", "enemy_erm_zerg", 500000)
function Debug_RemoteAPI.set_accumulated_attack_meter(force_name, value)
    RaceSettingsHelper.set_accumulated_attack_meter(force_name, value)
end


--- Usage: remote.call("enemyracemanager_debug", "set_evolution_factor", 0.5)
function Debug_RemoteAPI.set_evolution_factor(value)
    for force_name, _ in pairs(storage.race_settings) do
        local force = game.forces[force_name]
        if force then
            force.set_evolution_factor(math.min(value, 1))
        end
    end
end

--- Usage: remote.call("enemyracemanager_debug", "set_tier", 1)
function Debug_RemoteAPI.set_tier(value)
    for force_name, _ in pairs(storage.race_settings) do
        storage.race_settings[force_name].tier = math.min(value, 3)
        RaceSettingsHelper.refresh_current_tier(force_name)
    end
end

--- Usage: remote.call("enemyracemanager_debug", "set_boss_tier", 1)
function Debug_RemoteAPI.set_boss_tier(value)
    for force_name, _ in pairs(storage.race_settings) do
        storage.race_settings[force_name].boss_tier = math.max(1, math.min(value, 5))
    end
end

--- Usage: remote.call("enemyracemanager_debug", "reset_level")
function Debug_RemoteAPI.reset_level()
    for force_name, _ in pairs(storage.race_settings) do
        game.forces[force_name].set_evolution_factor(0)
    end
end

--- Usage: remote.call("enemyracemanager_debug", "attack_group_beacon_index")
function Debug_RemoteAPI.attack_group_beacon_index()
    AttackGroupBeaconProcessor.init_index()
end

--- Usage: remote.call("enemyracemanager_debug", "pick_spawn_location", "nauvis", "erm_marspeople", "player")
function Debug_RemoteAPI.pick_spawn_location(surface_name, force_name, target_force_name)
    local attack_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(game.surfaces[surface_name], game.forces[force_name], game.forces[target_force_name])
    local beacon = AttackGroupBeaconProcessor.pick_spawn_location(game.surfaces[surface_name], game.forces[force_name], attack_beacon)
    print(serpent.block(beacon))
end

--- Usage: remote.call("enemyracemanager_debug", "pick_attack_beacon", "nauvis", "erm_marspeople", "player")
function Debug_RemoteAPI.pick_attack_location(surface_name, source_force_name, target_force_name)
    local beacon = AttackGroupBeaconProcessor.pick_attack_beacon(game.surfaces[surface_name], game.forces[source_force_name] ,game.forces[target_force_name])
    print(serpent.block(beacon))
end

--- Usage: remote.call("enemyracemanager_debug", "wander_clean_up")
function Debug_RemoteAPI.wander_clean_up()
    SurfaceProcessor.wander_unit_clean_up()
end

function Debug_RemoteAPI.calculate_quality_points()
    QualityProcessor.calculate_quality_points()
end


--- Usage: remote.call("enemyracemanager_debug", "spawn_boss", {x=100,y=100})
function Debug_RemoteAPI.spawn_boss(position)
    local rocket_silos = game.surfaces[1].find_entities_filtered { name = "rocket-silo" }
    if rocket_silos and rocket_silos[1] then
        BossProcessor.exec(rocket_silos[1], position)
    end
end

--- Usage: remote.call("enemyracemanager_debug", "win_boss")
function Debug_RemoteAPI.win_boss()
    if storage.boss then
        storage.boss.victory = true
    end
end

--- Usage: remote.call("enemyracemanager_debug", "loss_boss")
function Debug_RemoteAPI.loss_boss()
    if storage.boss then
        storage.boss.despawn_at_tick = 1
    end
end

--- Usage: remote.call("enemyracemanager_debug", "forces_relation")
function Debug_RemoteAPI.forces_relation()
    local forces = game.forces
    for key = 1, #forces do
        local forceA = forces[key]
        print("------ " .. forceA.name .. " ------")
        for _, forceB in pairs(forces) do
            print(forceB.name .." is_friend: : " .. tostring(forceA.is_friend(forceB))..
                    ", get_friend: "..tostring(forceA.get_friend(forceB))..
                    ", get_cease_fire:"..tostring(forceA.get_cease_fire(forceB))
            )
        end
        print("------ END " .. forceA.name .. "------")
    end
end

--- Usage: remote.call("enemyracemanager_debug", "create_land_scout", "enemy", {x=100,y=100})
function Debug_RemoteAPI.create_land_scout(force_name, position)
   local surface = game.player.surface
    surface.create_entity({
        name = force_name.."--land-scout--1",
        position = position,
        force = force_name
    })
end

--- Usage: remote.call("enemyracemanager_debug", "create_air_scout", "enemy", {x=100,y=100})
function Debug_RemoteAPI.create_air_scout(force_name, position)
    local surface = game.player.surface
    surface.create_entity({
        name = force_name.."--aerial-scout--1",
        position = position,
        force = force_name
    })
end

--- Usage: remote.call("enemyracemanager_debug", "spawn_scout", "enemy", "player", "nauvis")
function Debug_RemoteAPI.spawn_scout(source_force_name, target_force_name, surface_name)
    local source_force = game.forces[source_force_name]
    local target_force = game.forces[target_force_name]
    local surface = game.surfaces[surface_name]
    AttackGroupProcessor.spawn_scout(source_force_name, source_force, surface, target_force)
end

--- Usage: remote.call("enemyracemanager_debug", "pick_surface", "enemy", "player")
function Debug_RemoteAPI.pick_surface(source_force_name, target_force_name)
    local target_force = game.forces[target_force_name]
    AttackGroupHeatProcessor.pick_surface(source_force_name, target_force)
end

--- remote.call("enemyracemanager_debug", "validate_erm_groups")
function Debug_RemoteAPI.validate_erm_groups()
    for id, content in pairs(storage.erm_unit_groups) do
        print(id.." = ".. tostring(content.group.valid))
    end
end

--- remote.call("enemyracemanager_debug", "interplanetary_attacks_queue_scan")
function Debug_RemoteAPI.interplanetary_attacks_scan()
    InterplanetaryAttacks.queue_scan()
end

--- remote.call("enemyracemanager_debug", "interplanetary_attacks_exec","enemy","players")
function Debug_RemoteAPI.interplanetary_attacks_exec(force_name, target_force, drop_location)
    InterplanetaryAttacks.exec(force_name, target_force, drop_location)
end

return Debug_RemoteAPI
