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

local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local BossGroupProcessor = {}

local spawn_cycles = 12
local chunkSize = 32

local FEATURE_GROUP_TYPE_MIXED = 1
local FEATURE_GROUP_TYPE_FLYING = 2


local is_flying_only_boss = function()
    return global.boss.flying_only
end

local get_colliding_unit = function(race_name)
    return ErmRaceSettingsHelper.get_race_entity_name(
        race_name,
        global.race_settings[race_name].colliding_unit,
        global.race_settings[race_name].level
    )
end

local can_spawn = function(chance_value)
    return  math.random(1, 100) > (100 - chance_value)
end

local create_group = function(max_cycles, unit_per_cycle)
    if global.boss_group_spawn.group or global.boss_group_spawn.featured_group_id == nil then
        return
    end

    local boss = global.boss
    local surface =  boss.surface
    local force =  boss.force
    local center_location = surface.find_non_colliding_position(get_colliding_unit(boss.race_name), boss.entity_position, chunkSize, 1 , true)
    if (center_location) then
        local group = surface.create_unit_group({position = center_location, force = force})

        global.boss_group_spawn.group = group
        global.boss_group_spawn.group_number = group.group_number
        ErmDebugHelper.print('BossGroupProcessor: Create Group...'..tostring(group.group_number))
        unit_per_cycle = unit_per_cycle or ErmConfig.boss_spawn_size()
        global.boss_group_spawn.max_cycles = max_cycles or spawn_cycles
        global.boss_group_spawn.unit_per_cycle = unit_per_cycle
        local max_units = global.boss_group_spawn.max_cycles * unit_per_cycle
        global.boss_group_spawn.max_units = max_units
        ErmDebugHelper.print('BossGroupProcessor: max_cycles:'..tostring(global.boss_group_spawn.max_cycles)
                ..' unit_per_cycle: '..tostring(global.boss_group_spawn.unit_per_cycle)
                ..' max_units: '..tostring(global.boss_group_spawn.max_units))
    end
end

local pick_featured_group = function()
    if global.boss_group_spawn.featured_group_id then
        return
    end

    local boss = global.boss
    local race_name = boss.race_name
    if is_flying_only_boss() and ErmRaceSettingsHelper.has_featured_flying_squad(race_name) then
        local squad_id = ErmRaceSettingsHelper.get_featured_flying_squad_id(race_name);
        global.boss_group_spawn.featured_group_id = squad_id
        global.boss_group_spawn.featured_group_type = FEATURE_GROUP_TYPE_FLYING
        ErmDebugHelper.print('BossGroupProcessor: Picked feature group...'..tostring(FEATURE_GROUP_TYPE_FLYING)..'/'..tostring(squad_id))
    else
        if ErmRaceSettingsHelper.has_featured_flying_squad(race_name) and can_spawn(33) then
            local squad_id = ErmRaceSettingsHelper.get_featured_flying_squad_id(race_name);
            global.boss_group_spawn.featured_group_id = squad_id
            global.boss_group_spawn.featured_group_type = FEATURE_GROUP_TYPE_FLYING
            ErmDebugHelper.print('BossGroupProcessor: Picked feature group...'..tostring(FEATURE_GROUP_TYPE_FLYING)..'/'..tostring(squad_id))
        elseif ErmRaceSettingsHelper.has_featured_squad(race_name) then
            local squad_id = ErmRaceSettingsHelper.get_featured_squad_id(race_name);
            global.boss_group_spawn.featured_group_id = squad_id
            global.boss_group_spawn.featured_group_type = FEATURE_GROUP_TYPE_MIXED
            ErmDebugHelper.print('BossGroupProcessor: Picked feature group...'..tostring(FEATURE_GROUP_TYPE_MIXED)..'/'..tostring(squad_id))
        end
    end
end

function BossGroupProcessor.generate_units()
    local unit_name
    local spawn_data = global.boss_group_spawn
    local boss_data = global.boss
    local group = spawn_data.group
    local surface = boss_data.surface

    local i = 0
    repeat
        ErmDebugHelper.print('BossGroupProcessor: TYPE: '..serpent.block(spawn_data))
        if spawn_data.featured_group_type == FEATURE_GROUP_TYPE_FLYING then
            unit_name = ErmRaceSettingsHelper.pick_featured_flying_unit(boss_data.race_name, spawn_data.featured_group_id)
            ErmDebugHelper.print('BossGroupProcessor: Flying  unit: '..tostring(unit_name))
        elseif spawn_data.featured_group_type == FEATURE_GROUP_TYPE_MIXED then
            unit_name = ErmRaceSettingsHelper.pick_featured_unit(boss_data.race_name, spawn_data.featured_group_id)
            ErmDebugHelper.print('BossGroupProcessor: Mixed unit: '..tostring(unit_name))
        end

        local unit_full_name = ErmRaceSettingsHelper.get_race_entity_name(
                boss_data.race_name,
                unit_name,
                ErmConfig.BOSS_LEVELS[global.race_settings[boss_data.race_name].boss_tier]
        )

        local position = surface.find_non_colliding_position(unit_full_name, group.position,
                chunkSize, 1)
        local entity = surface.create_entity({
            name = unit_full_name,
            position = position,
            force = boss_data.force
        })

        if entity then
            group.add_member(entity)
            spawn_data.total_units = #group.members
        end
        i = i + 1
    until i == spawn_data.unit_per_cycle

    ErmDebugHelper.print('BossGroupProcessor: Spawned Cycle: '..tostring(global.boss_group_spawn.current_cycle))
    spawn_data.current_cycle = spawn_data.current_cycle + 1
    ErmDebugHelper.print('BossGroupProcessor: Spawned units:'..tostring(i))

    if spawn_data.current_cycle == spawn_data.max_cycles or spawn_data.total_units >= spawn_data.max_units then
        local position = ErmAttackGroupChunkProcessor.pick_attack_location(surface, group)

        if position then
            local command = {
                type = defines.command.attack_area,
                destination = {x = position.x, y = position.y},
                radius = chunkSize
            }
            group.set_command(command)
        else
            group.set_autonomous()
        end

        table.insert(global.boss_attack_groups, spawn_data)
        global.boss_group_spawn = BossGroupProcessor.get_default_data()
        ErmDebugHelper.print('BossGroupProcessor: Assigned to attack group')
    else
        ErmCron.add_2_sec_queue('BossGroupProcessor.generate_units')
    end
end

function BossGroupProcessor.spawn_initial_group()
    pick_featured_group()
    create_group(spawn_cycles/3, ErmConfig.boss_spawn_size()*3)
    ErmCron.add_2_sec_queue('BossGroupProcessor.generate_units')
end

function BossGroupProcessor.spawn_regular_group()
    pick_featured_group()
    create_group()
end

function BossGroupProcessor.spawn_defense_group()
    pick_featured_group()
    create_group()
end

function BossGroupProcessor.get_default_data()
    return {
        group = nil,
        group_number = nil,
        total_units = 0,
        max_units = 0, -- When total unit reach this number, the group converts to attack group.
        current_cycle = 0,
        max_cycles = 0, -- When total cycle reach this number, the group converts to attack group.
        unit_per_cycle = 0,
        featured_group_id = nil,
        featured_group_type = nil,
    }
end

function BossGroupProcessor.get_group_size()
    return ErmConfig.rmConfig.boss_spawn_size() * spawn_cycles
end

return BossGroupProcessor