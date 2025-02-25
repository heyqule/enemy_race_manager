require("util")
local scenarios_helper = require("__enemyracemanager__/scenarios/shared.lua")

local spawned

script.on_init(function(event)
    game.map_settings.enemy_expansion.enabled = false
    local surface = game.surfaces[1]
    local mgs = surface.map_gen_settings
    mgs.autoplace_controls["enemy-base"].frequency = 0
    mgs.autoplace_controls["enemy-base"].size = 0
    mgs.autoplace_controls["enemy-base"].richness = 0
    game.surfaces[1].map_gen_settings = mgs
    local entities = surface.find_entities_filtered({ type = "unit-spawner" })
    for _, entity in pairs(entities) do
        entity.destroy()
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    local surface = game.surfaces[1]
    local player = game.players[1]
    local force = player.force

    local current_tech = 20
    scenarios_helper.spawn_tile(surface, 32)
    scenarios_helper.set_tech_level(force, current_tech)
    scenarios_helper.set_enemy_params(20, 3, 1.0)
    --scenarios_helper.set_attack_points()
    scenarios_helper.set_game_speed(1)
    local tier = 5
    scenarios_helper.set_boss_tier(tier)

    for i = 0, ((tier - 1) * 5), 1 do
        force.technologies["follower-robot-count-7"].researched = true
    end

    --surface.daytime = 0.5
    surface.daytime = 1
    surface.freeze_daytime = true

    -- Comment out the following to start with godmode
    --if player.character then player.character.destroy() end
    --local character = player.surface.create_entity{name = "character", position = player.surface.find_non_colliding_position("character", player.force.get_spawn_position(player.surface), 10, 2), force = force}
    --player.set_controller{type = defines.controllers.character, character = character}
    --player.teleport({0, 0})
    storage.rocket_silo = surface.create_entity({
        name = "rocket-silo",
        force = "player",
        player = 1,
        position = { -10, -10 }
    })
    surface.create_entity({
        name = "gun-turret",
        force = "player",
        player = 1,
        position = { 5, 5 }
    })
end)

local spawn_units = function(surface)
    local entities = {}
    for i = 1, 2 do
        table.insert(entities, surface.create_entity({
            name = "erm_terran/battlecruiser/yamato",
            force = "player",
            position = { -15, -15 }
        }))
        table.insert(entities, surface.create_entity({
            name = "erm_terran/battlecruiser/laser",
            force = "player",
            position = { -10, -10 }
        }))
    end
    for i = 1, 4 do
        table.insert(entities, surface.create_entity({
            name = "erm_terran/siege_tank/mk2",
            force = "player",
            position = { 15, 15 }
        }))
    end
    for i = 1, 10 do
        table.insert(entities, surface.create_entity({
            name = "erm_terran/wraith",
            force = "player",
            position = { -20, -20 }
        }))

        table.insert(entities, surface.create_entity({
            name = "erm_terran/goliath",
            force = "player",
            position = { 20, 20 }
        }))
    end
    for i = 1, 20 do
        table.insert(entities, surface.create_entity({
            name = "erm_terran/marine/mk3",
            force = "player",
            position = { 10, 10 }
        }))

        table.insert(entities, surface.create_entity({
            name = "erm_terran/firebat/mk2",
            force = "player",
            position = { 10, -10 }
        }))
    end

    local command = {
        type = defines.command.attack_area,
        destination = { x = 100, y = 0 },
        radius = 20
    }
    for _, entity in pairs(entities) do
        if entity and entity.valid then
            entity.commandable.set_command(command)
        end
    end

    return entities
end

Event.on_nth_tick(900, function(event)
    if (event.tick == 0) then
        return
    end

    local surface = game.surfaces[1]

    if storage.rocket_silo == nil or not storage.rocket_silo.valid then
        storage.rocket_silo = surface.create_entity({
            name = "rocket-silo",
            force = "player",
            player = 1,
            position = { -10, -10 }
        })
    end

    spawn_units(surface)
    --spawn_units(surface)

    if not spawned then
        remote.call("enemyracemanager_debug", "spawn_boss", { x = 100, y = 0 })
        spawned = true
    end
end)

