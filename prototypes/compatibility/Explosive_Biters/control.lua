local Event = require('__stdlib__/stdlib/event/event')
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local RaceSettingHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local modify_race_setting = function()
    local race_settings = remote.call('enemyracemanager', 'get_race', MOD_NAME)

    if script.active_mods['Explosive_biters'] then
        ErmDebugHelper.print('Explosive_biters is active')

        RaceSettingHelper.add_structure_to_tier(race_settings, 1, 'explosive-biter-spawner')

        RaceSettingHelper.add_turret_to_tier(race_settings, 1, 'medium-explosive-worm-turret')
        RaceSettingHelper.add_turret_to_tier(race_settings, 2, 'big-explosive-worm-turret')
        RaceSettingHelper.add_turret_to_tier(race_settings, 3, 'behemoth-explosive-worm-turret')

        RaceSettingHelper.add_unit_to_tier(race_settings, 1, 'medium-explosive-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 1, 'medium-explosive-spitter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 2, 'big-explosive-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 2, 'big-explosive-spitter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 3, 'behemoth-explosive-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 3, 'behemoth-explosive-spitter')

        table.insert(race_settings.featured_groups, { { 'behemoth-explosive-biter', 'behemoth-explosive-spitter' }, { 5, 2 }, 50 })
        table.insert(race_settings.featured_groups, { { 'behemoth-explosive-spitter', 'behemoth-explosive-biter' }, { 5, 2 }, 50 })

        RaceSettingHelper.process_unit_spawn_rate_cache(race_settings)
        RaceSettingHelper.refresh_current_tier(MOD_NAME)

    else
        ErmDebugHelper.print('Explosive_biters is inactive')
        RaceSettingHelper.remove_structure_from_tier(race_settings, 1, 'explosive-biter-spawner')

        RaceSettingHelper.remove_turret_from_tier(race_settings, 1, 'medium-explosive-worm-turret')
        RaceSettingHelper.remove_turret_from_tier(race_settings, 2, 'large-explosive-worm-turret')
        RaceSettingHelper.remove_turret_from_tier(race_settings, 3, 'behemoth-explosive-worm-turret')

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

