---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/21/2021 10:45 PM
---

require('util')
require('global')
local Position = require('__stdlib__/stdlib/area/position')
local Event = require('__stdlib__/stdlib/event/event')

local Config = require('__enemyracemanager__/lib/global_config')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local RaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')

local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local AttackGroupPathingProcessor = require('__enemyracemanager__/lib/attack_group_pathing_processor')
local AttackGroupHeatProcessor = require('__enemyracemanager__/lib/attack_group_heat_processor')
local SurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')


local Cron = require('__enemyracemanager__/lib/cron_processor')

local AttackGroupProcessor = {}

local NEARBY_SEARCH_ATTACK_RADIUS = 320
local SPAWN_CHANCE = 75
local MIN_GROUP_SIZE = 5
local DAY_TICK = 25000
local IDLE_TIME_OUT = 25000 * 2
local ERM_GROUP_TIME_TO_LIVE = 25000 * 14 --- 2 Weeks
local RETRY = 12


AttackGroupProcessor.MIXED_UNIT_POINTS = 25
AttackGroupProcessor.FLYING_UNIT_POINTS = 75
AttackGroupProcessor.DROPSHIP_UNIT_POINTS = 200

AttackGroupProcessor.UNIT_PER_BATCH = 5
AttackGroupProcessor.MAX_GROUP_SIZE = 2000

AttackGroupProcessor.GROUP_AREA = 128
AttackGroupProcessor.ATTACK_RADIUS = 32

AttackGroupProcessor.GROUP_TYPE_MIXED = 1
AttackGroupProcessor.GROUP_TYPE_FLYING = 2
AttackGroupProcessor.GROUP_TYPE_DROPSHIP = 3
AttackGroupProcessor.GROUP_TYPE_FEATURED = 4
AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING = 5

AttackGroupProcessor.FLYING_GROUPS = {
    [AttackGroupProcessor.GROUP_TYPE_FLYING] = true,
    [AttackGroupProcessor.GROUP_TYPE_DROPSHIP] = true,
    [AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING] = true,
}

AttackGroupProcessor.GROUP_TIERS = {
    { 1 },
    { 0.7, 0.3 },
    { 0.4, 0.35, 0.25 }
}

local DEBUG_GROUP_STATES = {
    [defines.group_state.gathering] = 'defines.group_state.gathering',
    [defines.group_state.moving] = 'defines.group_state.moving',
    [defines.group_state.attacking_distraction] = 'defines.group_state.attacking_distraction',
    [defines.group_state.attacking_target] = 'defines.group_state.attacking_target',
    [defines.group_state.finished] = 'defines.group_state.finished',
    [defines.group_state.pathfinding] = 'defines.group_state.pathfinding',
    [defines.group_state.wander_in_group] = 'defines.group_state.wander_in_group'
}


---
--- Track unit group, each race should only have 1 active group generator.
--- Units in a group seems considered active units and they have performance penalty.
---
local get_group_tracker = function(race_name)
    if global.group_tracker == nil then
        return nil
    end

    --- Expire after 25000 ticks to prevent stuck
    if global.group_tracker[race_name] and
       game.tick > global.group_tracker[race_name].tick + DAY_TICK
    then
        global.group_tracker[race_name] = nil
        return nil
    end

    return global.group_tracker[race_name] or nil
end

local set_group_tracker = function(race_name, value, field)
    if field then
        global.group_tracker[race_name][field] = value
    else
        global.group_tracker[race_name] = value
    end
end

local get_unit_level_for_tier = function(race_name)
    local level = RaceSettingsHelper.get_level(race_name) - 1
    if level == 0 then
        level = 1
    end
    return level
end

local get_unit_name_by_group_type = {
    [AttackGroupProcessor.GROUP_TYPE_MIXED] = function(race_name, current_tier, group_tracker)
        return RaceSettingsHelper.pick_an_unit_from_tier(race_name, current_tier), false
    end,
    [AttackGroupProcessor.GROUP_TYPE_FLYING] = function(race_name, current_tier, group_tracker)
        return RaceSettingsHelper.pick_a_flying_unit_from_tier(race_name, current_tier), false
    end,
    [AttackGroupProcessor.GROUP_TYPE_DROPSHIP] = function(race_name, current_tier, group_tracker)
        return RaceSettingsHelper.pick_dropship_unit(race_name, current_tier), false
    end,
    [AttackGroupProcessor.GROUP_TYPE_FEATURED] = function(race_name, current_tier, group_tracker)
        return RaceSettingsHelper.pick_featured_unit(race_name, group_tracker.featured_group_id), true
    end,
    [AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING] = function(race_name, current_tier, group_tracker)
        return RaceSettingsHelper.pick_featured_flying_unit(race_name, group_tracker.featured_group_id), true
    end,
}

