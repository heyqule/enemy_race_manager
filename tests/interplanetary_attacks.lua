
local TestShared = require("shared")

local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local InterplanetaryAttacks = require("__enemyracemanager__/lib/interplanetary_attacks")
local AttackGroupHeatProcessor = require("__enemyracemanager__/lib/attack_group_heat_processor")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local Event = require("__stdlib__/stdlib/event/event")

before_each(function()
    TestShared.prepare_the_factory()
    TestShared.reset_surfaces()
    TestShared.reset_forces()
    InterplanetaryAttacks.reset_globals()
    storage.erm_unit_groups = {}
    storage.is_multi_planets_game = true
    storage.override_interplanetary_attack_enabled = true
    storage.override_interplanetary_attack_roll_bypass = true
    storage.override_ask_friend = false
end)

after_each(function()
    TestShared.reset_the_factory()
    TestShared.reset_surfaces()
    TestShared.reset_forces()
    InterplanetaryAttacks.reset_globals()
    storage.erm_unit_groups = {}
    storage.override_interplanetary_attack_roll_bypass = nil
    storage.is_multi_planets_game = false
    storage.override_interplanetary_attack_enabled = false
    storage.override_interplanetary_attack_roll_bypass = false
    storage.override_ask_friend = nil
end)


local race_name = "erm_zerg"
local enemy_force_name = "enemy_erm_zerg"

it("Interplanetary Attack: Attack Target", function()
    async(12000)
    local surface = game.surfaces[1]
    local player = game.forces["player"]
    surface.request_to_generate_chunks({ 0, 0 }, 25)
    surface.force_generate_chunk_requests()
    AttackGroupBeaconProcessor.init_index()
    for i=1,24,1 do
        InterplanetaryAttacks.scan(surface)
    end
    storage.race_settings[race_name].level = 5
    storage.race_settings[race_name].tier = 3
    storage.race_settings[race_name].attack_meter = 3000
    storage.race_settings[race_name].next_attack_threshold = 3000

    after_ticks(1800, function()
        InterplanetaryAttacks.exec(race_name, player)
    end)

    after_ticks(12000, function()
        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = "unit",
            force = enemy_force_name
        })
        assert(table_size(entities) > 0,"Has units")

        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = "unit-spawner",
            force = "enemy_erm_zerg"
        })
        assert(table_size(entities) > 0,"Has victory expansion")

        assert(    storage.race_settings[race_name].attack_meter < 3000, "Attack point successfully deducted")
        done()
    end)
end)

it("Interplanetary Attack: No friends, have to launch attack", function()
    async(12000)
    local surface = game.surfaces[1]
    local surface2 = game.create_surface("test_surface_2")
    storage.interplanetary_intel[surface2.index]   = {
        radius = 900000,
        type = "planet",
        updated = game.tick,
        defense = 0,
        has_player_entities = true,
    }
    local player = game.forces["player"]
    surface.request_to_generate_chunks({ 0, 0 }, 25)
    surface.force_generate_chunk_requests()
    AttackGroupBeaconProcessor.init_index()
    for i=1,24,1 do
        InterplanetaryAttacks.scan(surface)
    end
    storage.race_settings[race_name].level = 5
    storage.race_settings[race_name].tier = 3
    storage.race_settings[race_name].attack_meter = 3000
    storage.race_settings[race_name].next_attack_threshold = 3000

    AttackGroupHeatProcessor.calculate_heat(race_name, surface.index, player.index, 300)
    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
    end

    after_ticks(12000, function()
        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = "unit",
            force = enemy_force_name
        })
        assert(table_size(entities) > 0,"Has units")

        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = "unit-spawner",
            force = "enemy_erm_zerg"
        })
        assert(table_size(entities) > 0,"Has victory expansion")

        assert(    storage.race_settings[race_name].attack_meter < 3000, "Attack point successfully deducted")
        done()
    end)
end)
