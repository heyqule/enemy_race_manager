---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 10/30/2024 10:11 PM
---

local TestShared = require("shared")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local QualityProcessor = require('lib/quality_processor')

before_each(function()
    TestShared.prepare_the_factory()
end)

after_each(function()
    TestShared.reset_the_factory()
end)

local enemy = 'enemy'
local planet = 'nauvis'

it("Test quality calculate_chance_cache", function()

    assert(settings.global['enemyracemanager-difficulty'].value == QUALITY_NORMAL, "Difficulty Setting is not correct. Please use Normal to test")

    game.forces[enemy].set_evolution_factor(0.5)
    QualityProcessor.calculate_quality_points()
    assert(math.floor(QualityProcessor.get_quality_point(enemy, planet)) == 1500, "Quality Point is correct")
    assert(QualityProcessor.is_maxed_out(enemy, planet) == false, "maxed_out is false")

    game.forces[enemy].set_evolution_factor(1)
    QualityProcessor.calculate_quality_points()
    assert(QualityProcessor.get_quality_point(enemy, planet) == 3000, "Quality Point is 30%")

    --- set 2000000 accumulate point to test 100%
    storage.race_settings.enemy.attack_meter_total = 2000001
    QualityProcessor.calculate_quality_points()
    assert(QualityProcessor.get_quality_point(enemy, planet) == 10000, "Quality Point is 100%")
    assert(QualityProcessor.is_maxed_out(enemy, planet) == true, "maxed_out is true")

    local spawn_rate = QualityProcessor.get_spawn_rates(enemy, planet)
    assert(spawn_rate[1] == 0, "Legendary = 0")
    assert(spawn_rate[2] == 0.1, "Epic = 0.1")
    assert(spawn_rate[3] == 0.6, "Rare = 0.6")
    assert(spawn_rate[4] == 1, "Uncommon = 1.0")
    assert(spawn_rate[5] == 0, "Normal = 0")
end)

it('Test when applicable entities spawn, it should roll', function()
    local nauvis = game.surfaces[1]

    game.forces[enemy].set_evolution_factor(1)
    storage.race_settings.enemy.attack_meter_total = 2000001
    QualityProcessor.calculate_quality_points()

    local entity = nauvis.create_entity {
        name = 'enemy--big-biter--1',
        position = {32, 32}
    }

    local units = nauvis.find_entities_filtered {
        type = 'unit',
        radius = 32,
        position = {32,32}
    }
    local unit = units[1]
    local unit_name = ForceHelper.get_name_token(unit.name)
    assert(tonumber(unit_name[3]) > 1, 'Unit is able to swap to higher tier')

    local entity = nauvis.create_entity {
        name = 'enemy--biter-spawner--1',
        position = {-32, -32}
    }

    local units = nauvis.find_entities_filtered {
        type = 'unit',
        radius = 32,
        position = {32,32}
    }
    local unit = units[1]
    local unit_name = ForceHelper.get_name_token(unit.name)
    assert(tonumber(unit_name[3]) > 1, 'Spawner is able to swap to higher tier')

    local entity = nauvis.create_entity {
        name = 'enemy--big-worm-turret--1',
        position = {-32, -32}
    }

    local units = nauvis.find_entities_filtered {
        type = 'unit',
        radius = 32,
        position = {32,32}
    }
    local unit = units[1]
    local unit_name = ForceHelper.get_name_token(unit.name)
    assert(tonumber(unit_name[3]) > 1, 'Turret is able to swap to higher tier')
end)

it('Test when unit spawn at higher tier, it should not re-roll', function()
    local nauvis = game.surfaces[1]

    game.forces[enemy].set_evolution_factor(1)
    storage.race_settings.enemy.attack_meter_total = 2000001
    QualityProcessor.calculate_quality_points()

    local entity = nauvis.create_entity {
        name = 'enemy--big-biter--5',
        position = {32, 32}
    }

    local units = nauvis.find_entities_filtered {
        type = 'unit',
        radius = 32,
        position = {32,32}
    }
    local unit = units[1]
    local unit_name = ForceHelper.get_name_token(unit.name)
    assert(tonumber(unit_name[3]) == 5, 'Biter should not able to swap to lower tier')
end)

it('Test when generate a group, whether it respect the ratio. However exceptions may happen, depends on RNG god', function()
    local nauvis = game.surfaces[1]
    game.forces[enemy].set_evolution_factor(1)
    storage.race_settings.enemy.attack_meter_total = 2000001
    QualityProcessor.calculate_quality_points()

    for i = 1, 100, 1 do
        nauvis.create_entity {
            name = 'enemy--big-biter--1',
            position = {0, 0}
        }
    end

    local units = nauvis.find_entities_filtered {
        type = 'unit',
        radius = 32,
        position = {0,0}
    }

    local total_two = 0
    local total_three = 0
    local total_four = 0
    local total_switch = {
        ['2'] = function() total_two = total_two + 1  end,
        ['3'] = function() total_three = total_three + 1  end,
        ['4'] = function() total_four = total_four + 1  end
    }
    for _, unit in pairs(units) do
        local unit_name_token = ForceHelper.get_name_token(unit.name)
        if total_switch[unit_name_token[3]] then
            total_switch[unit_name_token[3]]()
        end
    end

    assert(total_two < total_three, 'Uncommon < Rare')
    assert(total_four < total_three, 'Epic < Rare')
end)

it('Home planet test', function()
    local nauvis = game.surfaces[1]
    local char = game.planets.char.create_surface()
    QualityProcessor.calculate_quality_points()

    nauvis.create_entity {
        name = 'enemy_erm_zerg--zergling--1',
        position = {0, 0}
    }

    char.create_entity {
        name = 'enemy_erm_zerg--zergling--1',
        position = {0, 0}
    }

    local nauvis_units = nauvis.find_entities_filtered {
        type = 'unit',
        radius = 32,
        position = {0,0}
    }

    local char_units = nauvis.find_entities_filtered {
        type = 'unit',
        radius = 32,
        position = {0,0}
    }
    local nauvis_unit_name_token = ForceHelper.get_name_token(nauvis_units[1].name)
    local char_unit_name_token = ForceHelper.get_name_token(char_units[1].name)
    assert(tonumber(nauvis_unit_name_token[3]) == 1, 'Nauvis must be 1, yours:'..tostring(nauvis_unit_name_token[3]))
    assert(tonumber(char_unit_name_token[3]) == 1, 'Char must be 5, your:'..tostring(char_unit_name_token[3]))
end)


it.only('Schedule update test', function()
    async(3700)
    local nauvis = game.surfaces[1]
    local char = game.planets.char.create_surface()
    QualityProcessor.calculate_quality_points()

    for i = 1, 1000, 1 do
        local hive = nauvis.create_entity {
            name = 'enemy_erm_zerg--hive--1',
            position = {0, 0}
        }
        hive.die('player')
    end

    for i = 1, 1000, 1 do
        local hive = char.create_entity {
            name = 'enemy_erm_zerg--hive--1',
            position = {0, 0}
        }
        hive.die('player')
    end

    after_ticks(3660, function()
        local nauvis_point = storage.quality_on_planet['enemy']['nauvis'].points
        local char_point = storage.quality_on_planet['enemy']['char'].points

        assert(nauvis_point > 0, 'Must not be 0, yours:'..tostring(nauvis_point))
        assert(char_point > 0, 'Must not be 0, your:'..tostring(char_point))
        done()
    end)
end)