local pick_an_unit = function(race_name)
    local group_tracker = get_group_tracker(race_name)
    local current_tier = group_tracker.current_tier
    local unit_name = nil
    local is_featured_group = false

    unit_name, is_featured_group = get_unit_name_by_group_type[group_tracker.group_type](race_name, current_tier, group_tracker)
    if unit_name == nil then
        unit_name = RaceSettingsHelper.pick_an_unit(race_name)
    end

    if not is_featured_group then
        group_tracker.current_tier_unit = group_tracker.current_tier_unit + 1

        if group_tracker.current_tier_unit == group_tracker.tiers[current_tier] then
            group_tracker.current_tier_unit = 0
            group_tracker.current_tier = math.min(current_tier + 1, Config.MAX_TIER)
        end
    end

    return unit_name
end

local add_an_unit_to_group = function(surface, group, force, race_name, unit_name, is_elite)
    local unit_full_name
    if is_elite then
        unit_full_name = RaceSettingsHelper.get_race_entity_name(race_name, unit_name, RaceSettingsHelper.get_level(race_name) + Config.elite_squad_level())
    else
        unit_full_name = RaceSettingsHelper.get_race_entity_name(race_name, unit_name, RaceSettingsHelper.get_level(race_name))
    end

    local position = surface.find_non_colliding_position(unit_full_name, group.position,
            AttackGroupProcessor.GROUP_AREA, 2)

    local entity = surface.create_entity({
        name = unit_full_name,
        position = position,
        force = force
    })

    if entity then
        group.add_member(entity)
        return true
    end

    return false
end

local alter_distraction = function(commands,distraction)
    if commands.type then
        commands.distraction = distraction
    else
        for _, command in pairs(commands) do
            command.distraction = distraction
        end
    end
end

local add_to_group = function(surface, group, force, race_name, unit_batch)
    local group_tracker = get_group_tracker(race_name)
    if group.valid == false or group_tracker == nil then
        set_group_tracker(race_name, nil)
        return
    end
    local i = 0
    repeat
        local unit_name = pick_an_unit(race_name)

        local is_elite = false
        if group_tracker.is_elite_attack then
            is_elite = true
        end

        add_an_unit_to_group(surface, group, force, race_name, unit_name, is_elite)
        group_tracker.current_size = group_tracker.current_size + 1
        i = i + 1
    until i == unit_batch
    if group_tracker.current_size >= group_tracker.size then
        local entity_data = AttackGroupBeaconProcessor.pick_current_selected_attack_beacon(surface, group.force, true)
        local pollution_deduction = group_tracker.current_size * AttackGroupProcessor.MIXED_UNIT_POINTS * -2

        if entity_data and entity_data.position then
            local position = entity_data.position

            local commands = AttackGroupPathingProcessor.get_command(group.group_number)

            if commands == nil then
                commands = {
                    type = defines.command.attack_area,
                    destination = { x = position.x, y = position.y },
                    radius = AttackGroupProcessor.ATTACK_RADIUS
                }
            end

            if group_tracker.always_angry then
                alter_distraction(commands, defines.distraction.by_anything)
            end

            if group_tracker.is_precision_attack then
                alter_distraction(commands, defines.distraction.none)

                if Config.precision_strike_warning() then
                    local group_position = group.position
                    group.surface.print({
                        'description.message-incoming-precision-attack',
                        race_name,
                        SurfaceProcessor.get_gps_message(
                                group_position.x,
                                group_position.y,
                                group.surface.name
                        )
                    }, { r = 1, g = 0, b = 0 })
                end
            end
            group.set_command(commands)
            surface.pollute(position, pollution_deduction)
        else
            group.set_autonomous()
            surface.pollute({0, 0}, pollution_deduction)
        end

        set_group_tracker(race_name, nil)
    end
