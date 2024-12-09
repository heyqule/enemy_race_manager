---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/21/2021 10:45 PM
---

require("util")
require("global")
local Position = require("__erm_libs__/stdlib/position")


local Config = require("__enemyracemanager__/lib/global_config")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")
local DebugHelper = require("__enemyracemanager__/lib/debug_helper")

local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local AttackGroupPathingProcessor = require("__enemyracemanager__/lib/attack_group_pathing_processor")
local AttackGroupHeatProcessor = require("__enemyracemanager__/lib/attack_group_heat_processor")
local SurfaceProcessor = require("__enemyracemanager__/lib/surface_processor")
local QualityProcessor = require("__enemyracemanager__/lib/quality_processor")


local Cron = require("__enemyracemanager__/lib/cron_processor")

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
    [defines.group_state.gathering] = "defines.group_state.gathering",
    [defines.group_state.moving] = "defines.group_state.moving",
    [defines.group_state.attacking_distraction] = "defines.group_state.attacking_distraction",
    [defines.group_state.attacking_target] = "defines.group_state.attacking_target",
    [defines.group_state.finished] = "defines.group_state.finished",
    [defines.group_state.pathfinding] = "defines.group_state.pathfinding",
    [defines.group_state.wander_in_group] = "defines.group_state.wander_in_group"
}


---
--- Track unit group, each race should only have 1 active group generator.
--- Units in a group seems considered active units and they have performance penalty.
---
local get_group_tracker = function(force_name)
    if storage.group_tracker == nil then
        return nil
    end

    --- Expire after 25000 ticks to prevent stuck
    if storage.group_tracker[force_name] and
       game.tick > storage.group_tracker[force_name].tick + DAY_TICK
    then
        storage.group_tracker[force_name] = nil
        return nil
    end

    return storage.group_tracker[force_name] or nil
end

local set_group_tracker = function(force_name, value, field)
    if field then
        storage.group_tracker[force_name][field] = value
    else
        storage.group_tracker[force_name] = value
    end
end


local get_unit_name_by_group_type = {
    [AttackGroupProcessor.GROUP_TYPE_MIXED] = function(force_name, current_tier, group_tracker)
        return RaceSettingsHelper.pick_an_unit_from_tier(force_name, current_tier), false
    end,
    [AttackGroupProcessor.GROUP_TYPE_FLYING] = function(force_name, current_tier, group_tracker)
        return RaceSettingsHelper.pick_a_flying_unit_from_tier(force_name, current_tier), false
    end,
    [AttackGroupProcessor.GROUP_TYPE_DROPSHIP] = function(force_name, current_tier, group_tracker)
        return RaceSettingsHelper.pick_dropship_unit(force_name, current_tier), false
    end,
    [AttackGroupProcessor.GROUP_TYPE_FEATURED] = function(force_name, current_tier, group_tracker)
        return RaceSettingsHelper.pick_featured_unit(force_name, group_tracker.featured_group_id), true
    end,
    [AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING] = function(force_name, current_tier, group_tracker)
        return RaceSettingsHelper.pick_featured_flying_unit(force_name, group_tracker.featured_group_id), true
    end,
}

local pick_an_unit = function(force_name)
    local group_tracker = get_group_tracker(force_name)
    local current_tier = group_tracker.current_tier
    local unit_name = nil
    local is_featured_group = false

    unit_name, is_featured_group = get_unit_name_by_group_type[group_tracker.group_type](force_name, current_tier, group_tracker)
    if unit_name == nil then
        unit_name = RaceSettingsHelper.pick_an_unit(force_name)
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

local add_an_unit_to_group = function(surface, group, force, force_name, unit_name, is_elite)
    local unit_full_name
    if is_elite then
        unit_full_name = RaceSettingsHelper.get_race_entity_name(force_name, unit_name, QualityProcessor.roll_quality(force_name, surface.name, true))
    else
        unit_full_name = RaceSettingsHelper.get_race_entity_name(force_name, unit_name, QualityProcessor.roll_quality(force_name, surface.name))
    end

    local position = surface.find_non_colliding_position(unit_full_name, group.position,
            AttackGroupProcessor.GROUP_AREA, 2)
    local entity

    if position then
        storage.skip_quality_rolling = true
        entity = surface.create_entity({
            name = unit_full_name,
            position = position,
            force = force
        })
    end

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

