
local TestShared = require('shared')

local TestShared = require('shared')
local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local InterplanetaryAttacks = require('__enemyracemanager__/lib/interplanetary_attacks')
local AttackGroupHeatProcessor = require('__enemyracemanager__/lib/attack_group_heat_processor')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')


before_each(function()
    TestShared.prepare_the_factory()
    TestShared.reset_surfaces()
    TestShared.reset_forces()
    InterplanetaryAttacks.reset_globals()
    global.erm_unit_groups = {}
    global.is_multi_planets_game = true
    global.override_interplanetary_attack_enabled = true
    global.override_interplanetary_attack_roll_bypass = true
    global.override_ask_friend = false
end)

after_each(function()
    TestShared.reset_the_factory()
    TestShared.reset_surfaces()
    TestShared.reset_forces()
    InterplanetaryAttacks.reset_globals()
    global.erm_unit_groups = {}
    global.override_interplanetary_attack_roll_bypass = nil
    global.is_multi_planets_game = false
    global.override_interplanetary_attack_enabled = false
    global.override_interplanetary_attack_roll_bypass = false
    global.override_ask_friend = nil
end)


local race_name = 'erm_zerg'
local enemy_force_name = 'enemy_erm_zerg'

it("Interplanetary Attack: Attack Target", function()
    async(18000)
    local surface = game.surfaces[1]
    local player = game.forces['player']
    surface.request_to_generate_chunks({ 0, 0 }, 25)
    surface.force_generate_chunk_requests()
    AttackGroupBeaconProcessor.init_index()
    for i=1,24,1 do
        InterplanetaryAttacks.scan(surface)
    end
    global.race_settings[race_name].level = 20
    global.race_settings[race_name].tier = 3
    global.race_settings[race_name].attack_meter = 3000
    global.race_settings[race_name].next_attack_threshold = 3000


    after_ticks(1800, function()
        InterplanetaryAttacks.exec(race_name, player)
    end)

    after_ticks(18000, function()
        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = 'unit',
            force = enemy_force_name
        })
        assert(table_size(entities) > 0,'Has units')

        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = 'unit-spawner',
            force = 'enemy_erm_zerg'
        })
        assert(table_size(entities) > 0,'Has victory expansion')

        assert(    global.race_settings[race_name].attack_meter < 3000, 'Attack point successfully deducted')
        done()
    end)
end)

it("Interplanetary Attack: No friends, have to launch attack", function()
    async(36000)
    local surface = game.surfaces[1]
    local surface2 = game.create_surface('test_surface_2')
    global.interplanetary_intel[surface2.index]   = {
        radius = 900000,
        type = 'planet',
        se_fetch_on = game.tick,
        defense = 0,
        has_player_entities = true,
    }
    local player = game.forces['player']
    surface.request_to_generate_chunks({ 0, 0 }, 25)
    surface.force_generate_chunk_requests()
    AttackGroupBeaconProcessor.init_index()
    for i=1,24,1 do
        InterplanetaryAttacks.scan(surface)
    end
    global.race_settings[race_name].level = 20
    global.race_settings[race_name].tier = 3
    global.race_settings[race_name].attack_meter = 3000
    global.race_settings[race_name].next_attack_threshold = 3000

    AttackGroupHeatProcessor.calculate_heat(race_name, surface.index, player.index, 300)
    for active_race, _ in pairs(global.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
    end

    after_ticks(36000, function()
        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = 'unit',
            force = enemy_force_name
        })
        assert(table_size(entities) > 0,'Has units')

        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = 'unit-spawner',
            force = 'enemy_erm_zerg'
        })
        assert(table_size(entities) > 0,'Has victory expansion')

        assert(    global.race_settings[race_name].attack_meter < 3000, 'Attack point successfully deducted')
        done()
    end)
end)
