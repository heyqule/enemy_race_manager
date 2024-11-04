---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 4/11/2024 1:23 PM
---
-- Shortcut for menu

data:extend({
    {
        type = "shortcut",
        name = "erm-detail-window-toggle",
        icon = "__core__/graphics/force-editor-icon.png",
        icon_size = 64,
        small_icon = "__core__/graphics/force-editor-icon.png",
        small_icon_size = 64,
        action = "lua",
        order = "erm-detail-window-toggle",
    },
})

if mods["erm_terran"] then
    data:extend({
        {
            type = "shortcut",
            name = "erm-army-window-toggle",
            small_icon = "__erm_terran_hd_assets__/graphics/entity/icons/buildings/command_centre256.png",
            small_icon_size = 256,
            icon = "__erm_terran_hd_assets__/graphics/entity/icons/buildings/command_centre256.png",
            icon_size = 256,
            action = "lua",
            order = "erm-army-window-toggle",
        }
    } )
else
    data:extend({
        {
            type = "shortcut",
            name = "erm-army-window-toggle",
            icon = "__base__/graphics/icons/submachine-gun.png",
            icon_size = 64,
            small_icon = "__base__/graphics/icons/submachine-gun.png",
            small_icon_size = 64,
            action = "lua",
            order = "erm-army-window-toggle",
        }
    } )
end