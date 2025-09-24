require "global"
require "prototypes.noise-functions"
require "prototypes.extend-types"
require "prototypes.extend-biters"
require "prototypes.extend-spawners"

require "prototypes.base-units.defender"
require "prototypes.base-units.destroyer"
require "prototypes.base-units.distractor"
require "prototypes.base-units.construction"
require "prototypes.base-units.logistic"

require "prototypes.base-spawner.roboport"

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
--- Offical planets --
data.raw['mod-data'][MOD_DATA_INTERPLANETARY_ATTACKS].data["aquilo"] = true
--- 3rd party planets with their defined uniqueness, not suitable for invasion.
data.raw['mod-data'][MOD_DATA_INTERPLANETARY_ATTACKS].data["maraxsis"] = true
data.raw['mod-data'][MOD_DATA_INTERPLANETARY_ATTACKS].data["maraxsis-trench"] = true
data.raw['mod-data'][MOD_DATA_INTERPLANETARY_ATTACKS].data['lignumis'] = true



require "prototypes.extend-mapping-beacons"
require "prototypes.extend-rallypoint"
require "prototypes.tips-and-tricks.prototypes"
require "prototypes.shortcuts"

--- The following require quality mod ---
require "prototypes.extend-quality"