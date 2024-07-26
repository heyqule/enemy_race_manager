---
--- Generated Resources Beacons for scouting units
--- Created by heyqule.
--- DateTime: 12/10/2023 3:16 PM
---
require('util')

local BEACON_HEALTH_LIMIT = 200

data:extend({
    --- Spawn beacon marks an area with enemies' unit-spawners
    {
        type = "simple-entity-with-owner",
        name = "erm_spawn_beacon",
        subgroup = "erm_ai_beacons",
        icon = "__base__/graphics/icons/signal/signal_S.png",
        icon_size = 64,
        max_health = BEACON_HEALTH_LIMIT,
        collision_box = nil,
        collision_mask = {},
        flags = {"not-on-map","not-repairable","not-deconstructable","not-blueprintable"},
        picture = {
            filename = "__base__/graphics/icons/signal/signal_S.png",
            width = 64,
            height = 64,
            draw_as_glow = true,
        },
        map_color = nil,
    },
    --- Aerial beacon marks player's defense location via air
    {
        type = "simple-entity-with-owner",
        name = "erm_aerial_beacon",
        subgroup = "erm_ai_beacons",
        icon = "__base__/graphics/icons/signal/signal_A.png",
        icon_size = 64,
        max_health = BEACON_HEALTH_LIMIT,
        collision_box = nil,
        collision_mask = {},
        flags = {"not-on-map","not-repairable","not-deconstructable","not-blueprintable"},
        picture = {
            filename = "__base__/graphics/icons/signal/signal_A.png",
            width = 64,
            height = 64,
            draw_as_glow = true,
        },
        map_color = nil,
    },
    --- Land beacon marks player's defense location via land
    {
        type = "simple-entity-with-owner",
        name = "erm_land_beacon",
        subgroup = "erm_ai_beacons",
        icon = "__base__/graphics/icons/signal/signal_L.png",
        icon_size = 64,
        max_health = BEACON_HEALTH_LIMIT,
        collision_box = nil,
        collision_mask = {},
        flags = {"not-on-map","not-repairable","not-deconstructable","not-blueprintable"},
        picture = {
            filename = "__base__/graphics/icons/signal/signal_L.png",
            width = 64,
            height = 64,
            draw_as_glow = true,
        },
        map_color = nil,
    },
    --- Attackable entities beacon are an area that has entities with matching attack entity types
    {
        type = "simple-entity-with-owner",
        name = "erm_attackable_entity_beacon",
        subgroup = "erm_ai_beacons",
        icon = "__base__/graphics/icons/signal/signal_E.png",
        icon_size = 64,
        max_health = BEACON_HEALTH_LIMIT,
        collision_box = nil,
        collision_mask = {},
        flags = {"not-on-map","not-repairable","not-deconstructable","not-blueprintable"},
        picture = {
            filename = "__base__/graphics/icons/signal/signal_E.png",
            width = 64,
            height = 64,
            draw_as_glow = true,
        },
        map_color = nil,
    },
    --- Resource beacons are used to track resource locations, so that scout will attempt to scout those areas.
    {
        type = "simple-entity-with-owner",
        name = "erm_resource_beacon",
        subgroup = "erm_ai_beacons",
        icon = "__base__/graphics/icons/signal/signal_R.png",
        icon_size = 64,
        max_health = BEACON_HEALTH_LIMIT,
        collision_box = nil,
        collision_mask = {},
        flags = {"not-on-map","not-repairable","not-deconstructable","not-blueprintable"},
        picture = {
            filename = "__base__/graphics/icons/signal/signal_R.png",
            width = 64,
            height = 64,
            draw_as_glow = true,
        },
        map_color = nil,
    }
})


if DEBUG_MODE then
    --- Make it placable in campaign for testing purposes
    for _, data in pairs(data.raw['simple-entity-with-owner']) do
        if (data['subgroup'] == 'erm_ai_beacons') then
            data['render_layer'] = 'air-object'
            if BEACON_SELECTABLE then
                data['selection_box'] = { { -1, -1 }, { 1, 1 } }
            end
            data.flags = {"not-repairable","not-deconstructable","not-blueprintable"}
            data.map_color = {b=0,g=1,r=0,a=1}
            data.order = 'aaaaa'
        end
    end
else
    --- Replace picture with empty spite to hide it from view.
    for _, data in pairs(data.raw['simple-entity-with-owner']) do
        if (data['subgroup'] == 'erm_ai_beacons') then
            data['selectable_in_game'] = false
            data['pictures'] = util.empty_sprite()
            data['selection_box'] = nil
        end
    end
end