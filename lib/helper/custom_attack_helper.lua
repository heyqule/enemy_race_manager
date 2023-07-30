---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/24/2021 6:52 PM
---

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/setting-constants')

local String = require('__stdlib__/stdlib/utils/string')
local Math = require('__stdlib__/stdlib/utils/math')
local util = require("util")

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')

local ATTACK_CHUNK_SIZE = 32

local FEATURE_RACE_NAME = 1
local FEATURE_RACE_SPAWN_DATA = 2
local FEATURE_RACE_SPAWN_CACHE = 4
local FEATURE_RACE_SPAWN_CACHE_SIZE = 5

local get_name_token = function(name)
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

local register_time_to_live_unit = function(event, entity, race_name, name)
    if global.time_to_live_units == nil then
        global.time_to_live_units = {}
        global.time_to_live_units_total = 0
    end

    local race_settings = global.custom_attack_race_settings[race_name]
    if race_settings.timed_units and race_settings.timed_units[name] and entity.valid then
        global.time_to_live_units[entity.unit_number] = {
            entity = entity,
            time = event.tick + entity.prototype.min_pursue_time
        }
        global.time_to_live_units_total = global.time_to_live_units_total + 1
    end
end

local get_race_settings = function(race_name)
    if global.custom_attack_race_settings == nil then
        global.custom_attack_race_settings = {}
    end

    if global.custom_attack_race_settings[race_name] == nil then
        global.custom_attack_race_settings[race_name] = remote.call('enemyracemanager', 'get_race', race_name)
    end

    return global.custom_attack_race_settings[race_name]
end

local CustomAttackHelper = {}

function CustomAttackHelper.get_race_settings(race_name)
    local settings = get_race_settings(race_name)
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
--- for scripted attack b
--- not suitable for projectile
---
function CustomAttackHelper.drop_unit_at_target(event, race_name, unit_name, count)
    count = count or 1
    local race_settings = get_race_settings(race_name)
    local surface = game.surfaces[event.surface_index]
    local level = race_settings.level
    local force_name = ErmForceHelper.get_force_name_from(race_name)

    local position = event.target_position
    position.x = position.x + 2

    local final_unit_name = race_name .. '/' .. unit_name .. '/' .. tostring(level)

    if not surface.can_place_entity({ name = final_unit_name, position = position }) then
        position = surface.find_non_colliding_position(final_unit_name, event.target_position, 10, 3, true)
    end

    if position then
        local idx = 0;
        while idx < count do
            local entity = surface.create_entity({ name = final_unit_name, position = position, force = force_name })
            if entity.type == 'unit' then
                entity.set_command({
                    type = defines.command.attack_area,
                    destination = {x = position.x, y = position.y},
                    radius = ATTACK_CHUNK_SIZE,
                    distraction = defines.distraction.by_anything
                })

                if event.source_entity and event.source_entity.type == 'unit' and event.source_entity.unit_group then
                    event.source_entity.unit_group.add_member(entity)
                end

                register_time_to_live_unit(event, entity, race_name, unit_name)
            end
            idx = idx + 1
        end
    end
end


---
--- Process single type of unit drops
---
function CustomAttackHelper.drop_unit(event, race_name, unit_name, count)
    count = count or 1
    local race_settings = get_race_settings(race_name)
    local surface = game.surfaces[event.surface_index]
    local level = race_settings.level
    local force_name = ErmForceHelper.get_force_name_from(race_name)
    log(race_name)
    log(force_name)
    log(unit_name)
    log('1.------')

    local position = event.source_position or event.source_entity.position
    position.x = position.x + 2

    local final_unit_name = race_name .. '/' .. unit_name .. '/' .. tostring(level)

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
                    destination = {x = position.x, y = position.y},
                    radius = ATTACK_CHUNK_SIZE,
                    distraction = defines.distraction.by_anything
                })

                log(entity.name)
                log(entity.force.name)

                if event.source_entity and event.source_entity.type == 'unit' and event.source_entity.unit_group then
                    log(event.source_entity.name)
                    log(event.source_entity.force.name)
                    event.source_entity.unit_group.add_member(entity)
                end
                log('2.------')
                register_time_to_live_unit(event, entity, race_name, unit_name)
            end
            idx = idx + 1
        end
    end
