---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/16/2022 2:58 PM
---

require('__stdlib__/stdlib/utils/defines/time')

local Event = require('__stdlib__/stdlib/event/event')
local StdIs = require('__stdlib__/stdlib/utils/is')
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmAttackGroupChunkProcessor = require('__enemyracemanager__/lib/attack_group_chunk_processor')
local ErmSurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local ErmCron = require('__enemyracemanager__/lib/cron_processor')
local ErmBossGroupProcessor = require('__enemyracemanager__/lib/boss_group_processor')
local ErmBossAttackProcessor = require('__enemyracemanager__/lib/boss_attack_processor')
local ErmBaseBuildProcessor = require('__enemyracemanager__/lib/base_build_processor')
local ErmBossRewardProcessor = require('__enemyracemanager__/lib/boss_reward_processor')
local ErmBossDespawnProcessor = require('__enemyracemanager__/lib/boss_despawn_processor')

local ErmGui = require('__enemyracemanager__/gui/main')

local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local BossProcessor = {}

-- beam scan up to 100 chunks
local scanLength = ErmConfig.BOSS_ARTILLERY_SCAN_RANGE
-- 7 chunks
local scanMinLength = 224
local scanRadius = 16

local chunkSize = 32
local spawnRadius = 64
local cleanChunkSize = 8
local maxRetry = 3

local INCLUDE_SPAWNS = true -- Only for debug

local enemy_entities = {'unit-spawner','turret','unit'}
local enemy_buildings = {'unit-spawner','turret'}
local turrets = {'ammo-turret','electric-turret','fluid-turret'}
local indexable_turrets = {'ammo-turret', 'fluid-turret'}
local beacon_name = 'erm-boss-beacon'

