require("__enemyracemanager__/global")
require("__enemyracemanager__/setting-constants")
local debugHelper = require("__enemyracemanager__/lib/debug_helper")
if DEBUG_MODE then
    debugHelper.print("----- data.erm_registered_race -----")
    debugHelper.print(serpent.block(data.erm_registered_race))
    debugHelper.print("----- data.erm_spawn_specs -----")
    debugHelper.print(serpent.block(data.erm_spawn_specs))
end

require("prototypes/extend-ground-fire-patches.lua")

require("prototypes/extend-defense.lua")

require("prototypes/extend-weapons.lua")

require("prototypes/extend-super-weapons.lua")

require("prototypes/extend-styles.lua")

require "prototypes/extend-map-gen-setting"

require "prototypes/extend-boss-items"

require "prototypes/extend-inputs"

require "prototypes/extend-army-events"

require "prototypes/extend-freeforall"

require("prototypes/compatibility/data-updates")

require("prototypes/extend-scout-units")

require("prototypes/extend-creep-removal")

require('prototypes/quality-system-triggers')

require( 'prototypes/extend-trigger-mask')

require("prototypes/extend-resistances")

require("prototypes/extend-default-autoplace")

require("prototypes/map-generation.lua")

if TEST_MODE then
    require("prototypes/test-prototypes")
end