---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 10/4/2021 12:09 AM
---
---

require("util")

local Config = require("__enemyracemanager__/lib/global_config")
local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")

local AttackGroupHeatProcessor = {}

AttackGroupHeatProcessor.COOLDOWN_VALUE = 10
AttackGroupHeatProcessor.DEFAULT_VALUE = 5

local PLAYER = 1
local NAUVIS = 1

local init_data = function(force_name, surface_index)
    if  storage.attack_heat[force_name] == nil or
        storage.attack_heat[force_name][surface_index] == nil
    then
        storage.attack_heat[force_name] = storage.attack_heat[force_name] or {}
        storage.attack_heat[force_name][surface_index] = storage.attack_heat[force_name][surface_index] or {}
    end
end

AttackGroupHeatProcessor.init_globals = function()
    --- storage.attack_heat[race_index][surface_index][attacker_force_index]
    storage.attack_heat = storage.attack_heat or {}
    storage.attack_heat_by_forces = storage.attack_heat_by_forces or {}
    storage.attack_heat_by_surfaces = storage.attack_heat_by_surfaces or {}
end

AttackGroupHeatProcessor.reset_globals = function()
    storage.attack_heat = {}
    storage.attack_heat_by_forces = storage.attack_heat_by_forces or {}
    storage.attack_heat_by_surfaces = storage.attack_heat_by_surfaces or {}
end

--- Handle removing surface data
AttackGroupHeatProcessor.remove_surface = function(surface_index)
    for active_race, _ in pairs(storage.active_races) do
        if storage.attack_heat[active_race] and storage.attack_heat[active_race][surface_index] then
            storage.attack_heat[active_race][surface_index] = nil
            AttackGroupHeatProcessor.aggregate_heat(active_race)
        end
    end
end

--- Handle removing player force data
AttackGroupHeatProcessor.remove_force = function(attacker_index)
    for active_race, _ in pairs(storage.active_races) do
        if storage.attack_heat[active_race] then
            for _, surface_data in pairs(storage.attack_heat[active_race]) do
                if surface_data[attacker_index] then
                    surface_data[attacker_index] = nil
                end
            end
        end

        AttackGroupHeatProcessor.aggregate_heat(active_race)
    end
end

AttackGroupHeatProcessor.calculate_heat = function(force_name, surface_index, attacker_index, heat_points)
    if force_name == nil then
        return
    end
    init_data(force_name, surface_index)
    local points = storage.attack_heat[force_name][surface_index][attacker_index] or 0
    heat_points = heat_points or AttackGroupHeatProcessor.DEFAULT_VALUE
    points = points + heat_points
    storage.attack_heat[force_name][surface_index][attacker_index] = points
end

AttackGroupHeatProcessor.cooldown_heat = function(force_name)
    local attack_heat = storage.attack_heat[force_name]
    if attack_heat == nil then
        return nil
    end

    for surface_index, surface_data in pairs(attack_heat) do
        for attacker_index, points in pairs(surface_data) do
            points = points - AttackGroupHeatProcessor.COOLDOWN_VALUE
            if points > 0 then
                attack_heat[surface_index][attacker_index] = points
            else
                --- Remove itself from calculation
                attack_heat[surface_index][attacker_index] = nil
            end
        end
    end
end

