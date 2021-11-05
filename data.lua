local Sprites = require('__stdlib__/stdlib/data/modules/sprites')

require "prototypes.extend-collision"

require "prototypes.extend-types"
require "prototypes.extend-bitters"
require "prototypes.extend-spawners"

data:extend({
            {
                type = "ammo-category",
                name = "erm-biter-damage"
            },
            --- Mod wide slow stickers
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
            }
})

if settings.startup['enemyracemanager-enable-bitters'].value == true then
    require "prototypes.base-units.defender"
    require "prototypes.base-units.destroyer"
    require "prototypes.base-units.distractor"
    require "prototypes.base-units.construction"
    require "prototypes.base-units.logistic"

    require "prototypes.base-spawner.roboport"
end