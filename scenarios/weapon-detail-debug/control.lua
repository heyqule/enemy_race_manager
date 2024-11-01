require("util")
local scenarios_helper = require("__enemyracemanager__/scenarios/shared.lua")


local Event = require("__stdlib__/stdlib/event/event")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")

local gun_turrets = '0eNrFmdtymzAQht9F1yJjHfDpVTIZj4wXVzMgXEmkdTJ+9wrcJE0rd7RYpbmBgLz692f1obVfyb7p4WS18WT7SnTVGUe2j6/E6aNRzXDNqBbIlrh+77zyujPkQok2B/hOtuxCI0O1qbXR/lxUX8D5X4bzyxMlYLz2Gq7TjP+cd6Zv92BDPPoWo1bOF9o4sD7coOTUOT1OHqYZJpYPJSVnshUPZYh/0Baq6+31IOm3sPw97LE3he+tBR+LOUbkl0gEkSxshREm04StbwsrU4VxhhG2TBLG+W1hK3qjHG4/Szkqexu+c+C9Nkc3DLPQds+w68O9JqQHh5320IZbtWocUHK9fK2pn9P2Vhndt4XtenNwRauO6kUbCPNX4Uood7ZYUNJ2h2Gw8kUDalT3XtpPsbTW6Wmt/klaJw22Cp/PnNcmOa/3QsqbVx0KUtk2Vz5sQSPkijykMZV1NATDYIMFFpKvvWpCiKH6TNW17QjLPwNzzLLHBBaYZYsJLPGrmYmZlnMkhTtrp0S/hhhPoSpb4umR2ca/4CO/jyv0WzPRxzWeVpl9jOAqv38b9Ms9zT+OgiNbxcRxFB35Z9ZYZSHGGZ5IxhUqaCIVGSroBCLy+Yk4yr+vCjmehjytCifQkP8HGubwEE/CRA8nkJDPSMIc3uEpmOadQFGQRykoUBQU/BNb4KSrGFsEx7fBSV2dEBi8pqqV+N44TW2J4Xaq2iW+YU5TO6HhFXL2F8Loy30LUkzogYWcn9s5Up3QFgs5H14zpChRFBTRTlmiKCjFp5XawBHMQdlzbLlKVKuMiozaFaIiT9gaynJ2EnzkcGcB4feHUiZ9OTphf5jZxyTOZDMSv0lMNHLCJjGzkX+lWDYD8TvFNANLFCPlJvpF/QcjoQmTWV0VYMAez0FnEFmrCiJCxRiylEHkvq9rsDunX2A06O1v+FHlW0hgMPyRLWhJQ39fPtHH4UDF9Xw4UHk9Hw60HM7DJ4dHFzR9/AxEyXN4eKOEcsk3crMpJZOcM3a5/ABJSsP5'

Event.on_init(function(event)
    game.map_settings.enemy_expansion.enabled = false
    local surface = game.surfaces[1]
    local mgs = surface.map_gen_settings
    mgs.autoplace_controls["enemy-base"].frequency = 0
    mgs.autoplace_controls["enemy-base"].size = 0
    mgs.autoplace_controls["enemy-base"].richness = 0
    game.surfaces[1].map_gen_settings = mgs
end)

script.on_event(defines.events.on_player_created, function(event)
    local surface = game.surfaces[1]
    local player = game.players[1]
    local force = player.force
    local level = 15
    scenarios_helper.spawn_tile(surface, 320)

    scenarios_helper.set_tech_level(force, level)
    scenarios_helper.build_base(surface, gun_turrets, 0, 0)
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
    --local character = player.surface.create_entity { name = "character", position = player.surface.find_non_colliding_position("character", player.force.get_spawn_position(player.surface), 10, 2), force = force }
    --player.set_controller { type = defines.controllers.character, character = character }
    --player.teleport({ 0, 0 })
    local prototypes = prototypes.get_entity_filtered({
        { filter = "type", type = "ammo-turret", mode = "or" },
        { filter = "type", type = "fluid-turret", mode = "or" },
        { filter = "type", type = "electric-turret", mode = "or" }
    })

    local i = 0
    local x = -200
    local y = -200
    local gap = 20

    local qualities = {'normal','uncommon','rare','epic','legendary'}

    for _, item in pairs(prototypes) do

        for _, quality in pairs(qualities) do
            local y_offset = 0
            x = -100 + i * gap
            local entity = surface.create_entity({
                name = item.name,
                force = "player",
                position = { x, y },
                quality = quality
            })
            entity.active = false



            rendering.draw_text({
                text=entity.prototype.name,
                color = { r = 1, g = 1, b = 1, a = 1 },
                target={ x+2, y + y_offset},
                surface=entity.surface,
                scale=2
            })
            y_offset = y_offset + 2

            rendering.draw_text({
                text="Health: "..entity.prototype.get_max_health(quality),
                color = { r = 1, g = 0, b = 0, a = 1 },
                target={ x+2, y + y_offset},
                surface=entity.surface,
                scale=2
            })
            y_offset = y_offset + 2


            if entity.prototype.speed then
                rendering.draw_text({
                    text="Speed: "..entity.prototype.speed,
                    color = { r = 1, g = 1, b = 1, a = 1 },
                    target={ x+2, y+y_offset },
                    surface=entity.surface,
                    scale=2
                })
                y_offset = y_offset + 2
            end

            if entity.prototype.attack_parameters then
                rendering.draw_text({
                    text="Attack Cooldown: ".. (entity.prototype.attack_parameters.cooldown / 60) .. "s",
                    color = { r = 1, g = 1, b = 1, a = 1 },
                    target={ x+2, y+y_offset },
                    surface=entity.surface,
                    scale=2
                })
                y_offset = y_offset + 2
                rendering.draw_text({
                    text="Attack Warmup: ".. (entity.prototype.attack_parameters.warmup / 60) .."s",
                    color = { r = 1, g = 1, b = 1, a = 1 },
                    target={ x+2, y+y_offset },
                    surface=entity.surface,
                    scale=2
                })
                y_offset = y_offset + 2
            end

            i = i + 1
            if i % 21 == 0 then
                x = -100
                y = y + gap
                i = 0
            end
        end
    end
end)

