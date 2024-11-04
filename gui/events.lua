---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/4/2024 10:41 AM
---

require("__enemyracemanager__/global")
local String = require('__erm_libs__/stdlib/string')
local GuiContainer = require("__enemyracemanager__/gui/main")

local is_valid_element = function(event)
    if event.element and event.element.valid then
        return true
    end

    return false
end

local get_event_action_by_name = function(element, action_handlers, using_parent)
    using_parent = using_parent or false
    local name = element.name
    local pattern = element.tags.filter_pattern

    if using_parent then
        name = element.parent.name
    end

    local action = action_handlers[name]
    if action then
        return action
    elseif pattern then
        action = action_handlers[pattern]
        if pattern and element.name:match(pattern) then
            return action
        end
    end

    return nil
end


local Click = {}
--- Validation not require as they performed under on_click()
Click.erm_toggle = function(event)
    local owner = game.players[event.element.player_index]
    GuiContainer.main_window.toggle_main_window(owner)
end

Click.erm_close_button = function(event)
    local owner = game.players[event.element.player_index]
    GuiContainer.main_window.toggle_close(owner)
end

Click.more_action = function(event)
    local element = event.element
    local owner = game.players[element.player_index]
    if owner then
        local nameToken = String.split(element.name, "/")
        GuiContainer.detail_window.show(owner, storage.race_settings[nameToken[1]])
    end
end

Click.erm_clean_idle_biter = function(event)
    GuiContainer.main_window.kill_idle_units(event)
end

Click.erm_reset_default_bitter = function(event)
    GuiContainer.main_window.reset_default(event)
end


Click.erm_detail_close_button = function(event)
    local element = event.element
    local owner = game.players[element.player_index]
    if owner then
        GuiContainer.detail_window.toggle_close(owner)
        GuiContainer.main_window.show(owner)
    end
end

Click.detail_setting_confirm = function(event)
    local element = event.element
    local owner = game.players[element.player_index]
    if owner then
        local nameToken = String.split(element.name, "/")
        GuiContainer.detail_window.confirm(owner, nameToken, element)
        GuiContainer.main_window.show(owner)
        GuiContainer.main_window.update_all()
    end
end

Click.boss_detail = function(event)
    local element = event.element
    local nameToken = String.split(element.name, "/")
    local owner = game.players[element.player_index]
    GuiContainer.boss_detail_window.show(owner, nameToken[1], storage.boss_logs[nameToken[1]])
end

Click.erm_boss_detail_close_button = function(event)
    local element = event.element
    local owner = game.players[element.player_index]
    if owner then
        GuiContainer.boss_detail_window.toggle_close(owner)
        GuiContainer.main_window.show(owner)
    end
end

Click.victory_dialog_tier_cancel = function(event)
    local owner = game.players[element.element.player_index]
    GuiContainer.victory_dialog.hide(owner)
end

Click.victory_dialog_tier_confirm = function(event)
    local element = event.element
    local nameToken = String.split(element.name, "/")
    local owner = game.players[element.player_index]
    GuiContainer.victory_dialog.confirm(nameToken[1])
    GuiContainer.victory_dialog.hide(owner)
end

Click.erm_army_control_toggle = function(event)
    local owner = game.players[event.element.player_index]
    GuiContainer.army_control_window.toggle_main_window(owner)
end

Click.erm_army_close_button = function(event)
    local owner = game.players[event.element.player_index]
    if owner then
        GuiContainer.army_control_window.toggle_close(owner)
    end
end

--- army_deployer: all buttons
Click.army_deploy_all = function(event)
    local element = event.element
    local player = game.players[element.player_index]
    if player and player.valid then
        local nameToken = String.split(element.name, "/")
        local army_window = GuiContainer.army_control_window
        if nameToken[3] == "on" then
            army_window.deployer_turn_all_on(player)
        else
            army_window.deployer_turn_all_off(player)
        end
    end
end

--- army_deployer: filter
Click.army_deploy_filter_type = function(event)
    local element = event.element
    local player = game.players[element.player_index]
    if player and player.valid then
        local nameToken = String.split(element.name, "/")
        local army_window = GuiContainer.army_control_window
        local filter = storage.army_windows_tab_player_data[player.index].deployer_type_filters[nameToken[3].."/"..nameToken[4]]
        if filter then
            filter = false
        else
            filter = true
        end
        storage.army_windows_tab_player_data[player.index].deployer_type_filters[nameToken[3].."/"..nameToken[4]] = filter
        army_window.update_deployers()
    end
end


--- army_deployer: open map
Click.army_deploy_open_map = function(event)
    local element = event.element
    if not (element and element.valid) then
        return
    end

    local player = game.players[element.player_index]
    if player and player.valid then
        local nameToken = String.split(element.name, "/")
        local deployers = storage.army_built_deployers[player.force.index]
        local unit_number = tonumber(nameToken[3])
        if deployers and deployers[unit_number] and deployers[unit_number].entity.valid then
            player.zoom_to_world(deployers[unit_number].entity.position)
        end
    end
end

