--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/17/2020
-- Time: 11:29 AM
-- To change this template use File | Settings | File Templates.
--
require "util"
require "global"

require "testcase"

--- Store script.generate_event_name() IDs
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
if script then
    GlobalConfig.custom_event_handlers = {
        [GlobalConfig.EVENT_FLUSH_GLOBAL] = script.generate_event_name(),
        [GlobalConfig.EVENT_ADJUST_ATTACK_METER] = script.generate_event_name(),
        [GlobalConfig.EVENT_ADJUST_ACCUMULATED_ATTACK_METER] = script.generate_event_name(),
        [GlobalConfig.EVENT_BASE_BUILT] = script.generate_event_name(),
        [GlobalConfig.EVENT_INTERPLANETARY_ATTACK_SCAN] = script.generate_event_name(),
        [GlobalConfig.EVENT_REQUEST_PATH] = script.generate_event_name(),
        [GlobalConfig.EVENT_REQUEST_BASE_BUILD] = script.generate_event_name(),
        [GlobalConfig.EVENT_INTERPLANETARY_ATTACK_EXEC] = script.generate_event_name(),
        [GlobalConfig.RACE_SETTING_UPDATE] = script.generate_event_name(),
        [GlobalConfig.PREPARE_WORLD] = script.generate_event_name(),
    }
end

handler = require("event_handler")
handler.add_lib(require("__enemyracemanager__/lib/quality_processor"))
handler.add_lib(require("__enemyracemanager__/lib/emotion_processor"))

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
handler.add_lib(require("__enemyracemanager__/controllers/on_player_died"))

--- On Rocket Launch Events
handler.add_lib(require("__enemyracemanager__/controllers/on_rocket_launch"))

--- Script Trigger for all functions
handler.add_lib(require("__enemyracemanager__/controllers/on_script_trigger_effects"))

handler.add_lib(require("__enemyracemanager__/controllers/on_trigger_created_entity"))

handler.add_lib(require("__enemyracemanager__/controllers/indestructible_entities"))

--- compatibility
handler.add_lib(require("__enemyracemanager__/controllers/compatibility/mining_drone"))

require("prototypes/compatibility/controls")

handler.add_lib(require("__enemyracemanager__/controllers/initializer"))

local RemoteApi = require("__enemyracemanager__/lib/remote_api")
remote.add_interface("enemyracemanager", RemoteApi)

local DebugRemoteApi = require("__enemyracemanager__/lib/debug_remote_api")
remote.add_interface("enemyracemanager_debug", DebugRemoteApi)

if SAMPLE_TILE_MODE then
    handler.add_lib(require("__enemyracemanager__/controllers/debug_events"))
end