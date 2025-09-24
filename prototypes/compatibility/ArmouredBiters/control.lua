
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local DebugHelper = require("__enemyracemanager__/lib/debug_helper")

local modify_race_setting = function()
    if script.active_mods["ArmouredBiters"] then
        local race_settings = remote.call("enemyracemanager", "get_race", MOD_NAME)

        DebugHelper.print("ArmouredBiters is active")
        if settings.startup["ab-enable-nest"].value then
            table.insert(race_settings.support_structures[1], "armoured-biter-spawner")
        end

        -- Refer to the following for full race_settings data structures.
        -- https://github.com/heyqule/enemy_race_manager/blob/main/controllers/initializer.lua#L52
        table.insert(race_settings.units[1], "medium-armoured-biter")
        table.insert(race_settings.units[2], "big-armoured-biter")
        table.insert(race_settings.units[3], "behemoth-armoured-biter")

        table.insert(race_settings.featured_groups, { { "behemoth-armoured-biter", "behemoth-biter", "big-armoured-biter", "big-biter" }, { 1, 2, 2, 3 }, 50 })
        table.insert(race_settings.featured_groups, { { "behemoth-armoured-biter", "behemoth-biter" }, { 3, 3 }, 100 })
        table.insert(race_settings.featured_groups, { { "behemoth-armoured-biter", "behemoth-biter" }, { 4, 1 }, 120 })

        remote.call("enemyracemanager", "register_race", race_settings)
    end
end

---
--- Inject race settings into existing race
---
local ArmouredBiters = {}

ArmouredBiters.events = {
    [GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_RACE_SETTING_UPDATE]] = function(event)
        if (event.affected_race == MOD_NAME) then
            modify_race_setting()
        end
    end
}

return ArmouredBiters

