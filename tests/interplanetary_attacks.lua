
local TestShared = require("shared")

local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local InterplanetaryAttacks = require("__enemyracemanager__/lib/interplanetary_attacks")
local AttackGroupHeatProcessor = require("__enemyracemanager__/lib/attack_group_heat_processor")

local race_name = "enemy_erm_zerg"
local enemy_force_name = "enemy_erm_zerg"

before_each(function()
    TestShared.prepare_the_factory()
    TestShared.reset_surfaces()
    TestShared.reset_forces()
    InterplanetaryAttacks.reset_globals()
    storage.erm_unit_groups = {}
    storage.is_multi_planets_game = true
    storage.override_interplanetary_attack_enabled = true
    storage.override_interplanetary_attack_roll_bypass = true
end)

after_each(function()
    TestShared.reset_the_factory()
    TestShared.reset_surfaces()
    TestShared.reset_forces()
    InterplanetaryAttacks.reset_globals()
    storage.erm_unit_groups = {}
    storage.is_multi_planets_game = false
    storage.override_interplanetary_attack_enabled = false
    storage.override_interplanetary_attack_roll_bypass = false
    storage.race_settings[race_name].interplanetary_attack_active = false
end)

it("Interplanetary Attack: Success Attack!", function()
    async(5400)
    local surface = game.surfaces[1]
    local player = game.forces["player"]
    
    surface.request_to_generate_chunks({ 0, 0 }, 25)
    surface.force_generate_chunk_requests()

    local char_surface = game.planets['char'].create_surface()
    local hive = char_surface.create_entity({name=race_name..'--hive--5',position={x=10,y=10}, force=race_name})
    hive.die('player')     
    
    AttackGroupBeaconProcessor.init_index()
    for i=1,32,1 do
        InterplanetaryAttacks.scan(surface)
    end
    storage.race_settings[race_name].attack_meter = 3000
    storage.race_settings[race_name].next_attack_threshold = 3000

    after_ticks(900, function()
        InterplanetaryAttacks.exec(race_name, player)
    end)
    
    after_ticks(5400, function()
        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = "unit",
            force = enemy_force_name
        })
        assert(table_size(entities) > 0,"Has units")

        assert(    storage.race_settings[race_name].attack_meter < 3000, "Attack point successfully deducted")
        done()
    end)
end)

it("Interplanetary Attack: Home planet not discovered", function()
    async(5400)
    local surface = game.surfaces[1]
    local surface2 = game.planets.vulcanus.create_surface()

    local player = game.forces["player"]
    surface.request_to_generate_chunks({ 0, 0 }, 25)
    surface.force_generate_chunk_requests()
    AttackGroupBeaconProcessor.init_index()
    for i=1,32,1 do
        InterplanetaryAttacks.scan(surface)
    end
    storage.race_settings[race_name].attack_meter = 3000
    storage.race_settings[race_name].next_attack_threshold = 3000

    AttackGroupHeatProcessor.calculate_heat(race_name, surface.index, player.index, 300)
    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
    end

    after_ticks(900, function()
        InterplanetaryAttacks.exec(race_name, player)
    end)

    after_ticks(5400, function()
        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = "unit",
            force = enemy_force_name
        })
        assert(table_size(entities) == 0,"Should not not have units")
        assert(    storage.race_settings[race_name].attack_meter == 3000, "Attack point should stay the same")
        done()
    end)
end)


it("Interplanetary Attack: pick new planet on second run", function()
    async(5400)
    local surface = game.surfaces[1]
    local surface2 = game.planets.vulcanus.create_surface()
    local surface3 = game.planets.char.create_surface() 
    
    local hive = surface3.create_entity({name=race_name..'--hive--5',position={x=10,y=10}, force=race_name})
    hive.die('player')

    local rocket_launcher = surface.create_entity({ name = "erm-rocket-silo-test", force = "player", position = { -10, -10 } })
    local rocket_launcher_2 = surface2.create_entity({ name = "erm-rocket-silo-test", force = "player", position = { -10, -10 } })
    
    local player = game.forces["player"]
    surface.request_to_generate_chunks({ 0, 0 }, 25)
    surface.force_generate_chunk_requests()
    surface2.request_to_generate_chunks({ 0, 0 }, 25)
    surface2.force_generate_chunk_requests()

    AttackGroupBeaconProcessor.init_index()
    for i=1,32,1 do
        InterplanetaryAttacks.scan(surface)
        InterplanetaryAttacks.scan(surface2)
    end
    storage.race_settings[race_name].attack_meter = 8000
    storage.race_settings[race_name].next_attack_threshold = 3000

    AttackGroupHeatProcessor.calculate_heat(race_name, surface.index, player.index, 300)
    for active_race, _ in pairs(storage.active_races) do
        AttackGroupHeatProcessor.aggregate_heat(active_race)
    end

    after_ticks(900, function()
        InterplanetaryAttacks.exec(race_name, player)
    end)

    after_ticks(2400, function()
        InterplanetaryAttacks.exec(race_name, player)
    end)

    game.players[1].teleport({0,0},'vulcanus')
    after_ticks(5400, function()
        local entities = surface.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = "unit",
            force = enemy_force_name
        })
        assert(table_size(entities) > 0,"Has unit on Nauvis")

        local entities = surface2.find_entities_filtered({
            area = {{-100,-100},{100,100}},
            type = "unit",
            force = enemy_force_name
        })
        assert(table_size(entities) > 0,"Has unit on Vulcanus")
        game.players[1].teleport({0,0},'vulcanus')
        done()
    end)
    
    
end)
