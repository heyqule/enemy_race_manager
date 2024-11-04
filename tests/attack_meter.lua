---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/7/2024 3:46 PM
---


local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local TestShared = require("shared")


local biter_name = "erm_vanilla--medium-biter--1" -- 1 points
local turret_name = "erm_vanilla--medium-worm-turret--1" -- 10 points
local spawner_name = "erm_vanilla--biter-spawner--1" -- 50 points
local force_name = "enemy"
local race_name = "erm_vanilla"

before_each(function()
    TestShared.prepare_the_factory()
end)

after_each(function()
    TestShared.reset_the_factory()
end)


it("Calculate attack points", function()
    async(16000)
    local surface = game.surfaces[1]
    AttackGroupBeaconProcessor.init_index()

    for i = 1, 20, 1 do
        surface.create_entity({name=biter_name,position={0,i * 10}}) -- 20
        surface.create_entity({name=turret_name,position={10,i * 10}}) -- 200
        surface.create_entity({name=spawner_name,position={20,i * 10}}) -- 1000
    end

    local entities = surface.find_entities_filtered(
        {force=force_name}
    )
    for _, entity in pairs(entities) do
        entity.die("player")
    end

    assert(1220 >= storage.race_settings[race_name].attack_meter ,"Round: Attack Meter Number")
    assert(1220 >= storage.race_settings[race_name].attack_meter_total, "Round: Accumulated Attack Meter Number")

    for i = 1, 70, 1 do
        surface.create_entity({name=biter_name,position={0,i * 10}}) -- 20
        surface.create_entity({name=turret_name,position={10,i * 10}}) -- 200
        surface.create_entity({name=spawner_name,position={20,i * 10}}) -- 1000
    end

    local entities_to_die = surface.find_entities_filtered({force=force_name})
    for _, entity in pairs(entities_to_die) do
        entity.die("player")
    end

    surface.create_entity({name=spawner_name,position={0,300}})
    AttackGroupBeaconProcessor.create_spawn_beacon_from_trunk(surface, { { -10, 295 }, { 10, 305 } })

    --- When attack group generated
    after_ticks(16000, function()
        assert(storage.race_settings[race_name].attack_meter < 5490,"Round2: Attack Meter Number should be lower after group generated")
        assert(5490 >= storage.race_settings[race_name].attack_meter_total,"Round2: Accumulated Attack Meter Number")
        done()
    end)
end)

it("Base evolution - kills-deduction true", function()
    async(7200)
    storage.settings["enemyracemanager-evolution-point-spawner-kills-deduction"] = true
    local surface = game.surfaces[1]
    AttackGroupBeaconProcessor.init_index()

    for i = 1, 100, 1 do
        surface.create_entity({name=spawner_name,position={20,i * 10}}) -- 1000
    end

    local entities = surface.find_entities_filtered({force=force_name})
    for _, entity in pairs(entities) do
        entity.die("player")
    end

    after_ticks(4000, function()
        --- technically it's -25000. But it doesn't dip into negative territory.
        --- anything under 1000 as rounding error.
        assert(storage.race_settings[race_name].attack_meter_total < 1000,"spawner-kills-deduction true")
        storage.settings["enemyracemanager-evolution-point-spawner-kills-deduction"] = false
        done()
    end)
end)

it("Time base attack", function()
    async(10800)
    local force = game.forces['enemy']
    force.set_evolution_factor(0.35, game.surfaces[1])
    AttackGroupBeaconProcessor.init_index()
    local last_minute = 0

    after_ticks(4000, function()
        assert(storage.race_settings[race_name].attack_meter > 0,"time base attack - 1st minute")
        last_minute = storage.race_settings[race_name].attack_meter
    end)

    after_ticks(7600, function()
        assert(storage.race_settings[race_name].attack_meter > last_minute,"time base attack - 2st minute")
        done()
    end)
end)

it("Time base attack - level req not met", function()
    async(10800)
    AttackGroupBeaconProcessor.init_index()

    after_ticks(4000, function()
        assert(storage.race_settings[race_name].attack_meter == 0,"time base attack - 1st minute")
    end)

    after_ticks(7600, function()
        assert(storage.race_settings[race_name].attack_meter == 0,"time base attack - 2st minute")
        done()
    end)
end)