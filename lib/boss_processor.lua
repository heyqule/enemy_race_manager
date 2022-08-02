---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/16/2022 2:58 PM
---

require('__stdlib__/stdlib/utils/defines/time')

local ErmConfig = require('lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmAttackGroupChunkProcessor = require('__enemyracemanager__/lib/attack_group_chunk_processor')
local ErmSurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local ErmCron = require('__enemyracemanager__/lib/cron_processor')
local ErmBossGroupProcessor = require('__enemyracemanager__/lib/boss_group_processor')

local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local BossProcessor = {}

-- beam scan up to 100 chunks
local scanLength = 3200
-- 10 chunks
local scanMinLength = 224
local scanRadius = 8

local chunkSize = 32
local cleanChunkSize = 8
local maxRetry = 3

local enemy_entities = {'unit-spawner','turret','unit'}
local enemy_buildings = {'unit-spawner','turret'}
local turrets = {'ammo-turret','electric-turret','fluid-turret'}
local indexable_turrets = {'ammo-turret','fluid-turret'}
local beacon_name = 'erm-boss-beacon'

local boss_setting_default = function()
    return {
        entity = nil,
        entity_name = '',
        entity_position = '',
        surface = nil,
        surface_name = '',
        race_name = '',
        force = nil,
        force_name = '',
        boss_tier = 1,
        flying_only = false,
        spawned_tick = 0,
        despawn_at_tick = 0,
        pathing_entity = nil,
        pathing_entity_checks = 0,
        last_hp_defense_unit = 0,
        last_hp_artillery = 0,
        last_hp_heavy_artillery = 0,
        victory = false
    }
end

local boss_spawnable_index_default = function()
    return {
        chunks = {},
        size = 0,
        retry = 0
    }
end


local index_boss_spawnable_chunk = function(gunturret, area, usefirst)
    local surface = gunturret.surface
    local spawners = surface.find_entities_filtered {type=enemy_buildings, force=global.boss.force, area=area, limit=50}

    local target_spawner
    local last = #spawners
    if usefirst then
        target_spawner = spawners[1]
    else
        target_spawner = spawners[last]
    end

    if target_spawner then
        -- Skip if it's too close to any of the turrets
        local turret = surface.find_entities_filtered {position=target_spawner.position, radius=160, type=turrets, limit = 1}
        if turret[1] then
            return
        end
        table.insert(global.boss_spawnable_index.chunks, target_spawner.position)
        global.boss_spawnable_index.size = global.boss_spawnable_index.size + 1
    end
end

local start_unit_spawn = function()
    ErmCron.add_15_sec_queue('BossProcessor.units_spawn')
    ErmCron.add_1_min_queue('BossProcessor.support_structures_spawn')
    ErmBossGroupProcessor.spawn_initial_group()
end

local boss_spawnable_index_switch = {
    [tostring(defines.direction.north)] = function(gunturret)
        local area = {left_top = {gunturret.position.x - scanRadius, gunturret.position.y - scanLength}, right_bottom = {gunturret.position.x + scanRadius, gunturret.position.y - scanMinLength}}
        index_boss_spawnable_chunk(gunturret, area)
    end,
    [tostring(defines.direction.east)] = function(gunturret)
        local area = {left_top = {gunturret.position.x + scanMinLength, gunturret.position.y - scanRadius}, right_bottom = {gunturret.position.x + scanLength, gunturret.position.y + scanRadius}}
        index_boss_spawnable_chunk(gunturret, area, true)
    end,
    [tostring(defines.direction.south)] = function(gunturret)
        local area = {left_top = {gunturret.position.x - scanRadius, gunturret.position.y + scanMinLength}, right_bottom = {gunturret.position.x + scanRadius, gunturret.position.y + scanLength}}
        index_boss_spawnable_chunk(gunturret, area, true)
    end,
    [tostring(defines.direction.west)] = function(gunturret)
        local area = {left_top = {gunturret.position.x - scanLength, gunturret.position.y - scanRadius}, right_bottom = {gunturret.position.x - scanMinLength, gunturret.position.y + scanRadius}}
        index_boss_spawnable_chunk(gunturret, area )
    end,
}

function BossProcessor.init_globals()
    global.boss = global.boss or boss_setting_default()
    global.boss_attack_groups = global.boss_attack_groups or {}
    global.boss_group_spawn = global.boss_group_spawn or ErmBossGroupProcessor.get_default_data()
    global.boss_spawnable_index = global.boss_spawnable_index or boss_spawnable_index_default()
end

--- Start the boss spawn flow
function BossProcessor.exec(rocket_silo)
    ErmDebugHelper.print('BossProcessor: Check rocket_silo valid...')
    if rocket_silo and rocket_silo.valid and global.boss.entity == nil then
        local surface = rocket_silo.surface
        local race_name = ErmSurfaceProcessor.get_enemy_on(rocket_silo.surface.name)
        local force = game.forces[ErmForceHelper.get_force_name_from(race_name)]
        ErmDebugHelper.print('BossProcessor: Data setup...')
        global.boss.race_name = race_name
        global.boss.force = force
        global.boss.force_name = force.name
        global.boss.surface = surface
        global.boss.surface_name = surface.name
        global.boss.spawned_tick = game.tick
        global.boss.despawn_at_tick = game.tick + (defines.time.minute * ErmConfig.BOSS_DESPAWN_TIMER[global.boss.boss_tier])

        BossProcessor.index_ammo_turret(surface)
        ErmDebugHelper.print('BossProcessor: Indexed positions: '..global.boss_spawnable_index.size)

        if global.boss_spawnable_index.size == 0 then
            surface.print('Unable to find location to spawn a boss')
            return
        end

        local spawn_position = global.boss_spawnable_index.chunks[math.random(1, global.boss_spawnable_index.size)]
        local entities = surface.find_entities_filtered {
            type = enemy_entities,
            area = {
                top_left={spawn_position.x - cleanChunkSize, spawn_position.y - cleanChunkSize},
                bottom_right={spawn_position.x + cleanChunkSize, spawn_position.y + cleanChunkSize}
            }
        }
        ErmDebugHelper.print('BossProcessor: To destroy entities: '..#entities)
        for i = 1, #entities do
            entities[i].destroy()
        end

        ErmDebugHelper.print('BossProcessor: Creating Entities...')
        local boss_entity = surface.create_entity {
            name=BossProcessor.get_boss_name(race_name),
            position=spawn_position,
            force=force
        }
        local boss_beacon_entity = surface.create_entity {
            name=beacon_name,
            position=spawn_position,
            force='player'
        }
        boss_beacon_entity.destructible = false

        ErmDebugHelper.print('BossProcessor: Assign Entities...')
        global.boss.entity = boss_entity
        global.boss.beacon_entity = boss_beacon_entity
        global.boss.entity_name = boss_entity.name
        global.boss.entity_position = boss_entity.position

        game.print({
            'description.boss-base-spawn-at',
            ErmSurfaceProcessor.get_gps_message(
                spawn_position.x,
                spawn_position.y,
                surface.name
            )
        })

        ErmDebugHelper.print('BossProcessor: Create Pathing Unit...')
        local pathing_entity_name = BossProcessor.get_pathing_entity_name(race_name)
        local pathing_spawn_location = surface.find_non_colliding_position(pathing_entity_name, spawn_position, 32, 8, true)
        local pathing_entity = surface.create_entity {
            name=pathing_entity_name,
            position=pathing_spawn_location,
            force=force
        }
        local command = {
            type = defines.command.attack,
            target = rocket_silo,
            distraction = defines.distraction.by_damage
        }
        pathing_entity.set_command(command)
        global.boss.pathing_entity = pathing_entity
        ErmCron.add_2_sec_queue('BossProcessor.check_pathing')
        ErmCron.add_2_sec_queue('BossProcessor.heartbeat')
    end
end

function BossProcessor.check_pathing()
    if global.boss.pathing_entity_checks == 5 then
        local pathing_entity = global.boss.pathing_entity
        ErmDebugHelper.print('BossProcessor: Comparing path unit position')
        if pathing_entity and pathing_entity.valid then
            if pathing_entity.spawner then
                ErmDebugHelper.print('BossProcessor: flying only [attached spawner]')
                global.boss.flying_only = true
                start_unit_spawn()
                return
            end

            local boss_base = pathing_entity.surface.find_entities_filtered {name=global.boss.entity_name, position=pathing_entity.position, radius=chunkSize/2}
            if boss_base and boss_base[1] then
                ErmDebugHelper.print('BossProcessor: flying only [unit proximity]')
                ErmDebugHelper.print(#boss_base)
                ErmDebugHelper.print(boss_base[1].name)
                global.boss.flying_only = true
                start_unit_spawn()
                return
            end
        end
        ErmDebugHelper.print('BossProcessor: Not a flying only boss ')
        start_unit_spawn()
        return
    end

    ErmDebugHelper.print('BossProcessor: Waiting to check path unit')
    global.boss.pathing_entity_checks = global.boss.pathing_entity_checks + 1
    ErmCron.add_2_sec_queue('BossProcessor.check_pathing')
end

function BossProcessor.get_boss_name(race_name)
    return ErmRaceSettingsHelper.get_race_entity_name(
            race_name,
            global.race_settings[race_name].boss_building,
            ErmConfig.BOSS_LEVELS[global.race_settings[race_name].boss_tier]
    )
end

function BossProcessor.get_pathing_entity_name(race_name)
    return ErmRaceSettingsHelper.get_race_entity_name(
            race_name,
            global.race_settings[race_name].pathing_unit,
            global.race_settings[race_name].level
    )
end

function BossProcessor.heartbeat()
    if global.boss.victory then
        -- start reward process
        return
    end

    if game.tick > global.boss.despawn_at_tick then
        -- start despawn process
        return
    end

    ErmCron.add_2_sec_queue('BossProcessor.heartbeat')
end

function BossProcessor.index_ammo_turret(surface)
    local gunturrets = surface.find_entities_filtered({type=indexable_turrets})
    local totalturrets = #gunturrets;
    local turret_gap = math.max(4,  math.floor(totalturrets / 64))
    local turret_gap_pick = math.max(2, math.random(2, math.floor(turret_gap / 2)))
    ErmDebugHelper.print('BossProcessor: Total: '..totalturrets)
    ErmDebugHelper.print('BossProcessor: Gap: '..turret_gap..'/'..turret_gap_pick)
    for i=1, #gunturrets do
        if i%turret_gap == turret_gap_pick then
            boss_spawnable_index_switch[tostring(gunturrets[i].direction)](gunturrets[i])
            i = i + turret_gap - 2
        end
    end
end

function BossProcessor.units_spawn()

end

function BossProcessor.support_structures_spawn()

end

function BossProcessor.reset()
    if global.boss.entity then
        global.boss.entity.destroy()

        local beacons = global.boss.surface.find_entities_filtered {name=beacon_name}
        for i=1,#beacons do
            beacons[i].destroy()
        end
    end

    global.boss = boss_setting_default()
    -- Kill all attack groups and its units
    global.boss_attack_groups = {}
    -- Kill all defense groups and its units
    global.boss_group_spawn = ErmBossGroupProcessor.get_default_data()
    global.boss_spawnable_index = boss_spawnable_index_default()
    ErmDebugHelper.print('BossProcessor: Reset...')
end


return BossProcessor