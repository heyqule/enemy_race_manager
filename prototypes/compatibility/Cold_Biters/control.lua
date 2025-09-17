
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local DebugHelper = require("__enemyracemanager__/lib/debug_helper")

local modify_race_setting = function()
    if script.active_mods["Cold_biters"] then
        local race_settings = remote.call("enemyracemanager", "get_race", MOD_NAME)

        DebugHelper.print("Cold_biters is active")

        table.insert(race_settings.support_structures[1], "cb-cold-spawner")

        table.insert(race_settings.turrets[1], "medium-cold-worm-turret")
        table.insert(race_settings.turrets[2], "big-cold-worm-turret")
        table.insert(race_settings.turrets[3], "behemoth-cold-worm-turret")

        table.insert(race_settings.units[1], "medium-cold-biter")
        table.insert(race_settings.units[2], "big-cold-biter")
        table.insert(race_settings.units[3], "behemoth-cold-biter")

        table.insert(race_settings.units[1], "medium-cold-spitter")
        table.insert(race_settings.units[2], "big-cold-spitter")
        table.insert(race_settings.units[3], "behemoth-cold-spitter")

        table.insert(race_settings.featured_groups, { { "behemoth-cold-biter", "behemoth-cold-spitter", "big-cold-biter", "big-cold-spitter" }, { 2, 1, 3, 2 }, 50 })
        table.insert(race_settings.featured_groups, { { "behemoth-cold-spitter", "behemoth-cold-biter" }, { 2, 4 }, 100 })

        remote.call("enemyracemanager", "register_race", race_settings)
    end
end

---
--- Inject race settings into existing race
---
local ColdBiters = {}
ColdBiters.events = {
    [GlobalConfig.custom_event_handlers[GlobalConfig.RACE_SETTING_UPDATE]] = function(event)
        if (event.affected_race == MOD_NAME) then
            modify_race_setting()
        end
    end
}

return ColdBiters

