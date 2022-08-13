---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 9:56 PM
---
local Event = require('__stdlib__/stdlib/event/event')
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local ErmReplacementProcessor = require('__enemyracemanager__/lib/replacement_processor')
local ErmBaseBuildProcessor = require('__enemyracemanager__/lib/base_build_processor')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmAttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')
local ErmAttackGroupChunkProcessor = require('__enemyracemanager__/lib/attack_group_chunk_processor')
local ErmConfig = require('__enemyracemanager__/lib/global_config')


local onBiterBaseBuilt = function(event)
    local entity = event.entity
    if entity and entity.valid then
        local replaced_entity = ErmReplacementProcessor.replace_entity(entity.surface, entity, global.race_settings, entity.force.name)
        if replaced_entity and replaced_entity.valid then
            ErmBaseBuildProcessor.exec(replaced_entity)
        end
    end
end


local onUnitFinishGathering = function(event)
    local group = event.group
    local max_settler = global.settings.enemy_expansion_max_settler

    if max_settler == nil then
        max_settler = math.min(ErmConfig.BUILD_GROUP_CAP, game.map_settings.enemy_expansion.settler_group_max_size)
        global.settings.enemy_expansion_max_settler = max_settler
    end

    if group.command and group.command.type == defines.command.build_base and table_size(group.members) > max_settler then
        local build_group = group.surface.create_unit_group {
            position = group.position,
            force= group.force
        }
        for i, unit in pairs(group.members) do
            if i <= max_settler then
                build_group.add_member(unit)
            end
        end
        build_group.set_command {
            type = defines.command.build_base,
            destination = group.command.destination
        }
        global.erm_unit_groups[build_group.group_number] = {
            group = build_group,
            start_position = group.position
        }
        build_group.start_moving()
        group.set_autonomous()
    end
end

local ermGroupCacheTableCleanup = function(target_table)
    local tmp = {}
    for _, group_data in pairs(target_table) do
        if group_data and group_data.valid
                and group_data.group and group_data.group.valid
        then
            local group = group_data.group
            if #group.members > 0 then
                tmp[group.group_number] = group_data
            end
        end
    end
    target_table = tmp

    return target_table
end

local onAiCompleted = function(event)
    if global.erm_unit_groups[event.unit_number] and global.erm_unit_groups[event.unit_number].group and global.erm_unit_groups[event.unit_number].group.valid then
        local group = global.erm_unit_groups[event.unit_number].group
        local start_position = global.erm_unit_groups[event.unit_number].start_position
        if group.valid and
                group.is_script_driven and
                group.command == nil and
                (start_position.x == group.position.x and start_position.y == group.position.y) and
                ErmForceHelper.is_enemy_force(group.force)
        then
            local members = group.members
            local refundPoints = 0
            for _, member in pairs(members) do
                member.destroy()
                refundPoints = refundPoints + ErmAttackGroupProcessor.MIXED_UNIT_POINTS
            end

            ErmRaceSettingsHelper.add_to_attack_meter(ErmForceHelper.extract_race_name_from(group.force.name), refundPoints)
            group.destroy()
        end

        if group.valid and (group.command == nil or
                group.state == defines.group_state.finished)then
            ErmAttackGroupProcessor.process_attack_position(group)
        end

        local group_count = table_size(global.erm_unit_groups)
        if group_count > ErmConfig.CONFIG_CACHE_SIZE then
            global.erm_unit_groups = ermGroupCacheTableCleanup(global.erm_unit_groups)
        end
    end
end

--- Unit processing events
Event.register(defines.events.on_biter_base_built, onBiterBaseBuilt)

Event.register(defines.events.on_unit_group_finished_gathering, onUnitFinishGathering)

Event.register(defines.events.on_ai_command_completed, onAiCompleted)