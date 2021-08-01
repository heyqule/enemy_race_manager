--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 03/26/2020
-- Time: 8:49 PM
-- To change this template use File | Settings | File Templates.
--

local Table = require('__stdlib__/stdlib/utils/table')
local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')

local ErmAttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')

local Debug_RemoteAPI = {}

--- Usage: remote.call('enemy_race_manager_debug', 'print_race_settings')
function Debug_RemoteAPI.print_race_settings()
    log(game.table_to_json(global.race_settings))
end

--- Usage: remote.call('enemy_race_manager_debug', 'print_surface_races')
function Debug_RemoteAPI.print_surface_races()
    local value_table = {}
    for index, value in pairs(global.enemy_surfaces) do
        value_table[game.surfaces[index].name] = value
    end
    log(game.table_to_json(value_table))
end

--- Usage: remote.call('enemy_race_manager_debug', 'print_forces')
function Debug_RemoteAPI.print_forces()
    log(game.table_to_json(game.forces))
end

--- Usage: remote.call('enemy_race_manager_debug', 'print_option_settings')
function Debug_RemoteAPI.print_option_settings()
    log(game.table_to_json(global.settings))
end

--- Usage: remote.call('enemy_race_manager_debug', 'print_installed_races')
function Debug_RemoteAPI.print_installed_races()
    log(game.table_to_json(GlobalConfig.get_installed_races()))
end

--- Usage: remote.call('enemy_race_manager_debug', 'print_enemy_races')
function Debug_RemoteAPI.print_enemy_races()
    log(game.table_to_json(GlobalConfig.get_enemy_races()))
end

--- Usage: remote.call('enemy_race_manager_debug', 'print_calculate_attack_points')
function Debug_RemoteAPI.print_calculate_attack_points()
    local table = {}
    for name, _ in pairs(global.race_settings) do
        table[name] = {
            current_points = ErmRaceSettingsHelper.get_attack_meter(name), 
            next_threshold = ErmRaceSettingsHelper.get_next_attack_threshold(name)
        }
    end   
    log(game.table_to_json(table))     
end

--- Usage: remote.call('enemy_race_manager_debug', 'exec_attack_group', 'erm_zerg')
function Debug_RemoteAPI.exec_attack_group(race_name)
    ErmAttackGroupProcessor.exec(
        race_name,
        game.forces[ErmForceHelper.get_force_name_from(race_name)],
        2000
    )
end

--- Usage: remote.call('enemy_race_manager_debug', 'generate_attack_group', 'erm_zerg')
function Debug_RemoteAPI.generate_attack_group(race_name)
    ErmAttackGroupProcessor.generate_group(
            race_name,
            game.forces[ErmForceHelper.get_force_name_from(race_name)],
            200
    )
end

--- Usage: remote.call('enemy_race_manager_debug', 'generate_flying_group', 'erm_zerg')
function Debug_RemoteAPI.generate_flying_group(race_name)
    ErmAttackGroupProcessor.generate_group(
            race_name,
            game.forces[ErmForceHelper.get_force_name_from(race_name)],
            40,
            ErmAttackGroupProcessor.GROUP_TYPE_FLYING
    )
end

return Debug_RemoteAPI
