---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 11/2/2024 7:01 PM
---
---
local simulations = {}

simulations.general =
{
    init =
    [[
        require("__core__/lualib/story")
        player = game.simulation.create_test_player{name = "you"}
        player.teleport({0, 2.5})
        game.simulation.camera_player = player
        game.simulation.camera_position = {0, 0}
        game.simulation.camera_player_cursor_position = player.position
        biter1 = game.surfaces[1].create_entity { name="erm_vanilla--small-biter--1", position={0, 0} }
        if script.active_mods['erm_zerg'] then
            biter2 = game.surfaces[1].create_entity { name="erm_zerg--zergling--1", position={-3, 0} }
        end
        if script.active_mods['erm_toss'] then
            biter3 = game.surfaces[1].create_entity { name="erm_toss--zealot--1", position={3, 0} }
        end

        local story_table =
        {
          {
            {
              name = "start",
              init = function() return game.simulation.move_cursor({position = biter1.position, speed = 2}) end,
              condition = story_elapsed_check(2)
            },
            {
              name = "step2",
              condition = story_elapsed_check(2),
              action = function() return game.simulation.move_cursor({position = biter2.position, speed = 2}) end
            },
            {
              name = "step3",
              condition = story_elapsed_check(2),
              action = function() return game.simulation.move_cursor({position = biter3.position, speed = 2}) end
            },
            {
              name = "step4",
              condition = story_elapsed_check(2),
              action = function() story_jump_to(storage.story, "start") end
            },
          }
        }
    tip_story_init(story_table)
    ]],
}

simulations.quality_system =
{
    init =
    [[
        require("__core__/lualib/story")
        player = game.simulation.create_test_player{name = "heyqule"}
        player.teleport({0, 2.5})
        game.simulation.camera_player = player
        game.simulation.camera_position = {0, 0}
        game.simulation.camera_player_cursor_position = player.position
        biter1 = game.surfaces[1].create_entity { name="erm_vanilla--small-biter--1", position={0, 0} }
        biter1.active = false
        if script.active_mods['erm_zerg'] then
            biter2 = game.surfaces[1].create_entity { name="erm_zerg--zergling--1", position={-3, 0} }
            biter2.active = false
        end
        if script.active_mods['erm_toss'] then
            biter3 = game.surfaces[1].create_entity { name="erm_toss--zealot--1", position={3, 0} }
            biter3.active = false
        end

        local story_table =
        {
          {
            {
              name = "start",
              init = function() return game.simulation.move_cursor({position = biter1.position, speed = 2}) end,
              condition = story_elapsed_check(2)
            },
            {
              name = "step2",
              condition = story_elapsed_check(2),
              action = function() return game.simulation.move_cursor({position = biter2.position, speed = 2}) end
            },
            {
              name = "step3",
              condition = story_elapsed_check(2),
              action = function() return game.simulation.move_cursor({position = biter3.position, speed = 2}) end
            },
            {
              name = "step4",
              condition = story_elapsed_check(2),
              action = function() story_jump_to(storage.story, "start") end
            },
          }
        }
        tip_story_init(story_table)
    ]],
}

return simulations