---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/21/2021 10:45 PM
---

local String = require('__stdlib__/stdlib/utils/string')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local ErmAttackGroupChunkProcessor = require('__enemyracemanager__/lib/attack_group_chunk_processor')
local ErmAttackGroupSurfaceProcessor = require('__enemyracemanager__/lib/attack_group_surface_processor')
local ErmSurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')

local ErmCron = require('__enemyracemanager__/lib/cron_processor')

local AttackGroupProcessor = {}

AttackGroupProcessor.MIXED_UNIT_POINTS = 20
AttackGroupProcessor.FLYING_UNIT_POINTS = 75
AttackGroupProcessor.DROPSHIP_UNIT_POINTS = 150

AttackGroupProcessor.UNIT_PER_BATCH = 5
AttackGroupProcessor.MAX_GROUP_SIZE = 2000

AttackGroupProcessor.GROUP_AREA = 256
AttackGroupProcessor.CHUNK_CENTER_POINT = 16

AttackGroupProcessor.GROUP_TYPE_MIXED = 1
AttackGroupProcessor.GROUP_TYPE_FLYING = 2
AttackGroupProcessor.GROUP_TYPE_DROPSHIP = 3
AttackGroupProcessor.GROUP_TYPE_FEATURED = 4
AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING = 5

AttackGroupProcessor.GROUP_TIERS = {
    {1},
    {0.7, 0.3},
    {0.4, 0.35, 0.25}
}

AttackGroupProcessor.PICK_SPAWN_RETRIES = 5

--- Pick surface with player entity.
local pick_surface = function(race_name)
    if ErmConfig.mapgen_is_one_race_per_surface() then
        return ErmAttackGroupSurfaceProcessor.exec(race_name)
    else
        return game.surfaces[1]
    end
end

---
--- Track unit group, each race should only have 1 active group.
--- Units in a group seems considered active units and they have performance penalty.
---
local get_group_tracker = function(race_name)
    if global.group_tracker == nil then
        return nil
    end

    return global.group_tracker[race_name] or nil
end

local set_group_tracker = function(race_name, value)
    if global.group_tracker == nil then
        global.group_tracker = {}
    end
    global.group_tracker[race_name] = value
end

local get_unit_level_for_tier = function(race_name)
    local level = ErmRaceSettingsHelper.get_level(race_name) - 1
    if level == 0 then
        level = 1
    end
    return level
end

local can_spawn = function(chance_value)
    return  math.random(1, 100) > (100 - chance_value)
end

local pick_an_unit = function(race_name)
    local group_tracker = get_group_tracker(race_name)
    local current_tier = group_tracker.current_tier
    local unit_name = nil
    local is_featured_group = false

    if group_tracker.group_type == AttackGroupProcessor.GROUP_TYPE_MIXED then
        unit_name = ErmRaceSettingsHelper.pick_an_unit_from_tier(race_name, current_tier)
    elseif group_tracker.group_type == AttackGroupProcessor.GROUP_TYPE_FLYING then
        unit_name = ErmRaceSettingsHelper.pick_a_flying_unit_from_tier(race_name, current_tier)
    elseif group_tracker.group_type == AttackGroupProcessor.GROUP_TYPE_DROPSHIP then
        unit_name = ErmRaceSettingsHelper.pick_dropship_unit(race_name)
    elseif group_tracker.group_type == AttackGroupProcessor.GROUP_TYPE_FEATURED then
        unit_name = ErmRaceSettingsHelper.pick_featured_unit(race_name, group_tracker.featured_group_id)
        is_featured_group = true
    elseif group_tracker.group_type == AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING then
        unit_name = ErmRaceSettingsHelper.pick_featured_flying_unit(race_name, group_tracker.featured_group_id)
        is_featured_group = true
    else
        unit_name = ErmRaceSettingsHelper.pick_an_unit(race_name)
    end

    if not is_featured_group then
        group_tracker.current_tier_unit = group_tracker.current_tier_unit + 1

        if group_tracker.current_tier_unit == group_tracker.tiers[current_tier] then
            group_tracker.current_tier_unit = 0
            group_tracker.current_tier = math.min(current_tier + 1, ErmConfig.MAX_TIER)
        end
    end

    return unit_name
