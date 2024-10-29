---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/15/2024 9:59 PM
---
require("util")

data:extend({
    {
        type = "item",
        name = "erm_rally_point",
        icon = "__core__/graphics/spawn-flag.png",
        icon_size = 64,
        subgroup = "erm_controllable_units",
        order = "erm_rally_point",
        place_result = "erm_rally_point",
        stack_size = 1,
        flags = {"only-in-cursor","spawnable","not-stackable","hide-from-bonus-gui","hide-from-fuel-tooltip"},
        hidden = true
    },
    {
        type = "simple-entity-with-owner",
        name = "erm_rally_point",
        subgroup = "erm_rally_point",
        icon = "__core__/graphics/spawn-flag.png",
        icon_size = 64,
        max_health = 100,
        collision_box = nil,
        collision_mask = {layers={}},
        flags = {"not-on-map","not-repairable","not-deconstructable","not-blueprintable","not-selectable-in-game"},
        hidden = true,
        picture = {
            filename = "__core__/graphics/spawn-flag.png",
            width = 64,
            height = 64,
            draw_as_glow = true,
        },
        map_color = nil,
        created_effect = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    type = "script",
                    effect_id = ARMY_RALLYPOINT_DEPLOY
                }
            }
        },
        selectable_in_game = false,
        selection_box = nil,
    }
})

if DEBUG_MODE then
    --- Make it placable in campaign for testing purposes
    data.raw["simple-entity-with-owner"]["erm_rally_point"]["selectable_in_game"] = true
    data.raw["simple-entity-with-owner"]["erm_rally_point"]["selection_box"] = {{ -1,-1 }, {1,1}}
end