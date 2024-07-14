---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/1/2024 5:42 PM
---
local Event = require('__stdlib__/stdlib/event/event')

local Cron = require('__enemyracemanager__/lib/cron_processor')
local Config = require('__enemyracemanager__/lib/global_config')
local SurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local RaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local SpawnLocationScanner = require('__enemyracemanager__/lib/spawn_location_scanner')
local AttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')
local AttackMeterProcessor = require('__enemyracemanager__/lib/attack_meter_processor')

local InterplanetaryAttacks = {}

local NAUVIS = 1

local base_spawn_rate = 50

local group_variance = 20
local home_group_size = 20

local can_perform_attack = function()
    return global.is_multi_planets_game and Config.interplanetary_attack_enable()
end

function InterplanetaryAttacks.init_globals()
    --- global.interplanetary_intel[surface_index] = {
    ---     radius,
    ---     type={"moon","planet",etc},
    ---     has_player_entities=true,
    ---     defense=0
    --- }
    global.interplanetary_intel = global.interplanetary_intel or {}
    global.interplanetary_tracker = global.interplanetary_tracker or {}

    if not global.interplanetary_intel[1] then
        global.interplanetary_intel[1] = InterplanetaryAttacks.get_default_intel()
        global.interplanetary_intel[1].has_player_entities = true
    end
end

function InterplanetaryAttacks.get_default_intel()
    return {
        radius = 900000,
        type = 'planet',
        updated = game.tick,
        defense = 0,
        has_player_entities = false,
    }
end

function InterplanetaryAttacks.exec(race_name, target_force, drop_location)
    if not can_perform_attack() then
        return false
    end

    local surface_id, intel = next(global.interplanetary_intel, global.interplanetary_tracker.surface_id)
    if not surface_id or not intel then
        global.interplanetary_tracker.surface_id = nil
        return false
    end
    local surface = game.surfaces[surface_id]

    global.interplanetary_tracker.surface_id = surface_id

    --- Lower spawn chance by up to 20%
    if intel.defense and intel.defense > 0 then
        intel.calculated_defense = math.ceil(math.min(math.pow(math.log(intel.defense),2) * 1.5, 20))
    else
        intel.calculated_defense = 0
    end

    if RaceSettingsHelper.can_spawn(base_spawn_rate - intel.calculated_defense) == false and
        not global.override_interplanetary_attack_roll_bypass then
        AttackMeterProcessor.adjust_attack_meter(race_name)
        return false
    end

    if not drop_location then
        drop_location = SpawnLocationScanner.get_spawn_location(surface)
    end

    if not drop_location then
        return false
    end

    local flying_enabled = Config.flying_squad_enabled() and RaceSettingsHelper.has_flying_unit(race_name)
    local spawn_as_flying_squad = RaceSettingsHelper.can_spawn(Config.flying_squad_chance()) and RaceSettingsHelper.get_level(race_name) > 1
    local max_unit_number = Config.max_group_size()
    local group_unit_number = math.random(max_unit_number - group_variance, max_unit_number + group_variance)

    --- If it's a build group, 20 units use for building on spot, the rest will attack.
     local build_home = RaceSettingsHelper.can_spawn(Config.interplanetary_attack_raid_build_base_chance()) or global.override_interplanetary_attack_build_base
    if build_home then
        group_unit_number = group_unit_number - home_group_size
    end


    local group_type
    if (flying_enabled and spawn_as_flying_squad) or global.override_interplanetary_attack_spawn_flyers then
        group_unit_number = math.ceil(group_unit_number / 2)
        group_type = AttackGroupProcessor.GROUP_TYPE_FLYING
    end

   if build_home then
        local group = AttackGroupProcessor.generate_immediate_group(
                game.surfaces[global.interplanetary_tracker.surface_id],
                drop_location,
                home_group_size,
                race_name
        )
        if group then
            Event.raise_event(Event.get_event_name(Config.EVENT_REQUEST_BASE_BUILD),{
                group = group
            })
        end
    end

    local options = {
        group_type = group_type,
        preserve_tracker = true,
        always_angry = false
    }
    AttackGroupProcessor.generate_group_via_quick_queue(
            race_name,
            target_force,
            group_unit_number,
            surface,
            drop_location,
            options
    )
    AttackMeterProcessor.adjust_attack_meter(race_name)

    return true
end

function InterplanetaryAttacks.queue_scan()
    for surface_name, _ in pairs(SurfaceProcessor.get_attackable_surfaces()) do
        local surface = game.surfaces[surface_name]
        Cron.add_quick_queue('InterplanetaryAttacks.scan', surface)
    end
end

--- Scan planets for player entities on a daily basis, mark it attack-able if entity found.
function InterplanetaryAttacks.scan(surface)
    if not can_perform_attack() then
        return
    end

    if surface and ForceHelper.can_have_enemy_on(surface) then
        --- Event to manipulate global.interplanetary_intel
        local intel =  global.interplanetary_intel[surface.index]
        Event.raise_event(Event.get_event_name(Config.EVENT_INTERPLANETARY_ATTACK_SCAN),{
            intel = intel,
            surface = surface
        })

        --- Scan planet for dropzone only if it's occupied
        if intel.has_player_entities then
            local max_planet_radius
            if intel.radius then
                max_planet_radius = intel.radius
            end
            SpawnLocationScanner.scan(surface, max_planet_radius)
        end
    end

end

function InterplanetaryAttacks.set_intel(surface_index, data)
    if data and not type(data) == 'table' then
        error("data must be a table")
        return
    end

    global.interplanetary_intel[surface_index] = data
end

function InterplanetaryAttacks.get_intel(surface_index)
    return global.interplanetary_intel[surface_index]
end

function InterplanetaryAttacks.remove_surface(surface_index)
    global.interplanetary_intel[surface_index] = nil
end

function InterplanetaryAttacks.reset_globals()
    global.interplanetary_intel = {}
    global.interplanetary_tracker =  {}
    InterplanetaryAttacks.init_globals()
end

return InterplanetaryAttacks