local Event = require('__stdlib__/stdlib/event/event')
local ErmConfig =  require('__enemyracemanager__/lib/global_config')
local RaceSettingHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local modify_race_setting = function()
    local race_settings = remote.call('enemy_race_manager', 'get_race', MOD_NAME)

    ErmDebugHelper.print('Before')
    ErmDebugHelper.print(game.table_to_json(remote.call('enemy_race_manager', 'get_race', MOD_NAME)))

    if game.active_mods['ArmouredBiters'] then
        ErmDebugHelper.print('ArmouredBiters is active')
        if settings.startup["ab-enable-nest"].value then
            RaceSettingHelper.add_structure_to_tier(race_settings, 1, 'armoured-biter-spawner')
        end
        RaceSettingHelper.add_unit_to_tier(race_settings, 1, 'small-armoured-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 1, 'medium-armoured-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 2, 'big-armoured-biter')
        RaceSettingHelper.add_unit_to_tier(race_settings, 3, 'behemoth-armoured-biter')
    else
        ErmDebugHelper.print('ArmouredBiters is inactive')
        RaceSettingHelper.remove_structure_to_tier(race_settings, 1, 'armoured-biter-spawner')
        RaceSettingHelper.remove_unit_to_tier(race_settings, 1, 'small-armoured-biter')
        RaceSettingHelper.remove_unit_to_tier(race_settings, 1, 'medium-armoured-biter')
        RaceSettingHelper.remove_unit_to_tier(race_settings, 2, 'big-armoured-biter')
        RaceSettingHelper.remove_unit_to_tier(race_settings, 3, 'behemoth-armoured-biter')
    end

    ErmDebugHelper.print('After')
    ErmDebugHelper.print(game.table_to_json(remote.call('enemy_race_manager', 'get_race', MOD_NAME)))
end

---
--- Inject race settings into existing race
---
Event.register(Event.generate_event_name(ErmConfig.RACE_SETTING_UPDATE), function(event)
    if(event.affected_race == MOD_NAME) then
        modify_race_setting()
    end
end)

