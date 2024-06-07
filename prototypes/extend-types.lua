local Sprites = require('__stdlib__/stdlib/data/modules/sprites')
--- Damage Types
data:extend(
        {
            --- This shares name with Space Explorations.
            {
                type = "damage-type",
                name = "cold",
            },
            {
                type = "damage-type",
                name = "healing",
            },
            --- ERM nukes will use this damage type and explosive
            --- This shares name with K2 radioactive resistance.
            --- All ERMs units will have 75% max resist, starting at 5%)
            {
                type = "damage-type",
                name = "radioactive"
            }
        })
--- Target Trigger Type
data:extend(
        {
            {
                type = "trigger-target-type",
                name = "air-unit"
            },
        })
--- Item Subgroup
data:extend(
        {
            {
                type = "item-subgroup",
                name = "erm-flying-enemies",
                group = "enemies",
                order = "erm-flying-enemies"
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
                name = "erm_controllable_units",
                group = "combat",
                order = "z-erm_controllable_units"
            },
            {
                type = "item-subgroup",
                name = "erm_controllable_buildings",
                group = "combat",
                order = "z-erm_controllable_buildings"
            },
            {
                type = "item-subgroup",
                name = "erm_ai_beacons",
                group = "combat",
                order = "z-erm_attack_beacons"
            }
        })
-- Recipe Category
data:extend({
    { type = "recipe-category", name = 'erm_controllable_infantry' },
    { type = "recipe-category", name = 'erm_controllable_factory' },
    { type = "recipe-category", name = 'erm_controllable_starport' },
    { type = "recipe-category", name = 'erm_controllable_buildings' },
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
        flags = { "not-on-map" },
        animation = Sprites.empty_pictures(),
        duration_in_ticks = 5 * 60,
        target_movement_modifier = 0.75,
        vehicle_speed_modifier = 0.75,
    },
    {
        type = "sticker",
        name = "5-050-slowdown-sticker",
        flags = { "not-on-map" },
        animation = Sprites.empty_pictures(),
        duration_in_ticks = 5 * 60,
        target_movement_modifier = 0.50,
        vehicle_speed_modifier = 0.50,
    },
    {
        type = "sticker",
        name = "5-025-slowdown-sticker",
        flags = { "not-on-map" },
        animation = Sprites.empty_pictures(),
        duration_in_ticks = 5 * 60,
        target_movement_modifier = 0.25,
        vehicle_speed_modifier = 0.25,
    },
    {
        type = "sticker",
        name = "30-050-slowdown-sticker",
        flags = { "not-on-map" },
        animation = Sprites.empty_pictures(),
        duration_in_ticks = 30 * 60,
        target_movement_modifier = 0.50,
        vehicle_speed_modifier = 0.50,
    },
    {
        type = "sticker",
        name = "10-025-slowdown-sticker",
        flags = { "not-on-map" },
        animation = Sprites.empty_pictures(),
        duration_in_ticks = 10 * 60,
        target_movement_modifier = 0.25,
        vehicle_speed_modifier = 0.25,
    }
})

