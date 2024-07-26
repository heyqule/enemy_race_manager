---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/15/2022 10:06 PM
---
local String = require('__stdlib__/stdlib/utils/string')
local Event = require('__stdlib__/stdlib/event/event')
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/global')

local GuiContainer = require('__enemyracemanager__/gui/main')
local EventGui = require('__stdlib__/stdlib/event/gui')

--- Enemy Main window events ---
Event.register(defines.events.on_player_created, function(event)
    GuiContainer.main_window.update_overhead_button(event.player_index)
end)

EventGui.on_click('erm_toggle', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local owner = game.players[element.player_index]
    GuiContainer.main_window.toggle_main_window(owner)
end)

EventGui.on_click('erm_close_button', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local owner = game.players[element.player_index]
    GuiContainer.main_window.toggle_close(owner)
end)

EventGui.on_click('.*/more_action', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local owner = game.players[element.player_index]
    if owner then
        local nameToken = String.split(event.element.name, '/')
        GuiContainer.detail_window.show(owner, global.race_settings[nameToken[1]])
    end
end)

EventGui.on_click('erm_clean_idle_biter', function(event)
    GuiContainer.main_window.kill_idle_units(event)
end)

EventGui.on_click('erm_reset_default_bitter', function(event)
    GuiContainer.main_window.reset_default(event)
end)

--- Enemy Details window events ---
EventGui.on_click('erm_detail_close_button', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local owner = game.players[element.player_index]
    if owner then
        GuiContainer.detail_window.toggle_close(owner)
        GuiContainer.main_window.show(owner)
    end
end)

EventGui.on_click(".*/" .. GuiContainer.detail_window.confirm_name, function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local owner = game.players[element.player_index]
    if owner then
        local nameToken = String.split(element.name, '/')
        GuiContainer.detail_window.confirm(owner, nameToken, element)
        GuiContainer.main_window.show(owner)
        GuiContainer.main_window.update_all()
    end
end)

EventGui.on_click('.*/replace_enemy', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local nameToken = String.split(element.name, '/')
    if (game.forces['enemy_' .. nameToken[1]] or nameToken[1] == MOD_NAME) and global.race_settings[nameToken[1]] then
        local owner = game.players[element.player_index]
        GuiContainer.detail_window.replace_enemy(owner, nameToken)
        GuiContainer.main_window.update_all()
    end
end)

EventGui.on_click('.*/boss_details', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local nameToken = String.split(element.name, '/')
    local owner = game.players[element.player_index]
    GuiContainer.boss_detail_window.show(owner, nameToken[1], global.boss_logs[nameToken[1]])
end)

--- Victory Dialog events ---
EventGui.on_click('.*/victory_dialog_tier_cancel', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local owner = game.players[element.player_index]
    GuiContainer.victory_dialog.hide(owner)
end)

EventGui.on_click('.*/victory_dialog_tier_confirm', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local nameToken = String.split(element.name, '/')
    local owner = game.players[element.player_index]
    GuiContainer.victory_dialog.confirm(nameToken[1])
    GuiContainer.victory_dialog.hide(owner)
end)

--- Boss Detail events ---
EventGui.on_click('erm_boss_detail_close_button', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local owner = game.players[element.player_index]
    if owner then
        GuiContainer.boss_detail_window.toggle_close(owner)
        GuiContainer.main_window.show(owner)
    end
end)

EventGui.on_selection_state_changed('.*/erm_boss_detail_list_box', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local owner = game.players[element.player_index]
    GuiContainer.boss_detail_window.update_data_box(element, owner)
end)

--- Army Control Window events ---
EventGui.on_click('erm_army_control_toggle', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local owner = game.players[element.player_index]
    GuiContainer.army_control_window.toggle_main_window(owner)
end)

EventGui.on_click('erm_army_close_button', function(event)
    local owner = game.players[event.element.player_index]
    if owner then
        GuiContainer.army_control_window.toggle_close(owner)
    end
end)

