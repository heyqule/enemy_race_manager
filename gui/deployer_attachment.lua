---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/15/2024 2:10 AM
---

local SharedGuiFunctions = require("__enemyracemanager__/gui/shared")
local ArmyDeploymentProcessor = require("__enemyracemanager__/lib/army_deployment_processor")

local DeployerAttachement = {
    root_name = "erm_deployer_attachment"
}

function DeployerAttachement.show(player, unit_number)
    DeployerAttachement.hide(player)

    local gui = player.gui.relative
    local force_index = player.force.index

    local anchor = {gui=defines.relative_gui_type.assembling_machine_gui, position=defines.relative_gui_position.right}
    local container = gui.add{
        type = "frame",
        name = DeployerAttachement.root_name,
        direction="vertical",
        anchor = anchor,
        -- use gui element tags to store a reference to deployer unit_number
        tags = {
            unit_number = unit_number
        }
    }
    container.style.vertically_stretchable = "stretch_and_expand"

    container.add { type = "label", caption = { "gui-rallypoint.current_location" } }

    local data = ArmyDeploymentProcessor.get_deployer_data(force_index, unit_number)

    if data.rally_point and data.rally_point.x then
        container.add { type = "label", caption = data.rally_point.x .. "," .. data.rally_point.y }
        SharedGuiFunctions.add_mini_map(container,  "erm_rallypoint_map",
                player, data.entity, data.rally_point, 1, { width = 128, height = 128 }, {"gui-rallypoint.map_open"})
    else
        container.add { type = "label", caption = "N/A"}
    end
    container.add { type = "button", name = "erm_rally_point_set", caption = { "gui-rallypoint.set" }, style = "green_button_no_confirm", tooltip=nil}
    container.add { type = "button", name = "erm_rally_point_unset", caption = { "gui-rallypoint.unset" }, style = "red_button"}

    local active_deployers = {}
    if storage.army_active_deployers[force_index] then
        active_deployers = storage.army_active_deployers[force_index]["deployers"]
    end
    container.add { type = "label", caption = {"gui-rallypoint.auto_deploy"}}
    local switch = container.add {
        type = "switch",
        name = "army_deployer/auto_deploy/" .. data.entity.unit_number,
        allow_none_state = false,
        left_label_caption = "OFF",
        right_label_caption = "ON"
    }
    if active_deployers[unit_number] then
        switch.switch_state = "right"
    end

end

function DeployerAttachement.hide(player)
    if player.gui.relative[DeployerAttachement.root_name] then
        player.gui.relative[DeployerAttachement.root_name].destroy()
    end
end

function DeployerAttachement.set_cursor(player)
    player.cursor_stack.set_stack({name = "erm_rally_point"})
end

function DeployerAttachement.remove_rallypoint(player)
    local ui = player.gui.relative[DeployerAttachement.root_name]
    if ui then
        ArmyDeploymentProcessor.remove_rallypoint(player.force.index, ui.tags.unit_number)
        DeployerAttachement.show(player, ui.tags.unit_number)
    end
end

function DeployerAttachement.go_to(player)
    local ui = player.gui.relative[DeployerAttachement.root_name]
    if ui then
        local deployer_data = ArmyDeploymentProcessor.get_deployer_data(player.force.index, ui.tags.unit_number)
        if player.render_mode == defines.render_mode.chart_zoomed_in then
            player.close_map()
        elseif deployer_data.rally_point then
            player.zoom_to_world(deployer_data.rally_point)
        end
    end
end

return DeployerAttachement