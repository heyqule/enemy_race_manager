---
--- This test case requires ERM_ZERG
---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/7/2024 6:10 PM
---

local TestShared = require('shared')
local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local AttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')

before_each(function()
    TestShared.prepare_the_factory()
    global.erm_unit_groups = {}
end)

after_each(function()
    TestShared.reset_the_factory()
    global.erm_unit_groups = {}
end)

local command_center = 'erm_zerg/hive/20'
local ultralisk = 'erm_zerg/ultralisk/20'
local force_name = 'enemy_erm_zerg'
local race_name = 'erm_zerg'
local PLAYER = 'player'
local SCOUT_NAME_PATTERN = '_scout/'

local function spawn_cc(surface)
    local position = {x=0,y=320}
    surface.request_to_generate_chunks({ position.x/32, position.y/32}, 2)
    surface.force_generate_chunk_requests()
    return surface.create_entity({name=command_center,force=force_name,position=position})
end

local function spawn_regular_unit_group(surface, position, is_auto)
    local group = surface.create_unit_group {position = position, force = 'enemy'}
    for i = 0, 50, 1 do
        local entity = surface.create_entity({
            name = 'erm_vanilla/small-biter/1',
            position = position
        })
        group.add_member(entity)
    end
    if is_auto then
        group.set_autonomous()
    end
    return group
