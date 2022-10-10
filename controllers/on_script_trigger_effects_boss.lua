---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 9:47 PM
---
local Event = require('__stdlib__/stdlib/event/event')
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local CustomAttacks = require('__enemyracemanager__/prototypes/base-units/custom_attacks')

local attack_functions = {
    ['embss-die'] = function(args)
        global.boss.victory = true
    end
}
Event.register(defines.events.on_script_trigger_effect, function(event)
    if attack_functions[event.effect_id] then
        attack_functions[event.effect_id](event)
    end
end)