--- on_gui_closed events
local gui_close_switch = {
    [GuiContainer.main_window.root_name] = function(owner)
        GuiContainer.main_window.hide(owner)
    end,
    [GuiContainer.detail_window.root_name] = function(owner)
        GuiContainer.detail_window.hide(owner)
    end,
    [GuiContainer.boss_detail_window.root_name] = function(owner)
        GuiContainer.boss_detail_window.hide(owner)
    end,
    [GuiContainer.army_control_window.root_name] = function(owner)
        GuiContainer.army_control_window.hide(owner)
    end
}

local onGuiClose = function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local owner = game.players[event.player_index]
    if owner then
        local name = element.name
        if gui_close_switch[name] then
            gui_close_switch[name](owner)
        end
    end
end

Event.register(defines.events.on_gui_closed, onGuiClose)

-- Register functions by gui_type for relative window functionality
local gui_open_switch = {
    [defines.gui_type.entity] = function(event)
        local owner = game.players[event.player_index]
        local entity = event.entity
        local registered_deployer = global.army_registered_deployers

        if event.gui_type == defines.gui_type.entity and
                entity and entity.valid and
                (registered_deployer[entity.name])
        then
            GuiContainer.deployer_attachment.show(owner, entity.unit_number)
        end
    end,
}

local onGuiOpen = function(event)
    if gui_open_switch[event.gui_type] then
        gui_open_switch[event.gui_type](event)
    end
end

Event.register(defines.events.on_gui_opened, onGuiOpen)

--- On Value Change Events
EventGui.on_value_changed(GuiContainer.detail_window.levelup_slider_name, function(event)
    GuiContainer.detail_window.update_slider_text(event, GuiContainer.detail_window.levelup_slider_name, GuiContainer.detail_window.levelup_value_name)
end)

EventGui.on_value_changed(GuiContainer.detail_window.evolution_factor_slider_name, function(event)
    GuiContainer.detail_window.update_slider_text(event, GuiContainer.detail_window.evolution_factor_slider_name, GuiContainer.detail_window.evolution_factor_value_name)
end)

--- Army GUI
local gui_tab_handlers = {
    [GuiContainer.army_control_window.root_name] = function(event)
        local element = event.element
        local player = game.players[event.player_index]
        if player and player.valid then
            global.army_windows_tab_player_data[event.player_index].active_tab_id = element.selected_tab_index
            GuiContainer.army_control_window.update(player, element.selected_tab_index)
        end
    end
}

local gui_tab_changed = function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    if element.parent and element.parent.valid and gui_tab_handlers[element.parent.name] then
        gui_tab_handlers[element.parent.name](event)
    end
end
Event.register(defines.events.on_gui_selected_tab_changed, gui_tab_changed)

Event.register(defines.events.on_gui_confirmed, function(event)
    local element = event.element
    local player = game.players[event.player_index]
    GuiContainer.army_control_window.update_army_planner(player, element)
end, Event.Filters.gui, 'army_deployer/planner/.*')

--- army_cc: CC Selection
EventGui.on_selection_state_changed('army_cc/cc_select_.*', function(event)
    local element = event.element
    local player = game.players[element.player_index]
    GuiContainer.army_control_window.set_selected_cc(player, element, element.get_item(element.selected_index))
end)

--- army_cc: Filter from/to surface
EventGui.on_selection_state_changed('army_cc/filter_.*_surface', function(event)
    local element = event.element
    local player = game.players[element.player_index]
    local window_tab_data = global.army_windows_tab_player_data[player.index]

    local surface_name = element.get_item(element.selected_index)
    if surface_name == ALL_PLANETS then
        surface_name = nil
    end

    if string.find(element.name, "from") then
        window_tab_data.cc_surfaces_select_from = surface_name
        window_tab_data.cc_surfaces_select_from_index = element.selected_index
    elseif string.find(element.name, "to") then
        window_tab_data.cc_surfaces_select_to = surface_name
        window_tab_data.cc_surfaces_select_to_index = element.selected_index
    end

    GuiContainer.army_control_window.update_command_centers()
end)

