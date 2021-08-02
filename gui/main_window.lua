---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/2/2021 4:48 PM
---
local mod_gui = require('mod-gui')
local String = require('__stdlib__/stdlib/utils/string')

local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local LevelManager = require('__enemyracemanager__/lib/level_processor')
local ReplacementProcessor = require('__enemyracemanager__/lib/replacement_processor')
local SurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')

local ERM_MainWindow = {
    require_update_all = false
}

local window_width = 660
local window_height = 400

function ERM_MainWindow.show(player)
    local mod_ui = mod_gui.get_frame_flow(player)
    local ERM_MainWindow = mod_ui.add { type = 'frame', name = 'races_manager', direction = 'vertical' }
    local admin = player.admin
    ERM_MainWindow.style.maximal_width = window_width
    ERM_MainWindow.style.minimal_width = window_width
    ERM_MainWindow.style.maximal_height = window_height * 2
    ERM_MainWindow.style.minimal_height = window_height
    -- Race Manager Title
    local title_flow = ERM_MainWindow.add { type = 'flow', name = 'title_flow', direction = 'horizontal' }
    title_flow.style.minimal_width = window_width
    title_flow.style.maximal_width = window_width

    local title = title_flow.add { type = 'label', name = 'title', caption = { "gui.title" }, style = 'caption_label' }
    title.style.minimal_width = window_width * 0.9

    local close_button = ERM_MainWindow.title_flow.add { type = "sprite-button", name = 'erm_close_button', sprite = "utility/close_white", style = 'tip_notice_close_button' }
    close_button.style.width = 24
    close_button.style.height = 24
    close_button.style.horizontal_align = 'right'

    local scroll = ERM_MainWindow.add { type = "scroll-pane", style = "scroll_pane_in_shallow_frame" }
    scroll.style.margin = 5
    ERM_MainWindow.style.minimal_height = window_height / 1.25

    scroll.add { type = 'label', name = 'surface_name', caption = { 'gui.current_planet',  player.surface.name } , style = 'caption_label' }
    if GlobalConfig.mapgen_is_one_race_per_surface() and global.enemy_surfaces[player.surface.index] then
        scroll.add { type = 'label', name = 'surface_race_name', caption = { 'gui.mapgen_1_race',  global.enemy_surfaces[player.surface.index] } }
    elseif GlobalConfig.mapgen_is_2_races_split() then
        scroll.add { type = 'label', name = 'surface_race_name', caption = { 'gui.mapgen_2_races', GlobalConfig.positive_axis_race(), GlobalConfig.negative_axis_race()} }
    else
        scroll.add { type = 'label', name = 'surface_race_name', caption = { 'gui.mapgen_mixed_races'} }
    end

    local item_table = scroll.add { type = "table", column_count = 7, style = "bordered_table" }
    item_table.style.horizontally_stretchable = false

    item_table.add { type = "label", caption = { 'gui.race_column' } }
    item_table.add { type = "label", caption = { 'gui.level_column' } }
    item_table.add { type = "label", caption = { 'gui.tier_column' } }
    item_table.add { type = "label", caption = { 'gui.evolution_column' } }
    item_table.add { type = "label", caption = { 'gui.evolution_factor_column' } }
    item_table.add { type = "label", caption = { 'gui.attack_column' } }
    item_table.add { type = "label", caption = { 'gui.action_column' } }

    LevelManager.calculateEvolutionPoints(global.race_settings, game.forces, settings)

    for name, race_setting in pairs(global.race_settings) do
        item_table.add { type = "label", caption = race_setting.race }
        item_table.add { type = "label", caption = race_setting.level }
        item_table.add { type = "label", caption = race_setting.tier }
        item_table.add { type = "label", caption = string.format("%.4f", race_setting.evolution_point) }
        item_table.add { type = "label", caption = string.format("%.4f", LevelManager.getEvolutionFactor(name)) }
        item_table.add { type = "label", caption = race_setting.attack_meter .. '/' .. race_setting.next_attack_threshold }
        local action_flow = item_table.add { type = "flow", name = name .. "_flow", direction = 'vertical' }

        if admin and name ~= MOD_NAME then
            action_flow.add { type = "button", name = name .. "/replace_enemy", caption = { 'gui.replace_enemy' }, tooltip = { 'gui.replace_enemy_tooltip' } }
        end
        if admin and name == MOD_NAME and settings.startup['enemyracemanager-enable-bitters'].value == true then
            action_flow.add { type = "button", name = name .. "/replace_enemy", caption = { 'gui.replace_enemy' }, tooltip = { 'gui.replace_enemy_tooltip' } }
        end
    end

    if admin then
        local bottom_flow = ERM_MainWindow.add { type = "flow", direction = 'horizontal' }
        bottom_flow.add { type = "button", name = "emr_reset_default_bitter", caption = { 'gui.reset_biter' }, tooltip = { 'gui.reset_biter_tooltip' }, style = 'red_button' }
        local button_flow_gap = bottom_flow.add { type = "flow", direction = 'horizontal'}
        button_flow_gap.style.width = 350
        bottom_flow.add { type = "button", name = "emr_nuke_biters", caption = { 'gui.nuke_biters' }, tooltip = { 'gui.nuke_biters_tooltip' }, style = 'red_button'}
    end
