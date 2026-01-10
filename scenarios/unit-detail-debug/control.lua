require("util")
local scenarios_helper = require("__enemyracemanager__/scenarios/shared.lua")


local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")

script.on_init(function(event)
    game.map_settings.enemy_expansion.enabled = false
    local surface = game.surfaces[1]
    local mgs = surface.map_gen_settings
    mgs.autoplace_controls["enemy-base"] = nil
    game.surfaces[1].map_gen_settings = mgs
end)

script.on_event(defines.events.on_player_created, function(event)
    local surface = game.surfaces[1]
    local player = game.players[1]
    local force = player.force

    scenarios_helper.set_tech_level(force, 20)
    --scenarios_helper.set_enemy_params(20, 3, 1.0)
    --scenarios_helper.set_attack_points()
    scenarios_helper.set_game_speed(1)

    --surface.daytime = 0.5
    surface.daytime = 1
    surface.freeze_daytime = true

    -- Comment out the following to start with godmode
    if player.character then
        player.character.destroy()
    end
    --local character = player.surface.create_entity{name = "character", position = player.surface.find_non_colliding_position("character", player.force.get_spawn_position(player.surface), 10, 2), force = force}
    --player.set_controller{type = defines.controllers.character, character = character}
    --player.teleport({0, 0})

    local prototypes = prototypes.get_entity_filtered({
        { filter = "type", type = "unit-spawner", mode = "or" },
        { filter = "type", type = "turret", mode = "or" },
        { filter = "type", type = "unit", mode = "or" }
    })
    scenarios_helper.spawn_tile(surface,300)
    local i = 0
    local x = -250
    local y = -250
    local gap = 20
    --for _, item in pairs(prototypes) do
    --    x = -100 + i * gap
    --    local entity = surface.create_entity({
    --        name=item.name,
    --        force="neutral",
    --        position={x, y}
    --    })
    --    entity.disabled_by_script = true
    --    i = i + 1
    --    if i % 20 == 0 then
    --        x = -100
    --        y = y + gap
    --        i = 0
    --    end
    --end

    local acceptLevels = {
        ["1"] = true,
        ["2"] = true,
        ["3"] = true,
        ["4"] = true,
        ["5"] = true
    }



    for _, item in pairs(prototypes) do
        x = -250 + i * gap
        local nameToken = ForceHelper.get_name_token(item.name)
        local entities = surface.find_entities({{x-10,y-10},{x+10,y+10}})
        for _, en in pairs(entities) do
            en.destroy()
        end
   
        local force_name = "enemy"
        if nameToken and (nameToken[1] == "erm_terran" or nameToken[2] == 'controllable') then
            force_name = "player"
        end

        remote.call('enemyracemanager','skip_roll_quality')
        local entity = surface.create_entity({
            name = item.name,
            force = force_name,
            position = { x, y }
        })
        if entity then
            entity.disabled_by_script = true

            local y_offset = 0

            rendering.draw_text({
                text=entity.prototype.localised_name,
                color = { r = 1, g = 1, b = 1, a = 1 },
                target={ x+2, y + y_offset},
                surface=entity.surface,
                scale=2
            })
            y_offset = y_offset + 2

            rendering.draw_text({
                text="Health: "..entity.prototype.get_max_health(),
                color = { r = 1, g = 0, b = 0, a = 1 },
                target={ x+2, y + y_offset},
                surface=entity.surface,
                scale=2
            })
            y_offset = y_offset + 2


            if entity.prototype.speed then
                rendering.draw_text({
                    text="Speed: ".. string.format('%.2f',entity.prototype.speed * 60 * 3600 / 1000)..'km/h',
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
        end
        
        i = i + 1
        if i % 21 == 0 then
            x = -100
            y = y + gap
            i = 0
        end
    end

end)

