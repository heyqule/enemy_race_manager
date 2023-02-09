local Event = require('__stdlib__/stdlib/event/event')
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local RaceSettingHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local modify_race_setting = function()
    local race_settings = remote.call('enemyracemanager', 'get_race', MOD_NAME)

    if game.active_mods['Explosive_biters'] then
        ErmDebugHelper.print('Explosive_biters is active')

        RaceSettingHelper.add_structure_to_tier(race_settings, 1, 'explosive-biter-spawner')

        RaceSettingHelper.add_unit_to_tier(race_settings, 1, 'medium-explosive-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 1, 'medium-explosive-spitter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 2, 'big-explosive-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 2, 'big-explosive-spitter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 3, 'behemoth-explosive-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 3, 'behemoth-explosive-spitter')
    else
        ErmDebugHelper.print('Explosive_biters is inactive')
        RaceSettingHelper.remove_structure_from_tier(race_settings, 1, 'explosive-biter-spawner')

        RaceSettingHelper.remove_unit_from_tier(race_settings, 1, 'small-explosive-biter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 1, 'small-explosive-spitter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 1, 'medium-explosive-biter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 1, 'medium-explosive-spitter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 2, 'big-explosive-biter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 2, 'big-explosive-spitter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 3, 'behemoth-explosive-biter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 3, 'behemoth-explosive-spitter')
    end
end

---
--- Inject race settings into existing race
---
Event.register(Event.generate_event_name(ErmConfig.RACE_SETTING_UPDATE), function(event)
    if (event.affected_race == MOD_NAME) then
        modify_race_setting()
    end
end)

