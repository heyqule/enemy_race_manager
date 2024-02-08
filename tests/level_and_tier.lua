---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/6/2024 5:02 PM
---

local LevelManager = require('__enemyracemanager__/lib/level_processor')
local TestShared = require('shared')
local Queue = require('__stdlib__/stdlib/misc/queue')

before_each(function()
    TestShared.prepare_the_factory()
end)

after_each(function()
    TestShared.reset_the_factory()
end)


describe("Level Manager", function()
    it("calculateLevels and calculateMutlipleLevels", function()
        global.race_settings['erm_vanilla'].evolution_base_point = 2
        LevelManager.calculateLevels()
        assert(global.race_settings['erm_vanilla'].level == 2, 'Level == 2')

        global.race_settings['erm_vanilla'].evolution_base_point = 10
        LevelManager.calculateLevels()
        assert(global.race_settings['erm_vanilla'].level == 3, 'Level == 3')

        global.race_settings['erm_vanilla'].evolution_base_point = 50
        LevelManager.calculateMultipleLevels()
        assert(global.race_settings['erm_vanilla'].level == 10, 'Level == 10')
    end)

    it("Test enemy level update", function()
        local surface = game.surfaces[1]
        local enemy_force = game.forces['enemy']
        local overlord = surface.create_entity({ name = 'erm_vanilla/biter-spawner/1', force = enemy_force, position = { 10, 10 } })
        global.race_settings['erm_vanilla'].evolution_base_point = 50
        LevelManager.calculateMultipleLevels()

        after_ticks(2, function()
            assert(global.race_settings['erm_vanilla'].level == 10, 'Level == 10')
            assert( Queue.size(global.mapproc_chunk_queue[surface.name]) > 0, 'Has map queue')
        end)

        after_ticks(1800, function()
            local entities = surface.find_entities_filtered({
                type='unit-spawner'
            })
            assert.equal('erm_vanilla/biter-spawner/10',entities[1].name, 'Correct updated unit spawner')
        end)
    end)

    it("Tiers switch", function()
        local force = game.forces['enemy']
        force.evolution_factor = 0.41
        LevelManager.calculateLevels()
        assert(global.race_settings['erm_vanilla'].tier == 2, 'Tier == 2')

        force.evolution_factor = 0.81
        LevelManager.calculateLevels()
        assert(global.race_settings['erm_vanilla'].tier == 3, 'Tier == 3')
    end)
end)