local Event = require('__stdlib__/stdlib/event/event')
local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local modify_race_setting = function()
    if script.active_mods['ArmouredBiters'] then
        local race_settings = remote.call('enemyracemanager', 'get_race', MOD_NAME)

        ErmDebugHelper.print('ArmouredBiters is active')
        if settings.startup["ab-enable-nest"].value then
            table.insert(race_settings.support_structures[1], 'armoured-biter-spawner')
        end

        -- Refer to the following for full race_settings data structures.
        -- https://github.com/heyqule/enemy_race_manager/blob/main/controllers/initializer.lua#L52
        table.insert(race_settings.units[1], 'medium-armoured-biter')
        table.insert(race_settings.units[2], 'big-armoured-biter')
        table.insert(race_settings.units[3], 'behemoth-armoured-biter')

        table.insert(race_settings.featured_groups, { { 'behemoth-armoured-biter', 'behemoth-biter' }, { 5, 2 }, 50 })
        table.insert(race_settings.featured_groups, { { 'behemoth-biter', 'behemoth-armoured-biter' }, { 5, 2 }, 50 })

        remote.call('enemyracemanager', 'register_race', race_settings)
    end
end

---
--- Inject race settings into existing race
---
Event.register(Event.generate_event_name(GlobalConfig.RACE_SETTING_UPDATE), function(event)
    if (event.affected_race == MOD_NAME) then
        modify_race_setting()
    end
end)

