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

local RemoteApi = require("__enemyracemanager__/lib/remote_api")
remote.add_interface("enemyracemanager", RemoteApi)

local DebugRemoteApi = require("__enemyracemanager__/lib/debug_remote_api")
remote.add_interface("enemyracemanager_debug", DebugRemoteApi)

handler = require("event_handler")
handler.add_lib(require("__enemyracemanager__/controllers/initializer"))
handler.add_lib(require("__enemyracemanager__/lib/quality_processor"))
handler.add_lib(require("__enemyracemanager__/controllers/cron"))
handler.add_lib(require("__enemyracemanager__/controllers/unit_control"))

handler.add_lib(require("__enemyracemanager__/controllers/army_population"))

handler.add_lib(require("__enemyracemanager__/controllers/army_teleportation"))

handler.add_lib(require("__enemyracemanager__/controllers/army_deployment"))

--- GUIs
handler.add_lib(require("__enemyracemanager__/gui/events"))

handler.add_lib(require("__enemyracemanager__/controllers/custom-input"))

--- Race Data Events
handler.add_lib(require("__enemyracemanager__/controllers/race_management"))

--- Map Processing Events
handler.add_lib(require("__enemyracemanager__/controllers/map_management"))

--- Attack points & group events
handler.add_lib(require("__enemyracemanager__/controllers/attack_group_management"))

handler.add_lib(require("__enemyracemanager__/controllers/attack_group_beacon"))


--- On Rocket Launch Events
handler.add_lib(require("__enemyracemanager__/controllers/on_rocket_launch"))

--- Script Trigger for all functions
handler.add_lib(require("__enemyracemanager__/controllers/on_script_trigger_effects"))

handler.add_lib(require("__enemyracemanager__/controllers/on_trigger_created_entity"))


handler.add_lib(require("__enemyracemanager__/controllers/debug_events"))

require("prototypes/compatibility/controls")