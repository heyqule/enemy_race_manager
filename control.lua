--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/17/2020
-- Time: 11:29 AM
-- To change this template use File | Settings | File Templates.
--
require("util")
require("global")

require("testcase")

require("prototypes/compatibility/controls")

local RemoteApi = require("__enemyracemanager__/lib/remote_api")
remote.add_interface("enemyracemanager", RemoteApi)

local DebugRemoteApi = require("__enemyracemanager__/lib/debug_remote_api")
remote.add_interface("enemyracemanager_debug", DebugRemoteApi)

handler = require("event_handler")
handler.add_lib(require("__enemyracemanager__/lib/quality_processor"))

--- CRON Events
require("__enemyracemanager__/controllers/cron")



require("__enemyracemanager__/controllers/initializer")

require("__enemyracemanager__/controllers/unit_control")

require("__enemyracemanager__/controllers/army_population")

require("__enemyracemanager__/controllers/army_teleportation")

require("__enemyracemanager__/controllers/army_deployment")

--- GUIs
require("__enemyracemanager__/controllers/gui")

require("__enemyracemanager__/controllers/custom-input")

--- Race Data Events
require("__enemyracemanager__/controllers/race_management")

--- Map Processing Events
require("__enemyracemanager__/controllers/map_management")

--- Attack points & group events
require("__enemyracemanager__/controllers/attack_group_management")

require("__enemyracemanager__/controllers/attack_group_beacon")


--- Script Trigger for all functions
require("__enemyracemanager__/controllers/on_script_trigger_effects")


--- On Rocket Launch Events
require("__enemyracemanager__/controllers/on_rocket_launch")



--require("__enemyracemanager__/controllers/debug_events")

-- Commands
--require("__enemyracemanager__/controllers/commands")

-- Compatibility
--require("__enemyracemanager__/controllers/compatibility/k2")
--
--require("__enemyracemanager__/controllers/compatibility/mining_drone")
--
--require("__enemyracemanager__/controllers/compatibility/space_exploration")