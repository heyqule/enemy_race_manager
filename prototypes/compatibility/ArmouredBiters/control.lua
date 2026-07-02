local ERM = require("__enemyracemanager__/global")
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local DebugHelper = require("__enemyracemanager__/lib/debug_helper")

local modify_race_setting = function()
    if script.active_mods["ArmouredBiters"] then
        local race_settings = remote.call("enemyracemanager", "get_race", ERM.MOD_NAME)

        DebugHelper.print("ArmouredBiters is active")
        if settings.startup["ab-enable-nest"].value then
            table.insert(race_settings.support_structures[1], "armoured-biter-spawner")
        end

        -- Refer to the following for full race_settings data structures.
        -- https://github.com/heyqule/enemy_race_manager/blob/main/controllers/initializer.lua#L52
        table.insert(race_settings.units[1], "medium-armoured-biter")
        table.insert(race_settings.units[2], "big-armoured-biter")
        table.insert(race_settings.units[3], "behemoth-armoured-biter")

        table.insert(race_settings.featured_groups, { { "behemoth-armoured-biter", "behemoth-biter", "big-armoured-biter", "big-biter" }, { 1, 2, 2, 3 }, 0.8 })
        table.insert(race_settings.featured_groups, { { "behemoth-armoured-biter", "behemoth-biter" }, { 3, 2 }, 0.6 })
        table.insert(race_settings.featured_groups, { { "behemoth-armoured-biter", "behemoth-spitter" }, { 4, 1 }, 0.5 })

        remote.call("enemyracemanager", "register_race", race_settings)
    end
end

---
--- Inject race settings into existing race
---
local ArmouredBiters = {}

ArmouredBiters.events = {
    [GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_RACE_SETTING_UPDATE]] = function(event)
        if (event.affected_race == ERM.MOD_NAME) then
            modify_race_setting()
        end
    end
}

return ArmouredBiters

