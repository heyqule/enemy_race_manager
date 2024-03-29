---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 9:47 PM
---
local Event = require('__stdlib__/stdlib/event/event')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmRaceSettingHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmSurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local ErmAttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')

local process_attack_point_event = function(event, attack_point)
    local race_name = ErmSurfaceProcessor.get_enemy_on(game.surfaces[event.surface_index].name)
    if race_name then
        ErmRaceSettingHelper.add_to_attack_meter(race_name, attack_point)
    end
end

local process_counter_attack_event = function(event, radius)
    ErmAttackGroupProcessor.generate_nuked_group(game.surfaces[event.surface_index], event.target_position, radius)
end

local is_valid_attack_for_attack_point = function(event)
    return ErmConfig.super_weapon_attack_points_enable() and game.surfaces[event.surface_index].valid
end

local is_valid_attack_for_counter_attack = function(event)
    return ErmConfig.super_weapon_counter_attack_enable() and game.surfaces[event.surface_index].valid
end

local attack_functions = {
    [PLAYER_SUPER_WEAPON_ATTACK] = function(event)
        if is_valid_attack_for_attack_point(event) then
            process_attack_point_event(event, ErmConfig.super_weapon_attack_points())
        end
    end,
    [PLAYER_PLANET_PURIFIER_ATTACK] = function(event)
        if is_valid_attack_for_attack_point(event) then
            process_attack_point_event(event, ErmConfig.super_weapon_attack_points() * 10)
        end
    end,
    [PLAYER_SUPER_WEAPON_COUNTER_ATTACK] = function(event)
        if is_valid_attack_for_counter_attack(event) then
            process_counter_attack_event(event, 48)
        end
    end,
    [PLAYER_PLANET_PURIFIER_COUNTER_ATTACK] = function(event)
        if is_valid_attack_for_counter_attack(event) then
            process_counter_attack_event(event, 96)
        end
    end
}
Event.register(defines.events.on_script_trigger_effect, function(event)
    if attack_functions[event.effect_id]
    then
        attack_functions[event.effect_id](event)
    end
end)