---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/16/2022 2:58 PM
---

require('__stdlib__/stdlib/utils/defines/time')

local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local ErmRaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')
local ErmAttackGroupChunkProcessor = require('__enemyracemanager__/lib/attack_group_chunk_processor')
local ErmSurfaceProcessor = require('__enemyracemanager__/lib/surface_processor')
local ErmCron = require('__enemyracemanager__/lib/cron_processor')

local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

local BossAttackProcessor = {}

local pick_near_by_player_entity_position = function()
    local attackable_entities_cache = global.boss.attackable_entities_cache
    local attackable_entities_cache_size = global.boss.attackable_entities_cache_size

    if attackable_entities_cache == nil then
        local surface = global.boss.surface
        attackable_entities_cache = surface.find_entities_filtered {
            force = ErmForceHelper.get_player_forces(),
            radius = 64,
            position = global.boss.entity_position,
            limit = 50
        }
        attackable_entities_cache_size = #attackable_entities_cache
        global.boss.attackable_entities_cache = attackable_entities_cache
        global.boss.attackable_entities_cache_size = attackable_entities_cache_size
    end
    return attackable_entities_cache[math.random(1,attackable_entities_cache_size)].position
end

function BossAttackProcessor.unset_attackable_entities_cache()
    global.boss.attackable_entities_cache = nil
    global.boss.attackable_entities_cache_size = 0
end

function BossAttackProcessor.exec_basic()
    local data = {
        entity_name = "erm-energy-explosion-blue-1",
        count = 1,
        spread = 3
    }
    for i=1, data['spread'] do
        local position = pick_near_by_player_entity_position()
        data['position'] = position;
        ErmCron.add_quick_queue('BossAttackProcessor.process_attack', table.deepcopy(data))
    end
end

function BossAttackProcessor.exec_advanced()
    local data = {
        entity_name = "erm-energy-explosion-green-1",
        count = 1,
        spread = 2
    }
    for i=1, data['spread'] do
        local position = pick_near_by_player_entity_position()
        data['position'] = position;
        ErmCron.add_quick_queue('BossAttackProcessor.process_attack', table.deepcopy(data))
    end
end

function BossAttackProcessor.exec_super()
    local data = {
        entity_name = "erm-ball-explosion-fire-2",
        count = 1,
        spread = 3
    }

    for i=1, data['spread'] do
        local position = pick_near_by_player_entity_position()
        data['position'] = position;
        ErmCron.add_quick_queue('BossAttackProcessor.process_attack', table.deepcopy(data))
    end
end

function BossAttackProcessor.process_attack(data)
    if data == nil or not global.boss or not global.boss.entity or not global.boss.entity.valid then
        return
    end

    local surface = global.boss.surface
    local position = data['position']
    local entity_name = data['entity_name']
    surface.create_entity({
        name = entity_name,
        position = position
    })
end

return BossAttackProcessor