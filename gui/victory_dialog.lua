---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/5/2022 11:12 AM
---

local GlobalConfig = require('__enemyracemanager__/lib/global_config')

--- Boss victory upgrade dialog
local ERM_BossVictoryDialog = {
    root_name = 'erm_races_manager_boss_victory_dialog',
    window_width = 340
}

function ERM_BossVictoryDialog.show(player, race_setting)
    local gui = player.gui.screen
    if gui[ERM_BossVictoryDialog.root_name] then
        return
    end
    local dialog = gui.add {
        type = "frame",
        name = ERM_BossVictoryDialog.root_name,
        direction = "vertical",
    }
    dialog.force_auto_center()
    ERM_BossVictoryDialog.parent_window = player.opened
    player.opened = dialog

    local title_flow = dialog.add { type = 'flow', name = 'title_flow', direction = 'horizontal' }
    title_flow.style.minimal_width = ERM_BossVictoryDialog.window_width

    local title = title_flow.add { type = 'label', name = 'title', caption = { "gui.boss_victory_title", race_setting.race }, style = 'caption_label' }

    local main_flow = dialog.add { type = 'flow', direction = "vertical"}
    local description = main_flow.add { type = 'label', name = 'description', caption = { "gui.boss_victory_description" } }

    local center_gap = main_flow.add {type="empty-widget"}
    center_gap.style.height = 16

    local bottom_flow = main_flow.add { type = "flow", direction = 'horizontal' }
    bottom_flow.add {type = "button", name = race_setting.race.."/victory_dialog_tier_cancel", caption = {"gui.victory_dialog_tier_cancel"}, style="red_button"}

    local button_pusher = bottom_flow.add{type = "empty-widget", style = "draggable_space_header"}
    button_pusher.style.width = 150
    button_pusher.style.height = 24

    bottom_flow.add {type = "button", name = race_setting.race.."/victory_dialog_tier_confirm", caption = {"gui.victory_dialog_tier_confirm"}, style="green_button"}
end

function ERM_BossVictoryDialog.hide(player)
    if player.gui.screen[ERM_BossVictoryDialog.root_name] then
        player.gui.screen[ERM_BossVictoryDialog.root_name].destroy()
    end
end

function ERM_BossVictoryDialog.confirm(race_name)
    if global.race_settings[race_name].boss_tier < GlobalConfig.BOSS_MAX_TIERS then
        global.race_settings[race_name].boss_tier = global.race_settings[race_name].boss_tier + 1
        game.print("[color=#ff0000]"..race_name..'[/color] is now on boss tier '..tostring(global.race_settings[race_name].boss_tier))
    end
end

return ERM_BossVictoryDialog