end

local generate_unit_queue = function(
        surface, center_location, force, race_name,
        units_number, options
)
    local group_type = options.group_type or AttackGroupProcessor.GROUP_TYPE_MIXED
    local featured_group_id = options.featured_group_id or nil
    local is_elite_attack = options.is_elite_attack or false
    local attack_beacon = options.attack_beacon or nil
    --- Generate in quick queue.  This group may start to move without custom pathing.
    local as_quick_queue = options.as_quick_queue or false
    --- preserve_tracker is to prevent the track get dropped immediately due to lacking a selected surface
    local preserve_tracker = options.preserve_tracker or false
    --- Makes the group to kill on sight.
    local always_angry = options.always_angry or false


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
        tiers = AttackGroupProcessor.GROUP_TIERS[math.min(get_unit_level_for_tier(race_name), Config.MAX_TIER)]

        local flying_unit_precision_enabled = Config.flying_squad_precision_enabled()
        local spawn_as_flying_unit_precision = RaceSettingsHelper.can_spawn(Config.flying_squad_precision_chance())

        if flying_unit_precision_enabled and spawn_as_flying_unit_precision then
            is_precision_attack = true
        end
    elseif group_type == AttackGroupProcessor.GROUP_TYPE_DROPSHIP then
        tiers = AttackGroupProcessor.GROUP_TIERS[1]
        is_precision_attack = true
    else
        tiers = AttackGroupProcessor.GROUP_TIERS[RaceSettingsHelper.get_tier(race_name)]
    end
    local tiers_units = {}
    for index, tier in pairs(tiers) do
        tiers_units[index] = math.floor((units_number * tier) + 0.5)
    end

    set_group_tracker(race_name, {
        size = units_number,
        current_size = 0,
        group_type = group_type,
        tiers = tiers_units,
        current_tier = 1,
        current_tier_unit = 0,
        is_precision_attack = is_precision_attack,
        is_elite_attack = is_elite_attack,
        featured_group_id = featured_group_id,
        group_spawn_position = center_location,
        attack_beacon_position = attack_beacon.position,
        attack_force = attack_beacon.force,
        tick = game.tick,
        preserve_tracker = preserve_tracker,
        always_angry = always_angry
    })

    local unit_group = surface.create_unit_group({ position = center_location, force = force })

    set_group_tracker(race_name, unit_group, 'group')
    set_group_tracker(race_name, unit_group.group_number, 'group_number')

    repeat
        local unit_batch = AttackGroupProcessor.UNIT_PER_BATCH
        if i == last_queue then
            unit_batch = math.ceil(last_queue_unit)
        end
        if as_quick_queue then
            Cron.add_quick_queue(
                'AttackGroupProcessor.add_to_group',
                surface,
                unit_group,
                force,
                race_name,
                unit_batch
            )
        else
            Cron.add_1_sec_queue(
                'AttackGroupProcessor.add_to_group',
                surface,
                unit_group,
                force,
                race_name,
                unit_batch
            )
        end
        i = i + 1
    until i == queue_length

    local is_aerial = AttackGroupProcessor.FLYING_GROUPS[group_type] or false
    global.erm_unit_groups[unit_group.group_number] = {
        group = unit_group,
        start_position = unit_group.position,
        always_angry = always_angry,
        nearby_retry = 0,
        attack_force = attack_beacon.force,
        created = game.tick,
        is_aerial = is_aerial
    }

    Event.dispatch({
        name = Event.get_event_name(Config.EVENT_REQUEST_PATH),
        source_force = force,
        surface = surface,
        start = center_location,
        goal = attack_beacon.position,
        is_aerial = is_aerial,
        group_number = unit_group.group_number,
    })
end

function AttackGroupProcessor.init_globals()
    --- Track all custom unit groups created by ERM
    global.erm_unit_groups = global.erm_unit_groups or {}
    AttackGroupProcessor.clear_invalid_erm_unit_groups()

    --- Track custom group spawn data, only one active group spawn per enemy race.
    global.group_tracker = global.group_tracker or {}

    --- Track active scout, only one active scout per enemy race.
    global.scout_tracker = global.scout_tracker or {}
    --- Track active scout by unit_number, used on_ai_command_completed event
    global.scout_by_unit_number = global.scout_by_unit_number or {}
    --- Toggle to run periodic scan when a scout spawns.
    global.scout_scanner = global.scout_scanner or false
    global.scout_unit_name = global.scout_unit_name or {}
    AttackGroupProcessor.clear_invalid_scout_unit_name()
    if next(global.scout_tracker) then
        global.scout_scanner = true
        Cron.add_15_sec_queue('AttackGroupBeaconProcessor.start_scout_scan')
    end
