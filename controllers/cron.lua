---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 10:16 PM
---
local Event = require('__stdlib__/stdlib/event/event')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local Cron = require('__enemyracemanager__/lib/cron_processor')
local Config = require('__enemyracemanager__/lib/global_config')
local BossRewardProcessor = require('__enemyracemanager__/lib/boss_reward_processor')
local AttackGroupPathingProcessor = require('__enemyracemanager__/lib/attack_group_pathing_processor')

--- Garbage Collection and Statistic aggregations, heavy task should run by quick cron
Event.on_nth_tick(Config.GC_AND_STATS, function(event)
    Config.clear_invalid_erm_unit_groups()

    BossRewardProcessor.clean_up()

    AttackGroupPathingProcessor.remove_old_nodes()

    for active_race, _ in pairs(global.active_races) do
        Cron.add_quick_queue('AttackGroupHeatProcessor.aggregate_heat',active_race)
        Cron.add_quick_queue('AttackGroupHeatProcessor.cooldown_heat',active_race)
    end
end)

Event.on_nth_tick(Config.ONE_MINUTE_CRON, function(event)
    Cron.process_1_min_queue()
end)

Event.on_nth_tick(Config.FIFTEEN_SECONDS_CRON, function(event)
    Cron.process_15_sec_queue()
end)

Event.on_nth_tick(Config.TEN_SECONDS_CRON, function(event)
    Cron.process_10_sec_queue()
end)

Event.on_nth_tick(Config.TWO_SECONDS_CRON, function(event)
    Cron.process_2_sec_queue()
end)

Event.on_nth_tick(Config.ONE_SECOND_CRON, function(event)
    Cron.process_1_sec_queue()
end)