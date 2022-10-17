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

BossAttackProcessor.TYPE_PROJECTILE = 1
BossAttackProcessor.TYPE_BEAM = 2
BossAttackProcessor.TYPE_EXPLOSION = 3

local type_name = {'projectile', 'beam', 'explosion'}
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

    local return_position = nil
    local retry = 0
    repeat
        return_position = attackable_entities_cache[math.random(1,attackable_entities_cache_size)].position
        retry = retry + 1
    until return_position or retry == 3

    return return_position
end

local queue_attack = function(data)
    for i=1, data['spread'] do
        local position = pick_near_by_player_entity_position()
        data['position'] = position;
        ErmCron.add_quick_queue('BossAttackProcessor.process_attack', table.deepcopy(data))
    end
end

local can_spawn = ErmRaceSettingsHelper.can_spawn

local set_optional_data = function(data, attacks, index, name)
    if attacks[name] then
        data[name] = attacks[name][index]
    end

    return data
end

local select_attack = function(mod_name, attacks, tier)
    local data
    for i, value in pairs(attacks['projectile_name']) do
        if can_spawn(attacks['projectile_chance'][i]) then
            data = {
                entity_name = mod_name..'/'..value..'-'..type_name[attacks['projectile_type'][i]]..'-t'..tier,
                count = attacks['projectile_count'][i],
                spread = attacks['projectile_spread'][i],
                type = attacks['projectile_type'][i],
            }

            if attacks['projectile_use_multiplier'][i] then
                data['count'] = math.floor(data['count'] * attacks['projectile_count_multiplier'][i][tier])
                data['spread'] = math.floor(data['spread'] * attacks['projectile_spread_multiplier'][i][tier])
            end

            data = set_optional_data(data, attacks, i, 'projectile_speed')
            data = set_optional_data(data, attacks, i, 'projectile_range')

            break
        end
    end
    return data
end

local fetch_attack_data = function(race_name)
    if not global.boss.attack_cache then
        global.boss.attack_cache = remote.call(race_name..'_boss_attacks','get_attack_data')
    end
end

local prepare_attack = function(type)
    local race_name = global.boss.race_name
    local tier = global.boss.boss_tier
    fetch_attack_data(race_name)
    local data = select_attack(race_name, global.boss.attack_cache[type], tier)
    queue_attack(data)
end

local get_despawn_attack = function()
    local race_name = global.boss.race_name
    local tier = global.boss.boss_tier
    fetch_attack_data(race_name)
    local data = select_attack(race_name, global.boss.attack_cache['despawn_attacks'], tier)
    return data
end

local process_attack = function(data)
    local surface = global.boss.surface
    local entity_name = data['entity_name']

    for i = 1, data['count'] do
        local position = data['position']
        if i > 1 then
            position['x'] = position['x'] + math.random(-16, 16)
            position['y'] = position['y'] + math.random(-16, 16)
        end
        if data['type'] == BossAttackProcessor.TYPE_PROJECTILE then
            surface.create_entity({
                name = entity_name,
                position = global.boss.entity_position,
                target = position,
                speed = data['speed'] or 0.3,
                max_range = data['range'] or 96,
                create_build_effect_smoke = false,
                raise_built = false,
                force = global.boss.force
            })
        elseif data['type'] == BossAttackProcessor.TYPE_BEAM then
            --- target_position
            --- source_position
            --- duration
            --- source_offset
            surface.create_entity({
                name = entity_name,
                position = position,
                create_build_effect_smoke = false,
                raise_built = false,
                force = global.boss.force
            })
        else
            surface.create_entity({
                name = entity_name,
                position = position,
                create_build_effect_smoke = false,
                raise_built = false,
                force = global.boss.force
            })
        end
    end
end


function BossAttackProcessor.unset_attackable_entities_cache()
    global.boss.attackable_entities_cache = nil
    global.boss.attackable_entities_cache_size = 0
end

function BossAttackProcessor.exec_basic()
    prepare_attack('basic_attacks')
end

function BossAttackProcessor.exec_advanced()
    prepare_attack('advanced_attacks')
end

function BossAttackProcessor.exec_super()
    prepare_attack('super_attacks')
end

function BossAttackProcessor.exec_phase()

end

function BossAttackProcessor.process_despawn_attack()
    ErmDebugHelper.print('Despawn Attack...')
    local data = get_despawn_attack()
    local position = pick_near_by_player_entity_position()
    data['position'] = position;
    process_attack(data)
end

function BossAttackProcessor.process_attack(data)
    if (data == nil or not global.boss or not global.boss.entity or not global.boss.entity.valid or not data['position']) then
        return
    end

    process_attack(data)
end

return BossAttackProcessor