local boss_setting_default = function()
    return {
        entity = nil,
        entity_name = '',
        entity_position = nil,
        target_position = {x=0, y=0},
        target_direction = defines.direction.north,
        silo_position = {x=0, y=0},
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
        attack_last_hp = {0, 0, 0, 0, 0, 0},
        victory = false,
        high_level_enemy_list = nil,  -- Track all high level enemies, they die when the base destroys.
        loading = false
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
    if gunturret.direction == defines.direction.east or
        gunturret.direction == defines.direction.south
    then
        target_spawner = spawners[1]
    else
        target_spawner = spawners[last]
    end

    if target_spawner then
        -- Skip if it's too close to any of the turrets
        local turret = surface.find_entities_filtered {position=target_spawner.position, radius=192, type=turrets, limit = 1}
        if turret[1] then
            return
        end
        table.insert(global.boss_spawnable_index.chunks, {
            spawn_position=target_spawner.position,
            turret_position=gunturret.position,
            turret_direction=gunturret.direction
        })
        global.boss_spawnable_index.size = global.boss_spawnable_index.size + 1
    end
end

local start_unit_spawn = function()
    ErmCron.add_15_sec_queue('BossProcessor.units_spawn')
    ErmCron.add_1_min_queue('BossProcessor.support_structures_spawn')
    ErmCron.add_15_sec_queue('BossGroupProcessor.process_attack_groups')
    if INCLUDE_SPAWNS then
        ErmBossGroupProcessor.spawn_initial_group()
    end
end


local process_boss_queue = function(event)
    ErmCron.process_boss_queue()
end

local start_boss_event = function()
    Event.on_nth_tick(ErmConfig.BOSS_QUEUE_CRON, process_boss_queue)
end

local remove_boss_event = function()
    Event.remove(ErmConfig.BOSS_QUEUE_CRON * -1, process_boss_queue)
    ErmCron.empty_boss_queue()
end

local get_scan_area = {
    [defines.direction.north] = function(x, y)
        return {left_top = {x - scanRadius, y - scanLength}, right_bottom = {x + scanRadius, y - scanMinLength}}
    end,
    [defines.direction.east] = function(x, y)
        return {left_top = {x + scanMinLength, y - scanRadius}, right_bottom = {x + scanLength, y + scanRadius}}
    end,
    [defines.direction.south] = function(x, y)
        return {left_top = {x - scanRadius, y + scanMinLength}, right_bottom = {x + scanRadius, y + scanLength}}
    end,
    [defines.direction.west] = function(x, y)
        return {left_top = {x - scanLength, y - scanRadius}, right_bottom = {x - scanMinLength, y + scanRadius}}
    end,    
}

local can_build_spawn_building = function()
    local boss_tier = global.boss.boss_tier
    local nearby_buildings = global.boss.surface.find_entities_filtered({
        position = global.boss.entity_position,
        radius  = spawnRadius,
        type    = enemy_buildings,
        force   = global.boss.force
    })
    if #nearby_buildings >= ErmConfig.BOSS_MAX_SUPPORT_STRUCTURES[boss_tier] then
        return false
    end

    return true
end

local spawn_building = function()
    if not can_build_spawn_building() then
        return
    end

    local boss = global.boss
    local boss_tier = boss.boss_tier
    for i = 1, ErmConfig.BOSS_SPAWN_SUPPORT_STRUCTURES[boss_tier] do
        local building_name
        if ErmRaceSettingsHelper.can_spawn(10) then
            building_name = ErmBaseBuildProcessor.getBuildingName(boss.race_name, 'cc')
        elseif ErmRaceSettingsHelper.can_spawn(50) then
            building_name = ErmBaseBuildProcessor.getBuildingName(boss.race_name, 'support')
        else
            building_name = ErmBaseBuildProcessor.getBuildingName(boss.race_name, 'turret')
        end

        ErmBaseBuildProcessor.build(
            boss.surface,
            building_name,
            boss.force_name,
            boss.entity_position
        )
    end
end

local destroy_beacons = function()
    local beacons = global.boss.surface.find_entities_filtered {name=beacon_name}
    for i=1,#beacons do
        beacons[i].destroy()
    end
end

local unset_boss_data = function()
    global.boss = boss_setting_default()
    for _, spawn_data in pairs(global.boss_attack_groups) do
        ErmCron.add_quick_queue('BossProcessor.remove_boss_groups', spawn_data)
    end

    ErmCron.add_quick_queue('BossProcessor.remove_boss_groups', global.boss_group_spawn)

    global.boss_attack_groups = {}
    global.boss_group_spawn = ErmBossGroupProcessor.get_default_data()
    global.boss_spawnable_index = boss_spawnable_index_default()
    remove_boss_event()
end

local spawn_unit_attack = function()
    if INCLUDE_SPAWNS then
        ErmBossGroupProcessor.spawn_defense_group()
    end
    return false, true
end

local spawn_base_attack = function()
    if INCLUDE_SPAWNS then
        spawn_building()
    end
    return false, true
end

local basic_attack = function()
    ErmBossAttackProcessor.exec_basic()
    return true, false
end

local advanced_attack = function()
    ErmBossAttackProcessor.exec_advanced()
    return true, false
end

local super_attack = function()
    ErmBossAttackProcessor.exec_super()
    return true, false
end

local phase_change = function()
    return false, false
end

--- Phase change + 5 attacks
local attack_functions = {
    phase_change,
    super_attack,
    spawn_unit_attack,
    advanced_attack,
    spawn_base_attack,
    basic_attack
}

local draw_time = function(boss, current_tick)
    local datetime_str = ErmConfig.format_daytime_string(current_tick, boss.despawn_at_tick)

    rendering.draw_text({
        text={"description.boss-despawn-in", datetime_str},
        surface=boss.surface_name,
        target=boss.entity,
        target_offset={-3.5,-8},
        color = {r = 1, g = 0, b = 0},
        time_to_live = ErmConfig.TWO_SECONDS_CRON,
        scale = 2,
        only_in_alt_mode = true
    })
end

local initialize_result_log = function(race_name, difficulty, squad_size)
    local default_best_record = {
        tier = 1,
        time = -1,
    }
    if global.boss_logs[race_name] == nil then
        global.boss_logs[race_name] = {
            difficulty = difficulty,
            squad_size = squad_size,
            best_record = default_best_record,
            entries = {}
        }
    end

    if not global.boss_logs[race_name].difficulty == difficulty or
        not global.boss_logs[race_name].difficulty == squad_size then
        global.boss_logs[race_name]['difficulty'] = difficulty
        global.boss_logs[race_name]['squad_size'] = squad_size
        global.boss_logs[race_name].best_record = default_best_record
    end
end

local has_better_record = function(current_best_record, record)
    local race_name = record.race
    return record.tier == current_best_record.tier and
            ((global.boss_logs[race_name].best_record.time == -1) or
             (record.last_tick - record.spawn_tick) < global.boss_logs[race_name].best_record.time)
end

local update_best_time = function(record)
    local race_name = record.race
    local current_best_record = global.boss_logs[race_name].best_record
    if record.victory and (record.tier > current_best_record.tier or has_better_record(current_best_record, record)) then
        global.boss_logs[race_name].best_record.tier = record.tier
        global.boss_logs[race_name].best_record.time = record.last_tick - record.spawn_tick
    end
end


local write_result_log = function(victory)
    local boss = global.boss
    local difficulty = settings.startup['enemyracemanager-boss-difficulty'].value
    local squad_size = settings.startup['enemyracemanager-boss-unit-spawn-size'].value

    initialize_result_log(boss.race_name, difficulty, squad_size)

    local record = {
        race = boss.race_name,
        tier = boss.boss_tier,
        victory = victory,
        surface = boss.surface_name,
        location = boss.entity_position,
        difficulty = difficulty,
        squad_size = squad_size,
        spawn_tick = boss.spawned_tick,
        last_tick = game.tick
    }
    table.insert(global.boss_logs[boss.race_name].entries, record)

    update_best_time(record)
end

function BossProcessor.init_globals()
    global.boss = boss_setting_default()
    global.boss_attack_groups = global.boss_attack_groups or {}
    global.boss_group_spawn = global.boss_group_spawn or ErmBossGroupProcessor.get_default_data()
    global.boss_spawnable_index = global.boss_spawnable_index or boss_spawnable_index_default()
    global.boss_rewards = global.boss_rewards or {}
    global.boss_logs = global.boss_logs or {}
end

--- Start the boss spawn flow
function BossProcessor.exec(rocket_silo, spawn_position)
    ErmDebugHelper.print('BossProcessor: Check rocket_silo valid...')
    if rocket_silo and rocket_silo.valid and global.boss.loading == false and
            (global.boss.entity == nil or global.boss.entity.valid == false) then
        global.boss.loading = true
        local surface = rocket_silo.surface
        local race_name = ErmSurfaceProcessor.get_enemy_on(rocket_silo.surface.name)
        local force = game.forces[ErmForceHelper.get_force_name_from(race_name)]
        ErmDebugHelper.print('BossProcessor: Data setup...')
        global.boss.race_name = race_name
        global.boss.force = force
        global.boss.force_name = force.name
        global.boss.surface = surface
        global.boss.surface_name = surface.name
        global.boss.silo_position = rocket_silo.position
        global.boss.spawned_tick = game.tick
        global.boss.boss_tier = ErmRaceSettingsHelper.boss_tier(global.boss.race_name)
        global.boss.despawn_at_tick = game.tick + (defines.time.minute * ErmConfig.BOSS_DESPAWN_TIMER[global.boss.boss_tier])
        BossProcessor.index_ammo_turret(surface)
        ErmDebugHelper.print('BossProcessor: Indexed positions: '..global.boss_spawnable_index.size)

        if global.boss_spawnable_index.size == 0 and spawn_position == nil then
            surface.print('Unable to find a boss spawner.  Please try again on a surface with enemy spawners.')
            return
        end

        if not StdIs.position(spawn_position) then
            local target_chunk_data =  global.boss_spawnable_index.chunks[math.random(1, global.boss_spawnable_index.size)]
            spawn_position = target_chunk_data.spawn_position
            global.boss.target_position = target_chunk_data.turret_position
            global.boss.target_direction = target_chunk_data.turret_direction
        end

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

        ErmDebugHelper.print('BossProcessor: Creating Boss Base...')
        ErmDebugHelper.print(BossProcessor.get_boss_name(race_name))
        local boss_entity = surface.create_entity {
            name=BossProcessor.get_boss_name(race_name),
            position=spawn_position,
            force=force
        }

        for _, value in pairs(ErmForceHelper.get_player_forces()) do
            local boss_beacon_entity = surface.create_entity {
                name=beacon_name,
                position=spawn_position,
                force=value.name
            }
            boss_beacon_entity.destructible = false
        end

        ErmDebugHelper.print('BossProcessor: Assign Entities...')
        global.boss.entity = boss_entity
        global.boss.attack_last_hp = {
            boss_entity.health,
            boss_entity.health,
            boss_entity.health,
            boss_entity.health,
            boss_entity.health,
            boss_entity.health
        }
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
        local pathing_spawn_location = surface.find_non_colliding_position(pathing_entity_name, spawn_position, chunkSize, 2, true)
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
        start_boss_event()
    end
end

function BossProcessor.check_pathing()
    local boss = global.boss
    if boss.pathing_entity_checks == 5 then
        local pathing_entity = boss.pathing_entity
        ErmDebugHelper.print('BossProcessor: Comparing path unit position')
        if pathing_entity and pathing_entity.valid then
            if pathing_entity.spawner then
                ErmDebugHelper.print('BossProcessor: flying only [attached spawner]')
                global.boss.flying_only = true
                start_unit_spawn()
                global.boss.loading = false
                return
            end

            local boss_base = pathing_entity.surface.find_entities_filtered {name=boss.entity_name, position=pathing_entity.position, radius=chunkSize/2}
            if boss_base and boss_base[1] then
                ErmDebugHelper.print('BossProcessor: flying only [unit proximity]')
                ErmDebugHelper.print(#boss_base)
                ErmDebugHelper.print(boss_base[1].name)
                global.boss.flying_only = true
                start_unit_spawn()
                global.boss.loading = false
                return
            end
        end
        ErmDebugHelper.print('BossProcessor: Not a flying only boss ')
        start_unit_spawn()
        global.boss.loading = false
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
            ErmConfig.BOSS_LEVELS[global.boss.boss_tier]
    )
end

function BossProcessor.get_pathing_entity_name(race_name)
    return ErmRaceSettingsHelper.get_race_entity_name(
            race_name,
            global.race_settings[race_name].pathing_unit,
            global.race_settings[race_name].level
    )
end

local display_victory_dialog = function(boss)
    if global.race_settings[boss.race_name].boss_tier >= ErmConfig.BOSS_MAX_TIERS then
        return
    end

    local targetPlayer = nil
    for _, player in pairs(game.players) do
        if player.valid and player.connected and player.surface == boss.surface then
            targetPlayer = player
            break
        end
    end

    if targetPlayer == nil then
        for _, player in pairs(game.players) do
            if player.valid and player.connected then
                targetPlayer = player
                break
            end
        end
    end

    if targetPlayer then
        ErmGui.victory_dialog.show(targetPlayer, global.race_settings[boss.race_name])
    end
end

function BossProcessor.heartbeat()
    local boss = global.boss
    local current_tick = game.tick
    local max_attacks = ErmConfig.BOSS_MAX_ATTACKS_PER_HEARTBEAT[boss.boss_tier]
    if boss.victory then
        -- start reward process
        global.race_settings[boss.race_name].boss_kill_count = global.race_settings[boss.race_name].boss_kill_count + 1
        write_result_log(true)
        display_victory_dialog(boss)
        ErmBossRewardProcessor.exec()
        BossProcessor.unset()
        ErmDebugHelper.print('BossProcessor: is victory')
        ErmDebugHelper.print('BossProcessor: Heartbeat stops')
        return
    end

    if current_tick > boss.despawn_at_tick then
        -- start despawn process
        ErmDebugHelper.print('BossProcessor: start despawn process')
        write_result_log(false)
        ErmBossDespawnProcessor.exec()
        BossProcessor.unset()
        ErmDebugHelper.print('BossProcessor: Heartbeat stops')
        return
    end

    if not ErmRaceSettingsHelper.is_in_boss_mode() then
        destroy_beacons()
        unset_boss_data()
        ErmDebugHelper.print('BossProcessor: No longer in boss mode')
        ErmDebugHelper.print('BossProcessor: Heartbeat stops')
        return
    end

    local boss_direct_attack = false
    local performed_attacks = 0
    for index, last_hp in pairs(boss.attack_last_hp) do
        local direct_attack = false
        local spawn_attack = false
        if last_hp - boss.entity.health > ErmConfig.BOSS_DEFENSE_ATTACKS[index] then
            global.boss.attack_last_hp[index] = boss.entity.health
            ErmDebugHelper.print('BossProcessor: Attack Index '..index..' @ '..boss.entity.health)
            direct_attack, spawn_attack = attack_functions[index]()
            performed_attacks = performed_attacks + 1

            if direct_attack then
                boss_direct_attack = true
            end

            if max_attacks == performed_attacks then
                break
            end
        end
    end

    if boss_direct_attack then
        ErmBossAttackProcessor.unset_attackable_entities_cache()
    end

    draw_time(boss, current_tick)
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
            local gunturret = gunturrets[i]
            index_boss_spawnable_chunk(gunturret, get_scan_area[gunturret.direction](gunturret.position.x, gunturret.position.y))
            i = i + turret_gap - 2
        end
    end
end

--- Queue to spawn boss units
--- @see enemyracemanager/control.lua
function BossProcessor.units_spawn()
    if not ErmRaceSettingsHelper.is_in_boss_mode() then
        ErmDebugHelper.print('BossProcessor: units_spawn stops...')
        return
    end

    if INCLUDE_SPAWNS then
        ErmBossGroupProcessor.spawn_regular_group()
        ErmCron.add_15_sec_queue('BossProcessor.units_spawn')
    end
end

--- Queue to build boss Spawner
--- @see enemyracemanager/control.lua
function BossProcessor.support_structures_spawn()
    if not ErmRaceSettingsHelper.is_in_boss_mode() then
        ErmDebugHelper.print('BossProcessor: support_structures_spawn stops...')
        return
    end

    if INCLUDE_SPAWNS then
        spawn_building()
        ErmCron.add_1_min_queue('BossProcessor.support_structures_spawn')
    end
end

function BossProcessor.unset()
    if ErmRaceSettingsHelper.is_in_boss_mode() then
        global.boss.entity.destroy()
        ErmDebugHelper.print('BossProcessor: destroy boss base...')
    end
    destroy_beacons()
    unset_boss_data()
    ErmDebugHelper.print('BossProcessor: unset...')
end

--- Build boss spawner
--- @see enemyracemanager/control.lua
function BossProcessor.build_spawner(surface, name, force, position)
    if not ErmRaceSettingsHelper.is_in_boss_mode() or not can_build_spawn_building() then
        return
    end

    ErmBaseBuildProcessor.build(surface, name, force, position)
end

function BossProcessor.remove_boss_groups(spawn_data)
    if spawn_data.group and spawn_data.group.valid then
        ErmDebugHelper.print('BossProcessor: Removing boss attack groups...')
        for _, member in pairs(spawn_data.group.members) do
            if member.valid then
                member.destroy()
            end
        end
    end
end

return BossProcessor