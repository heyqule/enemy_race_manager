---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/5/2022 11:13 AM
---

local mod_gui = require('mod-gui')
local String = require('__stdlib__/stdlib/utils/string')

local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local LevelManager = require('__enemyracemanager__/lib/level_processor')
local ReplacementProcessor = require('__enemyracemanager__/lib/replacement_processor')
local SurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')

--- Detail Windows
local DetailWindow = {
    root_name = 'erm_races_manager_detail',
    window_width = 680,
    levelup_slider_name = 'levelup_slider',
    levelup_value_name = 'levelup_value',
    evolution_factor_slider_name = 'evolution_factor_slider',
    evolution_factor_value_name = 'evolution_factor_value',
    confirm_name = 'setting_confirm',
}

local element_valid = function(event)
    return event.element and event.element.valid
end

--- Detail Windows functions
function DetailWindow.show(player, race_setting)
    local gui = player.gui.screen
    if gui[DetailWindow.root_name] then
        return
    end
    local detail_window = gui.add {
        type = 'frame',
        name = DetailWindow.root_name,
        direction = 'vertical',
    }
    detail_window.force_auto_center()
    DetailWindow.parent_window = player.opened
    player.opened = detail_window

    local admin = player.admin
    -- Race Manager Title
    local title_flow = detail_window.add { type = 'flow', name = 'title_flow', direction = 'horizontal' }
    title_flow.style.minimal_width = DetailWindow.window_width

    local title = title_flow.add { type = 'label', name = 'title', caption = { 'gui.detail_title', race_setting.race }, style = 'caption_label' }

    local pusher = title_flow.add { type = 'empty-widget', style = 'draggable_space_header' }
    pusher.style.width = DetailWindow.window_width - 24 - 175
    pusher.style.height = 24
    pusher.drag_target = detail_window

    local close_button = title_flow.add { type = 'sprite-button',
                                          name = 'erm_detail_close_button',
                                          sprite = 'utility/close',
                                          style = 'frame_action_button',
                                          tooltip = { 'gui.back-instruction' }
    }
    close_button.style.width = 24
    close_button.style.height = 24
    close_button.style.horizontal_align = 'right'

    local main_flow = detail_window.add { type = 'flow', direction = 'horizontal' }
    local left_flow = main_flow.add { type = 'flow', direction = 'vertical' }
    left_flow.style.width = DetailWindow.window_width / 2

    local item_table = left_flow.add { type = 'table', column_count = 2, style = 'bordered_table' }
    item_table.style.horizontally_stretchable = true

    item_table.add { type = 'label', caption = { 'gui.race_column' } }
    item_table.add { type = 'label', caption = race_setting.race }

    item_table.add { type = 'label', caption = { 'gui.level_column' } }
    item_table.add { type = 'label', caption = race_setting.level }

    item_table.add { type = 'label', caption = { 'gui.tier_column' } }
    item_table.add { type = 'label', caption = race_setting.tier }

    item_table.add { type = 'label', caption = { 'gui.evolution_column' } }
    item_table.add { type = 'label', caption = string.format('%.4f', race_setting.evolution_point) }

    item_table.add { type = 'label', caption = { 'gui.evolution_factor_column' } }
    item_table.add { type = 'label', caption = string.format('%.4f', LevelManager.get_evolution_factor(race_setting.race)) }

    item_table.add { type = 'label', caption = { 'gui.attack_column' } }
    item_table.add { type = 'label', caption = race_setting.attack_meter .. ' / ' .. race_setting.next_attack_threshold }

    item_table.add { type = 'label', caption = { 'gui.total_attack_column' } }
    item_table.add { type = 'label', caption = race_setting.attack_meter_total }

    local unit_killed_count = race_setting.unit_killed_count or 0
    item_table.add { type = 'label', caption = { 'gui.total_unit_killed' } }
    item_table.add { type = 'label', caption = unit_killed_count }

    local structure_killed_count = race_setting.structure_killed_count or 0
    item_table.add { type = 'label', caption = { 'gui.total_structures_killed' } }
    item_table.add { type = 'label', caption = structure_killed_count }

    local boss_tier = race_setting.boss_tier or 1
    item_table.add { type = 'label', caption = { 'gui.boss_tier' } }
    item_table.add { type = 'label', caption = boss_tier }

    local boss_kill_count = race_setting.boss_kill_count or 0
    item_table.add { type = 'label', caption = { 'gui.boss_kill_count' } }
    item_table.add { type = 'label', caption = boss_kill_count }

    local right_flow = main_flow.add { type = 'flow', direction = 'vertical' }
    right_flow.style.width = DetailWindow.window_width / 2

    if admin then
        local setting_flow = right_flow.add { type = 'flow', name = 'setting_flow', direction = 'vertical' }
        setting_flow.add { type = 'label', name = 'setting_description', caption = { 'gui.setting_description' } }

        local add_confirm_button = false

        --- LEVEL SLIDER ---
        local level_slider_flow = setting_flow.add { type = 'flow', name = 'level_slider_flow', direction = 'horizontal' }
        local current_level = LevelManager.get_calculated_current_level(race_setting)
        local max_level = GlobalConfig.get_max_level()

        if current_level < max_level then
            level_slider_flow.add { type = 'label',
                                    caption = { 'gui.level_up_slider' },
                                    tooltip = { 'gui.level_up_slider_tooltip' }
            }
            local level_slider = level_slider_flow.add { type = 'slider',
                                                         name = race_setting.race .. '/' .. DetailWindow.levelup_slider_name,
                                                         tooltip = { 'gui.level_up_slider_tooltip' },
                                                         minimum_value = current_level,
                                                         maximum_value = max_level,
                                                         value_step = 0.01,
                                                         style = 'notched_slider'
            }
            level_slider.slider_value = current_level
            level_slider.set_slider_value_step(1)
            level_slider.style.vertical_align = 'bottom'
            level_slider_flow.add { type = 'label', name = race_setting.race .. '/' .. DetailWindow.levelup_value_name, caption = race_setting.level }
            add_confirm_button = true
        else
            level_slider_flow.add { type = 'label',
                                    caption = { 'gui.level_up_slider' },
                                    tooltip = { 'gui.level_up_slider_tooltip' }
            }
            level_slider_flow.add { type = 'label', name = 'level_slider_not_settable_description', caption = { 'gui.not_settable_description' } }
        end
        --- END LEVEL UP SLIDER ---

        --- EVOLUTION FACTOR SLIDER ---
        local evolution_factor_slider_flow = setting_flow.add { type = 'flow', name = 'evolution_factor_slider_flow', direction = 'horizontal' }
        evolution_factor_slider_flow.add { type = 'label',
                                           caption = { 'gui.evolution_factor_slider' },
                                           tooltip = { 'gui.evolution_factor_slider_tooltip' }
        }
        local evolution_factor_slider = evolution_factor_slider_flow.add { type = 'slider',
                                                                           name = race_setting.race .. '/' .. DetailWindow.evolution_factor_slider_name,
                                                                           tooltip = { 'gui.evolution_factor_slider_tooltip' },
                                                                           minimum_value = 0,
                                                                           maximum_value = 100
        }
        local evolution_factor_value = math.floor(LevelManager.get_evolution_factor(race_setting.race) * 100)
        evolution_factor_slider.slider_value = evolution_factor_value
        evolution_factor_slider.style.vertical_align = 'bottom'
        evolution_factor_slider_flow.add { type = 'label', name = race_setting.race .. '/' .. DetailWindow.evolution_factor_value_name, caption = evolution_factor_value }
        evolution_factor_slider_flow.add { type = 'label', caption = '%' }
        --- END EVOLUTION FACTOR SLIDER ---

        local gap = setting_flow.add { type = 'empty-widget' }
        gap.style.height = 4
        setting_flow.add { type = 'button', name = race_setting.race .. '/' .. DetailWindow.confirm_name, caption = { 'gui.confirm' }, style = 'green_button' }

        local center_gap = right_flow.add { type = 'empty-widget' }
        center_gap.style.height = 16

        local action_flow = right_flow.add { type = 'flow', name = 'action_flow', direction = 'vertical' }
        action_flow.add { type = 'label', name = 'action_description', caption = { 'gui.action_description' } }
        local pass_new_race = race_setting.race ~= MOD_NAME
        local pass_biter_race = race_setting.race == MOD_NAME and settings.startup['enemyracemanager-enable-bitters'].value == true
        if pass_new_race or pass_biter_race then
            action_flow.add { type = 'button', name = race_setting.race .. '/replace_enemy', caption = { 'gui.replace_enemy' }, tooltip = { 'gui.replace_enemy_tooltip' } }
        end

        local center_gap = right_flow.add { type = 'empty-widget' }
        center_gap.style.height = 16
    end

    local boss_flow = right_flow.add { type = 'flow', name = 'boss_flow', direction = 'vertical' }
    boss_flow.add { type = 'label', name = 'boss_flow_description', caption = { 'gui.boss_flow_description' } }
    boss_flow.add { type = 'button', name = race_setting.race .. '/boss_details', caption = { 'gui.boss_details' } }
