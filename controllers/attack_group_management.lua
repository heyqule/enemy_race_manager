---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 10:29 PM
---

local Event = require('__stdlib__/stdlib/event/event')

require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmAttackMeterProcessor = require('__enemyracemanager__/lib/attack_meter_processor')
local ErmAttackGroupChunkProcessor = require('__enemyracemanager__/lib/attack_group_chunk_processor')


Event.on_nth_tick(ErmConfig.ATTACK_POINT_CALCULATION, function(event)
    ErmAttackMeterProcessor.exec()
end)

Event.on_nth_tick(ErmConfig.ATTACK_GROUP_GATHERING_CRON, function(event)
    ErmAttackMeterProcessor.add_form_group_cron()
end)

--- Native Event Handlers
script.on_event(defines.events.on_built_entity, function(event)
    if event.created_entity and event.created_entity.valid then
        ErmAttackGroupChunkProcessor.add_attackable_chunk_by_entity(event.created_entity)
    end
end, ErmAttackGroupChunkProcessor.get_built_entity_event_filter())

script.on_event(defines.events.on_robot_built_entity, function(event)
    if event.created_entity and event.created_entity.valid then
        ErmAttackGroupChunkProcessor.add_attackable_chunk_by_entity(event.created_entity)
    end
end, ErmAttackGroupChunkProcessor.get_built_entity_event_filter())