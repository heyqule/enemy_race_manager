---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/16/2022 2:58 PM
---



local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")
local AttackGroupProcessor = require("__enemyracemanager__/lib/attack_group_processor")

local Cron = require("__enemyracemanager__/lib/cron_processor")

local DebugHelper = require("__enemyracemanager__/lib/debug_helper")

local BossGroupProcessor = {}

-- Number of spawn cycle to send out attack group. 15 seconds per cycle. 6 minutes / about one narvis day.
-- spawn_cycles x enemyracemanager-boss-spawn-size = max boss group size, default 120 (10 * 24 / 2)
local default_spawn_cycles = 24
local chunkSize = 32

local FEATURE_GROUP_TYPE_MIXED = 1
local FEATURE_GROUP_TYPE_FLYING = 2

local is_flying_only_boss = function()
    return storage.boss.flying_only
end

local create_group = function(max_cycles, unit_per_cycle, default_max_group)
    if storage.boss_group_spawn.group or storage.boss_group_spawn.featured_group_id == nil then
        return
    end

    default_max_group = default_max_group or true
    local boss = storage.boss
    local surface = boss.surface
    local force = boss.force
    local center_location = surface.find_non_colliding_position(RaceSettingsHelper.get_colliding_unit(boss.force_name), boss.entity_position, chunkSize, 1, true)
    if (center_location) then
        local group = surface.create_unit_group({ position = center_location, force = force })

        storage.boss_group_spawn.group = group
        storage.boss_group_spawn.unique_id = group.unique_id
        DebugHelper.print("BossGroupProcessor: Create Group..." .. tostring(group.unique_id))
        unit_per_cycle = unit_per_cycle or GlobalConfig.boss_spawn_size
        storage.boss_group_spawn.max_cycles = max_cycles or default_spawn_cycles
        storage.boss_group_spawn.unit_per_cycle = unit_per_cycle

        local max_units
        if default_max_group then
            max_units = (storage.boss_group_spawn.max_cycles * GlobalConfig.boss_spawn_size)
        else
            max_units = storage.boss_group_spawn.max_cycles * unit_per_cycle
        end
        storage.boss_group_spawn.max_units = max_units
        DebugHelper.print("BossGroupProcessor: max_cycles:" .. tostring(storage.boss_group_spawn.max_cycles)
                .. " unit_per_cycle: " .. tostring(storage.boss_group_spawn.unit_per_cycle)
                .. " max_units: " .. tostring(storage.boss_group_spawn.max_units))
    end
end

local pick_featured_group = function()
    if storage.boss_group_spawn.featured_group_id then
        return
    end

    local boss = storage.boss
    local force_name = boss.force_name
    if is_flying_only_boss() and RaceSettingsHelper.has_featured_flying_squad(force_name) then
        local squad_id = RaceSettingsHelper.get_featured_flying_squad_id(force_name);
        storage.boss_group_spawn.featured_group_id = squad_id
        storage.boss_group_spawn.featured_group_type = FEATURE_GROUP_TYPE_FLYING
        DebugHelper.print("BossGroupProcessor: Picked feature group..." .. tostring(FEATURE_GROUP_TYPE_FLYING) .. "/" .. tostring(squad_id))
    else
        if RaceSettingsHelper.has_featured_flying_squad(force_name) and RaceSettingsHelper.can_spawn(33) then
            local squad_id = RaceSettingsHelper.get_featured_flying_squad_id(force_name);
            storage.boss_group_spawn.featured_group_id = squad_id
            storage.boss_group_spawn.featured_group_type = FEATURE_GROUP_TYPE_FLYING
            DebugHelper.print("BossGroupProcessor: Picked feature group..." .. tostring(FEATURE_GROUP_TYPE_FLYING) .. "/" .. tostring(squad_id))
        elseif RaceSettingsHelper.has_featured_squad(force_name) then
            local squad_id = RaceSettingsHelper.get_featured_squad_id(force_name);
            storage.boss_group_spawn.featured_group_id = squad_id
            storage.boss_group_spawn.featured_group_type = FEATURE_GROUP_TYPE_MIXED
            DebugHelper.print("BossGroupProcessor: Picked feature group..." .. tostring(FEATURE_GROUP_TYPE_MIXED) .. "/" .. tostring(squad_id))
        end
    end
end

