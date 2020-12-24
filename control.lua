--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/17/2020
-- Time: 11:29 AM
-- To change this template use File | Settings | File Templates.
--

-- Imports
local Position = require '__stdlib__/stdlib/area/position'
local Area = require '__stdlib__/stdlib/area/area'
local EventLog = require('__stdlib__/stdlib/misc/logger').new('Event')

local Table = require('__stdlib__/stdlib/utils/table')
local Game = require('__stdlib__/stdlib/game')
local Event = require('__stdlib__/stdlib/event/event')

local ErmConfig =  require('__enemyracemanager__/lib/global_config')
local ErmMapProccessor = require('__enemyracemanager__/lib/map_processor')

require('__stdlib__/stdlib/utils/defines/time')

local ErmRemoteApi = require('__enemyracemanager__/lib/remote_api')
remote.add_interface("enemy_race_manager", ErmRemoteApi)

-- local variables
local race_settings -- track race settings
local enemy_surfaces -- track which race are on a surface
local mod_settings

ERM_DEBUG = true


local onBuildBaseArrived = function(event)
    local group = event.group;
    if not ( group and group.valid) then
        local unit = event.unit;
        EventLog.log('on_build_base_arrived, Group '..unit.name)
    else
        EventLog.log('on_build_base_arrived, Unit '..group.name)
    end
end

local onBiterBaseBuilt = function(event)
    local entity = event.entity
    if entity.valid then
        EventLog.log('on_build_base_built, Entity '..entity.name)
    end
end

local onUnitGroupCreated = function(event)
    local group = event.group
    EventLog.log('on_unit_group_created, Group '..group.group_number)
end

local onUnitAddToGroup = function(event)
    local group = event.group
    EventLog.log('on_unit_added_to_group, Group '..group.group_number)
end

local onUnitFinishGathering = function(event)
    local group = event.group
    EventLog.log('on_unit_group_finished_gathering, Group '..group.group_number)
end

local onUnitRemovedFromGroup = function(event)
    local group = event.group
    EventLog.log('on_unit_removed_from_group, Group '..group.group_number)
end

local onEntitySpawned = function(event)

end


local prepare_world = function()
    -- Calculate Biter Level
    -- Queue Chunk to process
end

local print_force_data = function()
    for i, force in pairs(game.forces) do
        if force.name == 'player' or force.name == 'neutral' then
            goto print_force_data_for_force
        end
        EventLog.log('---------------------')
        EventLog.log(force.name)
        EventLog.log("AI:"..tostring(force.ai_controllable))
        for i2, force2 in pairs(game.forces) do
            EventLog.log(force2.name..' is friend: ' .. tostring(force2.get_friend(force2.name)))
        end

        if force.share_chart then
            EventLog.log("share cart:"..force.share_chart)
        end
        if force.evolution_factor then
            EventLog.log("evolution factor:".. tostring(force.evolution_factor))
        end
        if force.evolution_factor_by_pollution then
            EventLog.log("evolution pollution:".. tostring(force.evolution_factor_by_pollution))
        end
        if force.evolution_factor_by_time then
            EventLog.log("evolution time:".. tostring(force.evolution_factor_by_time))
        end
        if force.evolution_factor_by_killing_spawners then
            EventLog.log("evolution killing:".. tostring(force.evolution_factor_by_killing_spawners))
        end
        ::print_force_data_for_force::
    end
end

local randomBuilding = function(surface, position)
    local type = math.random(1,3)
    name = ({'hatchery', 'hydraden','spawning_pool'})[type]
    surface.create_entity({name='erm-'..name..'-spawner-1', position=position, force='enemy_erm_zerg'})
end

local initModSetting = function()
    return {
        current_level = 1,
        current_tier = 1,
        evolution_type = 1
    }
end

Event.register(defines.events.on_entity_spawned, onEntitySpawned)

Event.register(defines.events.on_build_base_arrived, onBuildBaseArrived)

Event.register(defines.events.on_biter_base_built, onBiterBaseBuilt)

Event.register(defines.events.on_unit_group_created, onUnitGroupCreated)

Event.register(defines.events.on_unit_group_finished_gathering, onUnitFinishGathering)

Event.register(defines.events.on_unit_added_to_group, onUnitAddToGroup)

Event.register(defines.events.on_unit_removed_from_group, onUnitRemovedFromGroup)

Event.on_nth_tick(900, function(event)
    EventLog.log('On '..event.tick.." Tick")
    print_force_data()

    if ERM_DEBUG then
        game.print('Current Level:'..tostring(mod_settings.current_level))
        game.print('Current Tier:'..tostring(mod_settings.current_tier))
        game.print('Evolution Type:'..tostring(mod_settings.evolution_type))
        game.print('Race Settings:'..tostring(#race_settings))
        game.print('Forces:'..tostring(#game.forces))
    end

    --
    --EventLog.log('Evolution Type'..tostring(race_settings['erm_zerg']))
end)

Event.register(defines.events.on_chunk_generated,function(event)
    local surface = event.surface
    local charted_position =  event.position
    local charted_area = Area.new(event.area)

    local spawners = Table.filter(Game.get_surface(event.surface).find_entities_filtered({area = charted_area, type = 'unit-spawner', force = 'enemy'}), Game.VALID_FILTER)
    local turrets = Table.filter(Game.get_surface(event.surface).find_entities_filtered({area = charted_area, type = 'turret', force = 'enemy'}), Game.VALID_FILTER)
    Table.each(spawners, function(entity)
        local position = entity.position
        --entity.destroy();
        --randomBuilding(surface, position)
    end)

    Table.each(turrets, function(entity)
        local position = entity.position
        --entity.destroy();
        --randomBuilding(surface, position)
    end)
end)

Event.on_init(function(event)
    -- Internal Mod Settings
    global.mod_settings = initModSetting()
    -- ID by mod name, each mod should have it own statistic out side of what force tracks.
    global.race_settings = {}
    -- Track what type of enemies on a surface
    global.enemy_surfaces = {}

    mod_settings = global.mod_settings
    race_settings = global.race_settings
    enemy_surfaces = global.enemy_surfaces

    prepare_world()
end)

Event.on_load(function(event)
    race_settings = global.race_settings or {}
    enemy_surfaces = global.enemy_surfaces or {}
    mod_settings = global.mod_settings or initModSetting()

    prepare_world()
end)
