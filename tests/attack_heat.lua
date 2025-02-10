---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 5/4/2024 3:46 PM
---

local TestShared = require("shared")
local AttackGroupHeatProcessor = require("__enemyracemanager__/lib/attack_group_heat_processor")
local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")

before_each(function()
    TestShared.prepare_the_factory()
    storage.is_multi_planets_game = true
    storage.skip_interplanetary_attack = true
end)

after_each(function()
    TestShared.reset_the_factory()
    TestShared.reset_surfaces()
    TestShared.reset_forces()
    AttackGroupHeatProcessor.reset_globals()
    storage.is_multi_planets_game = false
    storage.skip_interplanetary_attack = false
end)

local biter_spawner = "enemy--biter-spawner--1"
local zerg_spawner = "enemy_erm_zerg--hatchery--1"


it("When a unit killed, point adds to heat", function()
    local surface = game.surfaces[1]
    local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
    })
    biter.die("player")

    local ling = surface.create_entity({
        name=zerg_spawner,position={0, 0}, force = "enemy_erm_zerg"
    })
    ling.die("player")

    assert(storage.attack_heat["enemy"][1][1] == AttackGroupHeatProcessor.DEFAULT_VALUE, "Vanilla calculated heat incorrect")
    assert(storage.attack_heat["enemy_erm_zerg"][1][1] == AttackGroupHeatProcessor.DEFAULT_VALUE, "Zerg calculated heat incorrect")
end)

it("Heat aggregation with 2 races", function()
    local surface = game.surfaces[1]
    for i=1, 20, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end

    for i=1, 30, 1 do
        local ling = surface.create_entity({
            name=zerg_spawner,position={0, 0}, force = "enemy_erm_zerg"
        })
        ling.die("player")
    end

    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
        AttackGroupHeatProcessor.cooldown_heat(active_race)
    end

    assert(storage.attack_heat_by_surfaces["enemy"][1].heat == AttackGroupHeatProcessor.DEFAULT_VALUE * 20, "Vanilla aggregated surface value incorrect")
    assert(storage.attack_heat_by_surfaces["enemy_erm_zerg"][1].heat == AttackGroupHeatProcessor.DEFAULT_VALUE * 30, "Zerg aggregated surface value incorrect")
    assert(storage.attack_heat_by_forces["enemy"][1].heat == AttackGroupHeatProcessor.DEFAULT_VALUE * 20, "Vanilla aggregated forces value incorrect")
    assert(storage.attack_heat_by_forces["enemy_erm_zerg"][1].heat == AttackGroupHeatProcessor.DEFAULT_VALUE * 30, "Zerg aggregated forces value incorrect")
end)

it("Heat aggregation with 2 races, 3 surfaces", function()
    local surface = game.surfaces[1]
    for i=1, 10, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end

    for i=1, 10, 1 do
        local ling = surface.create_entity({
            name=zerg_spawner,position={0, 0}, force = "enemy_erm_zerg"
        })
        ling.die("player")
    end

    game.planets.vulcanus.create_surface()
    local surface = game.surfaces[2]
    for i=1, 20, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end

    game.planets.fulgora.create_surface()
    local surface = game.surfaces[3]
    for i=1, 30, 1 do
        local ling = surface.create_entity({
            name=zerg_spawner,position={0, 0}, force = "enemy_erm_zerg"
        })
        ling.die("player")
    end


    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
        AttackGroupHeatProcessor.cooldown_heat(active_race)
    end

    assert(storage.attack_heat_by_surfaces["enemy"][1].heat == AttackGroupHeatProcessor.DEFAULT_VALUE * 20, "Vanilla aggregated surface 1 value incorrect")
    assert(storage.attack_heat_by_surfaces["enemy"][2].heat == AttackGroupHeatProcessor.DEFAULT_VALUE * 10, "Vanilla aggregated surface 2 value incorrect")
    assert(storage.attack_heat_by_surfaces["enemy_erm_zerg"][1].heat == AttackGroupHeatProcessor.DEFAULT_VALUE * 30, "Zerg aggregated surface 1 value incorrect")
    assert(storage.attack_heat_by_surfaces["enemy_erm_zerg"][2].heat == AttackGroupHeatProcessor.DEFAULT_VALUE * 10, "Zerg aggregated surface 3 value incorrect")
    assert(storage.attack_heat_by_forces["enemy"][1].heat == AttackGroupHeatProcessor.DEFAULT_VALUE * 30, "Vanilla aggregated forces value incorrect")
    assert(storage.attack_heat_by_forces["enemy_erm_zerg"][1].heat == AttackGroupHeatProcessor.DEFAULT_VALUE * 40, "Zerg aggregated forces value incorrect")

    assert(storage.attack_heat["enemy"][1][1] == AttackGroupHeatProcessor.DEFAULT_VALUE * 10 - AttackGroupHeatProcessor.COOLDOWN_VALUE, "Surface 1 Cooldown is working: "..storage.attack_heat["enemy"][1][1].."--".. AttackGroupHeatProcessor.DEFAULT_VALUE * 20 - AttackGroupHeatProcessor.COOLDOWN_VALUE)
    assert(storage.attack_heat["enemy"][2][1] == AttackGroupHeatProcessor.DEFAULT_VALUE * 20 - AttackGroupHeatProcessor.COOLDOWN_VALUE, "Surface 2 Cooldown is working" .. storage.attack_heat["enemy"][2][1].."--".. AttackGroupHeatProcessor.DEFAULT_VALUE * 10 - AttackGroupHeatProcessor.COOLDOWN_VALUE)
end)

