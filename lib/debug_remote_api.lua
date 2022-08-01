--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 03/26/2020
-- Time: 8:49 PM
-- To change this template use File | Settings | File Templates.
--
local util = require('util')

local Table = require('__stdlib__/stdlib/utils/table')
local GlobalConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')

local ErmAttackGroupChunkProcessor = require('__enemyracemanager__/lib/attack_group_chunk_processor')
local ErmAttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')
local ErmLevelProcessor = require('__enemyracemanager__/lib/level_processor')
local ErmSurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local ErmBossProcessor = require('__enemyracemanager__/lib/boss_processor')

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

--- Usage: remote.call('enemy_race_manager_debug', 'print_global')
function Debug_RemoteAPI.print_global()
    game.write_file('enemyracemanager/erm-global.json',game.table_to_json(util.copy(global)))
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
        3000
    )
end

--- Usage: remote.call('enemy_race_manager_debug', 'generate_attack_group', 'erm_zerg', 150)
function Debug_RemoteAPI.generate_attack_group(race_name, size)
    size = size or 150
    ErmAttackGroupProcessor.generate_group(
            race_name,
            game.forces[ErmForceHelper.get_force_name_from(race_name)],
            size
    )
end

--- Usage: remote.call('enemy_race_manager_debug', 'generate_flying_group', 'erm_zerg', 40)
function Debug_RemoteAPI.generate_flying_group(race_name, size)
    size = size or 40
    ErmAttackGroupProcessor.generate_group(
            race_name,
            game.forces[ErmForceHelper.get_force_name_from(race_name)],
            size,
            ErmAttackGroupProcessor.GROUP_TYPE_FLYING
    )
end

--- Usage: remote.call('enemy_race_manager_debug', 'generate_dropship_group', 'erm_zerg', 20)
function Debug_RemoteAPI.generate_dropship_group(race_name, size)
    size = size or 20
    ErmAttackGroupProcessor.generate_group(
            race_name,
            game.forces[ErmForceHelper.get_force_name_from(race_name)],
            size,
            ErmAttackGroupProcessor.GROUP_TYPE_DROPSHIP
    )
end

--- Usage: remote.call('enemy_race_manager_debug', 'generate_featured_group', 'erm_zerg', 100, 1)
function Debug_RemoteAPI.generate_featured_group(race_name, size, squad_id)
    if ErmRaceSettingsHelper.has_featured_squad(race_name) then
        size = size or 100
        squad_id = squad_id or ErmRaceSettingsHelper.get_featured_flying_squad_id(race_name)
        ErmAttackGroupProcessor.generate_group(
                race_name,
                game.forces[ErmForceHelper.get_force_name_from(race_name)],
                size,
                ErmAttackGroupProcessor.GROUP_TYPE_FEATURED,
                squad_id
        )
    end
end

--- Usage: remote.call('enemy_race_manager_debug', 'generate_featured_flying_group', 'erm_zerg', 50, 1)
function Debug_RemoteAPI.generate_featured_flying_group(race_name, size, squad_id)
    if ErmRaceSettingsHelper.has_featured_flying_squad(race_name) then
        size = size or 50
        squad_id = squad_id or ErmRaceSettingsHelper.get_featured_flying_squad_id(race_name)
        ErmAttackGroupProcessor.generate_group(
                race_name,
                game.forces[ErmForceHelper.get_force_name_from(race_name)],
                size,
                ErmAttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
                squad_id
        )
    end
end

--- Usage: remote.call('enemy_race_manager_debug', 'generate_elite_featured_group', 'erm_zerg', 100, 1)
function Debug_RemoteAPI.generate_elite_featured_group(race_name, size, squad_id)
    if ErmRaceSettingsHelper.has_featured_squad(race_name) then
        size = size or 100
        squad_id = squad_id or ErmRaceSettingsHelper.get_featured_flying_squad_id(race_name)
        ErmAttackGroupProcessor.generate_group(
                race_name,
                game.forces[ErmForceHelper.get_force_name_from(race_name)],
                size,
                ErmAttackGroupProcessor.GROUP_TYPE_FEATURED,
                squad_id,
                true
        )
    end
end

