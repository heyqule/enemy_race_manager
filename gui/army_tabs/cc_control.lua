---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/22/2024 10:01 PM
---

local SharedGuiFunctions = require("__enemyracemanager__/gui/shared")
local SharedTabFunctions = require("__enemyracemanager__/gui/army_tabs/shared")
local ArmyTeleportationProcessor = require("__enemyracemanager__/lib/army_teleportation_processor")

local has_selected_cc = function(player, backer_name, type)
    if storage.army_windows_tab_player_data[player.index].selected_cc[type] == backer_name then
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

local get_cc_name = function(entity)
    local rc = "N/A"
    if entity and entity.valid then
        rc = entity.backer_name
    end
    return rc
end

local get_command_centers = function(player, windows_tab_data)
    local left_name_list = {}
    local right_name_list = {}
    local left_selected_surface = windows_tab_data.cc_surfaces_select_from
    local right_selected_surface = windows_tab_data.cc_surfaces_select_to
    local force_list = storage.army_built_teleporters[player.force.index];
    local left_surface, right_surface

    if left_selected_surface and left_selected_surface ~= ALL_PLANETS then
        left_surface = game.surfaces[left_selected_surface]
    end

    if right_selected_surface and right_selected_surface ~= ALL_PLANETS then
        right_surface = game.surfaces[right_selected_surface]
    end

    local surface_selection = {ALL_PLANETS}

    if force_list then
        for surface_id, surface_items in pairs(force_list) do
                for _, item in pairs(surface_items) do
                    if left_surface == nil or (left_surface and surface_id == left_surface.index) then
                        table.insert(left_name_list, item.entity.backer_name)
                    end

                    if right_surface == nil or (right_surface and surface_id == right_surface.index) then
                        table.insert(right_name_list, item.entity.backer_name)
                    end
                end
            local _, item = next(surface_items)
            table.insert(surface_selection, item.entity.surface.name)
        end
    end

    storage.army_windows_tab_player_data[player.index].cc_surfaces_selection = surface_selection

    return left_name_list, right_name_list
end

local CommandCenterControlGUI = {
    name = "command-center-pane",
    cc_from_selector = "army_cc/cc_select_from",
    cc_to_selector = "army_cc/cc_select_to",
    stop_link_button = "army_cc/stop_link",
    start_link_button = "army_cc/start_link",
}


