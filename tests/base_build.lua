---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/8/2024 9:30 PM
---

local TestShared = require('shared')
local BaseBuildProcessor = require('__enemyracemanager__/lib/base_build_processor')

local enemy_force = 'enemy_erm_zerg'
local function spawn_units(surface,name)
    local unit_group = surface.create_unit_group {
        position={0,2},
        force = enemy_force
    }
    for i=1,20,1 do
        local unit = surface.create_entity({
            name=name,
            position={0,0},
            force = enemy_force
        })
        unit_group.add_member(unit)
    end
    unit_group.set_command {
        type = defines.command.build_base,
        destination={3,3},
    }
    return unit_group
end

before_each(function()
    TestShared.prepare_the_factory()
end)

after_each(function()
    TestShared.reset_the_factory()
end)

describe("Base Building", function()
    it("Default", function()
        global.settings['enemyracemanager-build-style'] = BUILDING_DEFAULT
        local surface = game.surfaces[1]
        local name = 'erm_zerg/zergling/1'
        local building = surface.create_entity({
            name='erm_zerg/hatchery/1',
            position={0,0},
            force = enemy_force
        })
        spawn_units(surface,name)
        BaseBuildProcessor.exec(building)

        after_ticks(300, function()
            local count = surface.count_entities_filtered({
                type="unit-spawner",
                force = enemy_force
            })
            assert(count == 1, 'Only 1 spawner')
        end)
    end)
    it("Command Center / Build a town", function()
        global.settings['enemyracemanager-build-style'] = BUILDING_EXPAND_ON_CMD
        local surface = game.surfaces[1]
        local name = 'erm_zerg/zergling/1'
        local building = surface.create_entity({
            name='erm_zerg/hatchery/1',
            position={0,0},
            force = enemy_force
        })
        local unit_group = spawn_units(surface,name)
        BaseBuildProcessor.exec(building)
        after_ticks(3500, function()
            local count = surface.count_entities_filtered({
                type="unit-spawner",
                force = enemy_force
            })
            local turret_count = surface.count_entities_filtered({
                type="turret",
                force = enemy_force
            })
            local unit_count = table_size(unit_group.members)
            assert(count > 1, 'spawners spawned')
            assert(turret_count > 1, 'turrets spawned')
            assert(unit_count > 1, 'building units remained')
        end)
    end)
    it("Build a town", function()
        global.settings['enemyracemanager-build-style'] = BUILDING_A_TOWN
        local surface = game.surfaces[1]
        local name = 'erm_zerg/zergling/1'
        local building = surface.create_entity({
            name='erm_zerg/hatchery/1',
            position={20,20},
            force = enemy_force
        })
        local unit_group = spawn_units(surface,name)
        BaseBuildProcessor.exec(building)
        after_ticks(3500, function()
            local count = surface.count_entities_filtered({
                type="unit-spawner",
                force = enemy_force
            })
            local turret_count = surface.count_entities_filtered({
                type="turret",
                force = enemy_force
            })
            local unit_count = table_size(unit_group.members)
            assert(count > 1, 'spawners spawned')
            assert(turret_count > 1, 'turrets spawned')
            assert(unit_count > 1, 'building units remained')
        end)
    end)
    it("Fully Expansion", function()
        global.settings['enemyracemanager-build-style'] = BUILDING_EXPAND_ON_ARRIVAL
        local surface = game.surfaces[1]
        local name = 'erm_zerg/zergling/1'
        local building = surface.create_entity({
            name='erm_zerg/hatchery/1',
            position={0,0},
            force = enemy_force
        })
        local unit_group = spawn_units(surface,name)
        BaseBuildProcessor.exec(building)
        after_ticks(3500, function()
            local count = surface.count_entities_filtered({
                type="unit-spawner",
                force = enemy_force
            })
            local turret_count = surface.count_entities_filtered({
                type="turret",
                force = enemy_force
            })
            assert(count > 6, 'more than 6 spawner spawned')
            assert(turret_count > 6, 'more than 6 turret spawned')
            assert.falsy(unit_group.valid, 'builder group disbanded')
        end)
    end)
end)