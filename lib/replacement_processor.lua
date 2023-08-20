---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/21/2020 4:55 PM
---
--- Reference:
--- https://lua-api.factorio.com/latest/LuaSurface.html
--- https://lua-api.factorio.com/latest/Concepts.html#ChunkPositionAndArea
---

local Table = require('__stdlib__/stdlib/utils/table')
local String = require('__stdlib__/stdlib/utils/string')
local Game = require('__stdlib__/stdlib/game')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmDebugHelper = require('__enemyracemanager__/lib//debug_helper')

local ReplacementProcessor = {}

local replace_structures = function(surface, entity, race_settings)
    local position = entity.position
    local race_pick = global.replacement_race_pick
    local base_name = ErmRaceSettingHelper.pick_a_spawner(race_pick)
    local new_force_name = ErmForceHelper.get_force_name_from(race_pick)

    local name = race_settings[race_pick].race .. '/' .. base_name .. '/' .. race_settings[race_pick].level
    entity.destroy()
    if not surface.can_place_entity({ name = name, force = new_force_name, position = position }) then
        position = surface.find_non_colliding_position(name, position, 32, 8, true)
    end

    if position then
        return surface.create_entity({ name = name, force = new_force_name, position = position, spawn_decorations = true })
    end
end

local replace_turrets = function(surface, entity, race_settings)
    local position = entity.position
    local race_pick = global.replacement_race_pick
    local base_name = ErmRaceSettingHelper.pick_a_turret(race_pick)
    local name = race_settings[race_pick].race .. '/' .. base_name .. '/' .. race_settings[race_pick].level
    local new_force_name = ErmForceHelper.get_force_name_from(race_pick)

    entity.destroy()
    if not surface.can_place_entity({ name = name, force = new_force_name, position = position }) then
        position = surface.find_non_colliding_position(name, position, 32, 8, true)
    end

    if position then
        return surface.create_entity({ name = name, force = new_force_name, position = position })
    end
end

function ReplacementProcessor.process_chunks(surface, area, race_settings)
    local turrets = Table.filter(surface.find_entities_filtered({ area = area, type = 'turret' }), Game.VALID_FILTER)
    local turret_size = Table.size(turrets)
    if turret_size > 0 then
        Table.each(turrets, function(entity)
            if ErmForceHelper.is_enemy_force(entity.force) then
                replace_turrets(surface, entity, race_settings)
            end
        end)
    end

    local spawners = Table.filter(surface.find_entities_filtered({ area = area, type = 'unit-spawner' }), Game.VALID_FILTER)
    local spawners_size = Table.size(spawners)
    if spawners_size > 0 then
        Table.each(spawners, function(entity)
            if ErmForceHelper.is_enemy_force(entity.force) then
                replace_structures(surface, entity, race_settings)
            end
        end)
    end
end

function ReplacementProcessor.rebuild_map(surface, race_settings, race_pick)
    if surface then
        global.replacement_race_pick = race_pick
        local profiler = game.create_profiler()
        for chunk in surface.get_chunks() do
            ReplacementProcessor.process_chunks(surface, chunk.area, race_settings)
        end

        for _, force in pairs(game.forces) do
            if ErmForceHelper.is_enemy_force(force) then
                force.kill_all_units()
            end
        end
        profiler.stop()
        game.print({ '', 'Rebuild Map: ' .. global.replacement_race_pick .. ' on ' .. surface.name .. '  ', profiler })
    end
end

function ReplacementProcessor.replace_entity(surface, entity, race_settings, target_force_name)
    local returned_entity = entity

    if ErmForceHelper.is_enemy_force(entity.force) == false then
        return
    end

    if surface then
        local race_pick = ErmForceHelper.extract_race_name_from(target_force_name)
        global.replacement_race_pick = race_pick
        local nameToken = ErmForceHelper.get_name_token(entity.name)

        if (race_pick == nameToken[1] and nameToken[3] == race_settings[race_pick].level) then
            return
        end

        if (entity.type == 'unit-spawner') then
            returned_entity = replace_structures(surface, entity, race_settings)
        elseif (entity.type == 'turret') then
            returned_entity = replace_turrets(surface, entity, race_settings)
        end
    end

    return returned_entity
end

function ReplacementProcessor.resetDefault(surface)
    local spawners = Table.filter(surface.find_entities_filtered({ type = 'unit-spawner' }), Game.VALID_FILTER)
    local spawners_size = Table.size(spawners)
    local spawner_names = { 'spitter-spawner', 'biter-spawner' }
    if spawners_size > 0 then
        Table.each(spawners, function(entity)
            if ErmForceHelper.is_enemy_force(entity.force) then
                local position = entity.position
                local name = spawner_names[math.random(1, 2)]
                entity.destroy()
                surface.create_entity({ name = name, position = position, force = 'enemy', spawn_decorations = true })
            end
        end)
    end

    local turrets = Table.filter(surface.find_entities_filtered({ type = 'turret' }), Game.VALID_FILTER)
    local turret_size = Table.size(turrets)
    local turret_names = { 'big-worm-turret', 'behemoth-worm-turret' }
    if turret_size > 0 then
        Table.each(turrets, function(entity)
            if ErmForceHelper.is_enemy_force(entity.force) then
                local position = entity.position
                local name = turret_names[math.random(1, 2)]
                entity.destroy()
                surface.create_entity({ name = name, position = position, force = 'enemy' })
            end
        end)
    end

    for _, force in pairs(game.forces) do
        if ErmForceHelper.is_enemy_force(force) then
            force.kill_all_units()
        end
    end
end

return ReplacementProcessor