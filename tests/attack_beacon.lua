---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/31/2023 3:22 PM
---


local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local TestShared = require('shared')

local SCAN_DISTANCE = { 700, 1500, 2200, 3000, 3800, 4800 }
local NOT_SCAN_DISTANCE = {5200, 6400}
local RADIUS_SCAN_DISTANCE = {512, 1200}
local SCAN_HALF_WIDTH = 160
local directions = {0,2,4,6}

local bounding_box_calc = {
    [defines.direction.north] = function(target_position, range)
        return {
            { target_position.x - SCAN_HALF_WIDTH, target_position.y - range[2] },
            { target_position.x + SCAN_HALF_WIDTH, target_position.y - range[1] },
        }
    end,
    [defines.direction.east] = function(target_position, range)
        return {
            { target_position.x + range[1], target_position.y - SCAN_HALF_WIDTH },
            { target_position.x + range[2], target_position.y + SCAN_HALF_WIDTH },
        }
    end,
    [defines.direction.south] = function(target_position, range)
        return {
            { target_position.x - SCAN_HALF_WIDTH, target_position.y + range[1] },
            { target_position.x + SCAN_HALF_WIDTH, target_position.y + range[2] },
        }
    end,
    [defines.direction.west] = function(target_position, range)
        return {
            { target_position.x - range[2], target_position.y - SCAN_HALF_WIDTH },
            { target_position.x - range[1], target_position.y + SCAN_HALF_WIDTH },
        }
    end
}

local test_locations = {
    [defines.direction.north] = function(range)
        return {x=0, y=range*-1}
    end,
    [defines.direction.east] = function(range)
        return {x=range, y=0}
    end,
    [defines.direction.south] = function(range)
        return {x=0, y=range}
    end,
    [defines.direction.west] = function(range)
        return {x=range*-1, y=0}
    end
}

before_each(function()
    TestShared.prepare_the_factory()
end)

after_each(function()
    TestShared.reset_the_factory()
end)

