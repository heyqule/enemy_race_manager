-- Damage Types
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
-- Target Trigger Type
data:extend(
        {
            {
                type = "trigger-target-type",
                name = "flying"
            }
        })
-- Item Subgroup
data:extend(
        {
            {
                type = "item-subgroup",
                name = "flying-enemies",
                group = "enemies",
                order = "erm-flying-enemies"
            },
            {
                type = "item-subgroup",
                name = "dropship-enemies",
                group = "enemies",
                order = "erm-dropship-enemies"
            },
            {
                type = "item-subgroup",
                name = "erm_controlable_units",
                group = "combat",
                order = "z-erm_controlable_units"
            },
        })
-- Recipe Category
data:extend({
    { type = "recipe-category", name = 'erm_controlable_units' },

})