local add_to_group = function(surface, group, force, force_name, unit_batch)
    local group_tracker = get_group_tracker(force_name)
    if group.valid == false or group_tracker == nil then
        set_group_tracker(force_name, nil)
        return
    end
    local i = 0
    repeat
        local unit_name = pick_an_unit(force_name)

        local is_elite = false
        if group_tracker.is_elite_attack then
            is_elite = true
        end

        add_an_unit_to_group(surface, group, force, force_name, unit_name, is_elite)
        group_tracker.current_size = group_tracker.current_size + 1
        i = i + 1
    until i == unit_batch
    if group_tracker.current_size >= group_tracker.size then
        local entity_data = AttackGroupBeaconProcessor.pick_current_selected_attack_beacon(surface, group.force, true)
        local pollution_deduction = group_tracker.current_size * AttackGroupProcessor.MIXED_UNIT_POINTS * -2

        if entity_data and entity_data.position then
            local position = entity_data.position

            local commands = AttackGroupPathingProcessor.get_command(group.unique_id)

            if commands == nil then
                commands = {
                    type = defines.command.attack_area,
                    destination = { x = position.x, y = position.y },
                    radius = AttackGroupProcessor.ATTACK_RADIUS
                }
                if DEBUG_MODE then
                    DebugHelper.drawline(1, "default attack path", {r=1,g=1,b=0,a=0.5}, group.position , position)
                end
            else
                if DEBUG_MODE then
                    for index, command in pairs(commands) do
                        if index == 1 then
                            DebugHelper.drawline(1, "custom attack path:"..index, {r=1,g=1,b=0,a=0.5}, group.position , command.destination)
                        elseif commands.commands[index] then
                            DebugHelper.drawline(1, "custom attack path:"..index, {r=1,g=1,b=0,a=0.5},  commands.commands[index-1].destination ,  command.destination)
                        end
                    end
                end
            end

            if group_tracker.always_angry then
                alter_distraction(commands, defines.distraction.by_anything)
            end

            if group_tracker.is_precision_attack then
                alter_distraction(commands, defines.distraction.none)

                if Config.precision_strike_warning() then
                    local group_position = group.position
                    group.surface.print({
                        "description.message-incoming-precision-attack",
                        force_name,
                        SurfaceProcessor.get_gps_message(
                                group_position.x,
                                group_position.y,
                                group.surface.name
                        )
                    }, { r = 1, g = 0, b = 0 })
                end
            end
            group.set_command(commands)
            if not storage.erm_unit_groups[group.unique_id] then
                storage.erm_unit_groups[group.unique_id] = {
                    commands = commands,
                    start_position = group.position,
                    group = group,
                    always_angry = false,
                    nearby_retry = 0,
                    attack_force = 'player',
                    created = game.tick
                }
            else
                storage.erm_unit_groups[group.unique_id].commands = commands
            end
            surface.pollute(position, pollution_deduction)
        elseif group.surface.pollutant_type then
            group.set_autonomous()
            surface.pollute({0, 0}, pollution_deduction)
        else
            --- Re-add 20% of AttackGroupProcessor.MIXED_UNIT_POINTS
            RaceSettingsHelper.add_to_attack_meter(group.force.name, #group.members * 5)
            AttackGroupProcessor.queue_for_destroy(group)
        end

        set_group_tracker(force_name, nil)
    end
end

local generate_unit_queue = function(
        surface, center_location, force, force_name,
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
        tiers = AttackGroupProcessor.GROUP_TIERS[math.min(QualityProcessor.get_tier(force_name, surface.name), Config.MAX_TIER)]

        local flying_unit_precision_enabled = Config.flying_squad_precision_enabled()
        local spawn_as_flying_unit_precision = RaceSettingsHelper.can_spawn(Config.flying_squad_precision_chance())

        if flying_unit_precision_enabled and spawn_as_flying_unit_precision then
            is_precision_attack = true
        end
    elseif group_type == AttackGroupProcessor.GROUP_TYPE_DROPSHIP then
        tiers = AttackGroupProcessor.GROUP_TIERS[1]
        is_precision_attack = true
    else
        tiers = AttackGroupProcessor.GROUP_TIERS[QualityProcessor.get_tier(force.name, surface.name)]
    end
    local tiers_units = {}
    for index, tier in pairs(tiers) do
        tiers_units[index] = math.floor((units_number * tier) + 0.5)
    end

    set_group_tracker(force_name, {
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

    set_group_tracker(force_name, unit_group, "group")
    set_group_tracker(force_name, unit_group.unique_id, "unique_id")

    repeat
        local unit_batch = AttackGroupProcessor.UNIT_PER_BATCH
        if i == last_queue then
            unit_batch = math.ceil(last_queue_unit)
        end
        if as_quick_queue then
            Cron.add_quick_queue(
                "AttackGroupProcessor.add_to_group",
                surface,
                unit_group,
                force,
                force_name,
                unit_batch
            )
        else
            Cron.add_1_sec_queue(
                "AttackGroupProcessor.add_to_group",
                surface,
                unit_group,
                force,
                force_name,
                unit_batch
            )
        end
        i = i + 1
    until i == queue_length

    local is_aerial = AttackGroupProcessor.FLYING_GROUPS[group_type] or false
    storage.erm_unit_groups[unit_group.unique_id] = {
        group = unit_group,
        start_position = unit_group.position,
        always_angry = always_angry,
        nearby_retry = 0,
        attack_force = attack_beacon.force,
        created = game.tick,
        is_aerial = is_aerial
    }

    script.raise_event(
        Config.custom_event_handlers[Config.EVENT_REQUEST_PATH],
        {
            source_force = force,
            surface = surface,
            start = center_location,
            goal = attack_beacon.position,
            is_aerial = is_aerial,
            group_number = unit_group.unique_id,
        }
    )
end

function AttackGroupProcessor.init_globals()
    --- Track all custom unit groups created by ERM
    storage.erm_unit_groups = storage.erm_unit_groups or {}
    AttackGroupProcessor.clear_invalid_erm_unit_groups()

    --- Track custom group spawn data, only one active group spawn per enemy race.
    storage.group_tracker = storage.group_tracker or {}

    --- Track active scout, only one active scout per enemy race.
    storage.scout_tracker = storage.scout_tracker or {}
    --- Track active scout by unit_number, used on_ai_command_completed event
    storage.scout_by_unit_number = storage.scout_by_unit_number or {}
    --- Toggle to run periodic scan when a scout spawns.
    storage.scout_scanner = storage.scout_scanner or false
    storage.scout_unit_name = storage.scout_unit_name or {}
    AttackGroupProcessor.clear_invalid_scout_unit_name()
    if next(storage.scout_tracker) then
        storage.scout_scanner = true
        Cron.add_15_sec_queue("AttackGroupBeaconProcessor.start_scout_scan")
    end
end

function AttackGroupProcessor.add_to_group_cron(arg)
    add_to_group(unpack(arg))
end

function AttackGroupProcessor.exec(force_name, force, attack_points)
    if get_group_tracker(force_name) then
        return false
    end

    local target_force = AttackGroupHeatProcessor.pick_target(force_name)
    local surface = AttackGroupHeatProcessor.pick_surface(force_name, target_force, true)
    if target_force == nil or surface == nil then
        return false
    end

    local tier =  QualityProcessor.get_tier(force.name, surface.name)

    local flying_enabled = Config.flying_squad_enabled() and RaceSettingsHelper.has_flying_unit(force_name)
    local spawn_as_flying_squad = RaceSettingsHelper.can_spawn(Config.flying_squad_chance()) and tier > 2
    local spawn_as_featured_squad = RaceSettingsHelper.can_spawn(Config.featured_squad_chance()) and tier == 3

    --- Try flying Squad. starts at level 2 and max tier at level 4
    if flying_enabled and spawn_as_flying_squad then
        local dropship_enabled = Config.dropship_enabled() and RaceSettingsHelper.has_dropship_unit(force_name)
        local spawn_as_dropship_squad = RaceSettingsHelper.can_spawn(Config.dropship_chance())

        if spawn_as_featured_squad and RaceSettingsHelper.has_featured_flying_squad(force_name) then
            --- Drop as featured flying group
            local squad_id = RaceSettingsHelper.get_featured_flying_squad_id(force_name);
            local units_number = math.min(math.ceil(attack_points / RaceSettingsHelper.get_featured_unit_cost(force_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(
                force, units_number,
                { group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
                  target_force=target_force,
                  surface=surface,
                 featured_group_id = squad_id}
            )
        elseif dropship_enabled and spawn_as_dropship_squad then
            --- Dropship Group
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.DROPSHIP_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(
                force, units_number,
                { group_type = AttackGroupProcessor.GROUP_TYPE_DROPSHIP,
                  target_force=target_force,
                  surface=surface,
                }
            )
        else
            --- Regular Flying Group
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.FLYING_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(
                    force, units_number,
                    { group_type = AttackGroupProcessor.GROUP_TYPE_FLYING,
                      target_force=target_force,
                      surface=surface
                    }
            )
        end
    else
        if spawn_as_featured_squad and RaceSettingsHelper.has_featured_squad(force_name) then
            --- Regular featured Group
            local squad_id = RaceSettingsHelper.get_featured_squad_id(force_name);
            local units_number = math.min(math.ceil(attack_points / RaceSettingsHelper.get_featured_unit_cost(force_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(
                force, units_number,
                {
                  group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED,
                  featured_group_id = squad_id,
                  target_force=target_force,
                  surface=surface
                }
            )
        else
            --- Mixed Group
            local units_number = math.min(math.ceil(attack_points / AttackGroupProcessor.MIXED_UNIT_POINTS), AttackGroupProcessor.MAX_GROUP_SIZE)
            return AttackGroupProcessor.generate_group(force, units_number, {
                target_force=target_force,
                surface=surface,
            })
        end
    end
end

---
--- options={group_type, featured_group_id, is_elite_attack, target_force, surface, from_retry, bypass_attack_meter, spawn_location}
---
--- @TODO param refactor
function AttackGroupProcessor.generate_group(
        force,
        units_number,
        options
)
    options = options or {}
    local force_name = force.name
    local from_retry = tonumber(options.from_retry) or 0
    local bypass_attack_meter = options.bypass_attack_meter or false
    local group_tracker = get_group_tracker(force_name)

    if from_retry == 0 and group_tracker then
        return false
    end

    local target_force = options.target_force or AttackGroupHeatProcessor.pick_target(force_name)
    local surface = options.surface or AttackGroupHeatProcessor.pick_surface(force_name, target_force, true)

    if storage.override_interplanetary_attack_enabled or
       surface == nil or
       not surface.valid
    then
        if group_tracker and
            not group_tracker.preserve_tracker
        then
            set_group_tracker(force_name, nil)
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
                Cron.add_quick_queue("AttackGroupProcessor.generate_group",
                        force, units_number, options)
            else
                --- Drop current group if retry fails
                set_group_tracker(force_name, nil)

                --- @TODO interplanetary attack disabled for 2.0
                --- Try roll a interplantary attack, 33% chance
                --if Config.interplanetary_attack_enable() and
                --   RaceSettingsHelper.can_spawn(33)
                --then
                --    script.raise_event(
                --            Config.custom_event_handlers[Config.EVENT_INTERPLANETARY_ATTACK_EXEC],
                --            {
                --                force_name = force_name,
                --                target_force = target_force
                --            })
                --end
            end
            return false
        end

        local scout = AttackGroupBeaconProcessor.get_scout_name(force_name, AttackGroupBeaconProcessor.LAND_SCOUT)
        center_location = surface.find_non_colliding_position(
                scout, spawn_beacon.position,
                AttackGroupProcessor.GROUP_AREA, 1)

    end


    if center_location then
        options.attack_beacon = attack_beacon_data.beacon
        generate_unit_queue(
                surface, center_location, force,
                force_name, units_number, options
        )

        if bypass_attack_meter == false then
            if options.is_elite_attack then
                script.raise_event(
                        Config.custom_event_handlers[Config.EVENT_ADJUST_ACCUMULATED_ATTACK_METER],
                        {
                            force_name = force_name
                        }
                )
            end

            script.raise_event(
                    Config.custom_event_handlers[Config.EVENT_ADJUST_ATTACK_METER],
                    {
                        force_name = force_name
                    }
            )
        end

        return true
    end

    return false
end

function AttackGroupProcessor.generate_nuked_group(surface, position, radius, source_entity)
    if source_entity == nil then
        return
    end

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
        condition = "same"
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
        AttackGroupProcessor.process_attack_position({
            group = group,
            target_force = source_entity.force,
            distraction = defines.distraction.by_anything
        })

        storage.erm_unit_groups[group.unique_id] = {
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
function AttackGroupProcessor.exec_elite_group(force_name, force, attack_points)
    if get_group_tracker(force_name) then
        return false
    end

    if not RaceSettingsHelper.has_featured_flying_squad(force_name) and
            not RaceSettingsHelper.has_featured_squad(force_name) then
        return false
    end

    local flying_enabled = Config.flying_squad_enabled() and RaceSettingsHelper.has_flying_unit(force_name)
    local spawn_as_flying_squad = RaceSettingsHelper.can_spawn(Config.flying_squad_chance())

    if flying_enabled and spawn_as_flying_squad and RaceSettingsHelper.has_featured_flying_squad(force_name) then
        local squad_id = RaceSettingsHelper.get_featured_flying_squad_id(force_name);
        local units_number = math.min(math.ceil(attack_points / RaceSettingsHelper.get_featured_unit_cost(force_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
        return AttackGroupProcessor.generate_group(
            force, units_number,
            {group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
            featured_group_id = squad_id,
            is_elite_attack = true}
        )
    elseif RaceSettingsHelper.has_featured_squad(force_name) then
        local squad_id = RaceSettingsHelper.get_featured_squad_id(force_name);
        local units_number = math.min(math.ceil(attack_points / RaceSettingsHelper.get_featured_unit_cost(force_name, squad_id)), AttackGroupProcessor.MAX_GROUP_SIZE)
        return AttackGroupProcessor.generate_group(
            force, units_number,
            {group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED,
             featured_group_id = squad_id,
             is_elite_attack = true
            }
        )
    end

    return false
end

---
--- { group = required, distraction = optional, find_nearby = optional, target_force = optional, new_beacon = optional}
---
function AttackGroupProcessor.process_attack_position(options)

    local group = options.group
    local distraction = options.distraction or defines.distraction.by_enemy
    local find_nearby = options.find_nearby or false
    local new_beacon = options.new_beacon or false
    local target_force = options.target_force or AttackGroupHeatProcessor.pick_target(group.force.name)

    local attack_position = nil
    local target_entity = nil

    local command = AttackGroupPathingProcessor.get_command(group.unique_id)
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

    local erm_group_data = storage.erm_unit_groups[group.unique_id]
    --- @TODO SPIDER AI ISSUE BYPASS, only assign now attack command if the group is not in same location.
    local is_near_same_location = false
    if erm_group_data and erm_group_data.has_completed_command_at then
        is_near_same_location = Position.manhattan_distance(erm_group_data.has_completed_command_at, group.position) < AttackGroupProcessor.ATTACK_RADIUS
    end

    if target_entity then
        local command = {
            type = defines.command.attack,
            target = target_entity,
            distraction = distraction
        }
        group.set_command(command)
    elseif attack_position and not is_near_same_location then
        local command = {
            type = defines.command.attack_area,
            destination = { x = attack_position.x, y = attack_position.y },
            radius = AttackGroupProcessor.ATTACK_RADIUS / 2,
            distraction = distraction
        }    
        group.set_command(command)
    elseif erm_group_data then
        --- Victory Wander and Victory Expansion
        if erm_group_data.ran_wandering_command then
            script.raise_event(
                    Config.custom_event_handlers[Config.EVENT_REQUEST_BASE_BUILD],
                    {
                        group = group,
                        limit = 1
                    }
            )

            AttackGroupProcessor.queue_for_destroy(group)
        else
            erm_group_data.ran_wandering_command = true
            erm_group_data.has_completed_command_at = nil
            local command = {
                type = defines.command.wander,
                ticks_to_wait = 3600
            }
            group.set_command(command)
        end            
    end
end

---
--- Generate a group immediately without queue, without pathing.  Targets small groups, <= 50 units
---
function AttackGroupProcessor.generate_immediate_group(options)
    local surface = options.surface
    local group_position = options.group_position
    local spawn_count = options.spawn_count
    local force_name = options.force_name

    if spawn_count > 50 then
        spawn_count = 50
    end

    local force_name = force_name or SurfaceProcessor.get_enemy_on(surface.name)

    local force = game.forces[force_name]
    local group = surface.create_unit_group { position = group_position, force = force_name}

    local i = 0
    repeat
        local unit_name =  RaceSettingsHelper.pick_an_unit(force_name)
        add_an_unit_to_group(surface, group, force, force_name, unit_name, false)
        i = i + 1
    until i == spawn_count

    return group
end

---
--- Generate an unit via queue, without command.  Targets custom pathing via 3rd party conditions
---
function AttackGroupProcessor.generate_group_via_quick_queue(options)
    local force_name = options.force_name
    local target_force = options.target_force
    local group_unit_number = options.group_unit_number
    local surface = options.surface
    local drop_location = options.drop_location

    local force = game.forces[force_name]
    local attack_beacon_data  = AttackGroupBeaconProcessor.pick_new_attack_beacon(surface, force, target_force)
    if attack_beacon_data then
        options.attack_beacon = attack_beacon_data.beacon
        options.as_quick_queue = true
        generate_unit_queue(
                surface, drop_location, force,
                force_name, group_unit_number, options
        )
    end
end

function AttackGroupProcessor.spawn_scout(force_name, source_force, surface, target_force)
    if storage.scout_tracker[force_name] then
        return nil
    end

    local scout_name = AttackGroupBeaconProcessor.LAND_SCOUT
    if RaceSettingsHelper.can_spawn(33) and not TEST_MODE then
        scout_name = AttackGroupBeaconProcessor.AERIAL_SCOUT
    end

    scout_name = AttackGroupBeaconProcessor.get_scout_name(force_name, scout_name)

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

    if not spawn_location then
        return nil
    end

    storage.skip_quality_rolling = true
    local scout = surface.create_entity({
        name = scout_name,
        force = source_force,
        position = spawn_location
    })

    if scout == nil then
        return nil
    end

    scout.commandable.set_command({
        type = defines.command.go_to_location,
        destination = target_beacon.position,
        radius = 16,
        distraction = defines.distraction.none
    })

    storage.scout_tracker[force_name] = {
        entity = scout,
        unit_number = scout.unit_number,
        position = scout.position,
        final_destination = target_beacon.position,
        target_force = target_force,
        update_tick = game.tick
    }
    storage.scout_by_unit_number[scout.unit_number] = {
        entity = scout,
        force_name = force_name,
        can_repath = true
    }

    if storage.scout_scanner == false then
        storage.scout_scanner = true
        Cron.add_15_sec_queue("AttackGroupBeaconProcessor.start_scout_scan")
    end

    return scout
end

function AttackGroupProcessor.is_erm_unit_group(unit_number)
    local erm_unit_groups = storage.erm_unit_groups
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
        local group_number = group.unique_id
        local force_name = group_force.name
        local refund_points = AttackGroupProcessor.destroy_members(group)

        --- Hardcoded chance to spawn half size aerial group
        if (RaceSettingsHelper.can_spawn(SPAWN_CHANCE) and group_size >= MIN_GROUP_SIZE) or TEST_MODE then
            local group_type = AttackGroupProcessor.GROUP_TYPE_FLYING
            local target_force =  AttackGroupHeatProcessor.pick_target(force_name)
            local surface =  AttackGroupHeatProcessor.pick_surface(force_name, target_force)

            AttackGroupPathingProcessor.remove_node(group_number)
            --- This call needs to bypass attack meters calculations
            Cron.add_2_sec_queue("AttackGroupProcessor.generate_group",
                group_force, math.max(math.ceil(group_size / 2), 10),
                { group_type=group_type,
                  target_force = target_force,
                  surface=surface,
                  bypass_attack_meter=true
                }
            )
        elseif Config.race_is_active(force_name) then
            RaceSettingsHelper.add_to_attack_meter(force_name, refund_points)
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
    local erm_groups = storage.erm_unit_groups
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
                    AttackGroupProcessor.process_attack_position({
                        group = group,
                        target_force = erm_groups.attack_force
                    })
                    group.start_moving()
                end
            end
        end
    end
end

function AttackGroupProcessor.clear_invalid_scout_unit_name()
    for group_number, group in pairs(storage.scout_unit_name) do
        local group_created = tonumber(group.tick) or 0
        if not group.entity.valid and game.tick > group_created + DAY_TICK then
            storage.scout_unit_name[group_number] = nil
        end
    end
end

function AttackGroupProcessor.queue_for_destroy(commandable)
    Cron.add_1_min_queue("AttackGroupProcessor.cleanup_commandable", commandable)
end

--- Clean up unit without triggering dying effect
function AttackGroupProcessor.cleanup_commandable(commandable)
    if commandable and commandable.valid then
        if commandable.is_unit_group and commandable.members  then
            for _, member in pairs(commandable.members) do
                member.destory({raise_destroy=true})
            end
        elseif commandable.entity and commandable.entity.valid then
            commandable.entity.destroy({raise_destroy=true})
        end
    end
end
return AttackGroupProcessor