end

local add_to_group = function(surface, group, force, race_name, unit_batch)
    local group_tracker = get_group_tracker(race_name)
    if group.valid == false or group_tracker == nil then
        return
    end

    local i = 0
    repeat
        local unit_name = pick_an_unit(race_name)
        local unit_full_name = nil
        if group_tracker.is_elite_attack then
            unit_full_name = ErmRaceSettingsHelper.get_race_entity_name(race_name, unit_name, ErmRaceSettingsHelper.get_level(race_name) + ErmConfig.elite_squad_level())
        else
            unit_full_name = ErmRaceSettingsHelper.get_race_entity_name(race_name, unit_name, ErmRaceSettingsHelper.get_level(race_name))
        end

        local position = surface.find_non_colliding_position(unit_full_name, group.position,
                AttackGroupProcessor.GROUP_AREA, 1)
        local entity = surface.create_entity({
            name = unit_full_name,
            position = position,
            force = force
        })
        group.add_member(entity)
        group_tracker.current_size = group_tracker.current_size + 1
        i = i + 1
    until i == unit_batch


    if group_tracker.current_size >= group_tracker.size then
        --local profiler = game.create_profiler()
        local position = ErmAttackGroupChunkProcessor.pick_attack_location(surface, group)
        --profiler.stop()
        --log({'', 'Attack Path finding...  ', profiler})

        if position then
            local command = {
                type = defines.command.attack_area,
                destination = {x = position.x + AttackGroupProcessor.CHUNK_CENTER_POINT, y = position.y + AttackGroupProcessor.CHUNK_CENTER_POINT},
                radius = AttackGroupProcessor.CHUNK_CENTER_POINT
            }

            if group_tracker.is_precision_attack then
                command['distraction'] = defines.distraction.none
                if ErmConfig.precision_strike_warning() then
                    group.surface.print({
                        'description.message-incoming-precision-attack',
                        race_name,
                        '[gps='..(position.x + AttackGroupProcessor.CHUNK_CENTER_POINT)..','..(position.y + AttackGroupProcessor.CHUNK_CENTER_POINT)..','..group.surface.name..']'
                    }, {r=1,g=0,b=0})
                end
            end
            group.set_command(command)
            global.erm_unit_groups[group.group_number] = {
                group =  group,
                start_position = group.position
            }
        else
            group.set_autonomous()
        end
        set_group_tracker(race_name, nil)
    end
end

local pick_gathering_location = function(surface, force, race_name)
    if surface == nil or not surface.valid then
        return nil
    end

    --local profiler = game.create_profiler()
    local target_cc = ErmAttackGroupChunkProcessor.pick_spawn_location(surface, force)
    --profiler.stop()
    --log({'', 'Gathering Path finding...  ', profiler})
    if target_cc == nil then
        return nil
    end
    return surface.find_non_colliding_position(target_cc.name, target_cc.position, AttackGroupProcessor.GROUP_AREA, 1)
end