--- army_cc: Link/unlink handler
Click.army_cc_link = function(event)
    local element = event.element
    local player = game.players[event.element.player_index]
    if player and player.valid then
        local army_control_window = GuiContainer.army_control_window
        if element.name == army_control_window.start_link_button then
            army_control_window.start_link(player)
        elseif element.name == army_control_window.stop_link_button then
            army_control_window.stop_link(player)
        end
    end
end

-- Rally point handling
Click.erm_rally_point_set = function(event)
    local player = game.players[event.player_index]
    if player and player.valid then
        GuiContainer.deployer_attachment.set_cursor(player)
    end
end

Click.erm_rallypoint_map = function(event)
    local player = game.players[event.player_index]
    if player and player.valid then
        GuiContainer.deployer_attachment.go_to(player)
    end
end

Click.erm_rally_point_unset = function(event)
    local player = game.players[event.player_index]
    if player and player.valid then
        GuiContainer.deployer_attachment.remove_rallypoint(player)
    end
end

Click.events = {
    --- setup: ['click_elememt_name_pattern'] = function_name(event)

    --- Enemy Main window clicks ---
    ["erm_toggle"] = Click.erm_toggle,
    ["erm_close_button"] = Click.erm_close_button,
    [".*/more_action"] = Click.more_action,
    ["erm_clean_idle_biter"] = Click.erm_clean_idle_biter,
    ["erm_reset_default_bitter"] = Click.erm_reset_default_bitter,

    --- Enemy Detail window clicks ---
    ["erm_detail_close_button"] = Click.erm_detail_close_button,
    [".*/" .. GuiContainer.detail_window.confirm_name] = Click.detail_setting_confirm,

    --- Boss Detail window clicks ---
    [".*/boss_details"] = Click.boss_detail,
    ["erm_boss_detail_close_button"] = Click.erm_boss_detail_close_button,

    --- Boss Victory dialog tier upgrade confirmation ---
    [".*/victory_dialog_tier_cancel"] = Click.victory_dialog_tier_cancel,
    [".*/victory_dialog_tier_confirm"] = Click.victory_dialog_tier_confirm,

    --- Army Control Window clicks ---
    ["erm_army_control_toggle"] = Click.erm_army_control_toggle,
    ["erm_army_close_button"] = Click.erm_army_close_button,

    --- Army Deploy ---
    ["army_deployer/all/.*"] = Click.army_deploy_all,
    ["army_deployer/filter_type/.*"] = Click.army_deploy_filter_type,
    ["army_deployer/open_map/.*"] = Click.army_deploy_open_map,

    --- Army CC ---
    ["army_cc/.*_link"] = Click.army_cc_link,

    --- Army RallyPoint ---
    ["erm_rally_point_set"] = Click.erm_rally_point_set,
    ["erm_rallypoint_map"] = Click.erm_rallypoint_map,
    ["erm_rally_point_unset"] = Click.erm_rally_point_unset
}
--- handle all ERM on_click function calls
Click.on_click_event = function(event)
    if is_valid_element(event) then
        local event_action = get_event_action_by_name(event.element, Click.events)
        if event_action then
            event_action(event)
        end
    end
end

local SelectionStateChanged = {}

SelectionStateChanged.erm_boss_detail_list_box = function(event)
    local element = event.element
    local owner = game.players[element.player_index]
    GuiContainer.boss_detail_window.update_data_box(element, owner)
end

--- army_cc: CC Selection
SelectionStateChanged.cc_selection = function(event)
    local element = event.element
    local player = game.players[element.player_index]
    GuiContainer.army_control_window.set_selected_cc(player, element, element.get_item(element.selected_index))
end

--- army_cc: Filter from/to surface
SelectionStateChanged.cc_filter_surface = function(event)
    local element = event.element
    local player = game.players[element.player_index]
    local window_tab_data = storage.army_windows_tab_player_data[player.index]

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
end

SelectionStateChanged.events = {
    [".*/erm_boss_detail_list_box"] = SelectionStateChanged.erm_boss_detail_list_box,
    ["army_cc/cc_select_.*"] = SelectionStateChanged.cc_selection,
    ["army_cc/filter_.*_surface"] = SelectionStateChanged.cc_filter_surface,
}

SelectionStateChanged.on_selection_state_changed = function(event)
    if is_valid_element(event) then
        local event_action = get_event_action_by_name(event.element, SelectionStateChanged.events)
        if event_action then
            event_action(event)
        end
    end
end

---  defines.event.on_gui_opened
-- Register functions by gui_type for relative window functionality
local gui_open_switch = {
    [defines.gui_type.entity] = function(event)
        local owner = game.players[event.player_index]
        local entity = event.entity
        local registered_deployer = storage.army_registered_deployers

        if event.gui_type == defines.gui_type.entity and
                entity and entity.valid and
                (registered_deployer[entity.name])
        then
            GuiContainer.deployer_attachment.show(owner, entity.unit_number)
        end
    end,
}

local on_gui_opened = function(event)
    if is_valid_element(event) and gui_open_switch[event.gui_type] then
        gui_open_switch[event.gui_type](event)
    end
end

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

