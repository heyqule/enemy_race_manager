---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/5/2022 11:19 AM
---

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local String = require('__stdlib__/stdlib/utils/string')

--- Boss Details Windows
local ERM_BossDetailsWindow = {
    root_name = 'erm_races_manager_boss_details',
    window_width = 680,
    window_height = 400,
}

local get_victory_label = function(victory)
    local title_str
    if victory == true then
        title_str = '[img=virtual-signal.signal-green] '
    else
        title_str = '[img=virtual-signal.signal-red] '
    end

    return title_str
end

local add_data_entry = function(data_box, entry)
    data_box.add { type = "label", caption = { 'gui.boss_detail_data_tier' } }
    data_box.add { type = "label", caption = entry.tier }

    data_box.add { type = "label", caption = { 'gui.boss_detail_data_victory' } }
    data_box.add { type = "label", caption = get_victory_label(entry.victory) }

    data_box.add { type = "label", caption = { 'gui.boss_detail_data_location' } }
    data_box.add { type = "label", caption = entry.surface .. '  X:'..entry.location.x..' Y:'..entry.location.y}

    data_box.add { type = "label", caption = { 'gui.boss_detail_data_spawned_at' } }
    data_box.add { type = "label", caption = ErmConfig.format_daytime_string(0, entry.spawn_tick) }

    data_box.add { type = "label", caption = { 'gui.boss_detail_data_fight_duration' } }
    data_box.add { type = "label", caption = ErmConfig.format_daytime_string(entry.spawn_tick, entry.last_tick ) }

    data_box.add { type = "label", caption = { 'gui.boss_detail_data_difficulty' } }
    data_box.add { type = "label", caption = entry.difficulty }

    data_box.add { type = "label", caption = { 'gui.boss_detail_data_squad_size' } }
    data_box.add { type = "label", caption = entry.squad_size }
end

function ERM_BossDetailsWindow.show(player, race_name, boss_log)
    local gui = player.gui.screen
    if gui[ERM_BossDetailsWindow.root_name] then
        return
    end
    local detail_window = gui.add {
        type = "frame",
        name = ERM_BossDetailsWindow.root_name,
        direction = "vertical",
    }
    detail_window.force_auto_center()
    ERM_BossDetailsWindow.parent_window = player.opened
    player.opened = detail_window

    -- Race Manager Title
    local title_flow = detail_window.add { type = 'flow', name = 'title_flow', direction = 'horizontal' }
    title_flow.style.minimal_width = ERM_BossDetailsWindow.window_width

    local title = title_flow.add { type = 'label', name = 'title', caption = { "gui.boss_detail_title", race_name }, style = 'caption_label' }

    local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
    pusher.style.width = ERM_BossDetailsWindow.window_width - 24 - 175
    pusher.style.height = 24
    pusher.drag_target = detail_window

    local close_button = title_flow.add { type = "sprite-button",
                                          name = 'erm_boss_detail_close_button',
                                          sprite = "utility/close_white",
                                          style = 'frame_action_button',
                                          tooltip = {"gui.back-instruction"}
    }
    close_button.style.width = 24
    close_button.style.height = 24
    close_button.style.horizontal_align = 'right'

    local best_record_flow = detail_window.add { type = "flow", name = "best_record_flow", direction = 'vertical' }
    if boss_log == nil or boss_log.best_record.time == -1 then
        best_record_flow.add { type = 'label', name = 'erm_boss_detail_best_record', caption = { "gui.boss_detail_best_record_na"}, style = 'caption_label' }
    else
        local datetime_str = ErmConfig.format_daytime_string(0, boss_log.best_record.time)
        best_record_flow.add { type = 'label', name = 'erm_boss_detail_best_record', caption = { "gui.boss_detail_best_record", datetime_str, boss_log.best_record.tier, boss_log.difficulty, boss_log.squad_size }, style = 'caption_label' }
    end

    local entries_top_flow = detail_window.add { type = "flow", name = "entries_root_flow", direction = 'vertical' }
    local entries_horizontal_flow = entries_top_flow.add { type = "flow", name = "entries_main_flow", direction = 'horizontal', style="inset_frame_container_horizontal_flow"}
    local list_box = entries_horizontal_flow.add{
        type = "list-box",
        name = race_name.."/erm_boss_detail_list_box"
    }
    list_box.style.width = ERM_BossDetailsWindow.window_width * 0.35
    list_box.style.height = ERM_BossDetailsWindow.window_height - 80

    local data_box = entries_horizontal_flow.add{
        type = 'table',
        name = race_name..'/erm_boss_detail_data_box',
        column_count = 2,
        style = 'bordered_table'
    }
    data_box.style.width = ERM_BossDetailsWindow.window_width * 0.6
    data_box.style.height = ERM_BossDetailsWindow.window_height - 80
    data_box.style.horizontally_stretchable = true

    if boss_log and boss_log.entries[1] then
        local descending_entries = {}
        local total_entries = #boss_log.entries
        for i = total_entries, 1, -1 do
            local entry = boss_log.entries[i]
            table.insert(descending_entries,
                    get_victory_label(entry.victory) .. ErmConfig.format_daytime_string(0, entry.spawn_tick) .. ' T'.. entry.tier)
        end
        list_box.items = descending_entries

        add_data_entry(data_box, boss_log.entries[total_entries])
    end

end

function ERM_BossDetailsWindow.hide(player)
    player.gui.screen[ERM_BossDetailsWindow.root_name].destroy()
end

function ERM_BossDetailsWindow.toggle_close(owner)
    if owner then
        ERM_BossDetailsWindow.hide(owner)
    end
end

function ERM_BossDetailsWindow.update_data_box(element, owner)
    if owner and element then
        local nameToken = String.split(element.name, '/')
        local boss_log =  global.boss_logs[nameToken[1]]
        local total_entries = #boss_log.entries
        local detail_element = element.parent[nameToken[1]..'/erm_boss_detail_data_box']
        detail_element.clear()
        local reverse_index = total_entries - (element.selected_index - 1)
        add_data_entry(detail_element, boss_log.entries[reverse_index])
    end
end

return ERM_BossDetailsWindow
