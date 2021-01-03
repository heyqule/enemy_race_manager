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
local Queue = require('__stdlib__/stdlib/misc/queue')
local Game = require('__stdlib__/stdlib/game')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')

local ReplacementProcessor = {}

local race_pick

local replace_structures = function(surface, entity, race_settings)
    local position = entity.position

    local structure_tier = race_settings[race_pick]['current_support_structures_tier']
    local strucutre_base = race_settings[race_pick]['current_command_centers_tier']
    local pick = math.random();

    local base_name = ''
    if pick < 0.3 then
        base_name = strucutre_base[math.random(1, #strucutre_base)]
    else
        base_name = structure_tier[math.random(1, #structure_tier)]
    end

    local new_force_name = 'enemy'
    if race_pick ~= MOD_NAME then
        new_force_name = 'enemy_'..race_pick
    end

    local name = race_settings[race_pick].race .. '/' ..base_name.. '/' .. race_settings[race_pick].level
    entity.destroy()
    surface.create_entity({name = name, position = position, force=new_force_name})
end

local replace_turrets = function(surface, entity, race_settings)
    local position = entity.position
    local turret_tier = race_settings[race_pick]['current_turrets_tier']
    local base_name = turret_tier[math.random(1, #turret_tier)]
    local name = race_settings[race_pick].race .. '/' ..base_name.. '/' .. race_settings[race_pick].level
    local new_force_name = 'enemy'
    if race_pick ~= MOD_NAME then
        new_force_name = 'enemy_'..race_pick
    end
    entity.destroy()
    surface.create_entity({name = name, position = position, force=new_force_name})
end

function ReplacementProcessor.process_chunks(surface, area, race_settings)
    local spawners = Table.filter(surface.find_entities_filtered({area = area, type = 'unit-spawner'}), Game.VALID_FILTER)
    local spawners_size = Table.size(spawners)
    if spawners_size > 0 then
        Table.each(spawners, function(entity)
            replace_structures(surface, entity, race_settings)
        end)
    end

    local turrets = Table.filter(surface.find_entities_filtered({area = area, type = 'turret'}), Game.VALID_FILTER)
    local turret_size = Table.size(turrets)
    if turret_size > 0 then
        Table.each(turrets, function(entity)
            replace_turrets(surface, entity, race_settings)
        end)
    end
end

function ReplacementProcessor.rebuildMap(surface, race_settings, target_force_name)
    if surface then
        race_pick = target_force_name
        game.print('Rebuild Map: '..target_force_name..' on '..surface.name)
        for chunk in surface.get_chunks() do
            ReplacementProcessor.process_chunks(surface, chunk.area, race_settings)
        end

        for name, force in pairs(game.forces) do
            if String.find(force.name,'enemy') then
                force.kill_all_units()
            end
        end
    end
end

function ReplacementProcessor.resetDefault(surface)
    local spawners = Table.filter(surface.find_entities_filtered({type = 'unit-spawner'}), Game.VALID_FILTER)
    local spawners_size = Table.size(spawners)
    local spawner_names = {'spitter-spawner','biter-spawner'}
    if spawners_size > 0 then
        Table.each(spawners, function(entity)
            local position = entity.position
            local name = spawner_names[math.random(1, 2)]
            entity.destroy()
            surface.create_entity({name = name, position = position, force='enemy'})
        end)
    end

    local turrets = Table.filter(surface.find_entities_filtered({type = 'turret'}), Game.VALID_FILTER)
    local turret_size = Table.size(turrets)
    local turret_names = {'big-worm-turret','behemoth-worm-turret'}
    if turret_size > 0 then
        Table.each(turrets, function(entity)
            local position = entity.position
            local name = turret_names[math.random(1, 2)]
            entity.destroy()
            surface.create_entity({name = name, position = position, force='enemy'})
        end)
    end

    for name, force in pairs(game.forces) do
        if String.find(force.name,'enemy') then
            force.kill_all_units()
        end
    end
end

return ReplacementProcessor