end

---
--- Process batch unit drops
---
function CustomAttackHelper.drop_batch_units(event, race_name, count, unit_name)
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
        local final_unit_name = race_name .. '/' .. CustomAttackHelper.get_unit(race_name, 'droppable_units') .. '/' .. tostring(level)
        if not surface.can_place_entity({ name = final_unit_name, position = position }) then
            position = surface.find_non_colliding_position(final_unit_name, position, 16, 3, true)
        end

        if position then
            local entity = surface.create_entity({ name = final_unit_name, position = position, force = force_name })
            if entity.type == 'unit' then
                if group.valid then
                    group.add_member(entity)
                end
                register_time_to_live_unit(event, entity, race_name, final_unit_name)
            end
        end
        i = i + 1
    until i == count

    if group.valid and new_group then
        group.set_command({
            type = defines.command.attack_area,
            destination = {x = position.x, y = position.y},
            radius = ATTACK_CHUNK_SIZE,
            distraction = defines.distraction.by_anything
        })

        remote.call('enemyracemanager', 'add_erm_attack_group', group)
    end
end

---
--- Process Boss Attack Group
---
function CustomAttackHelper.drop_boss_units(event, race_name, count, unit_name)
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
        local final_unit_name = race_name .. '/' ..CustomAttackHelper.get_unit(race_name, 'droppable_units').. '/' .. tostring(level)
        if not surface.can_place_entity({ name = final_unit_name, position = position }) then
            position = surface.find_non_colliding_position(final_unit_name, position, 16, 3, true)
        end

        if position then
            local entity = surface.create_entity({ name = final_unit_name, position = position, force = boss_data.force })
            if entity.type == 'unit' then
                group.add_member(entity)
            end
        end
        i = i + 1
    until i == count

    local target_position = boss_data.target_position

    if target_position == nil then
        target_position = boss_data.silo_position
    end

    group.set_command({
        type = defines.command.attack_area,
        destination = {x = target_position.x, y = target_position.y},
        radius = ATTACK_CHUNK_SIZE,
        distraction = defines.distraction.by_anything
    })

    remote.call('enemyracemanager', 'add_boss_attack_group', group)
end


local break_time_to_live = function(count, max_count, units_total)
    return count == max_count or units_total == 0
end

---
--- Clean up time to live units
---
function CustomAttackHelper.clear_time_to_live_units(event)

    local unit_total = global.time_to_live_units_total
    local units = global.time_to_live_units
    local is_overflow = false

    if unit_total == nil or unit_total == 0 then
        return
    end

    --log("Before Time to live unit total: "..tostring(unit_total))
    --log("Before Time to live unit: "..tostring(table_size(units)))
    --local profiler = game.create_profiler()

    local count = 0
    local max_count = ErmConfig.TIME_TO_LIVE_UNIT_BATCH
    if unit_total > ErmConfig.MAX_TIME_TO_LIVE_UNIT then
        max_count = ErmConfig.OVERFLOW_TIME_TO_LIVE_UNIT_BATCH
        is_overflow = true
    end
    for idx, value in pairs(units) do
        local entity = value.entity
        if entity.valid then
            if value.time < event.tick then
                entity.destroy()
                units[idx] = nil
                unit_total = unit_total - 1
            end
        else
            units[idx] = nil
            unit_total = unit_total - 1
        end

        count = count + 1
        if break_time_to_live(count, max_count, unit_total)  then
            break
        end
    end

    global.time_to_live_units_total = unit_total

    --profiler.stop()
    --log("After Time to live unit total: "..tostring(global.time_to_live_units_total))
    --log("After Time to live unit: "..tostring(table_size(global.time_to_live_units)))
    --log({'', 'clear_time_to_live_units...  ', profiler})
end


return CustomAttackHelper