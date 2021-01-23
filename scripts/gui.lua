---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/2/2021 4:48 PM
---
local mod_gui = require('mod-gui')
local LevelManager = require('__enemyracemanager__/lib/level_processor')
local ReplacementProcessor = require('__enemyracemanager__/lib/replacement_processor')

local String = require('__stdlib__/stdlib/utils/string')

local ERM_GUI = {
    require_update_all = false
}

local window_width = 660
local window_height = 400

function ERM_GUI.show(player)
    local mod_ui = mod_gui.get_frame_flow(player)
    local erm_gui = mod_ui.add{type='frame', name='races_manager', direction='vertical'}
    local admin = player.admin
    erm_gui.style.maximal_width = window_width
    erm_gui.style.minimal_width = window_width
    erm_gui.style.maximal_height = window_height * 2
    erm_gui.style.minimal_height = window_height
    -- Race Manager Title
    local title_flow = erm_gui.add{type='flow', name='title_flow', direction='horizontal'}
    title_flow.style.minimal_width = window_width
    title_flow.style.maximal_width = window_width

    local title = title_flow.add{type='label', name='title', caption={"gui.title"}, style='caption_label'}
    title.style.minimal_width = window_width * 0.9

    local close_button = erm_gui.title_flow.add{type="sprite-button", name='erm_close_button', sprite = "utility/close_white", style = 'tip_notice_close_button'}
    close_button.style.width = 24
    close_button.style.height = 24
    close_button.style.horizontal_align = 'right'

    local scroll = erm_gui.add{type = "scroll-pane", style = "scroll_pane_in_shallow_frame"}
    scroll.style.margin = 5
    erm_gui.style.minimal_height = window_height / 1.25
    local item_table = scroll.add{type = "table", column_count = 7, style = "bordered_table"}
    item_table.style.horizontally_stretchable = false

    item_table.add{type = "label", caption = {'gui.race_column'}}
    item_table.add{type = "label", caption = {'gui.level_column'}}
    item_table.add{type = "label", caption = {'gui.tier_column'}}
    item_table.add{type = "label", caption = {'gui.evolution_column'}}
    item_table.add{type = "label", caption = {'gui.evolution_factor_column'}}
    item_table.add{type = "label", caption = {'gui.angry_column'}}
    item_table.add{type = "label", caption = {'gui.action_column'}}

    for name, race_setting in pairs(global.race_settings) do
        item_table.add{type = "label", caption = race_setting.race}
        item_table.add{type = "label", caption = race_setting.level}
        item_table.add{type = "label", caption = race_setting.tier}
        item_table.add{type = "label", caption = string.format("%.4f", race_setting.evolution_point)}
        item_table.add{type = "label", caption = string.format("%.4f", LevelManager.getEvolutionFactor(name))}
        item_table.add{type = "label", caption = string.format("%.4f", race_setting.angry_meter)}
        local action_flow = item_table.add{type = "flow", name=name.."_flow", direction='vertical'}
        if admin and name ~= MOD_NAME then
            action_flow.add{type = "button", name=name.."/sync_with_enemy", caption={'gui.sync_with_enemy'}, tooltip={'gui.sync_with_enemy_tooltip'}}
        end

        if admin and name ~= MOD_NAME then
            action_flow.add{type = "button", name=name.."/replace_enemy", caption={'gui.replace_enemy'}, tooltip={'gui.replace_enemy_tooltip'}}
        end
        if admin and name == MOD_NAME and settings.startup['enemyracemanager-enable-bitters'].value == true then
            action_flow.add{type = "button", name=name.."/replace_enemy", caption={'gui.replace_enemy'}, tooltip={'gui.replace_enemy_tooltip'}}
        end
    end

    local bottom_flow = erm_gui.add{type = "flow", direction='horizontal'}
    bottom_flow.add{type = "button", name="emr_reset_default_bitter", caption={'gui.reset_biter'}, tooltip={'gui.reset_biter_tooltip'}, style='red_button'}
end

function ERM_GUI.hide(player)
    local mod_ui = mod_gui.get_frame_flow(player)
    mod_ui.races_manager.destroy()
end

function ERM_GUI.update(player)
    if ERM_GUI.is_showing(player) then
        ERM_GUI.hide(player)
        ERM_GUI.show(player)
    end
end

function ERM_GUI.update_all()
    for k, player in pairs(game.players) do
        ERM_GUI.update(player)
    end
end

function ERM_GUI.is_hidden(player)
    local mod_ui = mod_gui.get_frame_flow(player)
    return mod_ui.races_manager == nil
end

function ERM_GUI.is_showing(player)
    return not ERM_GUI.is_hidden(player)
end

function ERM_GUI.toggle_main_window(event)
    if event.element.name == "erm_toggle" then
        local owner = game.players[event.element.player_index]
        local button_flow = mod_gui.get_button_flow(owner)

        if ERM_GUI.is_hidden(owner) then
            button_flow.erm_toggle.tooltip = {'gui.hide-enemy-stats'}
            ERM_GUI.show(owner)
        else
            button_flow.erm_toggle.tooltip = {'gui.show-enemy-stats'}
            ERM_GUI.hide(owner)
        end
    end
end

function ERM_GUI.toggle_close(event)
    if event.element.name == "erm_close_button" then
        local owner = game.players[event.element.player_index]
        local button_flow = mod_gui.get_button_flow(owner)
        button_flow.erm_toggle.tooltip = {'gui.show-enemy-stats'}
        ERM_GUI.hide(owner)
    end
end

function ERM_GUI.sync_with_enemy(event)
    if String.find(event.element.name, "/sync_with_enemy") then
        nameToken = String.split(event.element.name, '/')
        if game.forces['enemy_'..nameToken[1]] and global.race_settings[nameToken[1]] then
            LevelManager.copyEvolutionFromEnemy(global.race_settings, game.forces['enemy_'..nameToken[1]], game.forces['enemy'])
            ERM_GUI.require_update_all = true;
        end
    end
end

function ERM_GUI.replace_enemy(event)
    if String.find(event.element.name, "/replace_enemy") then
        nameToken = String.split(event.element.name, '/')
        if (game.forces['enemy_'..nameToken[1]] or nameToken[1] == MOD_NAME) and global.race_settings[nameToken[1]] then
            local owner = game.players[event.element.player_index]
            ReplacementProcessor.rebuild_map(owner.surface, global.race_settings, nameToken[1])
            ERM_GUI.require_update_all = true;
        end
    end
end

function ERM_GUI.reset_default(event)
    if event.element.name == "emr_reset_default_bitter" then
        for _, surface in pairs(game.surfaces) do
            ReplacementProcessor.resetDefault(surface, global.race_settings, 'enemy')
            ERM_GUI.require_update_all = true;
        end
    end
end

function ERM_GUI.update_overhead_button(player_index)
    local player = game.players[player_index]
    local button_flow = mod_gui.get_button_flow(player)

    if button_flow and not button_flow['erm_toggle'] then

        button_flow.add{type="sprite-button", name="erm_toggle", tooltip={'gui.show-enemy-stats'},sprite='utility/force_editor_icon'}
    end
end

return ERM_GUI