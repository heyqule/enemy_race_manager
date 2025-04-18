---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/2/2024 7:01 PM
---
---
local simulations = {}

simulations.general = {
    init = [[
require("__core__/lualib/story")
local sim = game.simulation
player = sim.create_test_player{name = "you"}
player.teleport({0, 2.5})
sim.camera_player = player
sim.camera_position = {0, 0}
sim.hide_cursor = true
local surface = game.surfaces[1]
biter1 = surface.create_entity { name="enemy--small-biter--1", position={-10, -10} }
if script.active_mods['erm_zerg'] then
    biter2 = surface.create_entity { name="enemy_erm_zerg--zergling--1", position={0, -10} }
end
if script.active_mods['erm_toss'] then
    biter3 = surface.create_entity { name="enemy_erm_toss--zealot--1", position={10, -10} }
end
    ]],
}

simulations.custom_attack_groups = {

    init = [[
require("__core__/lualib/story")
local surface = game.surfaces[1]

local sim = game.simulation
sim.camera_position = {0, 0}
sim.camera_zoom = 0.75
sim.hide_cursor = true

-- had to add tile manually >.>
for x = -100, 100, 1 do
    for y = -32, 32 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "grass-1"}}
    end
end

local unit_sets = {
    {
        {"enemy--behemoth-biter--3", "enemy--behemoth-spitter--3"},
    },
    {
        {"enemy--destroyer--3", "enemy--defender--3"},
    },
}
storage.is_flyer = storage.is_flyer or 0
storage.race_index = storage.race_index or 0
storage.total_race_index = 1
if script.active_mods['erm_zerg'] then
    storage.total_race_index = storage.total_race_index + 1
    table.insert(unit_sets[1],  {"enemy_erm_zerg--zergling--3", "enemy_erm_zerg--ultralisk--3"} )
    table.insert(unit_sets[2],  {"enemy_erm_zerg--mutalisk--3", "enemy_erm_zerg--overlord--3"} )
end
if script.active_mods['erm_toss'] then
    storage.total_race_index = storage.total_race_index + 1
    table.insert(unit_sets[1],  {"enemy_erm_toss--zealot--3", "enemy_erm_toss--archon--3"} )
    table.insert(unit_sets[2],  {"enemy_erm_toss--scout--3", "enemy_erm_toss--carrier--3"} )
end

local story_table =
{
    {
        {
            name = "start",
            init = function()
                local entities = surface.find_entities {{-100, -100}, {100, 100}}
                for _, ent in pairs(entities) do
                    ent.destroy()
                end
            end,
        },
        {
            condition = story_elapsed_check(1),
            action = function()
                local is_flyer = storage.is_flyer + 1
                local race_index = storage.race_index + 1
                local units = unit_sets[is_flyer][race_index]
                for _, unit in pairs(units) do
                    for i = 0, 10, 1 do
                        local entity = surface.create_entity { name=unit, position={0, 0}, force="enemy" }
                    end
                end
            end
        },
        {
            condition = story_elapsed_check(3),
            action = function()
                storage.is_flyer = (storage.is_flyer + 1) % 2
                storage.race_index = (storage.race_index + 1) % storage.total_race_index
                story_jump_to(storage.story, "start")
            end
        }
    }
}
tip_story_init(story_table)
    ]]
}

