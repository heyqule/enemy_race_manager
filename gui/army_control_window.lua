---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/15/2022 9:44 PM
---
local mod_gui = require('mod-gui')
local String = require('__stdlib__/stdlib/utils/string')

local ArmyPopulationProcessor = require("__enemyracemanager__/lib/army_population_processor")
local ArmyTeleportationProcessor = require("__enemyracemanager__/lib/army_teleportation_processor")

local Army_MainWindow = {
    require_update_all = false,
    root_name = 'erm_army_main',
    window_width = 820,
    window_height = 400,
    cc_from_selector = "army_cc/cc_select_from",
    cc_to_selector = "army_cc/cc_select_to",
    stop_link_button = "army_cc/stop_link",
    start_link_button = "army_cc/start_link",
    tab_ids = {
        ['army-stats-pane'] = 1,
        ['deployer-pane'] = 2,
        ['command-center-pane'] = 3,
    },
    tab_names = {
        'army-stats-pane', 'deployer-pane', 'command-center-pane'
    },
    --- @see Army_MainWindow.check_player_data
    tab_player_data = { },
}


local get_player_tab_data = function(player)
    Army_MainWindow.check_player_data(player)
    return Army_MainWindow.tab_player_data[player.index]
end


local get_main_tab = function(player)
    if player.gui.screen[Army_MainWindow.root_name] and player.gui.screen[Army_MainWindow.root_name]['main-tab'] then
        return player.gui.screen[Army_MainWindow.root_name]['main-tab']
    end
end

local clear_tabs = function(main_tab)
    for _, name in pairs(Army_MainWindow.tab_names) do
        main_tab[name].clear()
    end
end

local update_unit_screen = function(player)
    local main_tab = get_main_tab(player)
    clear_tabs(main_tab)

    local pane = main_tab[Army_MainWindow.tab_names[1]]
    local army_data = ArmyPopulationProcessor.get_army_data(player.force)
    pane.add { type = 'label', name = 'army_pop_general_info', caption={"gui.army_pop_general_info",army_data['max_pop'], army_data['pop_count'], army_data['unit_count']}}

    if table_size(army_data['unit_types']) > 0 then
        local item_table = pane.add { type = "table", column_count = 3, style = "bordered_table" }
        item_table.style.horizontally_stretchable = false

        item_table.add { type = "label", caption = { 'gui.army_control_unit_type'}}
        item_table.add { type = "label", caption = { 'gui.army_control_unit_pop'}}
        item_table.add { type = "label", caption = { 'gui.army_control_unit_count'}}

        for name, unit_data in pairs(army_data['unit_types']) do
            if unit_data['unit_count'] > 0 then
                local sprite = item_table.add { type = "sprite", sprite = 'recipe/'..name }
                sprite.style.width = 32
                sprite.style.height = 32
                item_table.add { type = "label", caption = unit_data['pop_count']  }
                item_table.add { type = "label", caption = unit_data['unit_count'] }
            end
        end
    end
end

local has_selected_cc = function(player, backer_name, type)
    if Army_MainWindow.tab_player_data[player.index].selected_cc[type] == backer_name then
        return true
    end
    return false
end

local get_selected_index = function(commandcenters, player, type)
    for idx, value in pairs(commandcenters) do
        if has_selected_cc(player, value, type) then
            return idx
        end
    end
    return nil
end

local add_mini_map = function(pane, name, player, entity, style)
    local from_map = pane.add {
        type='minimap',
        name=name,
        force=entity.force.name,
        chart_player_index=player.index,
        surface_index=entity.surface.index,
        position=entity.position
    }
    for key, value in pairs(style) do
        from_map.style[key] = value
    end
end

local get_cc_name = function(entity)
    local rc = 'N/A'
    if entity and entity.valid then
        rc = entity.backer_name
    end
    return rc
end

