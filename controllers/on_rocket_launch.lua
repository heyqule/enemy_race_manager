---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 9:41 PM
---

local Event = require('__stdlib__/stdlib/event/event')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmRaceSettingHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')

Event.register(defines.events.on_rocket_launched, function(event)
    if ErmConfig.rocket_attack_point_enable() then
        local races = ErmConfig.get_enemy_races()
        ErmRaceSettingHelper.add_to_attack_meter(races[math.random(1, ErmConfig.get_enemy_races_total())], ErmConfig.rocket_attack_points())
    end
end)