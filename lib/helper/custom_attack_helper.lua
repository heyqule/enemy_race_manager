---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/24/2021 6:52 PM
---

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/setting-constants')


local String = require('__stdlib__/stdlib/utils/string')
local Math = require('__stdlib__/stdlib/utils/math')
require("util")

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')

local ATTACK_CHUNK_SIZE = 32

local FEATURE_RACE_NAME = 1
local FEATURE_RACE_SPAWN_DATA = 2
local FEATURE_RACE_SPAWN_CACHE = 4
local FEATURE_RACE_SPAWN_CACHE_SIZE = 5

local get_name_token = function(name)
    if global.force_entity_name_cache and global.force_entity_name_cache[name] then
        return global.force_entity_name_cache[name]
    end

    if global.force_entity_name_cache == nil then
        global.force_entity_name_cache = {}
    end

    if global.force_entity_name_cache[name] == nil then
        if not String.find(name, '/', 1, true) then
            global.force_entity_name_cache[name] = { MOD_NAME, name, '1' }
        else
            global.force_entity_name_cache[name] = String.split(name, '/')
        end
    end

    return global.force_entity_name_cache[name]
end

local get_race_settings = function(race_name, reload)
    if global.custom_attack_race_settings == nil then
        global.custom_attack_race_settings = {}
    end

    if global.custom_attack_race_settings[race_name] == nil or
        global.custom_attack_race_settings[race_name].tick == nil
    then
        global.custom_attack_race_settings[race_name] = {
            tick = 0
        }
    end

    if global.custom_attack_race_settings[race_name] and
        not reload and
        game.tick < global.custom_attack_race_settings[race_name].tick
    then
        return global.custom_attack_race_settings[race_name]
    end

    global.custom_attack_race_settings[race_name] = remote.call('enemyracemanager', 'get_race', race_name)
    global.custom_attack_race_settings[race_name].tick = game.tick + defines.time.minute * ErmConfig.LEVEL_PROCESS_INTERVAL + 1
    return global.custom_attack_race_settings[race_name]
end

local get_low_tier_flying_unit = function(race_name)
    local race_settings = get_race_settings(race_name)
    if type(race_settings['flying_units'][1][1]) ~= nil then
        return race_settings['flying_units'][1][1]
    end

    return nil
end

local get_drop_position = function(final_unit_name, surface, position, race_name, level)
    local drop_position = position
    if not surface.can_place_entity({ name = final_unit_name, position = drop_position }) then
        drop_position = surface.find_non_colliding_position(final_unit_name, drop_position, 16, 3, true)

        if drop_position == nil then
            local low_tier_flyer_name = get_low_tier_flying_unit(race_name)
            if low_tier_flyer_name then
                final_unit_name = race_name .. '/' .. low_tier_flyer_name ..'/' .. tostring(level)
                drop_position = surface.find_non_colliding_position(final_unit_name, position, 16, 3, true)
            end
        end
    end
    return final_unit_name, drop_position
end

local add_member = function(final_unit_name, surface, drop_position, force_name, group)
    if drop_position then
        local entity = surface.create_entity({ name = final_unit_name, position = drop_position, force = force_name })
        if entity.type == 'unit' then
            if group.valid then
                group.add_member(entity)
            end
        end
    end
end

local drop_unit = function(event, race_name, unit_name, count, position)
    position = position or event.source_position or event.source_entity.position
    count = count or 1
    local race_settings = get_race_settings(race_name)
    local surface = game.surfaces[event.surface_index]
    local level = race_settings.level
    local force_name = ErmForceHelper.get_force_name_from(race_name)

    position.x = position.x + 2

    local final_unit_name = race_name .. '/' .. unit_name .. '/' .. level

    if not surface.can_place_entity({ name = final_unit_name, position = position }) then
        position = surface.find_non_colliding_position(final_unit_name, position, 10, 3, true)
    end

    if position then
        local idx = 0;
        while idx < count do
            local entity = surface.create_entity({ name = final_unit_name, position = position, force = force_name })
            if entity.type == 'unit' then
                entity.set_command({
                    type = defines.command.attack_area,
                    destination = { x = position.x, y = position.y },
                    radius = ATTACK_CHUNK_SIZE,
                    distraction = defines.distraction.by_anything
                })

                if event.source_entity and
                        event.source_entity.type == 'unit' and
                        event.source_entity.unit_group and
                        event.source_entity.unit_group.force == entity.force
                then
                    event.source_entity.unit_group.add_member(entity)
                end
            end
            idx = idx + 1
        end
    end
