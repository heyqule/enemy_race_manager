---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/30/2021 12:18 AM
---
local Event = require('__stdlib__/stdlib/event/event')

local Config = require('__enemyracemanager__/lib/global_config')
local K2Creep = require('__enemyracemanager__/lib/compatibility/k2_creep')
local version = require('__stdlib__/stdlib/vendor/version')

if script.active_mods['Krastorio2'] and version(script.active_mods['Krastorio2']) >= version("1.2.0") then
    Event.register(defines.events.on_chunk_generated, function(event)
        K2Creep.on_chunk_generated(event)
    end)

    Event.register(defines.events.on_biter_base_built, function(event)
        K2Creep.on_spawner_built(event)
    end)

    Event.register(Event.generate_event_name(Config.EVENT_BASE_BUILT), function(event)
        K2Creep.on_spawner_built(event)
    end)
end