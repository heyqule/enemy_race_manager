--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/20/2020
-- Time: 5:36 PM
-- To change this template use File | Settings | File Templates.
--

--- Usage: remote.call('enemy_race_manager', 'get_race', MOD_NAME)
local Table = require('__stdlib__/stdlib/utils/table')
local ERM_RemoteAPI = {}

-- Create or update race setting
function ERM_RemoteAPI.register_race(race_setting)
    if global and global.race_settings then
        global.race_settings[race_setting.race] = race_setting
    end
    return nil
end

-- Return race setting
function ERM_RemoteAPI.get_race(race)
    if global and global.race_settings then
        return global.race_settings[race]
    end
    return nil
end

-- Return race tier
function ERM_RemoteAPI.get_race_tier(race)
    if global and global.race_settings and
            global.race_settings[race] and global.race_settings[race].tier then

        return global.race_settings[race].tier
    end
    return 1
end

-- -- Return race level
function ERM_RemoteAPI.get_race_level(race)
    if global.race_settings and
            global.race_settings[race] and
            global.race_settings[race].level then

        return global.race_settings[race].level
    end
    return 1
end

return ERM_RemoteAPI
