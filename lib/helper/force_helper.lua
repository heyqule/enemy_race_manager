---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/25/2020 10:43 AM
---
--- require("__enemyracemanager__/lib/helper/force_helper")
---

local String = require("__stdlib__/stdlib/utils/string")

local ForceHelper = {
    default_mod_name = "erm_vanilla"
}

local NEUTRAL_FORCES = {
    "maze-terraforming-targets",
}

function ForceHelper.init_globals()
    storage.force_entity_name_cache = storage.force_entity_name_cache or {}
    storage.force_race_name_cache = storage.force_race_name_cache or {}
    storage.enemy_force_cache = storage.enemy_force_cache or {}
    storage.surface_exclusion_list = storage.surface_exclusion_list or {}
    storage.surface_inclusion_list = storage.surface_inclusion_list or {}
    storage.enemy_force_check = storage.enemy_force_check or {}
end

---
--- Cache force name that is one of the ERM races.
---
function ForceHelper.extract_race_name_from(force_name)
    if force_name == "enemy" then
        return ForceHelper.default_mod_name
    end

    if storage.force_race_name_cache[force_name] then
        return storage.force_race_name_cache[force_name]
    end

    if string.find(force_name, "enemy_") ~= nil then
        if storage.force_race_name_cache[force_name] == nil then
            local unverified_race_name = String.gsub(force_name, "enemy_", "")
            if storage.race_settings[unverified_race_name] then
                storage.force_race_name_cache[force_name] = unverified_race_name
                return storage.force_race_name_cache[force_name]
            end
        end
    end

    storage.force_race_name_cache[force_name] = nil
    return storage.force_race_name_cache[force_name]
end

function ForceHelper.get_force_name_from(race_name)
    if race_name == ForceHelper.default_mod_name then
        return "enemy"
    end
    return "enemy_" .. race_name
end

-- Checks enemy_erm_ prefix
function ForceHelper.is_erm_unit(entity)
    local nameToken = ForceHelper.split_name(entity.name)
    return (storage and storage.active_races and storage.active_races[nameToken[1]]) or false
end

function ForceHelper.is_enemy_force(force)
    return storage.enemy_force_check[force.name]
end

function ForceHelper.set_friends(game, force_name, is_friend)
    for name, force in pairs(game.forces) do
        if String.find(force.name, "enemy", 1, true) then
            force.set_friend(force_name, is_friend);
            force.set_friend("enemy", is_friend);
            force.set_cease_fire(force_name, is_friend);
            force.set_cease_fire("enemy", is_friend);
            game.forces[force_name].set_friend(name, is_friend)
            game.forces[force_name].set_cease_fire(name, is_friend)
        end
    end
end

function ForceHelper.set_neutral_force(game, force_name)
    for _, force in pairs(NEUTRAL_FORCES) do
        if game.forces[force] ~= nil then
            game.forces[force].set_cease_fire(force_name, true);
            game.forces[force_name].set_cease_fire(force, true);
        end
    end
end

function ForceHelper.split_name(name)
    return String.split(name, "--")
end

function ForceHelper.get_name_token(name)
    if storage.force_entity_name_cache and storage.force_entity_name_cache[name] then
        return storage.force_entity_name_cache[name]
    end

    if storage.force_entity_name_cache == nil then
        storage.force_entity_name_cache = {}
    end

    if storage.force_entity_name_cache[name] == nil then
        if String.find(name, "--", 1, true) then
            storage.force_entity_name_cache[name] = ForceHelper.split_name(name)
        else
            storage.force_entity_name_cache[name] = { ForceHelper.default_mod_name, name, "1" }
        end
    end

    return storage.force_entity_name_cache[name]
end

function ForceHelper.get_non_player_forces()
    return storage.non_player_forces or { "neutral" }
end

function ForceHelper.get_player_forces()
    return storage.player_forces or { "player" }
end

function ForceHelper.get_enemy_forces()
    return storage.enemy_force_cache or { "enemy" }
end

function ForceHelper.refresh_all_enemy_forces()
    storage.enemy_force_cache = {}
    storage.non_player_forces = {}
    storage.player_forces = {}
    storage.enemy_force_check = {}
    for _, force in pairs(game.forces) do
        if force.name == "enemy" or (String.find(force.name, "enemy", 1, true) and script.active_mods[ForceHelper.extract_race_name_from(force.name)] ~= nil) then
            table.insert(storage.enemy_force_cache, force.name)
            storage.enemy_force_check[force.name] = true
            table.insert(storage.non_player_forces, force.name)
        end
    end

    for _, value in pairs(NEUTRAL_FORCES) do
        table.insert(storage.non_player_forces, value)
    end
    table.insert(storage.non_player_forces, "neutral")

    table.insert(storage.player_forces, "player")
    for _, force in pairs(game.forces) do
        if force.index ~= 1 and table_size(force.players) > 0 then
            table.insert(storage.player_forces, force.name)
        end

        if TEST_MODE and string.find(force.name, "test") then
            table.insert(storage.player_forces, force.name)
        end
    end
    storage.total_player_forces = #storage.player_forces

    if settings.startup["enemyracemanager-enable-bitters"].value == false then
        storage.enemy_force_check["enemy"] = nil
    end
end

-- Whether a surface can assign enemy
-- Based off Rampant 3.0"s surface exclusion
function ForceHelper.can_have_enemy_on(surface)
    if surface.valid then
        local surface_name = surface.name
        if storage.surface_inclusion_list[surface_name] == nil and
            (storage.surface_exclusion_list[surface_name] == true or

            string.find(surface_name, "Factory floor") or
            string.find(surface_name, " Orbit") or
            string.find(surface_name, "clonespace") or
            string.find(surface_name, "BPL_TheLabplayer") or
            string.find(surface_name, "starmap%-") or
            string.find(surface_name, "NiceFill") or
            string.find(surface_name, "Asteroid Belt") or
            string.find(surface_name, "Vault ") or
            string.find(surface_name, "spaceship") or
            string.find(surface_name, "bpsb%-lab%-") or

            (surface_name == "aai-signals") or
            (surface_name == "RTStasisRealm") or
            (surface_name == "minime_dummy_dungeon") or
            (surface_name == "minime-preview-character") or
            (surface_name == "pipelayer") or
            (surface_name == "beltlayer")
        )
        then
            storage.surface_exclusion_list[surface_name] = true
            storage.enemy_surfaces[surface_name] = nil
            storage.surface_inclusion_list[surface_name] = nil
            return false
        end

        storage.surface_inclusion_list[surface_name] = true
        storage.surface_exclusion_list[surface_name] = nil
        return true
    end

    return false
end

function ForceHelper.add_surface_to_exclusion_list(surface_name)
    storage.surface_exclusion_list[surface_name] = true
    storage.surface_inclusion_list[surface_name] = nil
    storage.enemy_surfaces[surface_name] = nil
end


function ForceHelper.reset_surface_lists()
    storage.surface_exclusion_list = {}
    storage.surface_inclusion_list = {}
end

return ForceHelper