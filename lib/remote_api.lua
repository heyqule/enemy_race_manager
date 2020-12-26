--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/20/2020
-- Time: 5:36 PM
-- To change this template use File | Settings | File Templates.
--
local Table = require('__stdlib__/stdlib/utils/table')
local ERM_RemoteAPI = {}

-- Create or update race setting
function ERM_RemoteAPI.register_race(race_setting)
    global.race_settings[race_setting.race] = race_setting
end

-- Return race setting
function ERM_RemoteAPI.get_race(race)
    return global.race_settings[race]
end

-- Return race tier
function ERM_RemoteAPI.get_race_tier(race)
    if global.race_settings and
            global.race_settings[race] and
            global.race_settings[race].current_tier then

        return global.race_settings[race].current_tier
    end
    return 1
end

-- -- Return race level
function ERM_RemoteAPI.get_race_level(race)
    if global.race_settings and
            global.race_settings[race] and
            global.race_settings[race].current_level then

        return global.race_settings[race].current_level
    end
    return 1
end

return ERM_RemoteAPI
