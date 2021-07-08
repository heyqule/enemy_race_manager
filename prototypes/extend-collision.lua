---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/3/2021 12:16 PM
---

if mods['space-exploration'] or mods['alien-biomes'] then
    -- Handle space exploration / alien-biomes collision layer
    local collision_mask_util_extended = require("__alien-biomes__/collision-mask-util-extended/data/collision-mask-util-extended")
    collision_mask_util_extended.get_make_named_collision_mask('flying-layer')
elseif mods['combat-mechanics-overhaul'] then
    local collision_mask_util_extended = require("__combat-mechanics-overhaul__/collision-mask-util-extended/data/collision-mask-util-extended")
    collision_mask_util_extended.get_make_named_collision_mask('flying-layer')
else
    -- Handle vanilla collision layer
    local collision_mask_util = require("__core__/lualib/collision-mask-util")
    local flying_layer = collision_mask_util.get_first_unused_layer()
    data:extend({
        {
            type = "arrow",
            name = "collision-mask-flying-layer",
            collision_mask = {flying_layer},
            flags = {"placeable-off-grid", "not-on-map"},
            circle_picture = { filename = "__core__/graphics/empty.png", priority = "low", width = 1, height = 1},
            arrow_picture = { filename = "__core__/graphics/empty.png", priority = "low", width = 1, height = 1}
        }
    })
end
