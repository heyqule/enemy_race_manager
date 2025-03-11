---***
--- Register created effect and dying effect trigger for Quality system
---
---***
local DebugHelper = require("__enemyracemanager__/lib/debug_helper")
local SharedFunctions = require("__enemyracemanager__/prototypes/shared_functions")

require("__enemyracemanager__/global")
require("__enemyracemanager__/setting-constants")

local roll_dice = {
    type = "script",
    effect_id = QUALITY_DICE_ROLL
}
local tally_point = {
    type = "script",
    effect_id = QUALITY_TALLY_POINT
}

local register_trigger = function (entity)
    if (type(entity.dying_trigger_effect) == "table") then
        table.insert(entity.dying_trigger_effect, tally_point)
    else
        entity.dying_trigger_effect = {
            tally_point
        }
    end
    
    if (type(entity.created_effect) == "table") then
        table.insert(entity.created_effect, {
            type = "direct",
            action_delivery = {
                type = "instant",
                source_effects = roll_dice
            }
        })
    else
        entity.created_effect = {
            {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    source_effects = {
                        roll_dice
                    }
                }

            }
        }
    end
end


local is_excluded_from_quality = function(name)
    local words = {"land-scout", "aerial-scout", "demolisher"}
    for _, word in pairs(words) do
        if string.find(name, word, 1, true) then
            return true
        end
    end

    return false
end

local types = {"unit-spawner", "turret", "unit"}

for _, type in pairs(types) do
    for _, entity in pairs(data.raw[type]) do
        if SharedFunctions.is_erm_unit(entity.name) or not is_excluded_from_quality(entity.name) then
            register_trigger(entity)
        end
    end
end

if mods['space-age'] then
    local types = {"segmented-unit", "spider-unit"}
    for _, type in pairs(types) do
        for _, entity in pairs(data.raw[type]) do
            if SharedFunctions.is_erm_unit(entity.name) or not is_excluded_from_quality(entity.name) then
                register_trigger(entity)
            end
        end
    end
end