--- Usage: remote.call('enemy_race_manager_debug', 'generate_elite_featured_flying_group', 'erm_zerg', 50, 1)
function Debug_RemoteAPI.generate_elite_featured_flying_group(race_name, size, squad_id)
    if ErmRaceSettingsHelper.has_featured_flying_squad(race_name) then
        size = size or 50
        squad_id = squad_id or ErmRaceSettingsHelper.get_featured_flying_squad_id(race_name)
        ErmAttackGroupProcessor.generate_group(
                race_name,
                game.forces[ErmForceHelper.get_force_name_from(race_name)],
                size,
                ErmAttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
                squad_id,
                true
        )
    end
end

--- Usage: remote.call('enemy_race_manager_debug', 'exec_elite_group', 'erm_zerg')
function Debug_RemoteAPI.exec_elite_group(race_name, attack_points)
    attack_points = attack_points or 3000
    ErmAttackGroupProcessor.exec_elite_group(race_name, game.forces[ErmForceHelper.get_force_name_from(race_name)], attack_points)
end

--- Usage: remote.call('enemy_race_manager_debug', 'add_points_to_attack_meter', 500000)
function Debug_RemoteAPI.add_points_to_attack_meter(value)
    for name, _ in pairs(global.race_settings) do
        ErmRaceSettingsHelper.add_to_attack_meter(name, value)
    end
end

--- Usage: remote.call('enemy_race_manager_debug', 'set_accumulated_attack_meter', 'erm_zerg', 500000)
function Debug_RemoteAPI.set_accumulated_attack_meter(name, value)
    ErmRaceSettingsHelper.set_accumulated_attack_meter(name, value)
end

--- Usage: remote.call('enemy_race_manager_debug', 'level_up', 20)
function Debug_RemoteAPI.level_up(level)
    for race_name, _ in pairs(global.race_settings) do
        ErmLevelProcessor.levelByCommand(global.race_settings, race_name, math.min(level, GlobalConfig.get_max_level()))
    end
end

--- Usage: remote.call('enemy_race_manager_debug', 'set_evolution_factor', 0.5)
function Debug_RemoteAPI.set_evolution_factor(value)
    for race_name, _ in pairs(global.race_settings) do
        game.forces[ErmForceHelper.get_force_name_from(race_name)].evolution_factor = math.min(value, 1)
    end
end

--- Usage: remote.call('enemy_race_manager_debug', 'set_tier', 1)
function Debug_RemoteAPI.set_tier(value)
    for race_name, _ in pairs(global.race_settings) do
        global.race_settings[race_name].tier = math.min(value, 3)
        ErmRaceSettingsHelper.refresh_current_tier(race_name)
    end
end

--- Usage: remote.call('enemy_race_manager_debug', 'reset_level')
function Debug_RemoteAPI.reset_level()
    for race_name, _ in pairs(global.race_settings) do
        global.race_settings[race_name].evolution_base_point = 0
        global.race_settings[race_name].evolution_point = 0
        global.race_settings[race_name].tier = 1
        ErmLevelProcessor.levelByCommand(global.race_settings, race_name, 1)
        game.forces[ErmForceHelper.get_force_name_from(race_name)].evolution_factor = 0
    end
end

--- Usage: remote.call('enemy_race_manager_debug', 'attack_group_chunk_index')
function Debug_RemoteAPI.attack_group_chunk_index()
    ErmAttackGroupChunkProcessor.init_index()
end

--- Usage: remote.call('enemy_race_manager_debug', 'wander_clean_up')
function Debug_RemoteAPI.wander_clean_up()
    ErmSurfaceProcessor.wander_unit_clean_up()
end

--- Usage: remote.call('enemy_race_manager_debug', 'check_race_level_curve')
function Debug_RemoteAPI.check_race_level_curve()
    ErmLevelProcessor.print_level_curve_table()
end

--- Usage: remote.call('enemy_race_manager_debug', 'set_evolution_base_point'，‘erm_zerg', 100)
function Debug_RemoteAPI.set_evolution_base_point(race_name, value)
    global.race_settings[race_name].evolution_base_point = value
end

--- Usage: remote.call('enemy_race_manager_debug', 'spawn_boss')
function Debug_RemoteAPI.spawn_boss()
    local rocket_silos = game.surfaces[1].find_entities_filtered {name = 'rocket-silo'}
    if rocket_silos and rocket_silos[1] then
        ErmBossProcessor.reset()
        ErmBossProcessor.exec(rocket_silos[1])
    end
end

--- Usage: remote.call('enemy_race_manager_debug', 'reset_boss')
function Debug_RemoteAPI.reset_boss()
    ErmBossProcessor.reset()
end

return Debug_RemoteAPI
