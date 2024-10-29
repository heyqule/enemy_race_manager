---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/22/2024 10:00 PM
---
local SharedGuiFunctions = require("__enemyracemanager__/gui/shared")
local SharedTabFunctions = require("__enemyracemanager__/gui/army_tabs/shared")

local DeployerControlGUI = {}

DeployerControlGUI.name = "deployer-pane"

function DeployerControlGUI.update(player)
    local main_tab = SharedTabFunctions.get_main_tab(player)
    local player_ui_data = SharedTabFunctions.get_player_tab_data(player)
    SharedTabFunctions.clear_tab(main_tab, DeployerControlGUI.name)
    local pane = main_tab[DeployerControlGUI.name]

    local force = player.force

    local deployer_type_filters = player_ui_data.deployer_type_filters
    local deployer_surface_filter = player_ui_data.deployer_surface_filter

    local deployers = storage.army_built_deployers[force.index]
    if deployers == nil then
        pane.add { type = "label", caption = { "gui-army.no_deployer" } }
        return
    end

    -- Data managemenent
    local active_deployers = {}
    if storage.army_active_deployers[force.index] then
        active_deployers = storage.army_active_deployers[force.index]["deployers"]
    end

    local filtered_deployers = {}
    local match_all_filter = (deployer_type_filters and deployer_surface_filter)

    local surfaces = {}

    for unit_number, deployer in pairs(deployers) do
        local entity = deployer.entity
        local pass = false
        if entity and entity.valid then
            if match_all_filter and deployer_type_filters[entity.name] and entity.surface.name == deployer_surface_filter
            then
                pass = true
            elseif deployer_type_filters[entity.name] and deployer_surface_filter == nil then
                pass = true
            end
        end

        if pass then
            filtered_deployers[unit_number] = deployer
        end

        local surface = deployer.entity.surface
        surfaces[surface.index] = surface.name
    end

    local filtered_surface = {ALL_PLANETS}
    local selected_index = 1
    local index = 1
    for _, name in pairs(surfaces) do
        table.insert(filtered_surface, name)
        index = index + 1
        if name == deployer_surface_filter then
            selected_index = index
        end
    end

    player_ui_data.filtered_deployers = filtered_deployers

    -- Rendering
    --- Filter types and surfaces
    local filters = pane.add { type = "flow", direction = "horizontal" }

    for name, _ in pairs(storage.army_registered_deployers) do
        local sprite = filters.add {
            type = "sprite-button",
            name="army_deployer/filter_type/"..name,
            sprite = "recipe/" .. name,
            style = "frame_button",
            auto_toggle = true,
        }
        sprite.style.width = 32
        sprite.style.height = 32

        if deployer_type_filters[name] then
            sprite.toggled = true
        end

    end

    local surface_dropdown = filters.add {
        type = "drop-down",
        name="army_deployer/filter_surface",
        items = filtered_surface,
        selected_index = selected_index
    }
    surface_dropdown.style.height = 32
    surface_dropdown.style.left_margin = 5

    local main_view = pane.add { type = "flow", direction = "horizontal", name="army_deployer/main_view" }

    local listing = main_view.add { type = "scroll-pane", direction = "vertical", name="army_deployer/listing"}
    listing.style.horizontally_stretchable = false
    listing.style.vertically_stretchable = false
    listing.style.width = 550

    local deployer_table = listing.add {
        type = "table",
        column_count = 5,
        vertical_centering = false,
        name = "army_deployer/deployer_table",
        style = "bordered_table"
    }

    for unit_number, deployer in pairs(filtered_deployers) do
        local entity = deployer.entity
        local unit_number = unit_number

        -- Deployer Type
        local sprite = nil
        if player.surface.index == entity.surface.index then
            sprite = deployer_table.add {
                type = "sprite-button",
                name = "army_deployer/open_map/"..unit_number,
                sprite = "recipe/" .. entity.name,
                tooltip = { "gui-army.deployer_name_click",
                            entity.localised_name }
            }
        else
            sprite = deployer_table.add {
                type = "sprite",
                name = "army_deployer/deployer/"..unit_number,
                sprite = "recipe/" .. entity.name,
                tooltip = { "gui-army.deployer_name",
                            entity.localised_name }
            }
            sprite.style.stretch_image_to_widget_size = true
        end
        sprite.style.width = 32
        sprite.style.height = 32
        -- Deployer Type
        local recipe = entity.get_recipe()
        if recipe then
            local output_sprite = deployer_table.add {
                type = "sprite",
                sprite = "recipe/" .. recipe.name,
                tooltip = { "gui-army.recipe_name",
                            recipe.localised_name }
            }
            output_sprite.style.width = 32
            output_sprite.style.height = 32
            output_sprite.style.stretch_image_to_widget_size = true
        else
            local output_sprite = deployer_table.add {
                type = "sprite",
                sprite = "utility/missing_icon",
                tooltip = {"gui-army.missing_recipe"}
            }
            output_sprite.style.width = 32
            output_sprite.style.height = 32
            output_sprite.style.stretch_image_to_widget_size = true
        end

        local label_position = deployer_table.add {
            type = "label",
            caption = { "gui-army.deployer_location",
                        entity.surface.name, entity.position.x, entity.position.y }
        }

        local switch = deployer_table.add {
            type = "switch",
            name = "army_deployer/build_only/" .. entity.unit_number,
            allow_none_state = false,
            left_label_caption = "B/D",
            left_label_tooltip = { "gui-army.deployer_bd_tooltip" },
            right_label_caption = "BO",
            right_label_tooltip = { "gui-army.deployer_bo_tooltip" }
        }
        if deployer.build_only then
            switch.switch_state = "right"
        end

        local switch = deployer_table.add {
            type = "switch",
            name = "army_deployer/auto_deploy/" .. entity.unit_number,
            allow_none_state = false,
            left_label_caption = "OFF",
            right_label_caption = "ON"
        }
        if active_deployers[unit_number] then
            switch.switch_state = "right"
        end
    end



    --- Batch Actions
    local batch_options = main_view.add { type = "flow", direction = "vertical" }

    local batch_label = batch_options.add { type = "label", caption = { "gui-army.deployer_auto_deploy" } }
    batch_label.style.left_margin = 10

    local deploy_buttons = batch_options.add { type = "flow", direction = "horizontal" }
    local turn_all_on = deploy_buttons.add { type = "button", name = "army_deployer/all/on", caption = { "gui-army.deployer_all_on" }, style = "green_button", tooltip = { "gui-army.deployer_all_on_tooltip" } }
    turn_all_on.style.left_margin = 10
    turn_all_on.style.width = 80
    local turn_all_off = deploy_buttons.add { type = "button", name = "army_deployer/all/off", caption = { "gui-army.deployer_all_off" }, style = "red_button", tooltip = { "gui-army.deployer_all_off_tooltip" } }
    turn_all_off.style.left_margin = 10
    turn_all_off.style.width = 80
end

return DeployerControlGUI