it("Select a default surface and force", function()
    assert(AttackGroupHeatProcessor.pick_surface("enemy") == game.surfaces[1], "Pick default surface")
    assert(AttackGroupHeatProcessor.pick_target("enemy") == game.forces[1], "Pick default target")
end)

it("Select a hottest force with multiple heat on a surface", function()
    local surface = game.surfaces[1]
    for i=1, 10, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end
    game.create_force("test_player_2")
    for i=1, 15, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("test_player_2")
    end
    game.create_force("test_player_3")
    for i=1, 20, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("test_player_3")
    end

    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
        AttackGroupHeatProcessor.cooldown_heat(active_race)
    end

    local picked_force = AttackGroupHeatProcessor.pick_target("enemy")
    assert( picked_force.name == game.forces["test_player_3"].name, "Pick test_player_3 target")
end)

it("Select a hottest surface with multiple surface", function()
    local surface = game.surfaces[1]
    for i=1, 10, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end

game.planets.vulcanus.create_surface()
    local surface = game.surfaces[2]
    for i=1, 20, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end

    game.planets.fulgora.create_surface()
    local surface = game.surfaces[3]
    for i=1, 30, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("player")
    end
    local rocket_launcher = surface.create_entity({ name = "erm-rocket-silo-test", force = "player", position = { 0, 0 }, raise_built=true })
    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
        AttackGroupHeatProcessor.cooldown_heat(active_race)
    end

    local picked_surface = AttackGroupHeatProcessor.pick_surface("enemy", game.forces["player"])
    assert( picked_surface.name == game.surfaces["fulgora"].name, "Pick Fulgora as surface.  It picked "..picked_surface.name)
end)

it("Select a hottest surface and force combo", function()
    game.create_force("test_player_2")
    game.create_force("test_player_3")

    local surface = game.surfaces[1]
    for i=1, 10, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end

game.planets.vulcanus.create_surface()
    local surface = game.surfaces[2]
    for i=1, 10, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_2")
    end
    for i=1, 20, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("test_player_3")
    end
    local rocket_launcher = surface.create_entity({ name = "erm-rocket-silo-test", force = "player", position = { 0, 0 }, raise_built=true })

    game.planets.fulgora.create_surface()
    local surface = game.surfaces[3]
    for i=1, 15, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_2")
    end
    for i=1, 10, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_3")
    end

    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
        AttackGroupHeatProcessor.cooldown_heat(active_race)
    end

    local picked_force = AttackGroupHeatProcessor.pick_target("enemy")
    assert( picked_force.name == game.forces["test_player_3"].name, "Pick test_player_3 target")
    local picked_surface = AttackGroupHeatProcessor.pick_surface("enemy", picked_force)
    assert( picked_surface.name == game.surfaces["vulcanus"].name, "Pick vulcanus as surface")
end)

it("Dude wiped planet 3, but his force doesn't have attack beacon on planet 3. But attackable on planet 2", function()
    game.create_force("test_player_2")
    game.create_force("test_player_3")

    local surface = game.surfaces[1]
    for i=1, 10, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end

game.planets.vulcanus.create_surface()
    local surface = game.surfaces[2]
    for i=1, 10, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_2")
    end
    for i=1, 20, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("test_player_3")
    end
    local rocket_launcher = surface.create_entity({ name = "erm-rocket-silo-test", force = "player", position = { 0, 0 }, raise_built=true })

    game.planets.fulgora.create_surface()
    local surface = game.surfaces[3]
    for i=1, 15, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_2")
    end
    for i=1, 40, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_3")
    end

    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
        AttackGroupHeatProcessor.cooldown_heat(active_race)
    end

    local picked_force = AttackGroupHeatProcessor.pick_target("enemy")
    assert( picked_force.name == game.forces["test_player_3"].name, "Pick test_player_3 target")
    local picked_surface = AttackGroupHeatProcessor.pick_surface("enemy", picked_force)
    assert( picked_surface.name == game.surfaces["vulcanus"].name, "Pick vulcanus as surface")
end)

