require "prototypes.extend-types"
require "prototypes.extend-bitters"
require "prototypes.extend-spawners"

data:extend({
    { type = "recipe-category", name = 'erm_controlable_units' },
    {
        type = "item-subgroup",
        name = "erm_controlable_units",
        group = "combat",
        order = "z-erm_controlable_units"
    },
})