---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/9/2024 6:19 PM
---

local TestShared = require("shared")
local Position = require("__erm_libs__/stdlib/position")

before_each(function()
    TestShared.prepare_the_factory()
end)

after_each(function()
    TestShared.reset_the_factory()
end)


it("Dropship", function()
    local surface = game.surfaces[1]
    local enemy_force = game.forces["enemy"]
    local player_force = game.forces["player"]
    local laser_entity = surface.create_entity({ name = "laser-turret", force = player_force, position = { 0, 0 } })
    local overlord = surface.create_entity({ name = "enemy_erm_zerg--overlord--1", force = enemy_force, position = { 10, 10 } })

    after_ticks(300, function()
        local unit_count = surface.count_entities_filtered({
            type="unit"
        })
        assert(unit_count > 1, "New unit spawned")
    end)
end)

it("Builder", function()
    local surface = game.surfaces[1]
    local enemy_force = game.forces["enemy"]
    local player_force = game.forces["player"]
    local laser_entity = surface.create_entity({ name = "laser-turret", force = player_force, position = { 0, 0 } })
    local overlord = surface.create_entity({ name = "enemy_erm_zerg--drone--1", force = enemy_force, position = { 10, 10 } })

    after_ticks(600, function()
        local building_count = surface.count_entities_filtered({
            type= {"unit-spawner","turret"}
        })
        assert(building_count == 1, "New building spawned")
    end)
end)

it("Timed units", function()
    async(14400)
    local surface = game.surfaces[1]
    local enemy_force = game.forces["enemy"]
    local player_force = game.forces["player"]
    local laser_entity = surface.create_entity({ name = "laser-turret", force = player_force, position = { 0, 0 } })
    local queen = surface.create_entity({ name = "enemy_erm_zerg--queen--1", force = enemy_force, position = { 10, 10 } })

    after_ticks(300, function()
        local unit_count = surface.count_entities_filtered({
            name = "enemy_erm_zerg--broodling--1"
        })
        assert(unit_count >= 1, "Has time to live unit spawned")
    end)

    after_ticks(14000, function()
        local unit_count = surface.count_entities_filtered({
            name = "enemy_erm_zerg--broodling--1"
        })
        assert(unit_count == 0, "time to live unit expired")
        done()
    end)
end)

it("Protoss: Time Unit Tree/Stone blockage test", function()
    async(7200)
    local surface = game.surfaces[1]
    local enemy_force = game.forces["enemy_erm_protoss"]
    local player_force = game.forces["player"]
    local reaver = surface.create_entity({ name = "enemy_erm_toss--reaver--1", force = enemy_force, position = { 10, 10 } })
    local stone = surface.create_entity({ name = "big-sand-rock", force = "neutral", position = { 0, 0 } })

    reaver.commandable.set_command({
        type = defines.command.attack,
        target = stone
    })
    after_ticks(180, function()
        local unit_count = surface.count_entities_filtered({
            name = "enemy_erm_toss--scarab--1"
        })
        assert(unit_count >= 1, "Has time to live unit spawned")
    end)

    after_ticks(7200, function()
        assert(stone.valid == false, "stone is still there.")
        done()
    end)
end)


it("Drop unit should based on parent entity", function()
    local surface = game.surfaces[1]
    local enemy_force = game.forces["enemy_erm_zerg"]
    local player_force = game.forces["player"]
    local laser_entity = surface.create_entity({ name = "laser-turret", force = player_force, position = { 0, 0 } })
    local overlord = surface.create_entity({ name = "enemy_erm_zerg--overlord--4", force = enemy_force, position = { 10, 10 } })

    after_ticks(600, function()
        local units = surface.find_entities_filtered({
            type="unit"
        })
        local i = 0
        for _, unit in pairs(units) do
            if (unit.force.name == enemy_force.name) then
                i = i + 1
            end
        end
        assert(i > 1, "Should have more than 1 friendly enemy unit")
        
    end)
end)

it("Drone build direction tests", function()
    async(3600)
    local surface = game.surfaces[1]
    local enemy_force = game.forces["enemy_erm_zerg"]
    local player_force = game.forces["player"]
    local gun_entity = surface.create_entity({ name = "gun-turret", force = player_force, position = { 0, 0 } })
    
    surface.create_entity({ name = "enemy_erm_zerg--drone--1", force = enemy_force, position = { 0, -20 } })
    after_ticks(600, function()
        local entities = surface.find_entities_filtered({ type={"unit-spawner","turret"}})
        local building = entities[1]
        assert(Position.manhattan_distance(gun_entity.position, entities[1].position) > 8, 'Incorrect distance')
        assert(Position.complex_direction_to(gun_entity.position, entities[1].position) == 0, 'Incorrect direction')
        building.destroy()
        
        surface.create_entity({ name = "enemy_erm_zerg--drone--1", force = enemy_force, position = { 20, 0 } })
    end)
    after_ticks(1200, function()
        local entities = surface.find_entities_filtered({ type={"unit-spawner","turret"}})
        local building = entities[1]
        assert(Position.manhattan_distance(gun_entity.position, entities[1].position) > 8, 'Incorrect distance')
        assert(Position.complex_direction_to(gun_entity.position, entities[1].position) == 4, 'Incorrect direction')
        building.destroy()

        surface.create_entity({ name = "enemy_erm_zerg--drone--1", force = enemy_force, position = {0,  20}})
    end)
    after_ticks(1800, function()
        local entities = surface.find_entities_filtered({ type={"unit-spawner","turret"}})
        local building = entities[1]
        assert(Position.manhattan_distance(gun_entity.position, entities[1].position) > 8, 'Incorrect distance')
        assert(Position.complex_direction_to(gun_entity.position, entities[1].position) == 8, 'Incorrect direction')
        building.destroy()

        surface.create_entity({ name = "enemy_erm_zerg--drone--1", force = enemy_force, position = { -20, 0 } })
    end)
    after_ticks(2400, function()
        local entities = surface.find_entities_filtered({ type={"unit-spawner","turret"}})
        local building = entities[1]
        assert(Position.manhattan_distance(gun_entity.position, entities[1].position) > 8, 'Incorrect Distance')
        assert(Position.complex_direction_to(gun_entity.position, entities[1].position) == 12, 'Incorrect direction')
        building.destroy()
        done()
    end)
end)