local get_command_centers = function(player)
    local name_list = {}
    local force_list = global.army_built_teleporters[player.force.index];
    local surface = player.surface

    if force_list and force_list[surface.index] then
        for _, item in pairs(force_list[surface.index]) do
            table.insert(name_list, item.entity.backer_name)
        end

        for surface_index, surface_items in pairs(force_list) do
            if surface_index ~= surface.index then
                for _, item in pairs(surface_items) do
                    table.insert(name_list, item.entity.backer_name)
                end
            end
        end
    end

    return name_list
end

local update_deployer = function(player)
    local main_tab = get_main_tab(player)
    clear_tabs(main_tab)
    local pane = main_tab[Army_MainWindow.tab_names[2]]
    pane.add { type = "label", caption = "Deployer Windows Test"}
end

local update_cc_screen = function(player)
    local player_data = get_player_tab_data(player)
    local main_tab = get_main_tab(player)
    clear_tabs(main_tab)


    local commandcenters = get_command_centers(player)
    local from_selected = get_selected_index(commandcenters, player, 'from') or 0
    local to_selected = get_selected_index(commandcenters, player, 'to') or 0
    local entrance, exit = ArmyTeleportationProcessor.get_linked_entities(player.force)

    local pane = main_tab[Army_MainWindow.tab_names[3]]
    local horizontal = pane.add {
        type = 'flow',
        direction = 'horizontal',
        name = ''
    }
    -- LEFT CC LISTBOX
    local cc_from = horizontal.add {
        type = 'list-box',
        name = 'army_cc/cc_select_from'
    }
    cc_from.style.width = 175
    cc_from.items = commandcenters
    cc_from.selected_index = from_selected

    -- CENTER CC
    local center_pane = horizontal.add {
        type = 'flow',
        direction = 'vertical',
        name = "center-pane"
    }
    center_pane.style.width = 390
    center_pane.style.left_margin = 5
    center_pane.style.right_margin = 5
    local center_pane_top_row = center_pane.add {
        type = 'flow',
        direction = 'horizontal'
    }

    local from_label = center_pane_top_row.add { type='label', caption="FROM: "}
    from_label.style.left_margin = 50

    local to_label = center_pane_top_row.add { type='label', caption="TO: "}
    to_label.style.left_margin = 200

    -- CENTER CC MAP ROW
    local center_pane_row_map = center_pane.add {
        type = 'flow',
        direction = 'horizontal',
        name='army_cc/minimap_row',
    }

    local selected_from_entity = ArmyTeleportationProcessor.getEntityByName(player_data.selected_cc.from)
    if selected_from_entity and selected_from_entity.valid then
        add_mini_map(
                center_pane_row_map,
         "army_cc/from_map",
                player,
                selected_from_entity,
          {width=150, height=150}
        )
    else
        local from_map = center_pane_row_map.add {
            type = 'flow',
            direction = 'horizontal',
            name='army_cc/minimap_row',
        }
        from_map.style.width = 150
        from_map.style.height = 150
    end

    local selected_to_entity = ArmyTeleportationProcessor.getEntityByName(player_data.selected_cc.to)
    if selected_to_entity and selected_to_entity.valid then
        add_mini_map(
                center_pane_row_map,
                "army_cc/to_map",
                player,
                selected_to_entity,
                {width=150, height=150, left_margin = 85}
        )
    end


    -- Center SELECTED CC
    local center_pane_row_selected = center_pane.add {
        type = 'flow',
        direction = 'horizontal',
        name = 'army_cc/selected_pane'
    }
    center_pane_row_selected.style.bottom_margin = 10

    local center_pane_row_selected_from = center_pane_row_selected.add {
        type = 'flow',
        direction = 'vertical',
        name = Army_MainWindow.cc_from_selector
    }
    center_pane_row_selected_from.add { type = 'label', caption='Selected FROM: '}
    center_pane_row_selected_from.add { type = 'label', name = "army_cc/selected/from_label", caption=get_cc_name(selected_from_entity)}
    center_pane_row_selected_from.style.width = 200
    center_pane_row_selected_from.style.right_margin = 20


    local center_pane_row_selected_to = center_pane_row_selected.add {
        type = 'flow',
        direction = 'vertical',
        name = 'army_cc/selected/to_pane'
    }
    center_pane_row_selected_to.add { type = 'label', caption='Selected TO: '}
    center_pane_row_selected_to.add { type = 'label', name = "army_cc/selected/to_label", caption=get_cc_name(selected_to_entity)}


    -- CENTER CC LINK BUTTONS
    local center_pane_row_links = center_pane.add {
        type = 'flow',
        direction = 'horizontal'
    }

    local unlink_button = center_pane_row_links.add { type = 'button', name = Army_MainWindow.stop_link_button, caption='UNLINK', style="red_button"}
    unlink_button.tooltip = 'Stop Communication'

    local link_button = center_pane_row_links.add { type = 'button', name = Army_MainWindow.start_link_button , caption='LINK', style="green_button"}
    link_button.style.left_margin = 165
    link_button.tooltip = 'Start Communication'

    if player_data.error_message ~= '' then
        local error_message = center_pane.add { type = 'label', name = "army_cc/linked/error_message", caption=player_data.error_message, visible =  true, style='bold_red_label'}
        error_message.style.top_margin = 10
        player_data.error_message = ''
    end

    if player_data.success_message ~= '' then
        local success_message = center_pane.add { type = 'label', name = "army_cc/linked/success_message", caption=player_data.success_message, visible =  true, style='bold_green_label'}
        success_message.style.top_margin = 10
        player_data.success_message = ''
    end


    local center_pane_row_active = center_pane.add {
        type = 'flow',
        direction = 'horizontal',
        name = 'army_cc/active_pane'
    }
    center_pane_row_active.style.bottom_margin = 10

    local center_pane_row_active_from = center_pane_row_active.add {
        type = 'flow',
        direction = 'vertical',
        name = 'army_cc/active/from_pane'
    }
    center_pane_row_active_from.add { type = 'label', caption='Linked FROM: '}
    center_pane_row_active_from.add { type = 'label', name = "army_cc/linked/from_label", caption=get_cc_name(entrance)}
    center_pane_row_active_from.style.width = 200
    center_pane_row_active_from.style.right_margin = 20

    local center_pane_row_active_to = center_pane_row_active.add {
        type = 'flow',
        direction = 'vertical',
        name = 'army_cc/active/to_pane'
    }
    center_pane_row_active_to.add { type = 'label', caption='Linked TO: '}
    center_pane_row_active_to.add { type = 'label', name = "army_cc/linked/to_label", caption=get_cc_name(exit)}

    local center_pane_row_link_map = center_pane.add {
        type = 'flow',
        direction = 'horizontal',
        name='army_cc/link_minimap_row',
    }


    if entrance and entrance.valid then
        add_mini_map(
                center_pane_row_link_map,
                "army_cc/from_map",
                player,
                entrance,
                {width=150, height=150}
        )
    else
        local from_map = center_pane_row_link_map.add {
            type = 'flow',
            direction = 'horizontal',
            name='army_cc/link_minimap_row',
        }
        from_map.style.width = 150
        from_map.style.height = 150
    end

    if exit and exit.valid then
        add_mini_map(
                center_pane_row_link_map,
                "army_cc/to_map",
                player,
                exit,
                {width=150, height=150, left_margin = 85}
        )
    end

    -- Right CC LISTBOX
    local cc_to = horizontal.add {
        type = 'list-box',
        name = Army_MainWindow.cc_to_selector
    }
    cc_to.style.width = 175
    cc_to.items = get_command_centers(player)
    cc_to.items = commandcenters
    cc_to.selected_index = to_selected