function CommandCenterControlGUI.update(player)
    local player_data = SharedTabFunctions.get_player_tab_data(player)
    local main_tab = SharedTabFunctions.get_main_tab(player)
    SharedTabFunctions.clear_tab(main_tab, CommandCenterControlGUI.name)

    local windows_tab_data = storage.army_windows_tab_player_data[player.index]
    local from_commandcenters, to_commandcenters = get_command_centers(player, windows_tab_data)
    local from_selected = get_selected_index(from_commandcenters, player, "from") or 0
    local to_selected = get_selected_index(to_commandcenters, player, "to") or 0
    local entrance, exit = ArmyTeleportationProcessor.get_linked_entities(player.force)

    local pane = main_tab[CommandCenterControlGUI.name]
    local horizontal = pane.add {
        type = "flow",
        direction = "horizontal",
        name = "main-pane"
    }
    -- LEFT CC LISTBOX
    local left_listing = horizontal.add {
        type = "flow",
        direction = "vertical",
        name = "left-listing"
    }
    local left_surface_filter = left_listing.add {
        type = "drop-down",
        name="army_cc/filter_from_surface",
        tags={filter_pattern="army_cc/filter_.*_surface"},
        items = windows_tab_data.cc_surfaces_selection,
        selected_index = windows_tab_data.cc_surfaces_select_from_index or 1,
    }
    left_surface_filter.style.width = 175

    local cc_from = left_listing.add {
        type = "list-box",
        name = CommandCenterControlGUI.cc_to_selector,
        tags={filter_pattern="army_cc/cc_select_.*"}
    }
    cc_from.style.width = 175
    cc_from.items = from_commandcenters
    cc_from.selected_index = from_selected

    -- CENTER CC
    local center_pane = horizontal.add {
        type = "flow",
        direction = "vertical",
        name = "center-pane"
    }
    center_pane.style.width = 390
    center_pane.style.left_margin = 5
    center_pane.style.right_margin = 5
    local center_pane_top_row = center_pane.add {
        type = "flow",
        direction = "horizontal"
    }

    local from_label = center_pane_top_row.add { type = "label", caption = { "gui-army.cc_from_title" } }
    from_label.style.left_margin = 50

    local to_label = center_pane_top_row.add { type = "label", caption = { "gui-army.cc_to_title" } }
    to_label.style.left_margin = 200

    -- CENTER CC MAP ROW
    local center_pane_row_map = center_pane.add {
        type = "flow",
        direction = "horizontal",
        name = "army_cc/minimap_row",
    }

    local selected_from_entity = ArmyTeleportationProcessor.getEntityByName(player_data.selected_cc.from)
    if selected_from_entity and selected_from_entity.valid then
        SharedGuiFunctions.add_mini_map(
                center_pane_row_map,
                "army_cc/from_map",
                player,
                selected_from_entity,
                nil,
                nil,
                { width = 150, height = 150 }
        )
    else
        local from_map = center_pane_row_map.add {
            type = "flow",
            direction = "horizontal",
            name = "army_cc/minimap_row",
        }
        from_map.style.width = 150
        from_map.style.height = 150
    end

    local selected_to_entity = ArmyTeleportationProcessor.getEntityByName(player_data.selected_cc.to)
    if selected_to_entity and selected_to_entity.valid then
        SharedGuiFunctions.add_mini_map(
                center_pane_row_map,
                "army_cc/to_map",
                player,
                selected_to_entity,
                nil,
                nil,
                { width = 150, height = 150, left_margin = 85 }
        )
    end


    -- Center SELECTED CC
    local center_pane_row_selected = center_pane.add {
        type = "flow",
        direction = "horizontal",
        name = "army_cc/selected_pane"
    }
    center_pane_row_selected.style.bottom_margin = 10

    local center_pane_row_selected_from = center_pane_row_selected.add {
        type = "flow",
        direction = "vertical",
        name = CommandCenterControlGUI.cc_from_selector
    }
    center_pane_row_selected_from.add { type = "label", caption = { "gui-army.cc_selected_from" } }
    center_pane_row_selected_from.add { type = "label", name = "army_cc/selected/from_label", caption = get_cc_name(selected_from_entity) }
    center_pane_row_selected_from.style.width = 200
    center_pane_row_selected_from.style.right_margin = 20

    local center_pane_row_selected_to = center_pane_row_selected.add {
        type = "flow",
        direction = "vertical",
        name = "army_cc/selected/to_pane"
    }
    center_pane_row_selected_to.add { type = "label", caption = { "gui-army.cc_selected_to" } }
    center_pane_row_selected_to.add { type = "label", name = "army_cc/selected/to_label", caption = get_cc_name(selected_to_entity) }


    -- CENTER CC LINK BUTTONS
    local center_pane_row_links = center_pane.add {
        type = "flow",
        direction = "horizontal"
    }

    local unlink_button = center_pane_row_links.add { type = "button", name = CommandCenterControlGUI.stop_link_button, tags={filter_pattern="army_cc/.*_link"}, caption = { "gui-army.cc_unlink" }, style = "red_button" }
    unlink_button.tooltip = "Stop Communication"

    local link_button = center_pane_row_links.add { type = "button", name = CommandCenterControlGUI.start_link_button, tags={filter_pattern="army_cc/.*_link"}, caption = { "gui-army.cc_link" }, style = "green_button" }
    link_button.style.left_margin = 165
    link_button.tooltip = "Start Communication"

    if player_data.error_message ~= nil then
        local error_message = center_pane.add { type = "label", name = "army_cc/linked/error_message", caption = player_data.error_message, visible = true, style = "bold_red_label" }
        error_message.style.top_margin = 10
        player_data.error_message = nil
    end

    if player_data.success_message ~= nil then
        local success_message = center_pane.add { type = "label", name = "army_cc/linked/success_message", caption = player_data.success_message, visible = true, style = "bold_green_label" }
        success_message.style.top_margin = 10
        player_data.success_message = nil
    end

    local center_pane_row_active = center_pane.add {
        type = "flow",
        direction = "horizontal",
        name = "army_cc/active_pane"
    }
    center_pane_row_active.style.bottom_margin = 10

    local center_pane_row_active_from = center_pane_row_active.add {
        type = "flow",
        direction = "vertical",
        name = "army_cc/active/from_pane"
    }
    center_pane_row_active_from.add { type = "label", caption = { "gui-army.cc_linked_from" } }
    center_pane_row_active_from.add { type = "label", name = "army_cc/linked/from_label", caption = get_cc_name(entrance) }
    center_pane_row_active_from.style.width = 200
    center_pane_row_active_from.style.right_margin = 20

    local center_pane_row_active_to = center_pane_row_active.add {
        type = "flow",
        direction = "vertical",
        name = "army_cc/active/to_pane"
    }
    center_pane_row_active_to.add { type = "label", caption = { "gui-army.cc_linked_to" } }
    center_pane_row_active_to.add { type = "label", name = "army_cc/linked/to_label", caption = get_cc_name(exit) }

    local center_pane_row_link_map = center_pane.add {
        type = "flow",
        direction = "horizontal",
        name = "army_cc/link_minimap_row",
    }

    if entrance and entrance.valid then
        SharedGuiFunctions.add_mini_map(
                center_pane_row_link_map,
                "army_cc/from_map",
                player,
                entrance,
                nil,
                nil,
                { width = 150, height = 150 }
        )
    else
        local from_map = center_pane_row_link_map.add {
            type = "flow",
            direction = "horizontal",
            name = "army_cc/link_minimap_row",
        }
        from_map.style.width = 150
        from_map.style.height = 150
    end

    if exit and exit.valid then
        SharedGuiFunctions.add_mini_map(
                center_pane_row_link_map,
                "army_cc/to_map",
                player,
                exit,
                nil,
                nil,
                { width = 150, height = 150, left_margin = 85 }
        )
    end

    -- Right CC LISTBOX
    local right_listing = horizontal.add {
        type = "flow",
        direction = "vertical",
        name = "right-listing"
    }

    local right_surface_filter = right_listing.add {
        type = "drop-down",
        name="army_cc/filter_to_surface",
        tags={filter_pattern="army_cc/filter_.*_surface"},
        items = windows_tab_data.cc_surfaces_selection,
        selected_index = windows_tab_data.cc_surfaces_select_to_index or 1,
    }
    right_surface_filter.style.width = 175

    local cc_to = right_listing.add {
        type = "list-box",
        name = CommandCenterControlGUI.cc_to_selector,
        tags={filter_pattern="army_cc/cc_select_.*"}
    }
    cc_to.style.width = 175
    cc_to.items = to_commandcenters
    cc_to.selected_index = to_selected
end

return CommandCenterControlGUI