local generate_unit_queue = function(surface, center_location, force, race_name, units_number, group_type, featured_group_id, is_elite_attack)
    if group_type == nil then
        group_type = AttackGroupProcessor.GROUP_TYPE_MIXED
    end
    local unit_group = surface.create_unit_group({position = center_location, force = force})
    local queue_length = math.ceil(units_number / AttackGroupProcessor.UNIT_PER_BATCH)
    local last_queue = queue_length - 1
    local last_queue_unit = units_number % AttackGroupProcessor.UNIT_PER_BATCH
    if last_queue_unit == 0 then
        last_queue_unit = AttackGroupProcessor.UNIT_PER_BATCH
    end
    local i = 0

    local tiers = nil
    local is_precision_attack = false
    if group_type == AttackGroupProcessor.GROUP_TYPE_FLYING then
        tiers = AttackGroupProcessor.GROUP_TIERS[ math.min(get_unit_level_for_tier(race_name), ErmConfig.MAX_TIER) ]

        local flying_unit_precision_enabled = ErmConfig.flying_squad_precision_enabled()
        local spawn_as_flying_unit_precision = can_spawn(ErmConfig.flying_squad_precision_chance())

        if flying_unit_precision_enabled and spawn_as_flying_unit_precision then
            is_precision_attack = true
        end
    elseif group_type == AttackGroupProcessor.GROUP_TYPE_DROPSHIP then
        tiers = AttackGroupProcessor.GROUP_TIERS[1]
        is_precision_attack = true
    else
        tiers = AttackGroupProcessor.GROUP_TIERS[ ErmRaceSettingsHelper.get_tier(race_name) ]
    end
    local tiers_units = {}
    for index, tier in pairs(tiers) do
        tiers_units[index] = math.floor((units_number * tier)+0.5)
    end

    set_group_tracker(race_name, {
        group = unit_group,
        group_number = unit_group.group_number,
        size = units_number,
        current_size = 0,
        group_type = group_type,
        tiers = tiers_units,
        current_tier = 1,
        current_tier_unit = 0,
        is_precision_attack = is_precision_attack,
        is_elite_attack = is_elite_attack,
        featured_group_id = featured_group_id
    })

    repeat
        local unit_batch = AttackGroupProcessor.UNIT_PER_BATCH
        if i == last_queue then
            unit_batch = last_queue_unit
        end
        ErmCron.add_1_sec_queue(
            'AttackGroupProcessor.add_to_group',
            surface,
            unit_group,
            force,
            race_name,
            unit_batch
        )
        i = i + 1
    until i == queue_length
end

function AttackGroupProcessor.add_to_group_cron(arg)
    add_to_group(arg[1], arg[2], arg[3], arg[4], arg[5])
end