simulations.new_enemy_types = {
    init = [[
        require("__core__/lualib/story")
        local surface = game.surfaces[1]

        local sim = game.simulation
        sim.camera_position = {0, 0}
        sim.camera_zoom = 0.75
        sim.hide_cursor = true

        -- had to add tile manually >.>
        for x = -100, 100, 1 do
            for y = -32, 32 do
                game.surfaces[1].set_tiles{{position = {x, y}, name = "grass-1"}}
            end
        end

        local unit_sets = {
            {"enemy--behemoth-biter--3", "enemy--destroyer--3", "enemy--logistic-robot--3", "enemy--construction-robot--3"},
        }
        storage.race_index = storage.race_index or 0
        storage.total_race_index = 1
        if script.active_mods['erm_zerg'] then
            storage.total_race_index = storage.total_race_index + 1
            table.insert(unit_sets,  {"enemy_erm_zerg--zergling--3", "enemy_erm_zerg--mutalisk--3", "enemy_erm_zerg--overlord--3", "enemy_erm_zerg--drone--3"} )
        end
        if script.active_mods['erm_toss'] then
            storage.total_race_index = storage.total_race_index + 1
            table.insert(unit_sets,  {"enemy_erm_toss--zealot--3", "enemy_erm_toss--carrier--3", "enemy_erm_toss--shuttle--3", "enemy_erm_toss--probe--3"} )
        end

        local story_table =
        {
            {
                {
                    name = "start",
                    init = function()
                        local entities = surface.find_entities {{-100, -100}, {100, 100}}
                        for _, ent in pairs(entities) do
                            ent.destroy()
                        end
                    end,
                },
                {
                    condition = story_elapsed_check(1),
                    action = function()
                        local race_index = storage.race_index + 1
                        local units = unit_sets[race_index]
                        for _, unit in pairs(units) do
                            for i = 1, 2, 1 do
                                local entity = surface.create_entity { name=unit, position={0, 0}, force="enemy" }
                            end
                        end
                    end
                },
                {
                    condition = story_elapsed_check(3),
                    action = function()
                        storage.race_index = (storage.race_index + 1) % storage.total_race_index
                        story_jump_to(storage.story, "start")
                    end
                }
            }
        }
        tip_story_init(story_table)
    ]]
}

simulations.base_expansions = {
    init = [[
require("__core__/lualib/story")
local surface = game.surfaces[1]

local sim = game.simulation
sim.camera_position = {0, 0}
sim.camera_zoom = 0.75
sim.hide_cursor = true

-- had to add tile manually >.>
for x = -100, 100, 1 do
    for y = -32, 32 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "grass-1"}}
    end
end

local unit_sets = {
    {
        "enemy--biter-spawner--3",
        "enemy--spitter-spawner--3",
        "enemy--roboport--3",
        "enemy--behemoth-worm-turret--3",
        "enemy--behemoth-worm-turret--3",
        "enemy--big-worm-turret--3"
    },
}
storage.race_index = storage.race_index or 0
storage.total_race_index = 1

if script.active_mods['erm_zerg'] then
    storage.total_race_index = storage.total_race_index + 1
    table.insert(unit_sets,  {
        "enemy_erm_zerg--hive--3",
        "enemy_erm_zerg--spawning_pool--3",
        "enemy_erm_zerg--ultralisk_cavern--3",
        "enemy_erm_zerg--spore_colony--3",
        "enemy_erm_zerg--sunken_colony--3",
        "enemy_erm_zerg--sunken_colony--3",
    } )
end
if script.active_mods['erm_toss'] then
    storage.total_race_index = storage.total_race_index + 1
    table.insert(unit_sets,  {
        "enemy_erm_toss--nexus--3",
        "enemy_erm_toss--pylon--3",
        "enemy_erm_toss--gateway--3",
        "enemy_erm_toss--cannon--3",
        "enemy_erm_toss--cannon--3",
        "enemy_erm_toss--shield_battery--3"
    } )
end


local story_table =
{
    {
        {
            name = "start",
            init = function()
                local entities = surface.find_entities {{-100, -100}, {100, 100}}
                for _, ent in pairs(entities) do
                    ent.destroy()
                end
                storage.race_index = storage.race_index + 1
            end,
        },
        {
            condition = story_elapsed_check(0.2),
            action = function()
                local unit = unit_sets[storage.race_index][1]
                local entity = surface.create_entity { name=unit, position={0, 0}, force="enemy" }
            end
        },
        {
            condition = story_elapsed_check(0.2),
            action = function()
                local unit = unit_sets[storage.race_index][2]
                local entity = surface.create_entity { name=unit, position={10, 0}, force="enemy" }
            end
        },
        {
            condition = story_elapsed_check(0.2),
            action = function()
                local unit = unit_sets[storage.race_index][3]
                local entity = surface.create_entity { name=unit, position={-10, 0}, force="enemy" }
            end
        },
        {
            condition = story_elapsed_check(0.2),
            action = function()
                local unit = unit_sets[storage.race_index][4]
                local entity = surface.create_entity { name=unit, position={0, 10}, force="enemy" }
            end
        },
        {
            condition = story_elapsed_check(0.2),
            action = function()
                local unit = unit_sets[storage.race_index][5]
                local entity = surface.create_entity { name=unit, position={-5, -10}, force="enemy" }
            end
        },
        {
            condition = story_elapsed_check(0.2),
            action = function()
                local unit = unit_sets[storage.race_index][6]
                local entity = surface.create_entity { name=unit, position={5, -10}, force="enemy" }
            end
        },
        {
            condition = story_elapsed_check(3),
            action = function()
                storage.race_index = (storage.race_index + 1) % storage.total_race_index
                story_jump_to(storage.story, "start")
            end
        }
    }
}
tip_story_init(story_table)
    ]]
}