local on_gui_closed = function(event)
    local element = event.element
    local owner = game.players[event.player_index]
    if is_valid_element(event) and owner and gui_close_switch[element.name] then
        gui_close_switch[element.name](owner)
    end
end

---  defines.event.on_value_changed
local on_value_changed_switch = {
    [GuiContainer.detail_window.evolution_factor_slider_name] = function(event)
        GuiContainer.detail_window.update_slider_text(event, GuiContainer.detail_window.evolution_factor_slider_name, GuiContainer.detail_window.evolution_factor_value_name)
    end
}

local on_value_changed = function(event)
    if is_valid_element(event) then
        local element = event.element
        if element.name == GuiContainer.detail_window.evolution_factor_slider_name then
            on_value_changed_switch[GuiContainer.detail_window.evolution_factor_slider_name](event)
        end
    end
end

---  defines.event.on_gui_selected_tab_changed
local gui_tab_handlers = {
    [GuiContainer.army_control_window.root_name] = function(event)
        local element = event.element
        local player = game.players[event.player_index]
        if player and player.valid then
            storage.army_windows_tab_player_data[event.player_index].active_tab_id = element.selected_tab_index
            GuiContainer.army_control_window.update(player, element.selected_tab_index)
        end
    end
}

local on_gui_selected_tab_changed = function(event)
    local element = event.element
    if is_valid_element(event) and gui_tab_handlers[element.parent.name] then
        gui_tab_handlers[element.parent.name](event)
    end
end

local on_gui_confirmed_handlers = {
    ["army_deployer/planner/.*"] = function(event)
        local element = event.element
        local player = game.players[event.player_index]
        GuiContainer.army_control_window.update_army_planner(player, element)
    end,
}

local on_gui_confirmed = function(event)
    if is_valid_element(event) then
        local event_action = get_event_action_by_name(event.element, on_gui_confirmed_handlers)
        if event_action then
            event_action(event)
        end
    end
end

local deployer_switch = function(event)
    local element = event.element
    local player = game.players[element.player_index]
    if player and player.valid then
        local nameToken = String.split(element.name, "/")
        local army_control_window = GuiContainer.army_control_window
        if nameToken[2] == "auto_deploy" then
            if element.switch_state == "left" then
                army_control_window.deployer_turn_off(player, nameToken[3])
            else
                army_control_window.deployer_turn_on(player, nameToken[3])
            end
        elseif nameToken[2] == "build_only" then
            local build_only = true
            if element.switch_state == "left" then
                build_only = false
            end
            army_control_window.set_build_only(player, nameToken[3], build_only)
        end
    end
end

local switch_state_change_handlers = {
    ["army_deployer/build_only/.*"] = deployer_switch
}

local on_gui_switch_state_changed = function(event)
    if is_valid_element(event) then
        local event_action = get_event_action_by_name(event.element, switch_state_change_handlers)
        if event_action then
            event_action(event)
        end
    end
end


local deployer_surface_dropdown = function(event)
    local element = event.element
    local player = game.players[element.player_index]
    if player and player.valid then
        local index = element.selected_index
        local surface_name = element.get_item(index)
        if surface_name == ALL_PLANETS then
            storage.army_windows_tab_player_data[player.index].deployer_surface_filter = nil
        else
            storage.army_windows_tab_player_data[player.index].deployer_surface_filter = surface_name
        end

        GuiContainer.army_control_window.update_deployers()
    end
end


local selection_state_changed_handler = {
    ["army_deployer/filter_surface"] = deployer_surface_dropdown
}

local on_gui_selection_state_changed = function(event)
    local element = event.element
    if is_valid_element(event) and selection_state_changed_handler[element.name] then
        gui_tab_handlers[element.name](event)
    end
end

local shortcut_handlers = {
    ["erm-detail-window-toggle"] = function(event)
        local owner = game.players[event.player_index]
        if owner then
            GuiContainer.main_window.toggle_main_window(owner)
        end
    end,
    ["erm-army-window-toggle"] = function(event)
        local owner = game.players[event.player_index]
        if owner then
            GuiContainer.army_control_window.toggle_main_window(owner)
        end
    end
}

local on_lua_shortcut = function(event)
    if shortcut_handlers[event.prototype_name] then
        shortcut_handlers[event.prototype_name](event)
    end
end

local GuiEvent = {}
GuiEvent.events = {
    [defines.events.on_player_created] = on_player_created,
    [defines.events.on_gui_click] = Click.on_click_event,
    [defines.events.on_gui_selection_state_changed] = SelectionStateChanged.on_selection_state_changed,
    [defines.events.on_gui_opened] = on_gui_opened,
    [defines.events.on_gui_closed] = on_gui_closed,
    [defines.events.on_gui_value_changed] = on_value_changed,
    [defines.events.on_gui_selected_tab_changed] = on_gui_selected_tab_changed,
    [defines.events.on_gui_confirmed] = on_gui_confirmed,
    [defines.events.on_gui_switch_state_changed] = on_gui_switch_state_changed,
    [defines.events.on_gui_selection_state_changed] = on_gui_selection_state_changed,
    [defines.events.on_lua_shortcut] = on_lua_shortcut
}

return GuiEvent