AttackGroupHeatProcessor.aggregate_heat = function(force_name)
    if storage.attack_heat[force_name] == nil then
        storage.attack_heat_by_surfaces[force_name] = nil
        storage.attack_heat_by_forces[force_name] = nil
        return nil
    end

    local attack_heat_by_surfaces = {}
    local attack_heat_by_forces = {}

    --- Aggregate
    for surface_index, surface_data in pairs(storage.attack_heat[force_name]) do
        local surface_heat = attack_heat_by_surfaces[surface_index] or { surface_index = surface_index, heat = 0 }
        for attacker_index, points in pairs(surface_data) do
            local force_heat = attack_heat_by_forces[attacker_index] or { attacker_index = attacker_index, heat = 0 }
            force_heat.heat = force_heat.heat + points
            surface_heat.heat = surface_heat.heat + points
            attack_heat_by_forces[attacker_index] = force_heat
        end
        attack_heat_by_surfaces[surface_index] = surface_heat
    end

    --- Sort
    local sorted_surfaces = {}
    local sorted_forces = {}
    for _, surface_data in pairs(attack_heat_by_surfaces) do
        --- Check whether surface has attackable entity
        local surface = game.get_surface(surface_data.surface_index)
        if surface and AttackGroupBeaconProcessor.has_attack_entity_beacon(surface) then
            surface_data.has_attack_beacon = true
        end
        table.insert(sorted_surfaces, surface_data)
    end
    for _, attacker_data in pairs(attack_heat_by_forces) do
        table.insert(sorted_forces, attacker_data)
    end

    table.sort(sorted_surfaces, function(a, b) return a.heat > b.heat  end)
    table.sort(sorted_forces, function(a, b) return a.heat > b.heat  end)

    --- Assign storage
    storage.attack_heat_by_surfaces[force_name] = sorted_surfaces
    storage.attack_heat_by_forces[force_name] = sorted_forces
end

AttackGroupHeatProcessor.pick_surface = function(force_name, target_force, ask_friend)
    target_force = target_force or game.forces[PLAYER]
    local surface_data = storage.attack_heat_by_surfaces[force_name]
    local return_surface = nil
    if storage.is_multi_planets_game and
        surface_data and
        storage.total_enemy_surfaces > 1
    then
        local _, surface = next(surface_data)
        if surface and surface.has_attack_beacon then
            return_surface = game.surfaces[surface.surface_index]
        else
            for _, surface in pairs(surface_data) do
                if surface.has_attack_beacon then
                    return_surface = game.surfaces[surface.surface_index]
                    break;
                end
            end
        end

        if not return_surface or storage.override_interplanetary_attack_enabled then
            local ask_friend_roll = nil
            local interplanetary_attack_enable = Config.interplanetary_attack_enable()

            if interplanetary_attack_enable then
                ask_friend_roll = storage.override_ask_friend
                if ask_friend_roll == nil then
                    ask_friend_roll = RaceSettingsHelper.can_spawn(50)
                end
            end

            -- Transfer all attack points to a friend that can attack.
            if ask_friend and ask_friend_roll then
                for friend_force_name, race_surface_data in pairs(storage.attack_heat_by_surfaces) do
                    for surface_index, surface in pairs(race_surface_data) do
                        if surface and surface.has_attack_beacon and
                                storage.attack_heat[friend_force_name][surface_index] ~= nil
                        then

                            --- AttackMeterProcessor.transfer_attack_points(force_name, friend_force_name)
                            RaceSettingsHelper.add_to_attack_meter(friend_force_name, RaceSettingsHelper.get_next_attack_threshold(force_name))
                            RaceSettingsHelper.add_to_attack_meter(force_name, RaceSettingsHelper.get_next_attack_threshold(force_name) * -1)
                            return nil
                        end
                    end
                end
            end

            if interplanetary_attack_enable or storage.override_interplanetary_attack_enabled then
                script.raise_event(Config.custom_event_handlers[Config.EVENT_INTERPLANETARY_ATTACK_EXEC],{
                    force_name = force_name,
                    target_force = target_force
                })
                return nil
            end
        end
    end

    return return_surface or game.surfaces[NAUVIS]
end

AttackGroupHeatProcessor.pick_target = function(force_name)
    --- If the game has multiple player forces, pick from heat list
    local attack_heat_by_forces = storage.attack_heat_by_forces[force_name]
    local total_player_forces = storage.total_player_forces

    if total_player_forces > 1 and
        attack_heat_by_forces and
        attack_heat_by_forces[1]
    then
        return game.forces[attack_heat_by_forces[1].attacker_index]
    end

    return game.forces[PLAYER]
end

return AttackGroupHeatProcessor