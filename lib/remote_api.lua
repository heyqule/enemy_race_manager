--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/20/2020
-- Time: 5:36 PM
-- To change this template use File | Settings | File Templates.
--
local Table = require('__stdlib__/stdlib/utils/table')
local ERM_RemoteAPI = {}

function ERM_RemoteAPI.register_race(race_setting)
    if race_setting and global.race_settings then
        Table.insert(global.race_settings, race_setting)
    end
end

function ERM_RemoteAPI.get_race(race)
    return Table.find(global.race_settings, race)
end

function ERM_RemoteAPI.get_tier()
    if global.mod_settings and global.mod_settings.current_tier then
        return global.mod_settings.current_tier
    end
    return 1
end

return ERM_RemoteAPI
