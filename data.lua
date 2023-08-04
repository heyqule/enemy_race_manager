require "prototypes.extend-collision"
require "prototypes.extend-types"

require "prototypes.extend-bitters"
require "prototypes.extend-spawners"

require "prototypes.base-units.defender"
require "prototypes.base-units.destroyer"
require "prototypes.base-units.distractor"
require "prototypes.base-units.construction"
require "prototypes.base-units.logistic"

require "prototypes.base-spawner.roboport"

if settings.startup['enemyracemanager-enable-bitters'].value then
    -- This set of data is used for set up default autoplace calculation.
    data.erm_enemy_races = data.erm_enemy_races or {}
    table.insert(data.erm_enemy_races, {
        name=MOD_NAME,
        force=FORCE_NAME,
        moisture=2, -- 1 = Wet and 2 = Dry
        aux=2, -- 1 = red desert, 2 = sand
        elevation=1, --1,2,3 (1 low elevation, 2. medium, 3 high elavation)
        temperature=2, --1,2,3 (1 cold, 2. normal, 3 hot)
    })
end