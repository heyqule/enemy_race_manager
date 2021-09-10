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

local ErmCron = require('__enemyracemanager__/lib/cron_processor')

local AttackGroupProcessor = {}

AttackGroupProcessor.MIXED_UNIT_POINTS = 20
AttackGroupProcessor.FLYING_UNIT_POINTS = 75
AttackGroupProcessor.DROPSHIP_UNIT_POINTS = 150

AttackGroupProcessor.UNIT_PER_BATCH = 5
AttackGroupProcessor.MAX_GROUP_SIZE = 600

AttackGroupProcessor.GROUP_AREA = 256

AttackGroupProcessor.GROUP_TYPE_MIXED = 1
AttackGroupProcessor.GROUP_TYPE_FLYING = 2
AttackGroupProcessor.GROUP_TYPE_DROPSHIP = 3

AttackGroupProcessor.GROUP_TIERS = {
    {1},
    {0.7, 0.3},
    {0.4, 0.35, 0.25}
}

AttackGroupProcessor.PICK_SPAWN_RETRIES = 5

AttackGroupProcessor.NORMAL_PRECISION_TARGET_TYPES = {
    'mining-drill',
    'rocket-silo',
    'artillery-turret',
}

AttackGroupProcessor.HARDCORE_PRECISION_TARGET_TYPES = {
    'lab',
    'furnace',
}

AttackGroupProcessor.EXTREME_PRECISION_TARGET_TYPES = {
    'assembling-machine',
    'generator',
    'solar-panel',
    'accumulator',
}

--- Pick surface with player entity.
local pick_surface = function()
    return game.surfaces[1]
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

local get_unit_level = function(race_name)
    local level = ErmRaceSettingsHelper.get_level(race_name) - 1
    if level == 0 then
        level = 1
    end
    return level
end

local get_spawn_chance = function(chance_value)
    local chance = math.random(1, 100)
    local spawn_as = chance > (100 - chance_value)
    return spawn_as
end

