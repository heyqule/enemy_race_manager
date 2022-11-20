local noise = require("noise")
local Table = require('__stdlib__/stdlib/utils/table')
local String = require('__stdlib__/stdlib/utils/string')
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')
require('__enemyracemanager__/global')
require('__enemyracemanager__/setting-constants')

require('prototypes/compatibility/data-updates.lua')

require('prototypes/map-generation.lua')

require('prototypes/extend-defense.lua')

require("prototypes/extend-reinforced-items")

require('prototypes/extend-weapons.lua')

require('prototypes/extend-super-weapons.lua')

require "prototypes.extend-map-gen-setting"

require "prototypes/extend-boss-items"

require "prototypes/extend-inputs"

require "prototypes/extend-army-events"