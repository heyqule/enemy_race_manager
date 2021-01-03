require "prototypes.extend-types"

if settings.startup['enemyracemanager-enable-bitters'].value == true then
    require "prototypes.extend-bitters"
    require "prototypes.extend-spawners"
end