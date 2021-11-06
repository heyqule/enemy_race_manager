require "prototypes.extend-collision"

require "prototypes.extend-types"
require "prototypes.extend-bitters"
require "prototypes.extend-spawners"


if settings.startup['enemyracemanager-enable-bitters'].value == true then
    require "prototypes.base-units.defender"
    require "prototypes.base-units.destroyer"
    require "prototypes.base-units.distractor"
    require "prototypes.base-units.construction"
    require "prototypes.base-units.logistic"

    require "prototypes.base-spawner.roboport"
end