local Event = require('__stdlib__/stdlib/event/event')
local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local modify_race_setting = function()
    if script.active_mods['Explosive_biters'] then
        local race_settings = remote.call('enemyracemanager', 'get_race', MOD_NAME)
        ErmDebugHelper.print('Explosive_biters is active')

        table.insert(race_settings.support_structures[1], 'explosive-biter-spawner')

        table.insert(race_settings.turrets[1], 'medium-explosive-worm-turret')
        table.insert(race_settings.turrets[2], 'big-explosive-worm-turret')
        table.insert(race_settings.turrets[3], 'behemoth-explosive-worm-turret')

        table.insert(race_settings.units[1], 'medium-explosive-biter')
        table.insert(race_settings.units[2], 'big-explosive-biter')
        table.insert(race_settings.units[3], 'behemoth-explosive-biter')

        table.insert(race_settings.units[1], 'medium-explosive-spitter')
        table.insert(race_settings.units[2], 'big-explosive-spitter')
        table.insert(race_settings.units[3], 'behemoth-explosive-spitter')

        table.insert(race_settings.featured_groups, { { 'behemoth-explosive-biter', 'behemoth-explosive-spitter' }, { 5, 2 }, 50 })
        table.insert(race_settings.featured_groups, { { 'behemoth-explosive-spitter', 'behemoth-explosive-biter' }, { 5, 2 }, 50 })

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

