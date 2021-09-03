---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/27/2021 5:22 PM
---
local String = require('__stdlib__/stdlib/utils/string')

local ErmConfig = require('lib/global_config')
local ErmForceHelper = require('lib/helper/force_helper')
local ErmLevelProcessor = require('__enemyracemanager__/lib/level_processor')

local CommandProcessor = {}

local is_not_from_admin = function(command)
    local player = game.get_player(command.player_index)
    if (not player.admin) then
        game.print({'description.command-error-permission'})
        return true
    end

    return false
end

function CommandProcessor.levelup(command)
    if is_not_from_admin(command) then
        return
    end


    if(command.parameter == nil or not String.find(command.parameter, ',', 1, true))  then
        game.print({'description.command-error-invalid-parameters'})
        return
    end

    local params = String.split(command.parameter, ',')

    if(params[1] == nil or params[2] == nil)  then
        game.print({'description.command-error-invalid-parameters'})
        return
    end

    local race_name = params[1]
    local force_name = ErmForceHelper.get_force_name_from(race_name)
    local level = tonumber(params[2])

    if race_name == nil or global.race_settings[race_name] == nil or game.forces[force_name] == nil then
        game.print({'description.command-error-invalid-race-name', race_name})
        return
    end

    if level == nil or level > ErmConfig.get_max_level() or level < 1 then
        game.print({'description.command-error-invalid-level', tostring(level)})
        return
    end

    ErmLevelProcessor.calculateEvolutionPoints(global.race_settings, game.forces, settings)

    if ErmLevelProcessor.canLevelByCommand(global.race_settings, game.forces[force_name], race_name, level) then
        ErmLevelProcessor.levelByCommand(global.race_settings, race_name, level)
    else
        game.print({'description.command-error-level-too-low'})
    end
end

function CommandProcessor.freeforall(command)
    if is_not_from_admin(command) then
        return
    end

    if ErmConfig.get_max_level() > 10 then
        game.print({'description.command-error-ffa-max-level'})
        return
    end

    if global.enemy_are_friends == nil then
        global.enemy_are_friends = true
    end

    if global.enemy_are_friends == false then
        global.enemy_are_friends = true
    else
        global.enemy_are_friends = false
    end
    game.print('[ERM] Free For All Mode: '..tostring( not (global.enemy_are_friends)))

    local enemy_names = ErmForceHelper.get_all_enemy_forces()
    for _, enemy_name_source in pairs(enemy_names) do
        for _, enemy_name_target in pairs(enemy_names) do
            if enemy_name_source ~= enemy_name_target then
                game.forces[enemy_name_source].set_friend(enemy_name_target, global.enemy_are_friends)
                game.forces[enemy_name_source].set_cease_fire(enemy_name_target, global.enemy_are_friends)
            end
        end

        if global.enemy_are_friends then
            game.forces[enemy_name_source].kill_all_units()
        end
    end
end

return CommandProcessor