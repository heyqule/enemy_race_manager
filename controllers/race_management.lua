---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 10:29 PM
---
local Event = require('__stdlib__/stdlib/event/event')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local MapProcessor = require('__enemyracemanager__/lib/map_processor')
local LevelProcessor = require('__enemyracemanager__/lib/level_processor')
local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local AttackGroupHeatProcessor = require('__enemyracemanager__/lib/attack_group_heat_processor')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')

--- Level Processing Events
Event.on_nth_tick(GlobalConfig.LEVEL_PROCESS_INTERVAL, function(event)
    LevelProcessor.calculate_levels()
end)

--- ERM Events
Event.register(Event.generate_event_name(GlobalConfig.EVENT_TIER_WENT_UP), function(event)
end)

Event.register(Event.generate_event_name(GlobalConfig.EVENT_LEVEL_WENT_UP), function(event)
    if GlobalConfig.race_is_active(event.affected_race.race) then
        MapProcessor.rebuild_map()
        if remote.interfaces[event.affected_race.race] and remote.interfaces[event.affected_race.race]["refresh_custom_attack_cache"] then
            remote.call(event.affected_race.race, "refresh_custom_attack_cache")
        end
    end
end)

--- Force Management
Event.register(defines.events.on_force_created, function(event)
    ForceHelper.refresh_all_enemy_forces()
    AttackGroupBeaconProcessor.add_new_force(event.force)
end)
Event.register(defines.events.on_forces_merged, function(event)
    ForceHelper.refresh_all_enemy_forces()
    AttackGroupBeaconProcessor.remove_merged_force(event.source_name)
    AttackGroupHeatProcessor.remove_force(event.source_index)
end)

Event.register(defines.events.on_player_changed_force, function(event)
    ForceHelper.refresh_all_enemy_forces()
end)
