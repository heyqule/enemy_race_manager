require('util')
local scenarios_helper = require('__enemyracemanager__/scenarios/shared.lua')

local Event = require('__stdlib__/stdlib/event/event')

local spawned

Event.on_init(function(event)
    game.map_settings.enemy_expansion.enabled = false
    local surface = game.surfaces[1]
    local mgs = surface.map_gen_settings
    mgs.autoplace_controls["enemy-base"].frequency = 0
    mgs.autoplace_controls["enemy-base"].size = 0
    mgs.autoplace_controls["enemy-base"].richness = 0
    game.surfaces[1].map_gen_settings = mgs
    local entities = surface.find_entities_filtered({type='unit-spawner'})
    for _, entity in pairs(entities) do
        entity.destroy()
    end
end)

Event.register(defines.events.on_player_created, function(event)
    local surface = game.surfaces[1]
    local player = game.players[1]
    local force = player.force

    scenarios_helper.spawn_tile(surface, 128)
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

Event.on_nth_tick(600, function(event)

    local surface = game.surfaces[1]
    local entities = surface.find_entities_filtered({type={'unit','electric-turret'}})
    for _, entity in pairs(entities) do
        entity.destroy()
    end

    surface.create_entity({
        name='erm-reinforced-laser-turret',
        --name='erm_terran/battlecruiser/yamato',
        force='player',
        player=1,
        position={-10,-10}
    })

    surface.create_entity({
        name='erm_zerg/defiler/20',
        force='enemy_erm_zerg',
        position={10,10}
    })
end)