end

local drop_player_unit = function(event, race_name, unit_name, count, position)
    position = position or event.source_position or event.source_entity.position
    local race_settings = get_race_settings(race_name)
    local force = event.source_entity.force or 'player'
    local surface = game.surfaces[event.surface_index]

    local final_unit_name = race_name .. '/' .. unit_name

    if not surface.can_place_entity({ name = final_unit_name, position = position }) then
        position = surface.find_non_colliding_position(final_unit_name, position, 10, 3, true)
    end

    if position then
        local idx = 0;
        while idx < count do
            local entity = surface.create_entity({ name = final_unit_name, position = position, force = force })
            if entity and entity.valid and entity.type == 'unit' then
                entity.set_command({
                    type = defines.command.attack_area,
                    destination = { x = position.x, y = position.y },
                    radius = ATTACK_CHUNK_SIZE,
                    distraction = defines.distraction.by_anything
                })
            end
            idx = idx + 1
        end
    end
end

local CustomAttackHelper = {}

function CustomAttackHelper.get_race_settings(race_name, force)
    local settings = get_race_settings(race_name, force)
    return settings
end

function CustomAttackHelper.can_spawn(chance_value)
    return math.random(1, 100) > (100 - chance_value)
end

function CustomAttackHelper.valid(event, race_name)
    return (event.source_entity and
            String.find(event.source_entity.name, race_name, 1, true) ~= nil) or
            String.find(event.effect_id, '-bs', 1, true) ~= nil
end

function CustomAttackHelper.get_unit(race_name, unit_type)
    local race_settings = get_race_settings(race_name)

    if race_settings == nil or race_settings[unit_type] == nil then
        return
    end

    local unit_data = race_settings[unit_type][race_settings.tier]

    return unit_data[FEATURE_RACE_NAME][unit_data[FEATURE_RACE_SPAWN_CACHE][Math.random(unit_data[FEATURE_RACE_SPAWN_CACHE_SIZE])]]
end

---
--- Process single type of unit drops
---
function CustomAttackHelper.drop_player_unit(event, race_name, unit_name, count)
    drop_player_unit(event, race_name, unit_name, count)
end

---
--- Process single type of unit drops
---
function CustomAttackHelper.drop_unit_at_target(event, race_name, unit_name, count)
    drop_unit(event, race_name, unit_name, count, event.target_position)
end

---
--- Process single type of unit drops
---
function CustomAttackHelper.drop_unit(event, race_name, unit_name, count)
    drop_unit(event, race_name, unit_name, count)
end

---
--- Process batch unit drops
---
function CustomAttackHelper.drop_batch_units(event, race_name, count)
    local race_settings = get_race_settings(race_name)

    if race_settings == nil then
        return
    end

    count = count or 10
    local surface = game.surfaces[event.surface_index]
    local level = race_settings.level
    local source_entity = event.source_entity
    local force_name = ErmForceHelper.get_force_name_from(race_name)

    local position = event.target_position or event.target_entity.position
    position.x = position.x + 2

    local i = 0
    local group = nil
    local new_group = false

    if source_entity and source_entity.unit_group then
        group = source_entity.unit_group
        force_name = source_entity.force.name
    else
        group = surface.create_unit_group {
            position = position, force = force_name
        }
        new_group = true
    end

    repeat
        local final_unit_name = race_name .. '/' .. CustomAttackHelper.get_unit(race_name, 'droppable_units') .. '/' .. level
        local drop_position
        final_unit_name, drop_position = get_drop_position(final_unit_name, surface, position, race_name, level)
        add_member(final_unit_name, surface, drop_position, force_name, group)
        i = i + 1
    until i == count

    if group.valid and new_group then
        group.set_command({
            type = defines.command.attack_area,
            destination = { x = position.x, y = position.y },
            radius = ATTACK_CHUNK_SIZE,
            distraction = defines.distraction.by_anything
        })

        remote.call('enemyracemanager', 'add_erm_attack_group', group)
    end
end

