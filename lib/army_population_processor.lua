---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/7/2022 10:25 PM
---
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
--- additive to combat drone count
local BASE_MAX_UNIT = 150

local set_default_values = function(force)
    return {
        max_pop = BASE_MAX_UNIT + force.maximum_following_robot_count,
        unit_count = 0,
        pop_count = 0,
        unit_types = {}
    }
end

local init_force_data = function(force, force_reset)
    force_reset = force_reset or false
    if not global.army_populations[force.name] or force_reset then
        global.army_populations[force.name] = set_default_values(force)
    end
end

local ArmyPopulationProcessor = {}

function ArmyPopulationProcessor.init_globals()
    global.army_populations = global.army_populations or {}
    --- Store player spawnable army unit names
    global.registered_units = global.registered_units or {}
end

function ArmyPopulationProcessor.register_unit(unit_name, pop_count)
    global.registered_units[unit_name] = pop_count
end

function ArmyPopulationProcessor.index()
    local profiler = game.create_profiler()
    local registered_units = global.registered_units
    ArmyPopulationProcessor.init_globals()
    if registered_units == nil or table_size(registered_units) == 0 then
        return
    end

    local playerForces = ErmForceHelper.get_player_forces()
    for _, force in pairs(playerForces) do
        init_force_data(game.forces[force], true)
    end

    for _, surface in pairs(game.surfaces) do
        if surface.valid then
            local units = surface.find_entities_filtered({
                type = "unit",
                force = ErmForceHelper.get_player_forces()
            })
            for _, unit in pairs(units) do
                if registered_units[unit.name] then
                    ArmyPopulationProcessor.add_unit_count(unit, registered_units[unit.name])
                end
            end
        end
    end
    profiler.stop()
    game.print({ '', 'Rebuild Player Army Index: ', profiler })
end

function ArmyPopulationProcessor.calculate_max_units(force)
    init_force_data(force)
    global.army_populations[force.name]['max_pop'] = BASE_MAX_UNIT + force.maximum_following_robot_count
    force.print('Max Army Population: ' .. global.army_populations[force.name]['max_pop'])
end

function ArmyPopulationProcessor.can_place_unit(unit)
    local unit_force = unit.force
    init_force_data(unit_force)
    return global.army_populations[unit_force.name]['max_pop'] >= (global.army_populations[unit_force.name]['pop_count'] + global.registered_units[unit.name])

end

function ArmyPopulationProcessor.add_unit_count(unit)
    local unit_name = unit.name
    local unit_force = unit.force
    init_force_data(unit_force)
    local registered_units = global.registered_units
    local army_pop = global.army_populations
    if unit_force and registered_units[unit_name] then

        local pop = registered_units[unit_name]
        local force_name = unit_force.name
        army_pop[force_name]['pop_count'] = army_pop[force_name]['pop_count'] + pop
        army_pop[force_name]['unit_count'] = army_pop[force_name]['unit_count'] + 1
        if not army_pop[force_name]['unit_types'][unit_name] then
            army_pop[force_name]['unit_types'][unit_name] = { pop_count = 0, unit_count = 0 }
        end
        army_pop[force_name]['unit_types'][unit_name]['unit_count'] = army_pop[force_name]['unit_types'][unit_name]['unit_count'] + 1
        army_pop[force_name]['unit_types'][unit_name]['pop_count'] = army_pop[force_name]['unit_types'][unit_name]['pop_count'] + pop
    end
end

function ArmyPopulationProcessor.remove_unit_count(unit)
    local unit_name = unit.name
    local unit_force = unit.force
    local registered_units = global.registered_units
    local army_pop = global.army_populations
    if unit_force and registered_units[unit_name] then
        local pop = registered_units[unit_name]
        local force_name =unit_force.name
        army_pop[force_name]['pop_count'] = army_pop[force_name]['pop_count'] - pop
        army_pop[force_name]['unit_count'] = army_pop[force_name]['unit_count'] - 1
        army_pop[force_name]['unit_types'][unit_name]['unit_count'] = army_pop[force_name]['unit_types'][unit_name]['unit_count'] - 1
        army_pop[force_name]['unit_types'][unit_name]['pop_count'] = army_pop[force_name]['unit_types'][unit_name]['pop_count'] - pop
    end
end

function ArmyPopulationProcessor.get_army_data(force)
    if global.army_populations[force.name] == nil then
        init_force_data(force)
    end

    return global.army_populations[force.name]
end

return ArmyPopulationProcessor