function BossGroupProcessor.generate_units(useCycle, queueCycle)
    useCycle = useCycle or true
    queueCycle = queueCycle or false
    local unit_name
    local spawn_data = storage.boss_group_spawn
    local boss_data = storage.boss
    local group = spawn_data.group
    local surface = boss_data.surface

    if group == nil or group.valid == false then
        storage.boss_group_spawn = BossGroupProcessor.get_default_data()
        return
    end

    local i = 0
    repeat
        if spawn_data.featured_group_type == FEATURE_GROUP_TYPE_FLYING then
            unit_name = RaceSettingsHelper.pick_featured_flying_unit(boss_data.force_name, spawn_data.featured_group_id)
        elseif spawn_data.featured_group_type == FEATURE_GROUP_TYPE_MIXED then
            unit_name = RaceSettingsHelper.pick_featured_unit(boss_data.force_name, spawn_data.featured_group_id)
        end

        local unit_full_name = RaceSettingsHelper.get_race_entity_name(
                boss_data.force_name,
                unit_name,
                GlobalConfig.BOSS_LEVELS[storage.race_settings[boss_data.force_name].boss_tier]
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
        end
        i = i + 1
    until i == spawn_data.unit_per_cycle

    storage.boss_group_spawn.total_units = #group.members
    if useCycle then
        storage.boss_group_spawn.current_cycle = storage.boss_group_spawn.current_cycle + 1
    end
    DebugHelper.print("BossGroupProcessor: Spawned Cycle: " .. tostring(storage.boss_group_spawn.current_cycle))
    DebugHelper.print("BossGroupProcessor: Spawned units:" .. tostring(i))
    DebugHelper.print("BossGroupProcessor: Total units:" .. tostring(spawn_data.total_units))
    --DebugHelper.print("BossGroupProcessor: TYPE: "..serpent.block(spawn_data))

    if storage.boss_group_spawn.current_cycle == storage.boss_group_spawn.max_cycles or
            storage.boss_group_spawn.total_units >= storage.boss_group_spawn.max_units
    then
        AttackGroupProcessor.process_attack_position({
            group = group,
            distraction = defines.distraction.by_anything,
        })

        table.insert(storage.boss_attack_groups, spawn_data)
        storage.boss_group_spawn = BossGroupProcessor.get_default_data()
        DebugHelper.print("BossGroupProcessor: Assigned to attack group")
    elseif (queueCycle) then
        Cron.add_2_sec_queue("BossGroupProcessor.generate_units", useCycle, queueCycle)
    end
end

function BossGroupProcessor.spawn_initial_group()
    DebugHelper.print("BossProcessor.spawn_initial_group")
    pick_featured_group()
    create_group(default_spawn_cycles / 3, GlobalConfig.boss_spawn_size * 3, true)
    Cron.add_2_sec_queue("BossGroupProcessor.generate_units", true, true)
end

function BossGroupProcessor.spawn_regular_group()
    DebugHelper.print("BossProcessor.spawn_regular_group")
    pick_featured_group()
    create_group()
    BossGroupProcessor.generate_units(true, false)
end

function BossGroupProcessor.spawn_defense_group()
    DebugHelper.print("BossProcessor.spawn_defense_group")
    pick_featured_group()
    create_group(nil, GlobalConfig.boss_spawn_size)
    BossGroupProcessor.generate_units(false, false)
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
    return GlobalConfig.boss_spawn_size * default_spawn_cycles
end

-- Clean up attack group automatically
function BossGroupProcessor.process_attack_groups()
    if not RaceSettingsHelper.is_in_boss_mode() then
        return
    end

    local number_of_groups = #storage.boss_attack_groups
    if number_of_groups > 0 then
        local removable_indexes = {}
        for i = 1, number_of_groups do
            local group_data = storage.boss_attack_groups[i];
            local group = group_data.group
            if group and group.valid then
                if group.command == nil or
                        group.state == defines.group_state.finished then
                    DebugHelper.print("BossGroupProcessor.process_attack_groups: New Target for " .. storage.boss_attack_groups[i].unique_id)
                    AttackGroupProcessor.process_attack_position({
                        group = group,
                        distraction = defines.distraction.by_anything,
                    })
                end
            else
                DebugHelper.print("BossGroupProcessor.process_attack_groups: Removing Group" .. storage.boss_attack_groups[i].unique_id)
                table.insert(removable_indexes, i)
            end
        end

        for i = 1, #removable_indexes do
            table.remove(storage.boss_attack_groups, removable_indexes[i])
        end
    end

    Cron.add_15_sec_queue("BossGroupProcessor.process_attack_groups")
end

return BossGroupProcessor