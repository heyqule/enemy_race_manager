require("util")
local scenarios_helper = require("__enemyracemanager__/scenarios/shared.lua")


local turrets = "0eNqtldtuozAQht/F16bimEJepYqQAwO1akzkQ7tplHffMSSQFCdCu+UG4cPnmX9+xieyFxYOiktDtifCq15qsn07Ec1byYQbk6wDsiUGtGCBsUqBIWdKuKzhD9lGZ+pZrBgXrZXL5fF5RwlIww2H8aDh41hK2+1BIY9eGXsrPgIuNSiDE5Qceo27eumOQVKQvGSUHHHH60uGB9RcQTXO5y6mH9x44t7E5YGOyM3Zg0gmhGAY1UNIegnLx0gnBpcNlzgVHPgBlpAouk/vurzUYAyXrb5Ru1K2hqDnwmFAVXgma2HQ0kCHIwxDxe8YiV1fuy3MBAKYxtJ4gsymIBuBb/Ou+q8n+UbhRTQM1EPbTDTVVx9gHnM215QfkF7pA38tUPGdOTyofFmH6h20eeaz/HEhFHT9J5QW5wS6FeqSo/I41TChgZJxeDT85VyrmOS2C1RvZa2DjrXsm0vnhApHjJM1XJbr5r/b+fIqVuc1q138al5jkf8zDWepdW1gTiNf0waiaLVAk4fi6HcFuniXdV1/K9M/qBSvVWnOJVyl0tzqtN1rw4alS+qITLyxpesQ4TPG3Ijubh9Psxwp3rYdzQ0IBGateBWABNUeUTBUq2GVp//G+YBMoh9qUZS6aUCVmn/D4O7r4262L1zpiv2GCmYUNch2OOos4Wo03bSUfKIpBmC2iYu0KLI0DdMkwwT+AmvHhLs="

script.on_init(function(event)
    game.map_settings.enemy_expansion.enabled = false
    local surface = game.surfaces[1]
    local mgs = surface.map_gen_settings
    if mgs.autoplace_controls["enemy-base"] then
        mgs.autoplace_controls["enemy-base"].frequency = 0
        mgs.autoplace_controls["enemy-base"].size = 0
        mgs.autoplace_controls["enemy-base"].richness = 0
    end
    game.surfaces[1].map_gen_settings = mgs
end)

script.on_event(defines.events.on_player_created, function(event)
    local surface = game.surfaces[1]
    local player = game.players[1]
    local force = player.force
    local level = 20
    scenarios_helper.spawn_tile(surface, 320)

    scenarios_helper.set_tech_level(force, level)
    scenarios_helper.build_base(surface, turrets, 0, 0)
    --scenarios_helper.set_attack_points()
    scenarios_helper.set_game_speed(1)

    surface.daytime = 0.5
    surface.daytime = 1
    surface.freeze_daytime = true

    player.cheat_mode = true

    -- Comment out the following to start with godmode
    --if player.character then
    --    player.character.destroy()
    --end
    local character = player.surface.create_entity { name = "character", position = player.surface.find_non_colliding_position("character", player.force.get_spawn_position(player.surface), 10, 2), force = force }
    player.set_controller { type = defines.controllers.character, character = character }
    player.teleport({ 0, 0 })
end)

script.on_event(defines.events.on_tick, function(event)
    if event.tick % 9999900 == 0 then
        local surface = game.surfaces[1]
        --local invis_darktemplar = surface.create_entity({name="enemy_erm_toss--invis_darktemplar--5", force="enemy_erm_toss", position={-10,-10}})
        local lings = surface.create_entity({name="enemy_erm_toss--nexus--1", force="enemy_erm_toss", position={-20,-20}})
    end
end)