end

    --- Regular attack group Test
    it("Regular Group by AP", function()
        async(18200)
        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()

        global.race_settings[race_name].level = 20
        global.race_settings[race_name].tier = 3
        global.race_settings[race_name].attack_meter = 3000
        global.race_settings[race_name].next_attack_threshold = 3000

        after_ticks(18000, function()
            assert(table_size(global.erm_unit_groups) == 1,'Check Erm unit group table')

            local key = next(global.erm_unit_groups)
            assert.not_nil(global.erm_unit_groups[key], 'Check Unit Group Data')

            local group = global.erm_unit_groups[key].group
            assert.truthy(global.erm_unit_groups[key].group.valid, 'Check Unit Group valid')

            local member = group.members[5]
            local nameToken = ForceHelper.get_name_token(member.name)
            assert.equal(20, tonumber(nameToken[3]), 'Check Group Level')
            done()
        end)
    end)
    --- Elite group Test
    it("Elite Group by AAP", function()
        async(18200)
        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()

        global.erm_unit_groups = {}
        global.race_settings[race_name].level = 20
        global.race_settings[race_name].tier = 3
        global.race_settings[race_name].attack_meter = 3000
        global.race_settings[race_name].next_attack_threshold = 3000
        global.race_settings[race_name].attack_meter_total = 45200

        after_ticks(18000, function()
            assert(table_size(global.erm_unit_groups) == 1,'Check Erm unit group table')

            local key = next(global.erm_unit_groups)
            assert.not_nil(global.erm_unit_groups[key], 'Check Group Record')

            local group = global.erm_unit_groups[key].group
            assert.truthy(global.erm_unit_groups[key].group.valid, 'Check Unit Group valid')

            local member = group.members[3]
            local nameToken = ForceHelper.get_name_token(member.name)
            assert.equal(22, tonumber(nameToken[3]), 'Check Group Level')
            done()
        end)
    end)

    it("Superweapon revenge", function()
        async(7300)
        global.race_settings[race_name].level = 20
        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()

        local laser_turret = surface.create_entity({
            name='laser-turret',
            position= { 0, 0},
            force=PLAYER
        })

        for i = 1, 50, 1 do
            surface.create_entity({
                name = ultralisk,
                force= force_name,
                position = { entity.position.x+16, entity.position.y}
            })
        end

        after_ticks(300, function()
            surface.create_entity({
                type = 'projectile',
                name = "atomic-rocket",
                force = PLAYER,
                target = entity,
                position = laser_turret.position,
                source = laser_turret,
                speed = 0.5
            })
        end)

        after_ticks(3600, function()
            assert(table_size(global.erm_unit_groups) == 1,'Check Erm unit group table')

            local key = next(global.erm_unit_groups)
            assert.not_nil(global.erm_unit_groups[key], 'Check Group Record')
            done()
        end)
    end)

    it("Flyers", function()
        async(7300)
        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()
        AttackGroupProcessor.generate_group(
                race_name,
                game.forces[force_name],
                20,
                {group_type = AttackGroupProcessor.GROUP_TYPE_FLYING}
        )

        after_ticks(7200, function()
            local entities = surface.find_entities_filtered({
                area = {{-100,-100},{100,100}},
                type = 'unit',
                force = force_name
            })

            local correct = 0
            for _, entity in pairs(entities) do
                if string.find(entity.name, 'mutalisk', 1, true) or string.find(entity.name, 'scout', 1, true) then
                    correct = correct + 1
                end
            end
            assert(correct > 0,'Has correct unit in the area')
            assert.equal(table_size(entities), correct,'Correct Unit Names')
            done()
        end)
    end)

    it("Dropships", function()
        async(7300)

        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()
        AttackGroupProcessor.generate_group(
                race_name,
                game.forces[force_name],
                20,
                {group_type =AttackGroupProcessor.GROUP_TYPE_DROPSHIP}
        )

        after_ticks(7200, function()
            local entities = surface.find_entities_filtered({
                area = {{-100,-100},{100,100}},
                type = 'unit',
                force = force_name
            })

            local correct = 0
            for _, entity in pairs(entities) do
                if string.find(entity.name, 'overlord', 1, true) or string.find(entity.name, 'scout', 1, true) then
                    correct = correct + 1
                end
            end
            assert(correct > 0,'Has correct unit in the area')
            assert.equal(table_size(entities), correct,'Correct Unit Names')
            done()
        end)
    end)

    it("Featured Group", function()
        async(7300)
        global.race_settings[race_name].level = 20
        global.race_settings[race_name].tier = 1

        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()
        AttackGroupProcessor.generate_group(
                race_name,
                game.forces[force_name],
                20,
                {group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED,
                featured_group_id = 1}
        )

        after_ticks(7200, function()
            local entities = surface.find_entities_filtered({
                area = {{-100,-100},{100,100}},
                type = 'unit',
                force = force_name
            })

            local correct = 0
            for _, entity in pairs(entities) do
                if string.find(entity.name, 'zergling', 1, true) or
                    string.find(entity.name, 'ultralisk', 1, true) or
                    string.find(entity.name, 'scout', 1, true)
                then
                    correct = correct + 1
                end
            end
            assert.equal(table_size(entities), correct,'Correct Unit Names')
            done()
        end)
    end)

    it("Featured Flyer Group", function()
        async(7300)
        global.race_settings[race_name].level = 20
        global.race_settings[race_name].tier = 1

        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()
        AttackGroupProcessor.generate_group(
                race_name,
                game.forces[force_name],
                20,
                {group_type = AttackGroupProcessor.GROUP_TYPE_FEATURED_FLYING,
                 featured_group_id = 2}
        )

        after_ticks(7200, function()
            local entities = surface.find_entities_filtered({
                area = {{-100,-100},{100,100}},
                type = 'unit',
                force = force_name
            })

            local correct = 0
            for _, entity in pairs(entities) do
                if string.find(entity.name, 'devourer', 1, true) or
                    string.find(entity.name, 'guardian', 1, true) or
                    string.find(entity.name, 'scout', 1, true)
                then
                    correct = correct + 1
                end
            end
            assert.equal(table_size(entities), correct,'Correct Unit Names')
            done()
        end)
    end)

    it("Group Killed during generation", function()
        async(1900)
        global.race_settings[race_name].level = 20
        global.race_settings[race_name].tier = 1

        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()
        AttackGroupProcessor.generate_group(
                race_name,
                game.forces[force_name],
                200
        )
        after_ticks(600, function()
            local group = global.group_tracker.erm_zerg.group
            group.destroy()
        end)
        after_ticks(1800, function()
            assert.equal(global.group_tracker.erm_zerg, nil, 'Remove record from group tracker')
            done()
        end)
    end)

    it("Autonomous Group should have an scout", function()
        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()

        local group = spawn_regular_unit_group(surface, entity.position, true)
        assert.not_nil(global.scout_unit_name[group.group_number],"Scout name in cache")
        group.start_moving()

        local has_scout = false
        for _, unit in pairs(group.members) do
            if string.find(unit.name, SCOUT_NAME_PATTERN) ~= nil then
                has_scout = true
                break;
            end
        end
        assert.equal(has_scout, true, 'Scout is in the team')
        assert.is_nil(global.scout_unit_name[group.group_number],"Scout name cache removed")
    end)

    it("Non-ERM Manual group should NOT have a scout", function()
        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()

        local group = spawn_regular_unit_group(surface, entity.position, false)
        assert.not_nil(global.scout_unit_name[group.group_number],"Scout name in cache")
        group.start_moving()

        local has_scout = false
        for _, unit in pairs(group.members) do
            if string.find(unit.name, SCOUT_NAME_PATTERN) ~= nil then
                has_scout = true
                break;
            end
        end
        assert.equal(has_scout, false, 'Scout is not in the team')
        assert.is_nil(global.scout_unit_name[group.group_number],"Scout name cache removed")
    end)

    it("Empty unit group should not include in ERM group tracker", function()
        local surface = game.surfaces[1]
        local entity = spawn_cc(surface)
        AttackGroupBeaconProcessor.init_index()
        local group = surface.create_unit_group {position = entity.position, force = 'enemy'}
        assert.not_nil(global.scout_unit_name[group.group_number],"Scout name in cache")
        group.start_moving()
        assert.is_nil(global.scout_unit_name[group.group_number],"Scout name cache removed")
    end)