--- army_cc: Link/unlink handler
EventGui.on_click('army_cc/.*_link', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local player = game.players[event.element.player_index]
    if player and player.valid then
        local army_control_window = GuiContainer.army_control_window
        if element.name == army_control_window.start_link_button then
            army_control_window.start_link(player)
        elseif element.name == army_control_window.stop_link_button then
            army_control_window.stop_link(player)
        end
    end
end)

--- army_deployer: deployer_switch
local deployer_switch = function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local player = game.players[element.player_index]
    if player and player.valid then
        local nameToken = String.split(element.name, '/')
        local army_control_window = GuiContainer.army_control_window
        if nameToken[2] == 'auto_deploy' then
            if element.switch_state == 'left' then
                army_control_window.deployer_turn_off(player, nameToken[3])
            else
                army_control_window.deployer_turn_on(player, nameToken[3])
            end
        elseif nameToken[2] == 'build_only' then
            local build_only = true
            if element.switch_state == 'left' then
                build_only = false
            end
            army_control_window.set_build_only(player, nameToken[3], build_only)
        end
    end
end
Event.register(defines.events.on_gui_switch_state_changed, deployer_switch, Event.Filters.gui, 'army_deployer/.*')

--- army_deployer: all buttons
EventGui.on_click('army_deployer/all/.*', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local player = game.players[element.player_index]
    if player and player.valid then
        local nameToken = String.split(element.name, '/')
        local army_window = GuiContainer.army_control_window
        if nameToken[3] == 'on' then
            army_window.deployer_turn_all_on(player)
        else
            army_window.deployer_turn_all_off(player)
        end
    end
end)

--- army_deployer: filter
EventGui.on_click('army_deployer/filter_type/.*', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local player = game.players[element.player_index]
    if player and player.valid then
        local nameToken = String.split(element.name, '/')
        local army_window = GuiContainer.army_control_window
        local filter = global.army_windows_tab_player_data[player.index].deployer_type_filters[nameToken[3]..'/'..nameToken[4]]
        if filter then
            filter = false
        else
            filter = true
        end
        global.army_windows_tab_player_data[player.index].deployer_type_filters[nameToken[3]..'/'..nameToken[4]] = filter
        army_window.update_deployers()
    end
end)

--- army_deployer: open map
EventGui.on_click('army_deployer/open_map/.*', function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local player = game.players[element.player_index]
    if player and player.valid then
        local nameToken = String.split(element.name, '/')
        local deployers = global.army_built_deployers[player.force.index]
        local unit_number = tonumber(nameToken[3])
        if deployers and deployers[unit_number] and deployers[unit_number].entity.valid then
            player.zoom_to_world(deployers[unit_number].entity.position)
        end
    end
end)

--- army_deployer: surface dropdown
local deployer_surface_dropdown = function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local player = game.players[element.player_index]
    if player and player.valid then
        local index = element.selected_index
        local surface_name = element.get_item(index)
        if surface_name == ALL_PLANETS then
            global.army_windows_tab_player_data[player.index].deployer_surface_filter = nil
        else
            global.army_windows_tab_player_data[player.index].deployer_surface_filter = surface_name
        end

        GuiContainer.army_control_window.update_deployers()
    end
end

Event.register(defines.events.on_gui_selection_state_changed, deployer_surface_dropdown, Event.Filters.gui, 'army_deployer/filter_surface')


-- Rally point handling
EventGui.on_click('erm_rally_point_set', function(event)
    local player = game.players[event.player_index]
    if player and player.valid then
        GuiContainer.deployer_attachment.set_cursor(player)
    end
end)

EventGui.on_click('erm_rallypoint_map', function(event)
    local player = game.players[event.player_index]
    if player and player.valid then
        GuiContainer.deployer_attachment.go_to(player)
    end
end)

EventGui.on_click('erm_rally_point_unset', function(event)
    local player = game.players[event.player_index]
    if player and player.valid then
        GuiContainer.deployer_attachment.remove_rallypoint(player)
    end
end)