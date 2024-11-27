
local TestShared = require("shared")
local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local EnvironmentalAttacks = require("__enemyracemanager__/lib/environmental_attacks")


before_each(function()
    TestShared.prepare_the_factory()
    storage.erm_unit_groups = {}
    EnvironmentalAttacks.reset_global()
end)

after_each(function()
    TestShared.reset_the_factory()
    storage.erm_unit_groups = {}
    EnvironmentalAttacks.reset_global()
    storage.override_environmental_attack_can_spawn = nil
    storage.override_environmental_attack_spawn_base = nil
end)


it("Attack Target", function()
    async(1200)
    local surface = game.surfaces[1]
    local rocket_launcher = surface.create_entity(
            { name = "erm-rocket-silo-test",
              force = "player",
              position = { 0, 0 }
            })
    AttackGroupBeaconProcessor.init_index()

    storage.override_environmental_attack_can_spawn = true
    storage.override_environmental_attack_spawn_base = false

    local meteor = surface.create_entity({ name = "erm-test-meteor",
         force = "neutral",
         position = { 100, 100 },
         target = {50, 50},
         speed = 0.5 })

    after_ticks(1200, function()
        local count = surface.count_entities_filtered({
            type={"unit"},
            position={0,0},
            radius = 100
        })
        assert(count > 1, "Has attack unit or spawner near the base")

        done()
    end)
end)

it("Build Base", function()
    async(900)
    local surface = game.surfaces[1]
    local rocket_launcher = surface.create_entity(
            { name = "erm-rocket-silo-test",
              force = "player",
              position = { 0, 0 }
            })
    AttackGroupBeaconProcessor.init_index()

    storage.override_environmental_attack_can_spawn = true
    storage.override_environmental_attack_spawn_base = true

    local meteor = surface.create_entity(
            { name = "erm-test-meteor",
              force = "neutral",
              position = { 120, 120 },
              target = {100, 100},
              speed = 0.5 })

    after_ticks(900, function()
        local count = surface.count_entities_filtered({
            type="unit-spawner",
            target = {100, 100},
            radius = 32
        })
        assert(count > 0, "Has unit spawner near the spawn location")
        done()
    end)
end)

it("Can't spawn", function()
    async(900)
    local surface = game.surfaces[1]
    local rocket_launcher = surface.create_entity(
            { name = "erm-rocket-silo-test",
              force = "player",
              position = { 0, 0 }
            })
    AttackGroupBeaconProcessor.init_index()

    storage.override_environmental_attack_can_spawn = false
    storage.override_environmental_attack_spawn_base = false

    local meteor = surface.create_entity(
            { name = "erm-test-meteor",
              force = "neutral",
              position = { 100, 100 },
              target = {80, 80},
              speed = 0.5 })

    after_ticks(900, function()
        local count = surface.count_entities_filtered({
            type="unit",
        })
        assert(count == 0, "Should not have unit on the surface, you have: "..count)
        done()
    end)
end)