function AttackGroupProcessor.exec(race_name, force, attack_points)
    if get_group_tracker(race_name) then
        return false
    end

    local flying_enabled = ErmConfig.flying_squad_enabled() and ErmRaceSettingsHelper.has_flying_unit(race_name)
    local spawn_as_flying_squad = can_spawn(ErmConfig.flying_squad_chance()) and ErmRaceSettingsHelper.get_level(race_name) > 1
    local spawn_as_featured_squad = can_spawn(ErmConfig.featured_squad_chance()) and ErmRaceSettingsHelper.get_tier(race_name) == 3

    --- Try flying Squad. starts at level 2 and max tier at level 4
    if flying_enabled and spawn_as_flying_squad then
        local dropship_enabled = ErmConfig.dropship_enabled() and ErmRaceSettingsHelper.has_dropship_unit(race_name)
        local spawn_as_dropship_squad = can_spawn(ErmConfig.dropship_chance())

        if spawn_as_featured_squad and ErmRaceSettingsHelper.has_featured_flying_squad(race_name) then
            --- Drop as featured flying group
            local squad_id = ErmRaceSettingsHelper.get_featured_flying_squad_id(race_name);
            local units_number = math.min(math.ceil(attack_points / ErmRaceSettingsHelper.get_featured_unit_cost(race_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(race_name, force, units_number, AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING, squad_id)
        elseif dropship_enabled and spawn_as_dropship_squad then
            --- Dropship Group
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.DROPSHIP_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(race_name, force, units_number, AttackGroupProcessor.GROUP_TYPE_DROPSHIP)
        else
            --- Regular Flying Group
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.FLYING_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(race_name, force, units_number, AttackGroupProcessor.GROUP_TYPE_FLYING)
        end
    else
        if spawn_as_featured_squad and ErmRaceSettingsHelper.has_featured_squad(race_name) then
            --- Regular featured Group
            local squad_id = ErmRaceSettingsHelper.get_featured_squad_id(race_name);
            local units_number = math.min(math.ceil(attack_points / ErmRaceSettingsHelper.get_featured_unit_cost(race_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(race_name, force, units_number, AttackGroupProcessor.GROUP_TYPE_FEATURED, squad_id)
        else
            --- Mixed Group
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.MIXED_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(race_name, force, units_number)
        end
    end
end    

function AttackGroupProcessor.generate_group(race_name, force, units_number, type, featured_group_id, is_elite_attack)
    if get_group_tracker(race_name) then
        return false
    end

    AttackGroupProcessor.UNIT_PER_BATCH = math.ceil(ErmConfig.max_group_size() * ErmConfig.attack_meter_threshold() / AttackGroupProcessor.MIXED_UNIT_POINTS)

    local surface = pick_surface(race_name)
    local center_location = pick_gathering_location(surface, force, race_name)
    if surface and center_location then
        generate_unit_queue(surface, center_location, force, race_name, units_number, type, featured_group_id, is_elite_attack)
        return true
    end

    return false
end

function AttackGroupProcessor.generate_nuked_group(surface, position, radius)
    local target_unit = surface.find_entities_filtered({
        type = {"unit-spawner"},
        force = ErmForceHelper.get_all_enemy_forces(),
        area = {
            { position.x - radius, position.y - radius },
            { position.x + radius, position.y + radius }
        },
        limit = 1
    })
    local units = {}

    if #target_unit == 0 then
        return
    end

    target_unit = target_unit[1]
    units = surface.find_units({
        area = {
            { position.x - radius, position.y - radius },
            { position.x + radius, position.y + radius }
        },
        force = target_unit.force,
        condition = 'same'
    })

    if #units >= 50 then
        local group = surface.create_unit_group({position = target_unit.position, force = target_unit.force})
        local max_unit = ErmConfig.max_group_size()
        local i = 0
        for _, unit in pairs(units) do
            group.add_member(unit)
            i = i + 1
            if max_unit == i then
                break
            end
        end

        local attack_position = ErmAttackGroupChunkProcessor.pick_attack_location(surface, group)

        if attack_position then
            local command = {
                type = defines.command.attack_area,
                destination = {x = attack_position.x + AttackGroupProcessor.CHUNK_CENTER_POINT, y = attack_position.y + AttackGroupProcessor.CHUNK_CENTER_POINT},
                radius = AttackGroupProcessor.CHUNK_CENTER_POINT
            }
            group.set_command(command)
        else
            group.set_autonomous()
        end
    end
end

-- Spawn Elite Group
function AttackGroupProcessor.exec_elite_group(race_name, force, attack_points)
    if get_group_tracker(race_name) then
        return false
    end

    if not ErmRaceSettingsHelper.has_featured_flying_squad(race_name) and
        not ErmRaceSettingsHelper.has_featured_squad(race_name) then
        return false
    end

    local flying_enabled = ErmConfig.flying_squad_enabled() and ErmRaceSettingsHelper.has_flying_unit(race_name)
    local spawn_as_flying_squad = can_spawn(ErmConfig.flying_squad_chance())

    if flying_enabled and spawn_as_flying_squad and ErmRaceSettingsHelper.has_featured_flying_squad(race_name) then
        local squad_id = ErmRaceSettingsHelper.get_featured_flying_squad_id(race_name);
        local units_number = math.min(math.ceil(attack_points / ErmRaceSettingsHelper.get_featured_unit_cost(race_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
        return AttackGroupProcessor.generate_group(race_name, force, units_number, AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING, squad_id, true)
    elseif ErmRaceSettingsHelper.has_featured_squad(race_name) then
        local squad_id = ErmRaceSettingsHelper.get_featured_squad_id(race_name);
        local units_number = math.min(math.ceil(attack_points / ErmRaceSettingsHelper.get_featured_unit_cost(race_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
        return AttackGroupProcessor.generate_group(race_name, force, units_number, AttackGroupProcessor.GROUP_TYPE_FEATURED, squad_id, true)
    end

    return false
end

return AttackGroupProcessor