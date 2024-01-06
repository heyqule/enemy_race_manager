---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/6/2024 6:34 PM
---

local ForceHelper = require('lib/helper/force_helper')
local LevelManager = require('lib/level_processor')
local AttackGroupBeaconProcessor = require('lib/attack_group_beacon_processor')

local TestShared = {}

function TestShared.prepare_the_factory()
    local surface = game.surfaces[1]

    for key, _ in pairs(game.forces) do
        local entities = surface.find_entities_filtered({ force = game.forces[key] })
        for _, entity in pairs(entities) do
            entity.destroy()
        end
    end

    LevelManager.reset_all_progress()
    AttackGroupBeaconProcessor.reset_globals()
end

function TestShared.reset_the_factory()
    LevelManager.reset_all_progress()
    AttackGroupBeaconProcessor.reset_globals()
end

return TestShared