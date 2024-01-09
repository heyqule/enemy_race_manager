---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/7/2024 3:46 PM
---


local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local TestShared = require('shared')


local biter_name = 'erm_vanilla/medium-biter/1' -- 1 points
local turret_name = 'erm_vanilla/medium-worm-turret/1' -- 10 points
local spawner_name = 'erm_vanilla/biter-spawner/1' -- 50 points
local force_name = 'enemy'
local race_name = 'erm_vanilla'

before_each(function()
    TestShared.prepare_the_factory()
end)

after_each(function()
    TestShared.reset_the_factory()
end)

describe("Attack Meters", function()
    it("Calculate attack points", function()
        async(24000)
        local surface = game.surfaces[1]
        AttackGroupBeaconProcessor.init_index()

        for i = 1, 20, 1 do
            surface.create_entity({name=biter_name,position={0,i * 10}}) -- 20
            surface.create_entity({name=turret_name,position={10,i * 10}}) -- 200
            surface.create_entity({name=spawner_name,position={20,i * 10}}) -- 1000
        end

        local entities = surface.find_entities_filtered({force=force_name})
        for _, entity in pairs(entities) do
            entity.die('player')
        end

        after_ticks(4200, function()
            assert.equal(1220, global.race_settings[race_name].attack_meter ,'Round: Attack Meter Number')
            assert.equal(1220, global.race_settings[race_name].attack_meter_total, 'Round: Accumulated Attack Meter Number')

            for i = 1, 70, 1 do
                surface.create_entity({name=biter_name,position={0,i * 10}}) -- 20
                surface.create_entity({name=turret_name,position={10,i * 10}}) -- 200
                surface.create_entity({name=spawner_name,position={20,i * 10}}) -- 1000
            end

            local entities_to_die = surface.find_entities_filtered({force=force_name})
            for _, entity in pairs(entities_to_die) do
                entity.die('player')
            end

            surface.create_entity({name=spawner_name,position={0,300}})
            AttackGroupBeaconProcessor.create_spawn_beacon_from_trunk(surface, { { -10, 295 }, { 10, 305 } })
        end)

        after_ticks(7800, function()
            assert(global.race_settings[race_name].attack_meter <= 5490,'Round2: Attack Meter Number')
            assert.equal(5490, global.race_settings[race_name].attack_meter_total,'Round2: Accumulated Attack Meter Number')
        end)

        --- When attack group generated
        after_ticks(22000, function()
            print(global.race_settings[race_name].attack_meter_total)
            print(global.race_settings[race_name].attack_meter)
            print(global.race_settings[race_name].next_attack_threshold)
            assert(global.race_settings[race_name].attack_meter < 5490,'Attack number after processing attack group')
            assert.equal(5490, global.race_settings[race_name].attack_meter_total,'Round3: Accumulated Attack Meter Number')
            done()
        end)
    end)

    it("Base evolution - kills-deduction true", function()
        async(7200)
        global.settings['enemyracemanager-evolution-point-spawner-kills-deduction'] = true
        local surface = game.surfaces[1]
        AttackGroupBeaconProcessor.init_index()

        for i = 1, 20, 1 do
            surface.create_entity({name=spawner_name,position={20,i * 10}}) -- 1000
        end

        local entities = surface.find_entities_filtered({force=force_name})
        for _, entity in pairs(entities) do
            entity.die('player')
        end

        after_ticks(4000, function()
            assert(global.race_settings[race_name].evolution_base_point < 0,'spawner-kills-deduction true')
            global.settings['enemyracemanager-evolution-point-spawner-kills-deduction'] = false
            done()
        end)
    end)

    it("Time base attack", function()
        async(10800)
        global.race_settings[race_name].level = 3
        AttackGroupBeaconProcessor.init_index()
        local last_minute = 0

        after_ticks(4000, function()
            assert(global.race_settings[race_name].attack_meter > 0,'time base attack - 1st minute')
            last_minute = global.race_settings[race_name].attack_meter
        end)

        after_ticks(7600, function()
            assert(global.race_settings[race_name].attack_meter > last_minute,'time base attack - 2st minute')
            done()
        end)
    end)

    it("Time base attack - level req not met", function()
        async(10800)
        AttackGroupBeaconProcessor.init_index()

        after_ticks(4000, function()
            assert(global.race_settings[race_name].attack_meter == 0,'time base attack - 1st minute')
        end)

        after_ticks(7600, function()
            assert(global.race_settings[race_name].attack_meter == 0,'time base attack - 2st minute')
            done()
        end)
    end)
end)