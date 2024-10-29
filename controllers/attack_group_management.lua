---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 10:29 PM
---

local Event = require("__stdlib__/stdlib/event/event")


require("__enemyracemanager__/global")

local Config = require("__enemyracemanager__/lib/global_config")
local AttackMeterProcessor = require("__enemyracemanager__/lib/attack_meter_processor")

Event.on_nth_tick(Config.ATTACK_POINT_CALCULATION, function(event)
    AttackMeterProcessor.exec()
end)

Event.on_nth_tick(Config.ATTACK_GROUP_GATHERING_CRON, function(event)
    AttackMeterProcessor.add_form_group_cron()
end)

Event.register(Event.generate_event_name(Config.EVENT_ADJUST_ATTACK_METER), function(event)
    AttackMeterProcessor.adjust_attack_meter(event.race_name)
end)

Event.register(Event.generate_event_name(Config.EVENT_ADJUST_ACCUMULATED_ATTACK_METER), function(event)
    AttackMeterProcessor.adjust_last_accumulated_attack_meter(event.race_name)
end)