local pick_an_unit = function(race_name)
    local group_tracker = get_group_tracker(race_name)
    local current_tier = group_tracker.current_tier
    local unit_name = nil
    if group_tracker.group_type == AttackGroupProcessor.GROUP_TYPE_MIXED then
        unit_name = ErmRaceSettingsHelper.pick_an_unit_from_tier(race_name, current_tier)
    elseif group_tracker.group_type == AttackGroupProcessor.GROUP_TYPE_FLYING then
        unit_name = ErmRaceSettingsHelper.pick_an_flying_unit_from_tier(race_name, current_tier)
    elseif group_tracker.group_type == AttackGroupProcessor.GROUP_TYPE_DROPSHIP then
        unit_name = ErmRaceSettingsHelper.pick_an_dropship_unit(race_name)
    else
        unit_name = ErmRaceSettingsHelper.pick_an_unit(race_name)
    end

    group_tracker.current_tier_unit = group_tracker.current_tier_unit + 1

    if group_tracker.current_tier_unit == group_tracker.tiers[current_tier] then
        group_tracker.current_tier_unit = 0
        group_tracker.current_tier = math.min(current_tier + 1, ErmConfig.MAX_TIER)
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
        local unit_full_name = ErmRaceSettingsHelper.get_race_entity_name(race_name, unit_name)
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
        local enemy = nil
        local type = ''
        --local profiler = game.create_profiler()
        if group_tracker.target_types then
            type = group_tracker.target_types[math.random(1,#group_tracker.target_types)]
            local enemies = group.surface.find_entities_filtered {
                type = type,
                position = group.position,
                force = 'player',
                radius = 3200,
                limit = 10
            }
            if #enemies > 0 then
                enemy = enemies[math.random(1, #enemies)]
            end
        end

        if enemy == nil then
            enemy = group.surface.find_nearest_enemy {
                position = group.position,
                force = group.force,
                max_distance = 3200
            }
        end
        --profiler.stop()
        --log('Searching Type: ' .. type)
        --log('Spawn Location: ' .. group.position.x ..','.. group.position.y)
        --if enemy then
        --    log('Enemy Location: ' .. enemy.name .. ' - ' .. enemy.type .. ' @ ' .. enemy.position.x ..','.. enemy.position.y)
        --end
        --log({'', 'Attack Path finding...  ', profiler})

        if enemy then
            local command = {
                type = defines.command.attack_area,
                destination = enemy.position,
                radius = 32
            }

            if group_tracker.target_types then
                command['distraction'] = defines.distraction.none
                if ErmConfig.precision_strike_warning() then
                    group.surface.print({
                        'description.message-incoming-precision-attack',
                        race_name,
                        '[gps='..enemy.position.x..','..enemy.position.y..','..group.surface.name..']'
                    }, {r=1,g=0,b=0})
                end
            end
            group.set_command(command)
            global.erm_unit_groups[group.group_number] = group
        else
            group.set_autonomous()
        end
        set_group_tracker(race_name, nil)
    end
end

local pick_gathering_location = function(surface, force, race_name)
    local profiler = game.create_profiler()
    local target_cc = ErmAttackGroupChunkProcessor.pick_spawn_location(surface, force)
    profiler.stop()
    log({'', 'Gathering Path finding...  ', profiler})
    if target_cc == nil then
        return nil
    end
    return surface.find_non_colliding_position(target_cc.name, target_cc.position, AttackGroupProcessor.GROUP_AREA, 1)
end

local generate_unit_queue = function(surface, center_location, force, race_name, units_number, group_type)
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
    local target_types = nil
    if group_type == AttackGroupProcessor.GROUP_TYPE_FLYING then
        tiers = AttackGroupProcessor.GROUP_TIERS[ math.min(get_unit_level(race_name), ErmConfig.MAX_TIER) ]

        local flying_unit_precision_enabled = ErmConfig.flying_squad_precision_enabled()
        local spawn_as_flying_unit_precision = get_spawn_chance(ErmConfig.flying_squad_precision_chance())

        if flying_unit_precision_enabled and spawn_as_flying_unit_precision then
            target_types = AttackGroupProcessor.NORMAL_PRECISION_TARGET_TYPES
        end
    elseif group_type == AttackGroupProcessor.GROUP_TYPE_DROPSHIP then
        tiers = AttackGroupProcessor.GROUP_TIERS[1]
        target_types = AttackGroupProcessor.NORMAL_PRECISION_TARGET_TYPES
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
        target_types = target_types
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
    local group_tracker = get_group_tracker(race_name)
    if group_tracker then
        return false
    end

    local flying_enabled = ErmConfig.flying_squad_enabled() and ErmRaceSettingsHelper.has_flying_unit(race_name)
    local spawn_as_flying_squad = get_spawn_chance(ErmConfig.flying_squad_chance())
    local status = false
    --- Flying Squad starts at level 2.  Max tier at level 4
    if flying_enabled and ErmRaceSettingsHelper.get_level(race_name) > 1 and
            spawn_as_flying_squad then

        local dropship_enabled = ErmConfig.dropship_enabled() and ErmRaceSettingsHelper.has_dropship_unit(race_name)
        local spawn_as_flying_squad = get_spawn_chance(ErmConfig.dropship_chance())

        if dropship_enabled and spawn_as_flying_squad then
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.DROPSHIP_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            status = AttackGroupProcessor.generate_group(race_name, force, units_number, AttackGroupProcessor.GROUP_TYPE_DROPSHIP)
        else
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.FLYING_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            status = AttackGroupProcessor.generate_group(race_name, force, units_number, AttackGroupProcessor.GROUP_TYPE_FLYING)
        end
    else
        local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.MIXED_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
        status = AttackGroupProcessor.generate_group(race_name, force, units_number)
    end

    return status
end    

function AttackGroupProcessor.generate_group(race_name, force, units_number, type)
    local surface = pick_surface()
    local center_location = pick_gathering_location(surface, force, race_name)
    if surface and center_location then
        generate_unit_queue(surface, center_location, force, race_name, units_number, type)
        return true
    end

    return false
end

return AttackGroupProcessor