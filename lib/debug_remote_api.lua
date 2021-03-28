--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 03/26/2020
-- Time: 8:49 PM
-- To change this template use File | Settings | File Templates.
--

--- Usage: remote.call('enemy_race_manager_debug', 'print_race_settings')
local Table = require('__stdlib__/stdlib/utils/table')
local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local Debug_RemoteAPI = {}

function Debug_RemoteAPI.print_race_settings()
    log(game.table_to_json(global.race_settings))
end

function Debug_RemoteAPI.print_surface_races()
    local value_table = {}
    for index, value in pairs(global.enemy_surfaces) do
        value_table[game.surfaces[index].name] = value
    end
    log(game.table_to_json(value_table))
end

function Debug_RemoteAPI.print_forces()
    log(game.table_to_json(game.forces))
end

function Debug_RemoteAPI.print_installed_races()
    log(game.table_to_json(GlobalConfig.get_installed_races()))
end

function Debug_RemoteAPI.print_enemy_races()
    log(game.table_to_json(GlobalConfig.get_enemy_races()))
end

return Debug_RemoteAPI
