
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local DebugHelper = require("__enemyracemanager__/lib/debug_helper")

local modify_race_setting = function()
    if script.active_mods["Explosive_biters"] then
        local race_settings = remote.call("enemyracemanager", "get_race", MOD_NAME)
        DebugHelper.print("Explosive_biters is active")

        table.insert(race_settings.support_structures[1], "explosive-biter-spawner")

        table.insert(race_settings.turrets[1], "medium-explosive-worm-turret")
        table.insert(race_settings.turrets[2], "big-explosive-worm-turret")
        table.insert(race_settings.turrets[3], "behemoth-explosive-worm-turret")

        table.insert(race_settings.units[1], "medium-explosive-biter")
        table.insert(race_settings.units[2], "big-explosive-biter")
        table.insert(race_settings.units[3], "behemoth-explosive-biter")

        table.insert(race_settings.units[1], "medium-explosive-spitter")
        table.insert(race_settings.units[2], "big-explosive-spitter")
        table.insert(race_settings.units[3], "behemoth-explosive-spitter")

        table.insert(race_settings.featured_groups, { { "behemoth-explosive-biter", "behemoth-explosive-spitter", "big-explosive-biter", "big-explosive-spitter" }, { 2, 1, 3, 1 }, 50 })
        table.insert(race_settings.featured_groups, { { "behemoth-explosive-biter", "behemoth-explosive-spitter" }, { 5, 2 }, 100 })
        table.insert(race_settings.featured_groups, { { "behemoth-explosive-spitter", "behemoth-explosive-biter" }, { 3, 2 }, 100 })

        remote.call("enemyracemanager", "register_race", race_settings)
    end
end

---
--- Inject race settings into existing race
---
local ExplosiveBiters = {}

ExplosiveBiters.events = {
    [GlobalConfig.custom_event_handlers[GlobalConfig.EVENT_RACE_SETTING_UPDATE]] = function(event)
        if (event.affected_race == MOD_NAME) then
            modify_race_setting()
        end
    end
}

return ExplosiveBiters