-- you can have many nested describe blocks:
describe("Create Beacon", function()
    it("Land Scout", function()
        local surface = game.surfaces[1]
        local force = game.forces['enemy']
        local player_force = game.forces['player']
        local laser_entity = surface.create_entity({ name = 'laser-turret', force = player_force, position = { 10, 10 } })
        local second_laser_entity = surface.create_entity({ name = 'laser-turret', force = player_force, position = { 15, 15 } })
        local entity = surface.create_entity({ name = 'erm_vanilla/land_scout/1', force = 'enemy', position = { 12, 12 } })
        entity.die(player_force)
        local land_beacons = surface.find_entities_filtered({ name = 'erm_land_beacon' })
        assert.not_nil(land_beacons, 'Beacon created')
        assert.equal(land_beacons[1].health, 2, 'Beacon health matches')
    end)

    it("Aerial Scout", function()
        local surface = game.surfaces[1]
        local force = game.forces['enemy']
        local player_force = game.forces['player']
        local laser_entity = surface.create_entity({ name = 'laser-turret', force = player_force, position = { 10, 10 } })
        local second_laser_entity = surface.create_entity({ name = 'laser-turret', force = player_force, position = { 15, 15 } })
        local entity = surface.create_entity({ name = 'erm_vanilla/aerial_scout/1', force = 'enemy', position = { 12, 12 } })
        entity.die(player_force)
        local aerial_beacons = surface.find_entities_filtered({ name = 'erm_aerial_beacon' })
        assert.not_nil(aerial_beacons, 'Beacon created')
        assert.equal(aerial_beacons[1].health, 2, 'Beacon health matches')
    end)

    it("Attackable Entity Scout", function()
        local surface = game.surfaces[1]
        local force = game.forces['enemy']
        local player_force = game.forces['player']
        local laser_entity = surface.create_entity({ name = 'artillery-turret', force = player_force, position = { 10, 10 } })
        local second_laser_entity = surface.create_entity({ name = 'artillery-turret', force = player_force, position = { 15, 15 } })
        local entity = surface.create_entity({ name = 'erm_vanilla/land_scout/1', force = 'enemy', position = { 12, 12 } })
        entity.die(player_force)
        local attackable_entity_beacon = surface.find_entities_filtered({ name = 'erm_attackable_entity_beacon' })
        assert.not_nil(attackable_entity_beacon, 'Beacon created')
        assert.equal(attackable_entity_beacon[1].health, 2, 'Beacon health matches')
    end)

    it("Resource Beacon on finite node", function()
        local surface = game.surfaces[1]

        for x = 25, 40, 1 do
            for y = 20, 50, 1 do
                surface.create_entity({ name = 'iron-ore', position = { x, y } })
            end
        end
        local iron_ores = surface.count_entities_filtered({ name = 'iron-ore' })
        assert(iron_ores > 10, 'Iron Ore Created')

        AttackGroupBeaconProcessor.create_resource_beacon_from_trunk(surface, { { 25, 20 }, { 65, 70 } })

        local resource_beacon = surface.count_entities_filtered({ name = 'erm_resource_beacon' })
        assert(resource_beacon == 1, 'Resource Beacon Created')
    end)

    it("Resource Beacon on infinite node", function()
        local surface = game.surfaces[1]
        surface.create_entity({ name = 'crude-oil', position = { 20, 20 } })

        local crude_oil = surface.count_entities_filtered({ name = 'crude-oil' })
        assert(crude_oil == 1, 'Crude Oil Created')

        AttackGroupBeaconProcessor.create_resource_beacon_from_trunk(surface, { { 15, 15 }, { 25, 25 } })
        local resource_beacon = surface.count_entities_filtered({ name = 'erm_resource_beacon' })
        assert(resource_beacon == 1, 'Resource Beacon Created')
    end)

    it("create_spawn_beacon_from_trunk()", function()
        local surface = game.surfaces[1]
        surface.create_entity({ name = 'erm_vanilla/biter-spawner/1', position = { 20, 20 } })

        local spawner = surface.count_entities_filtered({ type = 'unit-spawner' })
        assert(spawner == 1, 'Spawner Created')

        AttackGroupBeaconProcessor.create_spawn_beacon_from_trunk(surface, { { 15, 15 }, { 25, 25 } })
        local spawner_beacon = surface.count_entities_filtered({ name = 'erm_spawn_beacon' })
        assert(spawner_beacon == 1, 'Spawner Beacon Created')
    end)

    it("create_attack_entity_beacon_from_trunk()", function()
        local surface = game.surfaces[1]
        local laser_entity = surface.create_entity({ name = 'artillery-turret', force = 'player', position = { 10, 10 } })
        local rocket_launcher = surface.create_entity({ name = 'rocket-silo', force = 'player', position = { 20, 20 } })

        AttackGroupBeaconProcessor.create_attack_entity_beacon_from_trunk(surface, { { 5, 5 }, { 25, 25 } })
        local attack_beacons = surface.find_entities_filtered({ name = 'erm_attackable_entity_beacon' })
        assert.not_nil(attack_beacons, 'Beacon created')
        assert.equal(attack_beacons[1].health, 2, 'Beacon health matches')
    end)

end)
describe("Surfaces and Forces", function()

    it("Test surface create/clear/delete", function()
        local surface_name = 'test_surface_2'
        local surface = game.create_surface(surface_name)
        local surface_index = surface.index
        assert(#game.surfaces == 2, 'Surface Number Match')

        surface.request_to_generate_chunks({ 0, 0 }, 5)
        surface.force_generate_chunk_requests()

        local control_data = AttackGroupBeaconProcessor.get_control_data(surface.index)
        assert.equal('table', type(control_data), 'Valid Surface Control Data')
        assert.equal('table', type(control_data['enemy']), 'Valid Surface Force Control Data')

        local beacon_data = AttackGroupBeaconProcessor.get_beacon_data(AttackGroupBeaconProcessor.RESOURCE_BEACON, surface.index)
        assert.equal('table', type(beacon_data), 'Valid Beacon Data')

        surface.clear()

        control_data = AttackGroupBeaconProcessor.get_control_data(surface.index)
        assert.equal('table', type(control_data), 'Valid Surface Control Data')
        assert.equal('table', type(control_data['enemy']), 'Valid Surface Force Control Data')

        beacon_data = AttackGroupBeaconProcessor.get_beacon_data(AttackGroupBeaconProcessor.RESOURCE_BEACON, surface.index)
        assert.equal('table', type(beacon_data), 'Valid Beacon Data')

        game.delete_surface(surface_name)
        after_ticks(60, function()
            control_data = AttackGroupBeaconProcessor.get_control_data(surface_index)
            assert.equal(nil, control_data, 'Surface data is nil')

            beacon_data = AttackGroupBeaconProcessor.get_beacon_data(AttackGroupBeaconProcessor.RESOURCE_BEACON, surface_index)
            assert.equal(nil, beacon_data, 'Valid Beacon Data')
        end)
    end)

    it("Test add force and merge", function()
        local force_name = 'enemy_101';
        local force = game.create_force(force_name)
        local surface = game.surfaces[1]

        local control_data = AttackGroupBeaconProcessor.get_control_data(surface.index, force.name)
        assert.equal('table', type(control_data), 'Valid Force Control Data')

        game.merge_forces(force_name, 'player')
        after_ticks(60, function()
            control_data = AttackGroupBeaconProcessor.get_control_data(surface.index, force_name)
            assert.equal(nil, control_data, 'Valid Force Control Data')
        end)
    end)
end)

describe("Pick Attack Entity Beacon", function()
    it("attack beacons", function()
        AttackGroupBeaconProcessor.init_index()
        local surface = game.surfaces[1]
        local rocket_launcher = surface.create_entity({ name = 'rocket-silo', force = 'player', position = { 100, 100 } })
        local success = AttackGroupBeaconProcessor.create_attack_entity_beacon_from_trunk(surface, { { 90, 90 }, { 110, 110 } })

        local enemy = game.forces['enemy']
        local player = game.forces['player']
        local target_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(surface, enemy, player)
        assert.equal(true, target_beacon.is_spawn,'SPAWN ATTACK BEACON')

        target_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(surface, enemy, player)
        assert.equal(true, target_beacon.is_spawn,'Pick same attack beacon')

        target_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(surface, enemy, player, true)
        assert.equal(nil, target_beacon.is_spawn, 'Pick the next beacon')
    end)

    it("next attackable target", function()
        local surface = game.surfaces[1]
        local rocket_launcher = surface.create_entity({ name = 'rocket-silo', force = 'player', position = { 100, 100 } })
        local position = AttackGroupBeaconProcessor.pick_nearby_attack_location(surface, {x=0, y=0})
        assert.not_nil(position, 'Has next attack target')
    end)
end)

describe("Pick Spawn beacon", function()

    for _, direction in pairs(directions) do
        for tier, range in pairs(SCAN_DISTANCE) do
            it("Spawn beacon @ D:"..tostring(direction)..'/T:'..tostring(tier)..'/R:'..tostring(range),function()
                AttackGroupBeaconProcessor.init_index()
                local surface = game.surfaces[1]

                surface.request_to_generate_chunks(test_locations[direction](math.floor(range/32)),3)
                surface.force_generate_chunk_requests()

                local test_location = test_locations[direction](range)
                local entity = surface.create_entity({ name = 'erm_vanilla/biter-spawner/1', position = test_location })
                local created_beacon = AttackGroupBeaconProcessor.create_spawn_beacon_from_trunk(surface, {
                    {test_location.x-15, test_location.y-15 },
                    {test_location.x+15, test_location.y+15}
                })

                local enemy = game.forces['enemy']
                local player = game.forces['player']
                local target_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(surface, enemy, player)

                local spawn_location            
                spawn_location = AttackGroupBeaconProcessor.pick_spawn_location(surface, enemy, target_beacon)
                
                if not spawn_location then
                    for i = 0, (AttackGroupBeaconProcessor.get_max_tiers() * #directions) - 1, 1 do
                        spawn_location = AttackGroupBeaconProcessor.pick_spawn_location(surface, enemy, target_beacon, true)
                        if spawn_location then
                            break
                        end
                    end                        
                end
                assert.not_nil(spawn_location, 'Need spawn location')
            end)
        end
    end

    for _, range in pairs(NOT_SCAN_DISTANCE) do

        it("not valid range @ "..range, function()
            local direction = 0
            AttackGroupBeaconProcessor.init_index()
            local surface = game.surfaces[1]

            surface.request_to_generate_chunks(test_locations[direction](math.floor(range/32)),3)
            surface.force_generate_chunk_requests()

            local test_location = test_locations[direction](range)
            local entity = surface.create_entity({ name = 'erm_vanilla/biter-spawner/1', position = test_location })
            local created_beacon = AttackGroupBeaconProcessor.create_spawn_beacon_from_trunk(surface, {
                {test_location.x-15, test_location.y-15 },
                {test_location.x+15, test_location.y+15}
            })
            local spawner_beacon = surface.count_entities_filtered({ name = 'erm_spawn_beacon' })
            assert(spawner_beacon == 1, 'Has Spawner Beacon')

            local enemy = game.forces['enemy']
            local player = game.forces['player']
            local target_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(surface, enemy, player)

            local spawn_location
            spawn_location = AttackGroupBeaconProcessor.pick_spawn_location(surface, enemy, target_beacon)

            if not spawn_location then
                for i = 0, (AttackGroupBeaconProcessor.get_max_tiers() * #directions) - 1, 1 do
                    --- Disable fallback to test this.
                    spawn_location = AttackGroupBeaconProcessor.pick_spawn_location(surface, enemy, target_beacon, true, false)
                    if spawn_location then
                        break
                    end
                end
            end

            assert.is_nil(spawn_location, 'Should not able to find spawn location')
        end)
    end

    for _, radius in pairs(RADIUS_SCAN_DISTANCE) do
        it("fallback radius @ "..radius, function()
            local direction = 0
            AttackGroupBeaconProcessor.init_index()
            local surface = game.surfaces[1]

            surface.request_to_generate_chunks(test_locations[direction](math.floor(radius/32)),3)
            surface.force_generate_chunk_requests()

            local test_location = {x=radius, y=radius}
            local entity = surface.create_entity({ name = 'erm_vanilla/biter-spawner/1', position = test_location })
            local created_beacon = AttackGroupBeaconProcessor.create_spawn_beacon_from_trunk(surface, {
                {test_location.x-15, test_location.y-15 },
                {test_location.x+15, test_location.y+15}
            })
            local spawner_beacon = surface.count_entities_filtered({ name = 'erm_spawn_beacon' })
            assert(spawner_beacon == 1, 'Has Spawner Beacon')

            local enemy = game.forces['enemy']
            local player = game.forces['player']
            local target_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(surface, enemy, player)

            local spawn_location
            spawn_location = AttackGroupBeaconProcessor.pick_spawn_location(surface, enemy, target_beacon)

            if not spawn_location then
                for i = 0, (AttackGroupBeaconProcessor.get_max_tiers() * #directions) - 1, 1 do
                    spawn_location = AttackGroupBeaconProcessor.pick_spawn_location(surface, enemy, target_beacon, true)
                    if spawn_location then
                        break
                    end
                end
            end

            if radius < 1024 then
                assert.not_nil(spawn_location, 'Need spawn location')
            else
                assert.is_nil(spawn_location, 'Should not able to find spawn location')
            end
        end)
    end
end)

describe("Pick Resource Beacon", function()
    it("Crude Oil",function()
        AttackGroupBeaconProcessor.init_index()
        local surface = game.surfaces[1]

        for i = 1, 10, 1 do
            local entity = surface.create_entity({ name = 'crude-oil', position = { i * 80, 0 } })
            AttackGroupBeaconProcessor.create_resource_beacon_from_trunk(surface, { { i * 80 - 10, -10 }, { i * 80+10, 10 } })

            surface.request_to_generate_chunks({x=math.floor( i * 80/32), y=0},2)
            surface.force_generate_chunk_requests()
        end

        local entities = surface.find_entities_filtered({ name = 'erm_resource_beacon'})
        assert(table_size(entities) >= 10 , 'Has at least 10 resource beacons')

        local position = AttackGroupBeaconProcessor.pick_resource_location(surface, {x=0,y=0}, defines.direction.east)
        assert.not_nil(position, 'Found a position')
        assert.is_true(position.x == 801, 'Picking the furthest position')
    end)
end)

describe("Modify", function()
    it("Delete Defense Beacon",function()
        async(30)
        local surface = game.surfaces[1]
        local player_force = game.forces[1]
        local laser_entity = surface.create_entity({ name = 'laser-turret', force = player_force, position = { 10, 10 } })

        local land_scout = surface.create_entity({ name = 'erm_vanilla/land_scout/1', position = { 0, 0 } })
        land_scout.die('player')

        local land_beacons = surface.find_entities_filtered({ name = 'erm_land_beacon' })
        local beacon = land_beacons[1]
        local beacon_number = beacon.unit_number

        assert.is_true(beacon.valid, 'Beacon is valid')
        assert(type(global['erm_land_beacon'][1]['enemy'][beacon_number]) == 'table', "beacon data exist")
        laser_entity.die('player')

        after_ticks(30, function()
            local land_scout = surface.create_entity({ name = 'erm_vanilla/land_scout/1', position = { 0, 0 } })
            land_scout.die('player')

            assert.is_false(beacon.valid, 'Beacon is invalid after killed')
            assert(global['erm_land_beacon'][1]['enemy'][beacon_number] == nil, "global is nil")
            done()
        end)
    end)

    it("Update Defense Beacon",function()
        async(30)
        local surface = game.surfaces[1]
        local force = game.forces['enemy']
        local player_force = game.forces['player']
        local laser_entity = surface.create_entity({ name = 'laser-turret', force = player_force, position = { 10, 10 } })
        local second_laser_entity = surface.create_entity({ name = 'laser-turret', force = player_force, position = { 15, 15 } })
        local land_scout = surface.create_entity({ name = 'erm_vanilla/land_scout/1', position = { 0, 0 } })
        land_scout.die('player')
        local land_beacons = surface.find_entities_filtered({ name = 'erm_land_beacon' })
        assert(land_beacons[1].health == 2, 'Beacon health not match, should be 2')

        second_laser_entity.die('player')

        after_ticks(30, function()
            local land_scout = surface.create_entity({ name = 'erm_vanilla/land_scout/1', position = { 0, 0 } })
            land_scout.die('player')
            local land_beacons = surface.find_entities_filtered({ name = 'erm_land_beacon' })

            assert(land_beacons[1].health == 1, 'Beacon health not match, should be 1')

            done()
        end)
    end)

    it("Update Spawner Beacon",function()
        local surface = game.surfaces[1]
        local enemy = game.forces['enemy']
        local player = game.forces['player']
        local spawner1 = surface.create_entity({ name = 'erm_vanilla/biter-spawner/1', position = { 190, 0 } })
        local spawner2 = surface.create_entity({ name = 'erm_vanilla/biter-spawner/1', position = { 200, 0 } })
        local spawner3 = surface.create_entity({ name = 'erm_vanilla/biter-spawner/1', position = { 210, 0 } })
        local created_beacon = AttackGroupBeaconProcessor.create_spawn_beacon_from_trunk(surface, {
            {180, 0 },
            {200, 0}
        })
        local rocket_launcher = surface.create_entity({ name = 'rocket-silo', force = player, position = { 0, 0 }, raise_built = true })

        after_ticks(300, function()
            local spawn_beacons = surface.count_entities_filtered({ name = 'erm_spawn_beacon' })
            assert(spawn_beacons == 1, 'Spawner beach exists')
            spawner3.die(player)

            local target_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(surface, enemy, player)
            local spawn_location
            spawn_location = AttackGroupBeaconProcessor.pick_spawn_location(surface, enemy, target_beacon)

            if not spawn_location then
                for i = 0, (AttackGroupBeaconProcessor.get_max_tiers() * #directions) - 1, 1 do
                    spawn_location = AttackGroupBeaconProcessor.pick_spawn_location(surface, enemy, target_beacon, true)
                    if spawn_location then
                        break
                    end
                end
            end
        end)

        after_ticks(600, function()
            local spawn_beacons = surface.count_entities_filtered({ name = 'erm_spawn_beacon' })
            assert(spawn_beacons == 1, 'Spawner beacon still exists')
            done()
        end)
    end)

    it("Delete Spawner Beacon",function()
        local surface = game.surfaces[1]
        local enemy = game.forces['enemy']
        local player = game.forces['player']
        local spawner2 = surface.create_entity({ name = 'erm_vanilla/biter-spawner/1', position = { 0, 200 }})
        local created_beacon = AttackGroupBeaconProcessor.create_spawn_beacon_from_trunk(surface, {
            {-10, 180 },
            {10, 200}
        })
        local rocket_launcher = surface.create_entity({ name = 'rocket-silo', force = 'player', position = { 0, 0 }, raise_built = true  })

        after_ticks(300, function()
            local spawn_beacons = surface.count_entities_filtered({ name = 'erm_spawn_beacon' })
            assert(spawn_beacons == 1, 'Spawner beacon exists')
            spawner2.die(player)

            local target_beacon = AttackGroupBeaconProcessor.pick_attack_beacon(surface, enemy, player)
            local spawn_location
            spawn_location = AttackGroupBeaconProcessor.pick_spawn_location(surface, enemy, target_beacon)

            if not spawn_location then
                for i = 0, (AttackGroupBeaconProcessor.get_max_tiers() * #directions) - 1, 1 do
                    spawn_location = AttackGroupBeaconProcessor.pick_spawn_location(surface, enemy, target_beacon, true)
                    if spawn_location then
                        break
                    end
                end
            end
        end)

        after_ticks(600, function()

            local spawn_beacons = surface.count_entities_filtered({ name = 'erm_spawn_beacon' })
            assert(spawn_beacons == 0, 'Spawner beacon should not exists')
            done()
        end)
    end)
end)