end

local update_tabs = {
    ['army-stats-pane'] = update_unit_screen,
    ['deployer-pane'] = update_deployer,
    ['command-center-pane'] = update_cc_screen,
}

function Army_MainWindow.show(player)
    local gui = player.gui.screen
    if gui[Army_MainWindow.root_name] then
        return
    end
    local main_window = gui.add {
        type = "frame",
        name = Army_MainWindow.root_name,
        direction = "vertical",
    }
    main_window.force_auto_center()

    main_window.style.maximal_width = Army_MainWindow.window_width
    main_window.style.minimal_width = Army_MainWindow.window_width
    main_window.style.maximal_height = Army_MainWindow.window_height * 1.55
    main_window.style.minimal_height = Army_MainWindow.window_height * 0.75
    -- Race Manager Title
    local title_flow = main_window.add { type = 'flow', name = 'title_flow', direction = 'horizontal' }
    title_flow.style.minimal_width = Army_MainWindow.window_width
    title_flow.style.maximal_width = Army_MainWindow.window_width

    local title = title_flow.add { type = 'label', name = 'header-title', caption = { "gui.army-control-title" }, style = 'caption_label' }

    local pusher = title_flow.add{type = "empty-widget", name = "header-pusher", style = "draggable_space_header"}
    pusher.style.width = Army_MainWindow.window_width - 24 - 160
    pusher.style.height = 24
    pusher.drag_target = main_window

    local close_button = title_flow.add { type = "sprite-button",
                                          name = 'erm_army_close_button',
                                          sprite = "utility/close_white",
                                          style = 'frame_action_button',
                                          tooltip = {"gui.close-instruction"}
    }
    close_button.style.width = 24
    close_button.style.height = 24
    close_button.style.horizontal_align = 'right'

    local tabbed_pane = main_window.add{ type="tabbed-pane", name='main-tab' }
    local tab1 = tabbed_pane.add{type="tab", caption="Army Stats", name='army-stats-tab'}
    local tab2 = tabbed_pane.add{type="tab", caption="Deployers", name='deployer-tab'}
    local tab3 = tabbed_pane.add{type="tab", caption="Command Center", name='command-center-tab'}

    local army_stats_pane = tabbed_pane.add { type = "scroll-pane", name=Army_MainWindow.tab_names[1], style = "scroll_pane_in_shallow_frame" }
    army_stats_pane.style.margin = 5
    army_stats_pane.style.width = Army_MainWindow.window_width - 40

    local deployer_pane = tabbed_pane.add { type = "scroll-pane", name=Army_MainWindow.tab_names[2], style = "scroll_pane_in_shallow_frame" }
    deployer_pane.style.margin = 5
    deployer_pane.style.width = Army_MainWindow.window_width - 40

    local command_center_pane = tabbed_pane.add { type = "scroll-pane", name=Army_MainWindow.tab_names[3], style = "scroll_pane_in_shallow_frame" }
    command_center_pane.style.margin = 5
    command_center_pane.style.width = Army_MainWindow.window_width - 40

    tabbed_pane.add_tab(tab1, army_stats_pane)
    tabbed_pane.add_tab(tab2, deployer_pane)
    tabbed_pane.add_tab(tab3, command_center_pane)
