---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/25/2020 10:43 AM
---
--- require('__enemyracemanager__/lib/helper/force_helper')
---

local String = require('__stdlib__/stdlib/utils/string')

local ForceHelper = {}
-- Remove prefix enemy_ if force isn't enemy
function ForceHelper.extract_race_name_from(force_name)
    if force_name == 'enemy' then
        return MOD_NAME
    end
    return String.gsub(force_name, 'enemy_', '')
end

-- Checks enemy_erm_ prefix
function ForceHelper.is_erm_unit(entity)
    return String.find(entity.name, 'erm_')
end

function ForceHelper.set_friends(game, force_name)
    for name, force in pairs(game.forces) do
        if String.find(force.name, 'enemy') then
            force.set_friend(force_name, true);
            force.set_friend('enemy', true);
        end
    end
end

function ForceHelper.getNameToken(name)
    if not String.find(name, '/') then
        return { MOD_NAME, name, '1' }
    end
    return String.split(name, '/')
end

return ForceHelper