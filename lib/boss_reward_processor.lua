---
---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 9/25/2022 12:58 AM
---
--- Reward player when they beat boss within the time limit.
---
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')
local ErmCron = require('__enemyracemanager__/lib/cron_processor')

local BossRewardProcessor = {}

local can_spawn = ErmRaceSettingsHelper.can_spawn

local rewards_items_data = {
    {
        'advanced-circuit',
        'engine-unit',
        'electric-engine-unit',
        'battery'
    },
    {
        'electronic-circuit',
        'plastic-bar',
        'sulfur',
        'iron-gear-wheel',
        'steel-plate',
        'explosives',
    },
    {
        'copper-plate',
        'iron-plate',
        'stone-brick',
    }
}

local reward_settings =
{
    {
        position_offset= {x=10, y=10},
        chance = {100, 100, 100, 100, 100},
    },
    {
        position_offset= {x=-10, y=-10},
        chance = {0, 10, 33, 66, 100},
    },
    {
        position_offset= {x=-10, y=10},
        chance = {0, 0, 0, 10, 30},
    },
    {
        position_offset= {x=10, y=-10},
        chance = {0, 0, 0, 5, 20},
    }
}

local reward_tiers = {
    {0, 0},
    {0, 33},
    {5, 50},
    {20, 66},
    {33, 75},
}

-- Infinite chests stay for 14 Nauvis Days.
local expire_at = defines.time.minute * 7 * 14

local get_infinite_chest = function()
    return {
        name  = 'infinity-chest',
        force = 'neutral'
    }
end

local reward_data = function(entity)
    return {
        entity = entity,
        entity_position = entity.position,
        expire_at = game.tick + expire_at
    }
end

local spawn_chest = function(reward_setting, boss_data)
    local surface = boss_data.surface

    local chest = get_infinite_chest()
    local name = chest.name
    local force = chest.force
    local offset = reward_setting.position_offset
    local position = {
        x = boss_data.entity_position.x + offset.x,
        y = boss_data.entity_position.y + offset.y
    }

    if not surface.can_place_entity({ name = name, force = force, position = position }) then
        position = surface.find_non_colliding_position(name, position, 32, 10, true)
    end

    if position then
        local built_entity = surface.create_entity({ name = name, force = force, position = position })
        return built_entity
    end

    return nil
end

local get_item_name = function(tier)
    for key, value in pairs(reward_tiers[tier]) do
        if (can_spawn(value)) then
            return rewards_items_data[key][math.random(1,#rewards_items_data[key])]
        end
    end

    return rewards_items_data[3][math.random(1,#rewards_items_data[3])]

end

function BossRewardProcessor.exec()
    local boss = global.boss
    for _, value in pairs(reward_settings) do
        if(can_spawn(value['chance'][boss.boss_tier])) then
            local chest = spawn_chest(value, boss)
            if chest then
                local infinity_item_name = get_item_name(boss.boss_tier)
                chest.set_infinity_container_filter(1, {
                    name = infinity_item_name,
                    count = 100,
                    mode = 'exactly'
                })
                chest.destructible = false
                chest.minable = false
                chest.rotatable = false
                chest.operable = false
                ErmDebugHelper.print('Spawning Chest with '..infinity_item_name)
                table.insert(global.boss_rewards, reward_data(chest))
            end
        end
    end
end

function BossRewardProcessor.clean_up()
    local rewards = global.boss_rewards
    if rewards == nil or #rewards == 0 then
        return
    end

    local removed_positions = {}
    for position, reward in pairs(rewards) do
        if game.tick > reward.expire_at and
            reward.entity and
            reward.entity.valid
        then
            ErmDebugHelper.print('Destroy chest at '..reward.entity_position.x..'/'..reward.entity_position.y)
            reward.entity.destroy();
            table.insert(removed_positions, position)
        end
    end

    for _, position in pairs(removed_positions) do
        table.remove(global.boss_rewards, position)
    end
end

return BossRewardProcessor