end

function AttackGroupProcessor.add_to_group_cron(arg)
    add_to_group(unpack(arg))
end

function AttackGroupProcessor.exec(race_name, force, attack_points)
    if get_group_tracker(race_name) then
        return false
    end

    local flying_enabled = Config.flying_squad_enabled() and RaceSettingsHelper.has_flying_unit(race_name)
    local spawn_as_flying_squad = RaceSettingsHelper.can_spawn(Config.flying_squad_chance()) and RaceSettingsHelper.get_level(race_name) > 1
    local spawn_as_featured_squad = RaceSettingsHelper.can_spawn(Config.featured_squad_chance()) and RaceSettingsHelper.get_tier(race_name) == 3

    --- Try flying Squad. starts at level 2 and max tier at level 4
    if flying_enabled and spawn_as_flying_squad then
        local dropship_enabled = Config.dropship_enabled() and RaceSettingsHelper.has_dropship_unit(race_name)
        local spawn_as_dropship_squad = RaceSettingsHelper.can_spawn(Config.dropship_chance())

        if spawn_as_featured_squad and RaceSettingsHelper.has_featured_flying_squad(race_name) then
            --- Drop as featured flying group
            local squad_id = RaceSettingsHelper.get_featured_flying_squad_id(race_name);
            local units_number = math.min(math.ceil(attack_points / RaceSettingsHelper.get_featured_unit_cost(race_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(
                race_name, force, units_number,
                { group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
                 featured_group_id = squad_id}
            )
        elseif dropship_enabled and spawn_as_dropship_squad then
            --- Dropship Group
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.DROPSHIP_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(
                race_name, force, units_number,
                { group_type = AttackGroupProcessor.GROUP_TYPE_DROPSHIP }
            )
        else
            --- Regular Flying Group
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.FLYING_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(
                    race_name, force, units_number,
                    { group_type = AttackGroupProcessor.GROUP_TYPE_FLYING }
            )
        end
    else
        if spawn_as_featured_squad and RaceSettingsHelper.has_featured_squad(race_name) then
            --- Regular featured Group
            local squad_id = RaceSettingsHelper.get_featured_squad_id(race_name);
            local units_number = math.min(math.ceil(attack_points / RaceSettingsHelper.get_featured_unit_cost(race_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(
                race_name, force, units_number,
                {
                  group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED,
                  featured_group_id = squad_id
                }
            )
        else
            --- Mixed Group
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.MIXED_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(race_name, force, units_number)
        end
    end
end

---
--- options={group_type, featured_group_id, is_elite_attack, target_force, surface, from_retry, bypass_attack_meter, spawn_location}
function AttackGroupProcessor.generate_group(
        race_name,
        force,
        units_number,
        options
)
    options = options or {}
    local from_retry = tonumber(options.from_retry) or 0
    local bypass_attack_meter = options.bypass_attack_meter or false
    local group_tracker = get_group_tracker(race_name)

    if from_retry == 0 and group_tracker then
        return false
    end

    local target_force = options.target_force or AttackGroupHeatProcessor.pick_target(race_name)
    local surface = options.surface or AttackGroupHeatProcessor.pick_surface(race_name, target_force, true)

    if global.override_interplanetary_attack_enabled or
       surface == nil or
       not surface.valid
    then
        if group_tracker and
            not group_tracker.preserve_tracker
        then
            set_group_tracker(race_name, nil)
        end
        return false
    end

    AttackGroupProcessor.UNIT_PER_BATCH = math.ceil(Config.max_group_size() * Config.attack_meter_threshold() / AttackGroupProcessor.MIXED_UNIT_POINTS)

    local attack_beacon_data
    if from_retry > 0 then
        attack_beacon_data  = AttackGroupBeaconProcessor.pick_current_selected_attack_beacon(surface, force)
    else
        attack_beacon_data  = AttackGroupBeaconProcessor.pick_new_attack_beacon(surface, force, target_force)
    end

    local spawn_location = options.spawn_location
    local center_location
    if spawn_location and Position.is_position(spawn_location) then
        center_location = spawn_location
    else
        local spawn_beacon = nil
        local halt_cron = false
        if attack_beacon_data == nil then
            halt_cron = true
        else
            spawn_beacon, halt_cron = AttackGroupBeaconProcessor.pick_spawn_location(surface, force, attack_beacon_data, from_retry)
        end

        if spawn_beacon == nil or spawn_beacon.valid == false then
            if halt_cron == false and from_retry < RETRY then

                --- Retry to find new beacons
                options.from_retry = from_retry + 1
                Cron.add_quick_queue('AttackGroupProcessor.generate_group',
                        race_name, force, units_number, options)
            else
                --- Drop current group if retry fails
                set_group_tracker(race_name, nil)

                --- Try roll a interplantary attack, 33% chance
                if Config.interplanetary_attack_enable() and
                   RaceSettingsHelper.can_spawn(33)
                then
                    Event.dispatch({
                        name = Event.get_event_name(Config.EVENT_INTERPLANETARY_ATTACK_EXEC),
                        race_name = race_name,
                        target_force = target_force
                    })
                end
            end
            return false
        end

        local scout = AttackGroupBeaconProcessor.get_scout_name(race_name, AttackGroupBeaconProcessor.LAND_SCOUT)
        center_location = surface.find_non_colliding_position(
                scout, spawn_beacon.position,
                AttackGroupProcessor.GROUP_AREA, 1)

    end


    if center_location then
        options.attack_beacon = attack_beacon_data.beacon
        generate_unit_queue(
                surface, center_location, force,
                race_name, units_number, options
        )

        if bypass_attack_meter == false then
            if options.is_elite_attack then
                Event.dispatch({
                    name = Event.get_event_name(Config.EVENT_ADJUST_ACCUMULATED_ATTACK_METER),
                    race_name = race_name
                })
            end
            Event.dispatch({
                name = Event.get_event_name(Config.EVENT_ADJUST_ATTACK_METER),
                race_name = race_name
            })
        end

        return true
    end

    return false
end

function AttackGroupProcessor.generate_nuked_group(surface, position, radius, source_entity)
    local target_unit = surface.find_entities_filtered({
        type = { "unit-spawner" },
        force = ForceHelper.get_enemy_forces(),
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
        local group = surface.create_unit_group({ position = target_unit.position, force = target_unit.force })
        local max_unit = Config.max_group_size()
        local i = 0
        for _, unit in pairs(units) do
            group.add_member(unit)
            i = i + 1
            if max_unit == i then
                break
            end
        end

        AttackGroupProcessor.process_attack_position(group, defines.distraction.by_anything, nil, source_entity.force)

        global.erm_unit_groups[group.group_number] = {
            group = group,
            start_position = group.position,
            always_angry = true,
            nearby_retry = 0,
            attack_force = source_entity.force,
            created = game.tick,
            is_aerial = false
        }
    end
end

--- Spawn Elite Group, requires race with featured groups
function AttackGroupProcessor.exec_elite_group(race_name, force, attack_points)
    if get_group_tracker(race_name) then
        return false
    end

    if not RaceSettingsHelper.has_featured_flying_squad(race_name) and
            not RaceSettingsHelper.has_featured_squad(race_name) then
        return false
    end

    local flying_enabled = Config.flying_squad_enabled() and RaceSettingsHelper.has_flying_unit(race_name)
    local spawn_as_flying_squad = RaceSettingsHelper.can_spawn(Config.flying_squad_chance())

    if flying_enabled and spawn_as_flying_squad and RaceSettingsHelper.has_featured_flying_squad(race_name) then
        local squad_id = RaceSettingsHelper.get_featured_flying_squad_id(race_name);
        local units_number = math.min(math.ceil(attack_points / RaceSettingsHelper.get_featured_unit_cost(race_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
        return AttackGroupProcessor.generate_group(
            race_name, force, units_number,
            {group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
            featured_group_id = squad_id,
            is_elite_attack = true}
        )
    elseif RaceSettingsHelper.has_featured_squad(race_name) then
        local squad_id = RaceSettingsHelper.get_featured_squad_id(race_name);
        local units_number = math.min(math.ceil(attack_points / RaceSettingsHelper.get_featured_unit_cost(race_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
        return AttackGroupProcessor.generate_group(
            race_name, force, units_number,
            {group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED,
             featured_group_id = squad_id,
             is_elite_attack = true
            }
        )
    end

    return false
end

function AttackGroupProcessor.process_attack_position(group, distraction, find_nearby, target_force, new_beacon)
    distraction = distraction or defines.distraction.by_enemy
    find_nearby = find_nearby or false
    new_beacon = new_beacon or false
    target_force = target_force or game.forces['player']

    local attack_position = nil
    local target_entity = nil

    local command = AttackGroupPathingProcessor.get_command(group.group_number)
    if command then
        group.set_command(command)
        return
    end

    if find_nearby then
        target_entity = AttackGroupBeaconProcessor.pick_nearby_attack_location(group.surface, group.position)
    end

    if target_entity == nil then
        local beacon = AttackGroupBeaconProcessor.pick_attack_beacon(group.surface, group.force, target_force, new_beacon)
        if beacon then
            attack_position = beacon.position
        end
    end

    if target_entity then
        local command = {
            type = defines.command.attack,
            target = target_entity,
            distraction = distraction
        }
        group.set_command(command)
    elseif attack_position then
        local command = {
            type = defines.command.attack_area,
            destination = { x = attack_position.x, y = attack_position.y },
            radius = AttackGroupProcessor.ATTACK_RADIUS,
            distraction = distraction
        }
        group.set_command(command)
    else
        --- Victory Expansion
        local erm_group_data = global.erm_unit_groups[group.group_number]
        if erm_group_data and erm_group_data.has_completed_command then
            Event.dispatch({
                name = Event.get_event_name(Config.EVENT_REQUEST_BASE_BUILD),
                group = group,
                limit = 1
            })
        end
        group.set_autonomous()
    end
end

---
--- Generate a group immediately without queue, without pathing.  Targets small groups, <= 50 units
---
function AttackGroupProcessor.generate_immediate_group(surface, group_position, spawn_count, race_name)
    if spawn_count > 50 then
        spawn_count = 50
    end

    local race_name = race_name or SurfaceProcessor.get_enemy_on(surface.name)

    local force_name = ForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    local group = surface.create_unit_group { position = group_position, force = force_name}

    local i = 0
    repeat
        local unit_name =  RaceSettingsHelper.pick_an_unit(race_name)
        add_an_unit_to_group(surface, group, force, race_name, unit_name, false)
        i = i + 1
    until i == spawn_count

    return group
end

---
--- Generate an unit via queue, without command.  Targets custom pathing via 3rd party conditions
---
function AttackGroupProcessor.generate_group_via_quick_queue(
    race_name, target_force, group_unit_number, surface, drop_location, options
)
    local force_name = ForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    local attack_beacon_data  = AttackGroupBeaconProcessor.pick_new_attack_beacon(surface, force, target_force)
    if attack_beacon_data then
        options.attack_beacon = attack_beacon_data.beacon
        options.as_quick_queue = true
        generate_unit_queue(
                surface, drop_location, force,
                race_name, group_unit_number, options
        )
    end
end

function AttackGroupProcessor.spawn_scout(race_name, source_force, surface, target_force)
    if global.scout_tracker[race_name] then
        return nil
    end

    local scout_name = AttackGroupBeaconProcessor.LAND_SCOUT
    if RaceSettingsHelper.can_spawn(33) and not TEST_MODE then
        scout_name = AttackGroupBeaconProcessor.AERIAL_SCOUT
    end

    scout_name = AttackGroupBeaconProcessor.get_scout_name(race_name, scout_name)

    --local target_beacon = AttackGroupBeaconProcessor.get_attackable_spawn_beacon(surface, target_force)
    local target_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(surface, source_force, target_force, true)
    local spawn_beacon = AttackGroupBeaconProcessor.get_spawn_beacon(surface, source_force)

    if spawn_beacon == nil or spawn_beacon.valid == false
            or target_beacon == nil or target_beacon.beacon.valid == false then
        return nil
    end

    local spawn_location = surface.find_non_colliding_position(
            scout_name, spawn_beacon.position,
            AttackGroupProcessor.GROUP_AREA, 1)

    local scout = surface.create_entity({
        name = scout_name,
        force = source_force,
        position = spawn_location
    })

    scout.set_command({
        type = defines.command.go_to_location,
        destination = target_beacon.position,
        radius = 16,
        distraction = defines.distraction.none
    })

    global.scout_tracker[race_name] = {
        entity = scout,
        unit_number = scout.unit_number,
        position = scout.position,
        final_destination = target_beacon.position,
        target_force = target_force,
        update_tick = game.tick
    }
    global.scout_by_unit_number[scout.unit_number] = {
        entity = scout,
        race_name = race_name,
        can_repath = true
    }

    if global.scout_scanner == false then
        global.scout_scanner = true
        Cron.add_15_sec_queue('AttackGroupBeaconProcessor.start_scout_scan')
    end

    return scout
end

function AttackGroupProcessor.is_erm_unit_group(unit_number)
    local erm_unit_groups = global.erm_unit_groups
    return erm_unit_groups[unit_number] and erm_unit_groups[unit_number].group and erm_unit_groups[unit_number].group.valid
end

function AttackGroupProcessor.destroy_invalid_group(group, start_position)
    start_position = start_position or group.position

    if group.valid and
        ForceHelper.is_enemy_force(group.force) and
        group.is_script_driven and
        group.command == nil and
        (start_position.x == group.position.x and start_position.y == group.position.y)
    then
        local group_size = table_size(group.members)
        local group_force = group.force
        local group_number = group.group_number
        local race_name = ForceHelper.extract_race_name_from(group_force.name)
        local refund_points = AttackGroupProcessor.destroy_members(group)

        --- Hardcoded chance to spawn half size aerial group
        if (RaceSettingsHelper.can_spawn(SPAWN_CHANCE) and group_size >= MIN_GROUP_SIZE) or TEST_MODE then
            local group_type = AttackGroupProcessor.GROUP_TYPE_FLYING
            local target_force =  AttackGroupHeatProcessor.pick_target(race_name)
            local surface =  AttackGroupHeatProcessor.pick_surface(race_name, target_force)

            AttackGroupPathingProcessor.remove_node(group_number)
            --- This call needs to bypass attack meters calculations
            Cron.add_2_sec_queue('AttackGroupProcessor.generate_group',
                race_name, group_force, math.max(math.ceil(group_size / 2), 10),
                { group_type=group_type,
                  target_force = target_force,
                  surface=surface,
                  bypass_attack_meter=true
                }
            )
        elseif Config.race_is_active(race_name) then
            RaceSettingsHelper.add_to_attack_meter(race_name, refund_points)
        end
    end
end

function AttackGroupProcessor.destroy_members(group)
    local members = group.members
    local refundPoints = 0
    for _, member in pairs(members) do
        member.destroy()
        refundPoints = refundPoints + AttackGroupProcessor.MIXED_UNIT_POINTS
    end

    group.destroy()
    return refundPoints
end

-- Clear up invalid erm groups or small wandering groups.
function AttackGroupProcessor.clear_invalid_erm_unit_groups()
    local erm_groups = global.erm_unit_groups
    for id, content in pairs(erm_groups) do
        local group = content.group
        if group == nil or group.valid == false then

            erm_groups[id] = nil
        elseif group.valid then
            local member_size = #group.members
            local created_tick = content.created or 0
            local skip = false

            if member_size < MIN_GROUP_SIZE or game.tick >= created_tick + ERM_GROUP_TIME_TO_LIVE then
                AttackGroupProcessor.destroy_members(group)
                erm_groups[id] = nil
                skip = true
            end

            if not skip and
                game.tick >= created_tick + IDLE_TIME_OUT and
                group.state == defines.group_state.gathering
            then
                if group.command then
                    group.start_moving()
                else
                    AttackGroupProcessor.process_attack_position(group, nil, nil, erm_groups.attack_force)
                    group.start_moving()
                end
            end
        end
    end
end

function AttackGroupProcessor.clear_invalid_scout_unit_name()
    for group_number, group in pairs(global.scout_unit_name) do
        local group_created = tonumber(group.tick) or 0
        if not group.entity.valid and game.tick > group_created + DAY_TICK then
            global.scout_unit_name[group_number] = nil
        end
    end
end


return AttackGroupProcessor