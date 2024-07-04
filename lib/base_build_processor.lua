---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 3/31/2021 8:54 PM
---

local String = require('__stdlib__/stdlib/utils/string')
local Event = require('__stdlib__/stdlib/event/event')

local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local RaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local DebugHelper = require('__enemyracemanager__/lib/debug_helper')

local Cron = require('__enemyracemanager__/lib/cron_processor')

local BaseBuildProcessor = {}

local building_switch = {
    ['cc'] = function(race_name)
        return RaceSettingsHelper.pick_a_command_center(race_name)
    end,
    ['support'] = function(race_name)
        return RaceSettingsHelper.pick_a_support_building(race_name)
    end,
    ['turret'] = function(race_name)
        return RaceSettingsHelper.pick_a_turret(race_name)
    end
}

local expansion_switch = {
    [BUILDING_EXPAND_ON_CMD] = function(entity)
        BaseBuildProcessor.process_on_cmd(entity)
    end,
    [BUILDING_A_TOWN] = function(entity)
        BaseBuildProcessor.process_on_formation(entity)
    end,
    [BUILDING_EXPAND_ON_ARRIVAL] = function(entity)
        BaseBuildProcessor.process_on_arrival(entity)
    end
}

function BaseBuildProcessor.exec(entity)
    if entity and entity.valid and ForceHelper.is_erm_unit(entity) then
        local func = expansion_switch[GlobalConfig.build_style()]
        if func then
            func(entity)
        end
    end
end

function BaseBuildProcessor.process_on_cmd(entity)
    local nameToken = ForceHelper.get_name_token(entity.name)
    local race_name = ForceHelper.extract_race_name_from(entity.force.name)
    if GlobalConfig.race_is_active(race_name) and RaceSettingsHelper.is_command_center(race_name, nameToken[2]) then
        local unit_group = BaseBuildProcessor.determine_build_group(entity)
        if unit_group then
            BaseBuildProcessor.build_formation(unit_group, true)
        end
    end
end

function BaseBuildProcessor.process_on_formation(entity)
    local unit_group = BaseBuildProcessor.determine_build_group(entity)
    if unit_group then
        BaseBuildProcessor.build_formation(unit_group)
    end
end

function BaseBuildProcessor.process_on_arrival(entity)
    local unit_group = BaseBuildProcessor.determine_build_group(entity)
    if unit_group then
        for i, unit in pairs(unit_group.members) do
            if unit then
                BaseBuildProcessor.build_formation(unit_group)
            end
        end
    end
end

function BaseBuildProcessor.determine_build_group(entity)
    local near_by_units = entity.surface.find_entities_filtered {
        force = entity.force,
        position = entity.position,
        radius = 32,
        type = 'unit',
    }
    for _, unit in pairs(near_by_units) do
        if unit.unit_group and
                unit.unit_group.command and
                unit.unit_group.command.type == defines.command.build_base
        then
            return unit.unit_group
        end
    end
    return nil
end

function BaseBuildProcessor.build_formation(unit_group, has_cc)
    local force_name = unit_group.force.name
    local race_name = ForceHelper.extract_race_name_from(force_name)

    if race_name == nil then
        return
    end

    local members = unit_group.members
    local cc = 0
    local support = 0
    local turret = 0

    if has_cc then
        cc = 1
    end

    local formation = {}
    if GlobalConfig.build_formation() == 'random' then
        formation = { 1, math.random(3, 8), math.random(5, 12) }
    else
        formation = String.split(GlobalConfig.build_formation(), '-')
    end

    for _, unit in pairs(members) do
        local name = nil
        if cc < tonumber(formation[1]) then
            name = BaseBuildProcessor.getBuildingName(race_name, 'cc')
            cc = cc + 1
        elseif support < tonumber(formation[2]) then
            name = BaseBuildProcessor.getBuildingName(race_name, 'support')
            support = support + 1
        elseif turret < tonumber(formation[3]) then
            name = BaseBuildProcessor.getBuildingName(race_name, 'turret')
            turret = turret + 1
        else
            return
        end

        Cron.add_1_sec_queue(
                'BaseBuildProcessor.build',
                unit.surface,
                name,
                force_name,
                unit.position
        )
        unit.destroy()
    end
end

function BaseBuildProcessor.getBuildingName(race_name, type)
    local func = building_switch[type]

    return race_name .. '/' .. func(race_name) .. '/' .. RaceSettingsHelper.get_level(race_name)
end

function BaseBuildProcessor.build(surface, name, force_name, position, radius)
    radius = radius or 64
    if not surface.can_place_entity({ name = name, force = force_name, position = position }) then
        position = surface.find_non_colliding_position(name, position, radius, 11.33, true)
    end

    if position then
        local built_entity = surface.create_entity({ name = name, force = force_name, position = position, spawn_decorations = true })

        Event.dispatch({
            name = Event.get_event_name(GlobalConfig.BASE_BUILT_EVENT),
            entity = built_entity })
    end
end

return BaseBuildProcessor