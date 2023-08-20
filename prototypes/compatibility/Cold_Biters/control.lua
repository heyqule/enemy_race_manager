local Event = require('__stdlib__/stdlib/event/event')
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local RaceSettingHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local modify_race_setting = function()
    local race_settings = remote.call('enemyracemanager', 'get_race', MOD_NAME)

    if game.active_mods['Cold_biters'] then
        ErmDebugHelper.print('Cold_biters is active')

        RaceSettingHelper.add_structure_to_tier(race_settings, 1, 'cb-cold-spawner')

        RaceSettingHelper.add_turret_to_tier(race_settings, 1, 'medium-cold-worm-turret')
        RaceSettingHelper.add_turret_to_tier(race_settings, 2, 'big-cold-worm-turret')
        RaceSettingHelper.add_turret_to_tier(race_settings, 3, 'behemoth-cold-worm-turret')

        RaceSettingHelper.add_unit_to_tier(race_settings, 1, 'medium-cold-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 1, 'medium-cold-spitter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 2, 'big-cold-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 2, 'big-cold-spitter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 3, 'behemoth-cold-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 3, 'behemoth-cold-spitter')

        table.insert(race_settings.featured_groups, { { 'behemoth-cold-biter', 'behemoth-cold-spitter' }, { 5, 2 }, 50 })
        table.insert(race_settings.featured_groups, { { 'behemoth-cold-spitter', 'behemoth-cold-biter' }, { 5, 2 }, 50 })

        RaceSettingHelper.process_unit_spawn_rate_cache(race_settings)
        RaceSettingHelper.refresh_current_tier(MOD_NAME)
    else
        ErmDebugHelper.print('Cold_biters is inactive')
        RaceSettingHelper.remove_structure_from_tier(race_settings, 1, 'cb-cold-spawner')

        RaceSettingHelper.remove_turret_from_tier(race_settings, 1, 'medium-cold-worm-turret')
        RaceSettingHelper.remove_turret_from_tier(race_settings, 2, 'large-cold-worm-turret')
        RaceSettingHelper.remove_turret_from_tier(race_settings, 3, 'behemoth-cold-worm-turret')

        RaceSettingHelper.remove_unit_from_tier(race_settings, 1, 'small-cold-biter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 1, 'small-cold-spitter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 1, 'medium-cold-biter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 1, 'medium-cold-spitter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 2, 'big-cold-biter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 2, 'big-cold-spitter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 3, 'behemoth-cold-biter')
        RaceSettingHelper.remove_unit_from_tier(race_settings, 3, 'behemoth-cold-spitter')
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

