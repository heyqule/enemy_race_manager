local Sprites = require('__stdlib__/stdlib/data/modules/sprites')
--- Damage Types
data:extend(
        {
            {
                type = "damage-type",
                name = "cold",
            },
            {
                type = "damage-type",
                name = "healing",
            },
            {
                type = "damage-type",
                name = "self"
            }
        })
--- Target Trigger Type
data:extend(
        {
            {
                type = "trigger-target-type",
                name = "flying"
            }
        })
--- Item Subgroup
data:extend(
        {
            {
                type = "item-subgroup",
                name = "erm-flying-enemies",
                group = "enemies",
                order = "erm-erm-flying-enemies"
            },
            {
                type = "item-subgroup",
                name = "erm-dropship-enemies",
                group = "enemies",
                order = "erm-dropship-enemies"
            },
            {
                type = "item-subgroup",
                name = "erm-builder-enemies",
                group = "enemies",
                order = "erm-builder-enemies"
            },
            {
                type = "item-subgroup",
                name = "erm_controlable_units",
                group = "combat",
                order = "z-erm_controlable_units"
            },
            {
                type = "item-subgroup",
                name = "erm_controlable_buildings",
                group = "combat",
                order = "z-erm_controlable_buildings"
            },
        })
-- Recipe Category
data:extend({
    { type = "recipe-category", name = 'erm_controlable_units' },
    { type = "recipe-category", name = 'erm_controlable_buildings' },
})

--- Ammo Category
data:extend({
    {
        type = "ammo-category",
        name = "erm-biter-damage"
    },
})

--- Mod wide slow stickers
data:extend({
    {
        type = "sticker",
        name = "5-075-slowdown-sticker",
        flags = {},
        animation = Sprites.empty_pictures(),
        duration_in_ticks = 5 * 60,
        target_movement_modifier = 0.75,
        vehicle_speed_modifier = 0.75,
    },
    {
        type = "sticker",
        name = "5-050-slowdown-sticker",
        flags = {},
        animation = Sprites.empty_pictures(),
        duration_in_ticks = 5 * 60,
        target_movement_modifier = 0.50,
        vehicle_speed_modifier = 0.50,
    },
    {
        type = "sticker",
        name = "30-050-slowdown-sticker",
        flags = {},
        animation = Sprites.empty_pictures(),
        duration_in_ticks = 30 * 60,
        target_movement_modifier = 0.50,
        vehicle_speed_modifier = 0.50,
    },
    {
        type = "sticker",
        name = "30-075-slowdown-sticker",
        flags = {},
        animation = Sprites.empty_pictures(),
        duration_in_ticks = 30 * 60,
        target_movement_modifier = 0.50,
        vehicle_speed_modifier = 0.50,
    }
})