simulations.free_for_all = {
    init = [[
require("__core__/lualib/story")

if not script.active_mods['erm_zerg'] and not script.active_mods['erm_toss'] then
    error("This scene requires ERM_ZERG and ERM_TOSS mods")
end

local surface = game.surfaces[1]

local sim = game.simulation
sim.camera_position = {0, 0}
sim.camera_zoom = 0.75
sim.hide_cursor = true

-- had to add tile manually >.>
for x = -100, 100, 1 do
    for y = -32, 32 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "grass-1"}}
    end
end

local zerg_force = game.create_force("enemy_erm_zerg")
local toss_force = game.create_force("enemy_erm_toss")
zerg_force.set_friend(toss_force, false)

local story_table =
{
    {
        {
            name = "start",
            init = function()
                local entities = surface.find_entities {{-100, -100}, {100, 100}}
                for _, ent in pairs(entities) do
                    ent.destroy()
                end
                surface.create_entity { name="enemy_erm_zerg--zergling--3", position={-10, 0}, force=zerg_force }
                surface.create_entity { name="enemy_erm_zerg--zergling--3", position={-10, 0}, force=zerg_force }
                surface.create_entity { name="enemy_erm_zerg--zergling--3", position={-10, 0}, force=zerg_force }
                surface.create_entity { name="enemy_erm_toss--zealot--3", position={10, 0}, force=toss_force }
            end,
        },
        {
            condition = story_elapsed_check(5),
            action = function()
                story_jump_to(storage.story, "start")
            end
        }
    }
}
tip_story_init(story_table)
]]
}