end

function ERM_MainWindow.hide(player)
    local mod_ui = mod_gui.get_frame_flow(player)
    mod_ui.races_manager.destroy()
end

function ERM_MainWindow.update(player)
    if ERM_MainWindow.is_showing(player) then
        ERM_MainWindow.hide(player)
        ERM_MainWindow.show(player)
    end
end

function ERM_MainWindow.update_all()
    for k, player in pairs(game.players) do
        ERM_MainWindow.update(player)
    end
end

function ERM_MainWindow.is_hidden(player)
    local mod_ui = mod_gui.get_frame_flow(player)
    return mod_ui.races_manager == nil
end

function ERM_MainWindow.is_showing(player)
    return not ERM_MainWindow.is_hidden(player)
end

function ERM_MainWindow.toggle_main_window(event)
    if event.element.name == "erm_toggle" then
        local owner = game.players[event.element.player_index]
        local button_flow = mod_gui.get_button_flow(owner)

        if ERM_MainWindow.is_hidden(owner) then
            button_flow.erm_toggle.tooltip = { 'gui.hide-enemy-stats' }
            ERM_MainWindow.show(owner)
        else
            button_flow.erm_toggle.tooltip = { 'gui.show-enemy-stats' }
            ERM_MainWindow.hide(owner)
        end
    end
end

function ERM_MainWindow.toggle_close(event)
    if event.element.name == "erm_close_button" then
        local owner = game.players[event.element.player_index]
        local button_flow = mod_gui.get_button_flow(owner)
        button_flow.erm_toggle.tooltip = { 'gui.show-enemy-stats' }
        ERM_MainWindow.hide(owner)
    end
end

function ERM_MainWindow.replace_enemy(event)
    if String.find(event.element.name, "/replace_enemy", 1, true) then
        nameToken = String.split(event.element.name, '/')
        if (game.forces['enemy_' .. nameToken[1]] or nameToken[1] == MOD_NAME) and global.race_settings[nameToken[1]] then
            local owner = game.players[event.element.player_index]
            SurfaceProcessor.assign_race(owner.surface, nameToken[1])
            ERM_MainWindow.require_update_all = true;
            ReplacementProcessor.rebuild_map(owner.surface, global.race_settings, nameToken[1])
        end
    end
end

function ERM_MainWindow.reset_default(event)
    if event.element.name == "emr_reset_default_bitter" then
        for _, surface in pairs(game.surfaces) do
            ReplacementProcessor.resetDefault(surface, global.race_settings, 'enemy')
            ERM_MainWindow.require_update_all = true;
        end
    end
end

function ERM_MainWindow.nuke_biters(event)
    if event.element.name == "emr_nuke_biters" then
        local owner = game.players[event.element.player_index]
        local surface = owner.surface
        local pp = owner.position
        local units = surface.find_entities_filtered({force=ForceHelper.get_all_enemy_forces(), radius=32, position=pp, type='unit'})
        for key, entity in pairs(units) do
            entity.destroy()
        end
    end
end

function ERM_MainWindow.update_overhead_button(player_index)
    local player = game.players[player_index]
    local button_flow = mod_gui.get_button_flow(player)

    if button_flow and not button_flow['erm_toggle'] then
        button_flow.add { type = "sprite-button", name = "erm_toggle", tooltip = { 'gui.show-enemy-stats' }, sprite = 'utility/force_editor_icon' }
    end
end

return ERM_MainWindow