end

function DetailWindow.update_slider_text(event, slider_name, slider_value)
    if element_valid(event) then
        local nameToken = String.split(event.element.name, '/')

        if nameToken[2] == slider_name then
            local name = nameToken[1] .. '/' .. slider_value
            event.element.parent[name].caption = event.element.slider_value
        end
    end
end

local process_level_slider = function(element, race_name)
    local level_slider_name = race_name .. '/' .. DetailWindow.levelup_slider_name
    local level = tonumber(element.parent['level_slider_flow'][level_slider_name].slider_value)
    if level ~= storage.race_settings[race_name].level then
        LevelManager.level_by_command(storage.race_settings, race_name, level)
    end
end

local process_evolution_factor_slider = function(element, race_name)
    local evolution_slider_name = race_name .. '/' .. DetailWindow.evolution_factor_slider_name
    local evolution_factor = tonumber(element.parent['evolution_factor_slider_flow'][evolution_slider_name].slider_value) / 100
    game.forces[ForceHelper.get_force_name_from(race_name)].set_evolution_factor(evolution_factor)
    game.print('Setting ' .. race_name .. ' evolution factor to ' .. tostring(evolution_factor))
end

function DetailWindow.confirm(owner, nameToken, element)
    process_level_slider(element, nameToken[1])
    process_evolution_factor_slider(element, nameToken[1])
    DetailWindow.hide(owner)
end

function DetailWindow.replace_enemy(owner, nameToken)
    SurfaceProcessor.assign_race(owner.surface, nameToken[1])
    ReplacementProcessor.rebuild_map(owner.surface, storage.race_settings, nameToken[1])
end

function DetailWindow.hide(player)
    player.gui.screen[DetailWindow.root_name].destroy()
end

function DetailWindow.toggle_close(owner)
    if owner then
        DetailWindow.hide(owner)
    end
end

return DetailWindow