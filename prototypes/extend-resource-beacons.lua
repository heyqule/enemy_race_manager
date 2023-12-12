---
--- Generated Resources Beacons for scouting units
--- Created by heyqule.
--- DateTime: 12/10/2023 3:16 PM
---
require('util')

data:extend({
    {
        type = "simple-entity-with-owner",
        name = "erm_spawn_beacon",
        subgroup = "erm_ai_beacons",
        icon = "__base__/graphics/icons/signal/signal_S.png",
        icon_size = 64,
        collision_box = nil,
        selection_box = nil,
        collision_mask = nil,
        flags = {'not-on-map'},
        picture = {
            filename = "__base__/graphics/icons/signal/signal_S.png",
            width = 64,
            height = 64,
        },
        map_color = nil
    },
    {
        type = "simple-entity-with-owner",
        name = "erm_aerial_beacon",
        subgroup = "erm_ai_beacons",
        icon = "__base__/graphics/icons/signal/signal_A.png",
        icon_size = 64,
        collision_box = nil,
        selection_box = nil,
        collision_mask = nil,
        flags = {'not-on-map'},
        picture = {
            filename = "__base__/graphics/icons/signal/signal_A.png",
            width = 64,
            height = 64,
        },
        map_color = nil
    },
    {
        type = "simple-entity-with-owner",
        name = "erm_land_beacon",
        subgroup = "erm_ai_beacons",
        icon = "__base__/graphics/icons/signal/signal_L.png",
        icon_size = 64,
        collision_box = nil,
        selection_box = nil,
        collision_mask = nil,
        flags = {'not-on-map'},
        picture = {
            filename = "__base__/graphics/icons/signal/signal_L.png",
            width = 64,
            height = 64,
        },
        map_color = nil
    },
    {
        type = "simple-entity-with-owner",
        name = "erm_attackable_entity_beacon",
        subgroup = "erm_ai_beacons",
        icon = "__base__/graphics/icons/signal/signal_E.png",
        icon_size = 64,
        collision_box = nil,
        selection_box = nil,
        collision_mask = nil,
        flags = {'not-on-map'},
        picture = {
            filename = "__base__/graphics/icons/signal/signal_E.png",
            width = 64,
            height = 64,
        },
        map_color = nil
    }
})


if DEBUG_MODE then
    --- Make it placable in campaign for testing purposes
    for _, data in pairs(data.raw['resource']) do
        if (data['subgroup'] == 'erm_ai_beacons') then
            data['render_layer'] = 'air-object'
            data['flags'] = { 'placeable-neutral', 'not-on-map' }
        end
    end
else
    --- Replace picture with empty spite to hide it from view.
    for _, data in pairs(data.raw['resource']) do
        data['selectable_in_game'] = false
        data['pictures'] = util.empty_sprite()
    end
end