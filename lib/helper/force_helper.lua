---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/25/2020 10:43 AM
---
--- require('__enemyracemanager__/lib/helper/force_helper')
---

local String = require('__stdlib__/stdlib/utils/string')
local Table = require('__stdlib__/stdlib/utils/table')

local ForceHelper = {}

function ForceHelper.init_globals()
    global.force_entity_name_cache = global.force_entity_name_cache or {}
    global.force_race_name_cache = global.force_race_name_cache or {}
    global.enemy_force_cache = global.enemy_force_cache or {}
end

-- Remove prefix enemy_ if force isn't enemy
function ForceHelper.extract_race_name_from(force_name)
    if string.find(force_name, 'enemy_') ~= nil then
        if global.force_race_name_cache[force_name] == nil then
            global.force_race_name_cache[force_name] = String.gsub(force_name, 'enemy_', '')
        end

        return global.force_race_name_cache[force_name]
    else
        return MOD_NAME
    end
end

function ForceHelper.get_force_name_from(race_name)
    if race_name == MOD_NAME then
        return 'enemy'
    end
    return 'enemy_'..race_name
end

-- Checks enemy_erm_ prefix
function ForceHelper.is_erm_unit(entity)
    return String.find(entity.name, 'erm_', 1, true) ~= nil
end

function ForceHelper.is_enemy_force(force)
    return String.find(force.name, 'enemy', 1, true)
end

function ForceHelper.set_friends(game, force_name, is_friend)
    for name, force in pairs(game.forces) do
        if String.find(force.name, 'enemy', 1, true) then
            force.set_friend(force_name, is_friend);
            force.set_friend('enemy', is_friend);
            force.set_cease_fire(force_name, is_friend);
            force.set_cease_fire('enemy', is_friend);
        end
    end
end

function ForceHelper.split_name(name)
    return String.split(name, '/')
end

function ForceHelper.get_name_token(name)
    if global.force_entity_name_cache[name] == nil then
        if not String.find(name, '/', 1, true) then
            global.force_entity_name_cache[name] = { MOD_NAME, name, '1' }
        else
            global.force_entity_name_cache[name] = ForceHelper.split_name(name)
        end
    end

    return global.force_entity_name_cache[name]
end


function ForceHelper.get_all_enemy_forces()
    return global.enemy_force_cache
end

function ForceHelper.refresh_all_enemy_forces()
    global.enemy_force_cache = {}
    for _, force in pairs(game.forces) do
        if force.name == 'enemy' or (String.find(force.name, 'enemy', 1, true) and game.active_mods[ForceHelper.extract_race_name_from(force.name)] ~= nil) then
            Table.insert(global.enemy_force_cache, force.name)
        end
    end
end

-- Whether a surface can assign enemy
function ForceHelper.can_assign(surface_name)
    if string.find(surface_name, "Factory floor") or
            string.find(surface_name, " Orbit") or
            string.find(surface_name, "clonespace") or
            string.find(surface_name, "BPL_TheLabplayer") or
            string.find(surface_name, "starmap-") or
            (surface_name == "aai-signals") or
            string.find(surface_name, "NiceFill") or
            string.find(surface_name, "Asteroid Belt") or
            string.find(surface_name, "Vault ")
    then
        return false
    end

    return true
end

return ForceHelper