simulations.environmental_attacks = {
    init_update_count = 60,
    init = [[
require("__core__/lualib/story")

if not script.active_mods['erm_zerg'] and not script.active_mods['erm_toss'] then
    error("This scene requires ERM_ZERG and ERM_TOSS mods")
end

game.planets["vulcanus"].create_surface()
local vulcanus_surface = game.surfaces["vulcanus"]
vulcanus_surface.request_to_generate_chunks({0,0}, 2)
vulcanus_surface.force_generate_chunk_requests()

local sim = game.simulation
player = sim.create_test_player{name = "you"}
sim.camera_player = player
sim.camera_position = {0, 0}
sim.camera_zoom = 0.75
sim.hide_cursor = true

-- had to add tile manually >.>
for x = -100, 100, 1 do
    for y = -32, 32 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "grass-1"}}
    end
end

game.planets["fulgora"].create_surface()
local fulgora_surface = game.surfaces["fulgora"]
fulgora_surface.request_to_generate_chunks({0,0}, 2)
fulgora_surface.force_generate_chunk_requests()

local story_table =
{
    {
        {
            name = "start",
            init = function()
                local entities = vulcanus_surface.find_entities_filtered {type={"unit","segmented-unit"}}
                for _, ent in pairs(entities) do
                    ent.destroy()
                end
                player.teleport({0,0}, "vulcanus")
                vulcanus_surface.create_entity { name="enemy_erm_zerg--small-nydusworm", position={0, 0} }
            end,
        },
        {
            condition = story_elapsed_check(2),
            action = function()
                vulcanus_surface.create_entity { name="enemy_erm_zerg--zergling--3", position={-8, 0} }
                vulcanus_surface.create_entity { name="enemy_erm_zerg--zergling--3", position={8, 0} }
                vulcanus_surface.create_entity { name="enemy_erm_zerg--mutalisk--3", position={-8, 4} }
                vulcanus_surface.create_entity { name="enemy_erm_zerg--mutalisk--3", position={8, 4} }
            end
        },
        {
            condition = story_elapsed_check(2),
            action = function()
                local entities = fulgora_surface.find_entities_filtered {type="unit"}
                for _, ent in pairs(entities) do
                    ent.destroy()
                end
                player.teleport({0,0}, "fulgora")
                fulgora_surface.execute_lightning{name = "lightning", position = {0, 0}}
            end
        },
        {
            condition = story_elapsed_check(0.5),
            action = function()
                fulgora_surface.create_entity { name="protoss--recall-80-small", position={-2, 0}}
            end
        },
        {
            condition = story_elapsed_check(0.25),
            action = function()
                fulgora_surface.create_entity { name="enemy_erm_toss--zealot--3", position={-2, 0} }
            end
        },
        {
            condition = story_elapsed_check(3),
            action = function()
                story_jump_to(storage.story, "start")
            end
        }
    }
}
tip_story_init(story_table)
]]
}

simulations.bosses = {
    init = [[
require("__core__/lualib/story")

if not script.active_mods['erm_zerg'] and not script.active_mods['erm_toss'] then
    error("This scene requires ERM_ZERG and ERM_TOSS mods")
end

game.planets["vulcanus"].create_surface()
local vulcanus_surface = game.surfaces["vulcanus"]
vulcanus_surface.request_to_generate_chunks({0,0}, 2)
vulcanus_surface.force_generate_chunk_requests()

local sim = game.simulation
player = sim.create_test_player{name = "you"}
sim.camera_player = player
sim.camera_position = {0, 0}
sim.camera_zoom = 0.75
sim.hide_cursor = true

-- had to add tile manually >.>
for x = -100, 100, 1 do
    for y = -32, 32 do
        game.surfaces[1].set_tiles{{position = {x, y}, name = "grass-1"}}
    end
end

game.planets["fulgora"].create_surface()
local fulgora_surface = game.surfaces["fulgora"]
fulgora_surface.request_to_generate_chunks({0,0}, 2)
fulgora_surface.force_generate_chunk_requests()

local story_table =
{
    {
        {
            name = "start",
            init = function()
                local entities = vulcanus_surface.find_entities_filtered {type={"unit","segmented-unit"}}
                for _, ent in pairs(entities) do
                    ent.destroy()
                end
                player.teleport({0,0}, "vulcanus")
                vulcanus_surface.create_entity { name="enemy_erm_zerg--overmind--3", position={0, 0} }
            end,
        },
        {
            condition = story_elapsed_check(3),
            action = function()
                local entities = fulgora_surface.find_entities_filtered {type="unit"}
                for _, ent in pairs(entities) do
                    ent.destroy()
                end
                player.teleport({0,0}, "fulgora")
                fulgora_surface.create_entity { name="enemy_erm_toss--wrapgate--3", position={0, 0} }
            end
        },
        {
            condition = story_elapsed_check(0.5),
            action = function()
                fulgora_surface.create_entity { name="protoss--recall-80-small", position={-2, 0}}
            end
        },
        {
            condition = story_elapsed_check(0.25),
            action = function()
                fulgora_surface.create_entity { name="enemy_erm_toss--zealot--3", position={-2, 0} }
            end
        },
        {
            condition = story_elapsed_check(3),
            action = function()
                story_jump_to(storage.story, "start")
            end
        }
    }
}
tip_story_init(story_table)
]]
}

return simulations