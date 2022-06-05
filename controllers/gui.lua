---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 10:06 PM
---
local String = require('__stdlib__/stdlib/utils/string')
local Event = require('__stdlib__/stdlib/event/event')
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local ErmGui = require('__enemyracemanager__/gui/main')
local EventGui = require('__stdlib__/stdlib/event/gui')

Event.register(defines.events.on_player_created, function(event)
    ErmGui.main_window.update_overhead_button(event.player_index)
end)

--- On Click Events
EventGui.on_click('erm_detail_close_button',function(event)
    ErmGui.detail_window.toggle_close(event)
end)

EventGui.on_click('erm_toggle', function(event)
    ErmGui.main_window.toggle_main_window(event)
end)

EventGui.on_click('erm_close_button', function(event)
    ErmGui.main_window.toggle_close(event)
end)

EventGui.on_click('.*/more_action',  function(event)
    ErmGui.main_window.open_detail_window(event)
end)

EventGui.on_click('erm_nuke_biters',  function(event)
    ErmGui.main_window.nuke_biters(event)
end)

EventGui.on_click('erm_clean_idle_biter', function(event)
    ErmGui.main_window.kill_idle_units(event)
end)

EventGui.on_click('erm_reset_default_bitter', function(event)
    ErmGui.main_window.reset_default(event)
end)

EventGui.on_click(".*/"..ErmGui.detail_window.confirm_name, function(event)
    ErmGui.detail_window.confirm(event)
end)

EventGui.on_click('.*/replace_enemy', function(event)
    ErmGui.detail_window.replace_enemy(event)
end)

--- on_gui_closed events
local gui_close_switch = {
    [ErmGui.main_window.root_name] = function(owner)
        ErmGui.main_window.hide(owner)
    end,
    [ErmGui.detail_window.root_name] = function(owner)
        ErmGui.detail_window.hide(owner)
    end
}

local onGuiClose = function(event)
    local owner = game.players[event.player_index]
    if owner and event.element and event.element.valid then
        local name = event.element.name
        if gui_close_switch[name] then
            gui_close_switch[name](owner)
        end
    end
end

Event.register(defines.events.on_gui_closed, onGuiClose)

--- On Value Change Events
EventGui.on_value_changed(ErmGui.detail_window.levelup_slider_name, function(event)
    ErmGui.detail_window.update_slider_text(event, ErmGui.detail_window.levelup_slider_name, ErmGui.detail_window.levelup_value_name)
end)

EventGui.on_value_changed(ErmGui.detail_window.evolution_factor_slider_name, function(event)
    ErmGui.detail_window.update_slider_text(event, ErmGui.detail_window.evolution_factor_slider_name, ErmGui.detail_window.evolution_factor_value_name)
end)