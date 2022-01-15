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

local CHUNK_SIZE = 32

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

local CustomAttackHelper = {}

function CustomAttackHelper.valid(event, race_name)
    return event.source_entity and
            String.find(event.source_entity.name, race_name, 1, true) ~= nil
end

function CustomAttackHelper.get_unit(unit_names, race_name)
    if global.custom_attack_current_tiers == nil then
        global.custom_attack_current_tiers = {}
        global.custom_attack_current_tiers_tick =  0
    end

    local current_tiers = global.custom_attack_current_tiers
    if current_tiers[race_name] == nil and
        ErmConfig.is_cache_expired(global.custom_attack_current_tiers_tick, ErmConfig.CONFIG_CACHE_LENGTH)
    then
        current_tiers[race_name] = remote.call('enemy_race_manager', 'get_race_tier', race_name)
        global.custom_attack_current_tiers = current_tiers
        global.custom_attack_current_tiers_tick = game.tick
    end
    return unit_names[current_tiers[race_name]][Math.random(#unit_names[current_tiers[race_name]])]
end

function CustomAttackHelper.drop_unit(event, race_name, unit_name)
    local surface = game.surfaces[event.surface_index]
    local nameToken = get_name_token(event.source_entity.name)
    local level = nameToken[3]
    local position = event.source_position
    position.x = position.x + 2

    local final_unit_name = race_name .. '/' .. unit_name .. '/' .. level

    if not surface.can_place_entity({ name = final_unit_name, position = position }) then
        position = surface.find_non_colliding_position(final_unit_name, event.source_position, 10, 8, true)
    end

    if position then
        local entity = surface.create_entity({ name = final_unit_name, position = position, force = event.source_entity.force })
        if entity.type == 'unit' then
            entity.set_command({
                type = defines.command.attack_area,
                destination = {x = position.x, y = position.y},
                radius = CHUNK_SIZE
            })
        end
    end
end


return CustomAttackHelper