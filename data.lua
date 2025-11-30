require "global"
require "prototypes.noise-functions"
require "prototypes.extend-types"
require "prototypes.extend-biters"
require "prototypes.extend-spawners"

if settings.startup["enemyracemanager-enable-biter-corrupt-robots"].value then
    require "prototypes.base-spawner.roboport"
end

require "prototypes.base-units.defender"
require "prototypes.base-units.destroyer"
require "prototypes.base-units.distractor"
require "prototypes.base-units.construction"
require "prototypes.base-units.logistic"

data.erm_registered_race = data.erm_registered_race or {}
data.erm_spawn_specs = data.erm_spawn_specs or {}
data.erm_land_scout = data.erm_land_scout or {}
data.erm_aerial_scout = data.erm_aerial_scout or {}

-- This set of data is used for set up default autoplace calculation.

data.erm_registered_race[MOD_NAME] = true
table.insert(data.erm_spawn_specs, {
    mod_name = MOD_NAME,
    force_name = FORCE_NAME,
    moisture = 2, -- 1 = Dry and 2 = Wet
    aux = 1, -- 1 = red desert, 2 = sand
    elevation = 1, --1,2,3 (1 low elevation, 2. medium, 3 high elavation)
    temperature = 2, --1,2,3 (1 cold, 2. normal, 3 hot)
})

data.erm_land_scout[MOD_NAME] = "small-biter"
data.erm_aerial_scout[MOD_NAME] = "defender"


if not data.raw['mod-data'] or not data.raw['mod-data'][MOD_DATA_SURFACE_EXCLUSIONS] then
    data.extend({
        {
            type = 'mod-data',
            name = MOD_DATA_SURFACE_EXCLUSIONS,
            data_type = 'erm_data',
            data = {}
        }
    })
end
data.raw['mod-data'][MOD_DATA_SURFACE_EXCLUSIONS].data['lignumis'] = true

if not data.raw['mod-data'] or not data.raw['mod-data'][MOD_DATA_NEUTRAL_FORCES] then
    data.extend({
        {
            type = 'mod-data',
            name = MOD_DATA_NEUTRAL_FORCES,
            data_type = 'erm_data',
            data = {}
        }
    })
end
data.raw['mod-data'][MOD_DATA_NEUTRAL_FORCES].data['maze-terraforming-targets'] = true


if not data.raw['mod-data'] or not data.raw['mod-data'][MOD_DATA_INTERPLANETARY_ATTACKS] then
    data.extend({
        {
            type = 'mod-data',
            name = MOD_DATA_INTERPLANETARY_ATTACKS,
            data_type = 'erm_data',
            data = {}
        }
    })
end

--- Use to define tile to use when enemy places its bridge tile
if not data.raw['mod-data'] or not data.raw['mod-data'][MOD_DATA_SURFACE_BRIDGE_TILES] then
    data.extend({
        {
            type = 'mod-data',
            name = MOD_DATA_SURFACE_BRIDGE_TILES,
            data_type = 'erm_data',
            data = {}
        }
    })
end

data.raw['mod-data'][MOD_DATA_SURFACE_BRIDGE_TILES].data['valcanus'] = 'volcanic-ash-soil'
data.raw['mod-data'][MOD_DATA_SURFACE_BRIDGE_TILES].data['fulgoran'] = 'fulgoran-sand'
data.raw['mod-data'][MOD_DATA_SURFACE_BRIDGE_TILES].data['gleba'] = 'lowland-deadskin-mold'
data.raw['mod-data'][MOD_DATA_SURFACE_BRIDGE_TILES].data['aquilo'] = 'ice-smooth'

--- Offical planets --
data.raw['mod-data'][MOD_DATA_INTERPLANETARY_ATTACKS].data["aquilo"] = true
--- 3rd party planets with their defined uniqueness, not suitable for invasion.
data.raw['mod-data'][MOD_DATA_INTERPLANETARY_ATTACKS].data["maraxsis"] = true
data.raw['mod-data'][MOD_DATA_INTERPLANETARY_ATTACKS].data["maraxsis-trench"] = true
data.raw['mod-data'][MOD_DATA_INTERPLANETARY_ATTACKS].data['lignumis'] = true


if settings.startup['enemyracemanager-enable-engineer-army'].value then
    -- Remove wood ingredient from shotgun for automation
    for _, entity_name in pairs({"shotgun", "combat-shotgun"}) do
        for index, ingredient in pairs(data.raw.recipe[entity_name].ingredients) do
            if ingredient.name == "wood" then
                data.raw.recipe[entity_name].ingredients[index] = nil
            end
        end
    end

    require "prototypes.army.army_depot"
    require "prototypes.army.corpse"
    require "prototypes.army.miner"
    require "prototypes.army.miner_elite"
    require "prototypes.army.shotgun"
    require "prototypes.army.shotgun_elite"
    require "prototypes.army.flamethrower"
    require "prototypes.army.car_red"
    require "prototypes.army.car_uranium"
    require "prototypes.army.car_rocket"
    require "prototypes.army.tank_cannon"
    require "prototypes.army.tank_uranium_cannon"
    require "prototypes.army.drone_laser"
    require "prototypes.army.drone_suicide"
end

require "prototypes.extend-mapping-beacons"
require "prototypes.extend-rallypoint"
require "prototypes.tips-and-tricks.prototypes"
require "prototypes.shortcuts"

--- The following require quality mod ---
require "prototypes.extend-quality"