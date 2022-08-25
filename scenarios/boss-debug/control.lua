require('util')
local scenarios_helper = require('__enemyracemanager__/scenarios/shared.lua')

local Event = require('__stdlib__/stdlib/event/event')

Event.register(defines.events.on_player_created, function(event)
    local surface = game.surfaces[1]
    local player = game.players[1]
    local force = player.force

    scenarios_helper.spawn_concrete(surface, 32)
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
    global.rocket_silo = surface.create_entity({
        name='rocket-silo',
        force='player',
        player=1,
        position={-10,-10}
    })
end)

Event.on_nth_tick(900, function(event)
    if(event.tick == 0) then
        return
    end

    local surface = game.surfaces[1]

    if global.rocket_silo == nil or not global.rocket_silo.valid then
        global.rocket_silo = surface.create_entity({
            name='rocket-silo',
            force='player',
            player=1,
            position={-10,-10}
        })
    end

    surface.create_entity({
        name='erm_terran/battlecruiser/yamato',
        force='player',
        position={-10,-10}
    })
    surface.create_entity({
        name='erm_terran/battlecruiser/laser',
        force='player',
        position={-10,-10}
    })
    surface.create_entity({
        name='erm_terran/tank/mk2',
        force='player',
        position={-20,-20}
    })
    for i=1, 3 do
        surface.create_entity({
            name='erm_terran/wraith',
            force='player',
            position={-10,-10}
        })
    end
    for i=1, 10 do
        surface.create_entity({
            name='erm_terran/marine/mk3',
            force='player',
            position={-20,-20}
        })
    end

    remote.call('enemy_race_manager_debug', 'spawn_boss', {x=100,y=100})
end)