end

function Army_MainWindow.hide(player)
    if player.gui.screen[Army_MainWindow.root_name] then
        player.gui.screen[Army_MainWindow.root_name].destroy()
    end
end

function Army_MainWindow.update(player, tab_id)
    if Army_MainWindow.is_showing(player) then
        update_tabs[Army_MainWindow.tab_names[tab_id]](player)
    end
end

function Army_MainWindow.update_army_stats()
    for k, player in pairs(game.players) do
        local main_tab = get_main_tab(player)
        if player and main_tab and main_tab.selected_tab_index == 1 then
            Army_MainWindow.update(player, 1)
        end
    end
end


function Army_MainWindow.update_deployers()
    for k, player in pairs(game.players) do
        local main_tab = get_main_tab(player)
        if player and main_tab and  main_tab.selected_tab_index == 2 then
            Army_MainWindow.update(player, 2)
        end
    end
end

function Army_MainWindow.update_command_centers()
    for k, player in pairs(game.players) do
        local main_tab = get_main_tab(player)
        if player and main_tab and  main_tab.selected_tab_index == 3 then
            Army_MainWindow.update(player, 3)
        end
    end
end

function Army_MainWindow.open_tab(player, tab_name)
    if Army_MainWindow.is_hidden(player) then
        Army_MainWindow.show(player)
    end

    if player and player.valid then
        local player_data = get_player_tab_data(player)
        local main_tab = get_main_tab(player)
        if Army_MainWindow.tab_ids[tab_name] then
            player_data.active_tab_id = Army_MainWindow.tab_ids[tab_name]
            main_tab.selected_tab_index = player_data.active_tab_id
            update_tabs[tab_name](player)
        else
            local active_tab_name = Army_MainWindow.tab_names[player_data.active_tab_id]
            main_tab.selected_tab_index = player_data.active_tab_id
            update_tabs[active_tab_name](player)
        end
    end
