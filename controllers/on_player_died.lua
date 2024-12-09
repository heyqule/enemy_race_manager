﻿---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/8/2024 3:33 PM
---

require("__enemyracemanager__/global")

local Position = require("__erm_libs__/stdlib/position")
local NukePlanetDialog = require("__enemyracemanager__/gui/nuke_planet_dialog")

local OnPlayerDied = {}

local threshold = 30 * second


local death_loop_detection = function(event)
    if storage.death_loop_detection[event.player_index] and
       event.tick < storage.death_loop_detection[event.player_index].tick 
    then
        --- off nuke planet
        NukePlanetDialog.show(game.players[event.player_index])
    end
    
    local surface = game.players[event.player_index].character.surface
    local force = game.players[event.player_index].character.force
    local character_position = game.players[event.player_index].character.position

    if surface.planet and Position.manhattan_distance(character_position, force.get_spawn_position(surface)) < 64 then
        storage.death_loop_detection[event.player_index] = {
            player_index = event.player_index,
            surface_index = surface.index,
            force_index = force.index,
            tick = event.tick + threshold
        }
    else
        storage.death_loop_detection[event.player_index] = nil
    end
end

OnPlayerDied.events = {
    [defines.events.on_player_died] = death_loop_detection
}

return OnPlayerDied