it("Ask friend, Zerg can't attack, ask enemy to raid Surface 1", function()
    async(900)
    local surface = game.surfaces[1]
    for i=1, 10, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end
    local rocket_launcher = surface.create_entity({ name = "erm-rocket-silo-test", force = "player", position = { 0, 0 }, raise_built=true })

    game.planets.vulcanus.create_surface()
    local surface = game.surfaces[2]
    for i=1, 10, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy_erm_zerg"
        })
        ling.die("player")
    end
    for i=1, 20, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy_erm_zerg"
        })
        biter.die("player")
    end

    game.planets.fulgora.create_surface()
    local surface = game.surfaces[3]
    for i=1, 15, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy_erm_zerg"
        })
        ling.die("player")
    end
    for i=1, 40, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy_erm_zerg"
        })
        ling.die("player")
    end

    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
        AttackGroupHeatProcessor.cooldown_heat(active_race)
    end
    RaceSettingsHelper.add_to_attack_meter("enemy_erm_zerg", 1000)
    after_ticks(300, function()
        local target_force = AttackGroupHeatProcessor.pick_target("enemy_erm_zerg")
        local picked_surface = AttackGroupHeatProcessor.pick_surface("enemy_erm_zerg", target_force, true)
        assert( picked_surface == nil, "Couldnt pick surface, asking for friend")
        --- Check friend attack points.
        assert(RaceSettingsHelper.get_attack_meter("enemy") > RaceSettingsHelper.get_attack_meter("enemy_erm_zerg"), "enemy needs attack point")
        assert(RaceSettingsHelper.get_attack_meter("enemy_erm_zerg") < RaceSettingsHelper.get_attack_meter("enemy"), "enemy_erm_zerg needs give out points")
        done()
    end)
end)

it("Remove Surface", function()
    async(900)
    game.create_force("test_player_2")
    game.create_force("test_player_3")

    local surface = game.surfaces[1]
    for i=1, 10, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end

game.planets.vulcanus.create_surface()
    local surface = game.surfaces[2]
    for i=1, 10, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_2")
    end
    for i=1, 20, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("test_player_3")
    end
    local rocket_launcher = surface.create_entity({ name = "erm-rocket-silo-test", force = "player", position = { 0, 0 }, raise_built=true })

    game.planets.fulgora.create_surface()
    local surface3 = game.surfaces[3]
    for i=1, 15, 1 do
        local ling = surface3.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_2")
    end
    for i=1, 40, 1 do
        local ling = surface3.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_3")
    end

    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
        AttackGroupHeatProcessor.cooldown_heat(active_race)
    end

    local removed_surface_index = surface3.index
    game.delete_surface("fulgora")
    after_ticks(900, function()
        assert( storage.attack_heat["enemy"][removed_surface_index] == nil, "Fulgora has attack heat data")
        done()
    end)
end)

it("Remove Player Force", function()
    async(900)
    local force2 = game.create_force("test_player_2")
    local force3 = game.create_force("test_player_3")

    local surface = game.surfaces[1]
    for i=1, 10, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("player")
    end

game.planets.vulcanus.create_surface()
    local surface = game.surfaces[2]
    for i=1, 10, 1 do
        local ling = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_2")
    end
    for i=1, 20, 1 do
        local biter = surface.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        biter.die("test_player_3")
    end
    local rocket_launcher = surface.create_entity({ name = "erm-rocket-silo-test", force = "player", position = { 0, 0 }, raise_built=true })

    game.planets.fulgora.create_surface()
    local surface3 = game.surfaces[3]
    for i=1, 15, 1 do
        local ling = surface3.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_2")
    end
    for i=1, 40, 1 do
        local ling = surface3.create_entity({
            name=biter_spawner,position={0, 0}, force = "enemy"
        })
        ling.die("test_player_3")
    end

    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
        AttackGroupHeatProcessor.cooldown_heat(active_race)
    end

    local force2_index = force2.index
    game.merge_forces("test_player_2", "test_player_3" )

    after_ticks(900, function()
        assert( storage.attack_heat["enemy"][surface3.index][force2_index] == nil, "Force 2 has attack heat data")
        done()
    end)
end)
