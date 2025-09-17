
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local DebugHelper = require("__enemyracemanager__/lib/debug_helper")

local modify_race_setting = function()
    if script.active_mods["Toxic_biters"] then
        local race_settings = remote.call("enemyracemanager", "get_race", MOD_NAME)

        DebugHelper.print("Toxic_biters is active")

        table.insert(race_settings.support_structures[1], "toxic-biter-spawner")

        table.insert(race_settings.turrets[1], "medium-toxic-worm-turret")
        table.insert(race_settings.turrets[2], "big-toxic-worm-turret")
        table.insert(race_settings.turrets[3], "behemoth-toxic-worm-turret")

        table.insert(race_settings.units[1], "medium-toxic-biter")
        table.insert(race_settings.units[2], "big-toxic-biter")
        table.insert(race_settings.units[3], "behemoth-toxic-biter")

        table.insert(race_settings.units[1], "medium-toxic-spitter")
        table.insert(race_settings.units[2], "big-toxic-spitter")
        table.insert(race_settings.units[3], "behemoth-toxic-spitter")
        
        table.insert(race_settings.featured_groups, { { "behemoth-toxic-biter", "behemoth-toxic-spitter", "big-toxic-biter", "big-toxic-spitter" }, { 2, 1, 3, 1 }, 50 })
        table.insert(race_settings.featured_groups, { { "behemoth-toxic-biter", "behemoth-toxic-spitter" }, { 5, 2 }, 100 })
        table.insert(race_settings.featured_groups, { { "behemoth-toxic-spitter", "behemoth-toxic-biter" }, { 3, 2 }, 100 })

        remote.call("enemyracemanager", "register_race", race_settings)
    end
end

---
--- Inject race settings into existing race
---
local ToxicBiters = {}

ToxicBiters.events = {
    [GlobalConfig.custom_event_handlers[GlobalConfig.RACE_SETTING_UPDATE]] = function(event)
        if (event.affected_race == MOD_NAME) then
            modify_race_setting()
        end
    end
}

return ToxicBiters

