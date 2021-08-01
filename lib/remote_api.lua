--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/20/2020
-- Time: 5:36 PM
-- To change this template use File | Settings | File Templates.
--



local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmAttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')

local ERM_RemoteAPI = {}

--- Create or update race setting
--- Usage: remote.call('enemy_race_manager', 'register_race', {settings...})
function ERM_RemoteAPI.register_race(race_setting)
    if global and global.race_settings then
        global.race_settings[race_setting.race] = race_setting
    end
end

--- Return race setting
--- Usage: remote.call('enemy_race_manager', 'get_race', 'erm_zerg')
function ERM_RemoteAPI.get_race(race)
    if global and global.race_settings then
        return global.race_settings[race]
    end
    return nil
end

--- Return race tier
--- Usage: remote.call('enemy_race_manager', 'get_race_tier', 'erm_zerg')
function ERM_RemoteAPI.get_race_tier(race)
    if global and global.race_settings and
            global.race_settings[race] and global.race_settings[race].tier then

        return global.race_settings[race].tier
    end
    return 1
end

--- Return race level
--- Usage: remote.call('enemy_race_manager', 'get_race_level', 'erm_zerg')
function ERM_RemoteAPI.get_race_level(race)
    if global.race_settings and
            global.race_settings[race] and
            global.race_settings[race].level then

        return global.race_settings[race].level
    end
    return 1
end

--- Proper way to update race_setting in enemy mods ---
--- 1. local race_settings =  remote.call('enemy_race_manager', 'get_race', MOD_NAME)
--- 2. make change to race_settings
--- 3. remote.call('enemy_race_manager', 'update_race_setting', race_settings)
function ERM_RemoteAPI.update_race_setting(race_setting)
    if global and global.race_settings and global.race_settings[race_setting.race] then
        global.race_settings[race_setting.race] = race_setting
    end
end

--- Generate a mixed attack group
--- Usage: remote.call('enemy_race_manager', 'generate_attack_group', 'erm_zerg', 100)
function ERM_RemoteAPI.generate_attack_group(race_name, units_number)
    local force_name = ErmForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    units_number = tonumber(units_number)

    if force and units_number > 0 then
        ErmAttackGroupProcessor.generate_group(race_name, force, units_number)
    end
end

--- Generate a flying attack group
--- Usage: remote.call('enemy_race_manager', 'generate_flying_group', 'erm_zerg', 100)
function ERM_RemoteAPI.generate_flying_group(race_name, units_number)
    local force_name = ErmForceHelper.get_force_name_from(race_name)
    local force = game.forces[force_name]
    units_number = tonumber(units_number)

    if force and units_number > 0 then
        ErmAttackGroupProcessor.generate_group(race_name, force, units_number, ErmAttackGroupProcessor.GROUP_TYPE_FLYING)
    end
end

return ERM_RemoteAPI
