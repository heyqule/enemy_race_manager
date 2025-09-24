require('util')
local scenarios_helper = require('__enemyracemanager__/scenarios/shared.lua')


script.on_event(defines.events.on_player_created, function(event)
    local surface = game.surfaces[1]
    local player = game.players[1]
    local force = player.force

    scenarios_helper.spawn_lab_tiles(surface, 256)
    scenarios_helper.set_tech_level(force, 20)
    scenarios_helper.set_enemy_params(20, 3, 1.0)
    --scenarios_helper.set_attack_points()
    scenarios_helper.set_game_speed(1)

    --surface.daytime = 0.5
    surface.daytime = 1
    surface.freeze_daytime = true

    -- Comment out the following to start with godmode
    --if player.character then player.character.destroy() end
    --local character = player.surface.create_entity{name = "character", position = player.surface.find_non_colliding_position("character", player.force.get_spawn_position(player.surface), 10, 2), force = force}
    --player.set_controller{type = defines.controllers.character, character = character}
    --player.teleport({0, 0})
end)

local global_assets_explosion = function(surface)
    surface.create_entity({
        name = "erm-fire-explosion-air_normal-1",
        position = {0, 20}
    })

    surface.create_entity({
        name = "erm-fire-explosion-air_large-1",
        position = {20, 20}
    })

    surface.create_entity({
        name = "erm-fire-explosion-ground_normal-1",
        position = {40, 20}
    })
end

local zerg_explosions = function(surface)
    if not script.active_mods['erm_zerg'] then
        return
    end

    local MOD_NAME = 'enemy_erm_zerg'
    local explosion_types = {
        MOD_NAME..'--lurker-explosion',
        MOD_NAME..'--colony-explosion',
        MOD_NAME..'--mutalisk-explosion-small',
        MOD_NAME..'--hydralisk-explosion-small',
        MOD_NAME..'--blood-cloud-explosion',
        MOD_NAME..'--dark-swarm-80-explosion',
        MOD_NAME..'--dark-swarm-explosion',
        MOD_NAME..'--acid-cloud-explosion',
        MOD_NAME..'--devourer-cloud-explosion',
        MOD_NAME..'--scourge-explosion',
        'overlord-air-death',
        'guardian-air-death',
        MOD_NAME..'--dark-swarm-80-blood-explosion',
    }

    for key, value in pairs(explosion_types) do
        surface.create_entity({
            name = value,
            position = {-100 + (key * 15), 40}
        })
    end
end

local protoss_explosions = function(surface)
    if not script.active_mods['erm_toss'] then
        return
    end
    local MOD_NAME = 'protoss'
    local explosion_types = {
        MOD_NAME..'--dragoon-explosion',
        MOD_NAME..'--corsair-explosion',
        MOD_NAME..'--stasis-explosion',
        MOD_NAME..'--psystorm-explosion',
        MOD_NAME..'--disrupt-80',
        MOD_NAME..'--disrupt',
        MOD_NAME..'--recall-80',
        MOD_NAME..'--recall',
        MOD_NAME..'--archon-hit-explosion',
        MOD_NAME..'--small-air-death',
        MOD_NAME..'--large-air-death',
        MOD_NAME..'--zealot-death',
        MOD_NAME..'--templar-death',
        MOD_NAME..'--darkarchon-feedback',
        MOD_NAME..'--scarab-explosion',
        MOD_NAME..'--shield-battery-explosion',
        MOD_NAME..'--demo-darkarchon-maelstrom',
        MOD_NAME..'--large-building-explosion',
        MOD_NAME..'--small-building-explosion',
        MOD_NAME..'--darkarchon-explosion',
    }

    for key, value in pairs(explosion_types) do
        surface.create_entity({
            name = value,
            position = {-100 + (key * 15), 60}
        })
    end
end


script.on_nth_tick(180, function(event)
    local surface = game.surfaces[1]

    global_assets_explosion(surface)
    zerg_explosions(surface)
    protoss_explosions(surface)
end)