---
--- Process Boss Attack Group
---
function CustomAttackHelper.drop_boss_units(event, race_name, count)
    count = count or 10
    local boss_data = remote.call('enemyracemanager', 'get_boss_data')
    local surface = game.surfaces[event.surface_index]
    local nameToken = get_name_token(boss_data.entity_name)
    local level = tonumber(nameToken[3])

    local position = event.target_position or event.target_entity.position
    position.x = position.x + 2

    local i = 0
    local group = surface.create_unit_group {
        position = position, force = boss_data.force
    }
    repeat
        local final_unit_name = race_name .. '/' .. CustomAttackHelper.get_unit(race_name, 'droppable_units') .. '/' .. tostring(level)
        local drop_position
        final_unit_name, drop_position = get_drop_position(final_unit_name, surface, position, race_name, level)
        add_member(final_unit_name, surface, drop_position, boss_data.force, group)
        i = i + 1
    until i == count

    local target_position = boss_data.target_position

    if target_position == nil then
        target_position = boss_data.silo_position
    end

    group.set_command({
        type = defines.command.attack_area,
        destination = { x = target_position.x, y = target_position.y },
        radius = ATTACK_CHUNK_SIZE,
        distraction = defines.distraction.by_anything
    })

    remote.call('enemyracemanager', 'add_boss_attack_group', group)
end

local break_time_to_live = function(count, max_count, units_total)
    return count == max_count or units_total == 0
end

--- Try target trees and rocks when the parent unit is stuck on pathing and timed unit don't have targets.
local try_kill_a_tree_or_rock = function(units)
    local is_enemy_force = false
    local next_idx, value
    for i = 1, 5, 1 do
        next_idx, value = next(units, next_idx)

        local entity
        if value and value.entity then
            entity = value.entity
        end

        if entity and entity.valid then
            if not is_enemy_force then
                is_enemy_force = remote.call('enemyracemanager', 'is_enemy_force', entity.force)
            end

            local command = entity.command
            if is_enemy_force and
                    command and (command.type == nil or command.type == defines.command.wander)
            then
                local surface = entity.surface
                local entities = surface.find_entities_filtered({
                    position=entity.position,
                    radius=32,
                    -- tree and rocks
                    type={"tree", "simple-entity"},
                    force="neutral",
                    limit=1,
                })

                local _, target_entity = next(entities)
                if target_entity then
                    entity.set_command({
                        type = defines.command.attack,
                        target = target_entity,
                    })
                end
            end
        end
    end
end

---
--- Clean up time to live units
---
function CustomAttackHelper.clear_time_to_live_units(event, regular_batch, overflow_batch)
    regular_batch = regular_batch or ErmConfig.TIME_TO_LIVE_UNIT_BATCH
    overflow_batch = overflow_batch or ErmConfig.OVERFLOW_TIME_TO_LIVE_UNIT_BATCH

    local unit_total = global.time_to_live_units_total
    local units = global.time_to_live_units

    if unit_total == nil or unit_total == 0 then
        return
    end

    local count = 0
    local max_count = regular_batch
    if unit_total > ErmConfig.MAX_TIME_TO_LIVE_UNIT then
        max_count = overflow_batch
    end
    for idx, value in pairs(units) do
        local entity = value.entity
        if entity.valid then
            if value.time < event.tick then
                entity.die()
            end
        else
            units[idx] = nil
            unit_total = unit_total - 1
        end

        count = count + 1
        if break_time_to_live(count, max_count, unit_total) then
            break
        end
    end

    try_kill_a_tree_or_rock(units)

    global.time_to_live_units_total = unit_total
end

function CustomAttackHelper.time_to_live_unit_died(source_unit)
    if source_unit and source_unit.unit_number and
            global.time_to_live_units and global.time_to_live_units[source_unit.unit_number] then
        global.time_to_live_units[source_unit.unit_number] = nil
        global.time_to_live_units_total = global.time_to_live_units_total - 1
    end
end

function CustomAttackHelper.process_self_destruct(event)
    if event.source_entity then
        event.source_entity.die()
    end
end

function CustomAttackHelper.process_time_to_live_unit_created(event)
    if event.source_entity == nil then
        return
    end

    if global.time_to_live_units == nil then
        global.time_to_live_units = {}
        global.time_to_live_units_total = 0
    end

    local entity = event.source_entity
    local nameTokens = get_name_token(entity.name)
    local race_settings = get_race_settings(nameTokens[1])
    local name = nameTokens[2]

    if race_settings.timed_units and race_settings.timed_units[name] and entity.valid then
        global.time_to_live_units[entity.unit_number] = {
            entity = entity,
            time = event.tick + entity.prototype.min_pursue_time
        }
        global.time_to_live_units_total = global.time_to_live_units_total + 1
    end
end

function CustomAttackHelper.process_time_to_live_unit_died(event)
    if event.source_entity then
        CustomAttackHelper.time_to_live_unit_died(event.source_entity)
    end
end

return CustomAttackHelper