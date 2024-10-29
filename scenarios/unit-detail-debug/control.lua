require("util")
local scenarios_helper = require("__enemyracemanager__/scenarios/shared.lua")

local String = require("__stdlib__/stdlib/utils/string")
local Event = require("__stdlib__/stdlib/event/event")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")

Event.on_init(function(event)
    game.map_settings.enemy_expansion.enabled = false
    local surface = game.surfaces[1]
    local mgs = surface.map_gen_settings
    mgs.autoplace_controls["enemy-base"].frequency = 0
    mgs.autoplace_controls["enemy-base"].size = 0
    mgs.autoplace_controls["enemy-base"].richness = 0
    game.surfaces[1].map_gen_settings = mgs
end)

Event.register(defines.events.on_player_created, function(event)
    local surface = game.surfaces[1]
    local player = game.players[1]
    local force = player.force

    scenarios_helper.set_tech_level(force, 20)
    scenarios_helper.set_enemy_params(20, 3, 1.0)
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

    local prototypes = game.get_filtered_entity_prototypes({
        { filter = "type", type = "unit-spawner", mode = "or" },
        { filter = "type", type = "turret", mode = "or" },
        { filter = "type", type = "unit", mode = "or" }
    })
    local i = 0
    local x = -200
    local y = -200
    local gap = 20
    --for _, item in pairs(prototypes) do
    --    x = -100 + i * gap
    --    local entity = surface.create_entity({
    --        name=item.name,
    --        force="neutral",
    --        position={x, y}
    --    })
    --    entity.active = false
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
        ["5"] = true,
        ["10"] = true,
        ["15"] = true,
        ["20"] = true,
        ["25"] = true,
    }

    for _, item in pairs(prototypes) do
        x = -100 + i * gap
        local nameToken = ForceHelper.get_name_token(item.name)
        if nameToken[3] == nil or acceptLevels[nameToken[3]] or string.find(nameToken[3], "%d") ~= 1 then
            local entity = surface.create_entity({
                name = item.name,
                force = "neutral",
                position = { x, y }
            })
            entity.active = false

            local y_offset = 0

            rendering.draw_text({
                text=entity.prototype.name,
                color = { r = 1, g = 1, b = 1, a = 1 },
                target={ x+2, y + y_offset},
                surface=entity.surface,
                scale=2
            })
            y_offset = y_offset + 2

            rendering.draw_text({
                text="Health: "..entity.prototype.max_health,
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

