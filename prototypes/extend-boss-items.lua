---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/12/2022 6:15 PM
---
local Table = require('__stdlib__/stdlib/utils/table')

--- Add PSI Emitter Satellite, spawn boss and return 2000 space science pack
data:extend({{
    type = "item",
    name = "psi-emitter-satellite",
    icons = {
        {
            icon = "__base__/graphics/icons/satellite.png",
            icon_size = 64,
        },
        {
            icon = "__base__/graphics/icons/signal/signal_P.png",
            icon_size = 64,
            scale = 0.25,
            shift = {-9,-9}
        },
    },
    subgroup = "space-related",
    order = "m[psi-emitter-satellite]",
    stack_size = 1,
    rocket_launch_product = {"space-science-pack", 2000}
},
{
    type = "recipe",
    name = "psi-emitter-satellite",
    energy_required = 5,
    enabled = false,
    category = "crafting",
    ingredients =
    {
        {"satellite", 1},
        {"raw-fish", 50},
        {"wood", 100},
        {"processing-unit", 50},
    },
    result= "psi-emitter-satellite",
    requester_paste_multiplier = 1
}})

Table.insert(data.raw['technology']['space-science-pack']['effects'],
        {
            type = "unlock-recipe",
            recipe = "psi-emitter-satellite",
        }
)