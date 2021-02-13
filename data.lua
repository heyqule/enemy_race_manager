require "prototypes.extend-types"

if settings.startup['enemyracemanager-enable-bitters'].value == true then
    require "prototypes.extend-bitters"
    require "prototypes.extend-spawners"
end

data:extend({
    { type = "recipe-category", name = 'erm_controlable_units' },
    {
        type = "item-subgroup",
        name = "erm_controlable_units",
        group = "combat",
        order = "z-erm_controlable_units"
    },
})