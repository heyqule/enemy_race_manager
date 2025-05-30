---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/22/2024 11:29 PM
---

local Shared = {
    root_name = "erm_army_main",
    main_tab_name = "main-tab",
}

function Shared.get_main_tab(player)
    local root_name = Shared.root_name
    local tab_name = Shared.main_tab_name
    if player.gui.screen[root_name] and player.gui.screen[root_name][tab_name] then
        return player.gui.screen[root_name][tab_name]
    end
end

function Shared.clear_tab(main_tab, name)
    if main_tab[name] then
        main_tab[name].clear()
    end
end

function Shared.get_player_tab_data(player)
    Shared.check_player_data(player)
    return storage.army_windows_tab_player_data[player.index]
end

function Shared.check_player_data(player)
    if storage.army_windows_tab_player_data[player.index] == nil then
        storage.army_windows_tab_player_data[player.index] = {
            active_tab_id = 1,
            selected_cc = { from = "", to = "" },
            error_message = nil,
            success_message = nil,
            --- deployer type selection filter
            deployer_type_filters = {},
            --- deployer surface selection filter
            deployer_surface_filter = nil,
            --- Deployer detail view unit_number
            deployer_detail_view = nil,
        }


        for name, value in pairs(storage.army_registered_deployers) do
            storage.army_windows_tab_player_data[player.index].deployer_type_filters[name] = true
        end
    end
end

return Shared