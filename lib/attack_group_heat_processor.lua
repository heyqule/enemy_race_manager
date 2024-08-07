---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 10/4/2021 12:09 AM
---
---

require('util')
local Event = require('__stdlib__/stdlib/event/event')

local Config = require('__enemyracemanager__/lib/global_config')
local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local RaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')

local AttackGroupHeatProcessor = {}

AttackGroupHeatProcessor.COOLDOWN_VALUE = 10
AttackGroupHeatProcessor.DEFAULT_VALUE = 5

local PLAYER = 1
local NAUVIS = 1

local init_data = function(race_name, surface_index)
    if  global.attack_heat[race_name] == nil or
        global.attack_heat[race_name][surface_index] == nil
    then
        global.attack_heat[race_name] = global.attack_heat[race_name] or {}
        global.attack_heat[race_name][surface_index] = global.attack_heat[race_name][surface_index] or {}
    end
end

AttackGroupHeatProcessor.init_globals = function()
    --- global.attack_heat[race_index][surface_index][attacker_force_index]
    global.attack_heat = global.attack_heat or {}
    global.attack_heat_by_forces = global.attack_heat_by_forces or {}
    global.attack_heat_by_surfaces = global.attack_heat_by_surfaces or {}
end

AttackGroupHeatProcessor.reset_globals = function()
    global.attack_heat = {}
    global.attack_heat_by_forces = global.attack_heat_by_forces or {}
    global.attack_heat_by_surfaces = global.attack_heat_by_surfaces or {}
end

--- Handle removing surface data
AttackGroupHeatProcessor.remove_surface = function(surface_index)
    for active_race, _ in pairs(global.active_races) do
        if global.attack_heat[active_race] and global.attack_heat[active_race][surface_index] then
            global.attack_heat[active_race][surface_index] = nil
            AttackGroupHeatProcessor.aggregate_heat(active_race)
        end
    end
end

--- Handle removing player force data
AttackGroupHeatProcessor.remove_force = function(attacker_index)
    for active_race, _ in pairs(global.active_races) do
        if global.attack_heat[active_race] then
            for _, surface_data in pairs(global.attack_heat[active_race]) do
                if surface_data[attacker_index] then
                    surface_data[attacker_index] = nil
                end
            end
        end

        AttackGroupHeatProcessor.aggregate_heat(active_race)
    end
end

AttackGroupHeatProcessor.calculate_heat = function(race_name, surface_index, attacker_index, heat_points)
    if race_name == nil then
        return
    end
    init_data(race_name, surface_index)
    local points = global.attack_heat[race_name][surface_index][attacker_index] or 0
    heat_points = heat_points or AttackGroupHeatProcessor.DEFAULT_VALUE
    points = points + heat_points
    global.attack_heat[race_name][surface_index][attacker_index] = points
end

AttackGroupHeatProcessor.cooldown_heat = function(race_name)
    local attack_heat = global.attack_heat[race_name]
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

AttackGroupHeatProcessor.aggregate_heat = function(race_name)
    if global.attack_heat[race_name] == nil then
        global.attack_heat_by_surfaces[race_name] = nil
        global.attack_heat_by_forces[race_name] = nil
        return nil
    end

    local attack_heat_by_surfaces = {}
    local attack_heat_by_forces = {}

    --- Aggregate
    for surface_index, surface_data in pairs(global.attack_heat[race_name]) do
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

    --- Assign global
    global.attack_heat_by_surfaces[race_name] = sorted_surfaces
    global.attack_heat_by_forces[race_name] = sorted_forces
end

AttackGroupHeatProcessor.pick_surface = function(race_name, target_force, ask_friend)
    target_force = target_force or game.forces[PLAYER]
    local surface_data = global.attack_heat_by_surfaces[race_name]
    local return_surface = nil
    if global.is_multi_planets_game and
        surface_data and
        global.total_enemy_surfaces > 1
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

        if not return_surface or global.override_interplanetary_attack_enabled then
            local ask_friend_roll = nil
            local interplanetary_attack_enable = Config.interplanetary_attack_enable()

            if interplanetary_attack_enable then
                ask_friend_roll = global.override_ask_friend
                if ask_friend_roll == nil then
                    ask_friend_roll = RaceSettingsHelper.can_spawn(50)
                end
            end

            -- Transfer all attack points to a friend that can attack.
            if ask_friend and ask_friend_roll then
                for friend_race_name, race_surface_data in pairs(global.attack_heat_by_surfaces) do
                    for surface_index, surface in pairs(race_surface_data) do
                        if surface and surface.has_attack_beacon and
                                global.attack_heat[friend_race_name][surface_index] ~= nil
                        then

                            --- AttackMeterProcessor.transfer_attack_points(race_name, friend_race_name)
                            RaceSettingsHelper.add_to_attack_meter(friend_race_name, RaceSettingsHelper.get_next_attack_threshold(race_name))
                            RaceSettingsHelper.add_to_attack_meter(race_name, RaceSettingsHelper.get_next_attack_threshold(race_name) * -1)
                            return nil
                        end
                    end
                end
            end

            if interplanetary_attack_enable or global.override_interplanetary_attack_enabled then
                Event.raise_event(Event.get_event_name(Config.EVENT_INTERPLANETARY_ATTACK_EXEC),{
                    race_name = race_name,
                    target_force = target_force
                })
                return nil
            end
        end
    end

    return return_surface or game.surfaces[NAUVIS]
end

AttackGroupHeatProcessor.pick_target = function(race_name)
    --- If the game has multiple player forces, pick from heat list
    local attack_heat_by_forces = global.attack_heat_by_forces[race_name]
    local total_player_forces = global.total_player_forces

    if total_player_forces > 1 and
        attack_heat_by_forces and
        attack_heat_by_forces[1]
    then
        return game.forces[attack_heat_by_forces[1].attacker_index]
    end

    return game.forces[PLAYER]
end

return AttackGroupHeatProcessor