end

function Army_MainWindow.check_player_data(player)
    if Army_MainWindow.tab_player_data[player.index] == nil then
        Army_MainWindow.tab_player_data[player.index] = {
            active_tab_id = 1,
            selected_cc = { from = '', to = '' },
            error_message = '',
            success_message = '',
        }
    end
end

function Army_MainWindow.is_hidden(player)
    return player.gui.screen[Army_MainWindow.root_name] == nil
end

function Army_MainWindow.is_showing(player)
    return not Army_MainWindow.is_hidden(player)
end

function Army_MainWindow.toggle_main_window(owner)
    if owner then
        local button_flow = mod_gui.get_button_flow(owner)

        if Army_MainWindow.is_hidden(owner) then
            button_flow.erm_army_control_toggle.tooltip = { 'gui.show-army-control' }
            Army_MainWindow.open_tab(owner)
        else
            button_flow.erm_army_control_toggle.tooltip = { 'gui.show-army-control' }
            Army_MainWindow.hide(owner)
        end
    end
end

function Army_MainWindow.toggle_close(owner)
    if owner then
        local button_flow = mod_gui.get_button_flow(owner)
        button_flow.erm_army_control_toggle.tooltip = { 'gui.show-army-control' }
        Army_MainWindow.hide(owner)
    end
end

function Army_MainWindow.update_overhead_button(player_index)
    local owner = game.players[player_index]
    local button_flow = mod_gui.get_button_flow(owner)

    if owner and button_flow and not button_flow['erm_army_control_toggle'] then
        if game.item_prototypes['erm_terran/command-center'] then
            button_flow.add { type = "sprite-button", name = "erm_army_control_toggle", tooltip = { 'gui.show-army-control' }, sprite = 'item/erm_terran/command-center' }
        else
            button_flow.add { type = "sprite-button", name = "erm_army_control_toggle", tooltip = { 'gui.show-army-control' }, sprite = 'item/submachine-gun' }
        end
    end
end

function Army_MainWindow.set_selected_cc(player, cc_selector, cc_name)

    if not player and not player.valid then
        return
    end

    local player_data = get_player_tab_data(player)
    local selected_cc = player_data.selected_cc

    if cc_selector.name == Army_MainWindow.cc_from_selector then
        if selected_cc.to == cc_name then
            selected_cc.to = selected_cc.from
            selected_cc.from = cc_name
        else
            selected_cc.from = cc_name
        end
    elseif cc_selector.name == Army_MainWindow.cc_to_selector then
        if selected_cc.from == cc_name then
            selected_cc.from = selected_cc.to
            selected_cc.to = cc_name
        else
            selected_cc.to = cc_name
        end
    end

    Army_MainWindow.open_tab(player, 'command-center-pane')
end

function Army_MainWindow.start_link(player)
    local player_data = get_player_tab_data(player)
    local from_cc = ArmyTeleportationProcessor.getObjectByName(player_data.selected_cc.from)
    local to_cc = ArmyTeleportationProcessor.getObjectByName(player_data.selected_cc.to)
    if from_cc and to_cc then
        ArmyTeleportationProcessor.link(from_cc, to_cc)
        player_data.success_message = player_data.selected_cc.from..' is now linking with '..player_data.selected_cc.to
    else
        player_data.error_message = 'Missing selections. Unable to link command centers.'
    end
    Army_MainWindow.update_command_centers()
end

function Army_MainWindow.stop_link(player)
    local player_data = get_player_tab_data(player)
    ArmyTeleportationProcessor.unlink(player.force)
    player_data.success_message = player_data.selected_cc.from..' has now unlinked with '..player_data.selected_cc.to
    Army_MainWindow.update_command_centers()
end



return Army_MainWindow