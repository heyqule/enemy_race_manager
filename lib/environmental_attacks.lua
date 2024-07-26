---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/1/2024 5:42 PM
---

local Config = require('__enemyracemanager__/lib/global_config')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local RaceSettingHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local AttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')
local BaseBuildProcessor = require('__enemyracemanager__/lib/base_build_processor')

local is_valid = function(surface, target_position, force_spawn)
    local valid = Config.environmental_attack_enable() and surface and surface.valid and target_position
    local can_spawn = RaceSettingHelper.can_spawn(Config.environmental_attack_raid_chance())

    if force_spawn ~= nil then
        can_spawn = force_spawn
    end

    if valid and can_spawn then
        return true
    end
    return false
end

local EnvironmentalAttacks = {}

function EnvironmentalAttacks.exec(surface, target_position,
                                   force_spawn, force_spawn_base)
    if is_valid(surface, target_position, force_spawn) and
       ForceHelper.can_have_enemy_on(surface)
    then
        local spawn_count = Config.environmental_attack_units_count()

        local group = AttackGroupProcessor.generate_immediate_group(surface, target_position, spawn_count)

        local can_spawn_home = RaceSettingHelper.can_spawn(Config.environmental_attack_raid_chance())

        if force_spawn_base ~= nil then
            can_spawn_home = force_spawn_base
        end

        if can_spawn_home then
            BaseBuildProcessor.build_formation(group)
        else
            AttackGroupProcessor.process_attack_position(group, defines.distraction.by_enemy, true)
            global.erm_unit_groups[group.group_number] = {
                group = group,
                start_position = group.position,
                always_angry = false,
                nearby_retry = 0,
                attack_force = nil,
                created = game.tick,
                is_aerial = false
            }
        end
    end
end

function EnvironmentalAttacks.reset_global()
    global.override_environmental_attack_spawn_home = nil
    global.override_environmental_attack_can_spawn = nil
end

return EnvironmentalAttacks