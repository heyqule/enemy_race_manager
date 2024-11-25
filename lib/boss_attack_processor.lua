---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/16/2022 2:58 PM
---



local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local RaceSettingsHelper = require("__enemyracemanager__/lib/helper/race_settings_helper")
local AttackGroupBeaconProcessor = require("__enemyracemanager__/lib/attack_group_beacon_processor")
local Cron = require("__enemyracemanager__/lib/cron_processor")

local DebugHelper = require("__enemyracemanager__/lib/debug_helper")

local BossAttackProcessor = {}

BossAttackProcessor.TYPE_PROJECTILE = 1
BossAttackProcessor.TYPE_BEAM = 2

local scanLength = GlobalConfig.BOSS_ARTILLERY_SCAN_RANGE
local scanRadius = GlobalConfig.BOSS_ARTILLERY_SCAN_RADIUS
local scanMinLength = 128
local type_name = { "projectile", "beam" }

local get_scan_area = {
    [defines.direction.north] = function(x, y)
        return { left_top = { x - scanRadius, y - scanLength }, right_bottom = { x + scanRadius, y - scanMinLength } }
    end,
    [defines.direction.east] = function(x, y)
        return { left_top = { x + scanMinLength, y - scanRadius }, right_bottom = { x + scanLength, y + scanRadius } }
    end,
    [defines.direction.south] = function(x, y)
        return { left_top = { x - scanRadius, y + scanMinLength }, right_bottom = { x + scanRadius, y + scanLength } }
    end,
    [defines.direction.west] = function(x, y)
        return { left_top = { x - scanLength, y - scanRadius }, right_bottom = { x - scanMinLength, y + scanRadius } }
    end,
}

local pick_near_by_player_entity_position = function(artillery_mode)
    artillery_mode = artillery_mode or false

    local return_position
    local boss = storage.boss
    local surface = boss.surface
    local attackable_entities_cache = boss.attackable_entities_cache
    local attackable_entities_cache_size = boss.attackable_entities_cache_size

    if attackable_entities_cache == nil and not artillery_mode then
        attackable_entities_cache = surface.find_entities_filtered {
            force = ForceHelper.get_player_forces(),
            radius = 64,
            position = boss.entity_position,
            limit = 50,
            is_military_target = true
        }
        attackable_entities_cache_size = #attackable_entities_cache
        storage.boss.attackable_entities_cache = attackable_entities_cache
        storage.boss.attackable_entities_cache_size = attackable_entities_cache_size
    end

    if attackable_entities_cache_size == nil or attackable_entities_cache_size == 0 then
        attackable_entities_cache = surface.find_entities_filtered {
            force = ForceHelper.get_player_forces(),
            area = get_scan_area[boss.target_direction](storage.boss.entity_position.x, storage.boss.entity_position.y),
            limit = GlobalConfig.BOSS_ARTILLERY_SCAN_ENTITY_LIMIT,
            is_military_target = true
        }
        attackable_entities_cache_size = #attackable_entities_cache
        storage.boss.attackable_entities_cache = attackable_entities_cache
        storage.boss.attackable_entities_cache_size = attackable_entities_cache_size
        artillery_mode = true
    end

    if storage.boss.attackable_entities_cache_size > 0 then
        local retry = 0
        repeat
            local entity = attackable_entities_cache[math.random(1, attackable_entities_cache_size)]
            if entity.valid then
                return_position = entity.position
            end
            retry = retry + 1
        until return_position or retry == 3
    end

    if return_position == nil then
        return_position = boss.silo_position or {0, 0}
        artillery_mode = true
    end

    return return_position, artillery_mode

end

local queue_attack = function(data)
    for i = 1, data["spread"] do
        local position, artillery_mode = pick_near_by_player_entity_position()
        data["artillery_mode"] = artillery_mode
        data["position"] = position
        Cron.add_boss_queue("BossAttackProcessor.process_attack", table.deepcopy(data))
    end
end

local can_spawn = RaceSettingsHelper.can_spawn

local set_optional_data = function(data, attacks, index, name)
    if attacks[name] then
        data[name] = attacks[name][index]
    end

    return data
end

local select_attack = function(mod_name, attacks, tier)
    local data
    local boss = storage.boss
    for i, value in pairs(attacks["projectile_name"]) do
        if can_spawn(attacks["projectile_chance"][i]) then
            data = {
                entity_name = mod_name .. "--" .. value .. "-" .. type_name[attacks["projectile_type"][i]] .. "-t" .. tier,
                count = attacks["projectile_count"][i],
                spread = attacks["projectile_spread"][i],
                type = attacks["projectile_type"][i],
            }

            if attacks["projectile_use_multiplier"][i] then
                data["count"] = math.floor(data["count"] * attacks["projectile_count_multiplier"][i][tier])
                data["spread"] = math.floor(data["spread"] * attacks["projectile_spread_multiplier"][i][tier])
            end

            data = set_optional_data(data, attacks, i, "projectile_speed")
            data = set_optional_data(data, attacks, i, "projectile_range")

            break
        end
    end
    data["entity_position"] = boss.entity_position
    data["surface"] = boss.surface
    data["entity_force"] = boss.force
    return data
end

local fetch_attack_data = function(force_name)
    if not storage.boss.attack_cache then
        storage.boss.attack_cache = remote.call(force_name .. "_boss_attacks", "get_attack_data")
    end
end

local prepare_attack = function(type)
    local force_name = storage.boss.force_name
    local tier = storage.boss.boss_tier
    fetch_attack_data(force_name)
    local data = select_attack(force_name, storage.boss.attack_cache[type], tier)
    queue_attack(data)
end

local get_despawn_attack = function()
    local force_name = storage.boss.force_name
    local tier = storage.boss.boss_tier
    fetch_attack_data(force_name)
    local data = select_attack(force_name, storage.boss.attack_cache["despawn_attacks"], tier)
    return data
end

local process_attack = function(data, unique_position)
    unique_position = unique_position or false
    data["artillery_mode"] = data["artillery_mode"] or false

    local surface = data["surface"]
    local entity_force = data["entity_force"]
    if not (surface and surface.valid and entity_force and entity_force.valid) or data["position"] == nil then
        DebugHelper.print("not valid surface / force / position")
        return
    end
    local start_position = {
        data["entity_position"]["x"]  + math.random(-8, 8),
        data["entity_position"]["y"] + math.random(-8, 8)
    }
    local entity_name = data["entity_name"]

    if data["artillery_mode"] then
        data["speed"] = 1
        data["range"] = GlobalConfig.BOSS_ARTILLERY_SCAN_RANGE
    end

    for i = 1, data["count"] do
        -- First shot always accurate, subsequent shot varies
        local position = data["position"]
        if i > 1 then
            if unique_position then
                position = pick_near_by_player_entity_position(data["artillery_mode"])
            end

            if data["artillery_mode"] then
                position["x"] = position["x"] + math.random(-16, 16)
                position["y"] = position["y"] + math.random(-16, 16)
            else
                position["x"] = position["x"] + math.random(-8, 8)
                position["y"] = position["y"] + math.random(-8, 8)
            end
        end

        if data["type"] == BossAttackProcessor.TYPE_PROJECTILE then
            surface.create_entity({
                name = entity_name,
                position = start_position,
                target = position,
                speed = data["speed"] or 0.3,
                max_range = data["range"] or 96,
                create_build_effect_smoke = false,
                raise_built = false,
                force = entity_force
            })
        elseif data["type"] == BossAttackProcessor.TYPE_BEAM then
            --- target_position
            --- source_position
            --- duration
            --- source_offset
            surface.create_entity({
                name = entity_name,
                position = position,
                create_build_effect_smoke = false,
                raise_built = false,
                force = entity_force
            })
        end
    end
end

function BossAttackProcessor.unset_attackable_entities_cache()
    storage.boss.attackable_entities_cache = nil
    storage.boss.attackable_entities_cache_size = 0
end

function BossAttackProcessor.exec_basic()
    prepare_attack("basic_attacks")
end

function BossAttackProcessor.exec_advanced()
    prepare_attack("advanced_attacks")
end

function BossAttackProcessor.exec_super()
    prepare_attack("super_attacks")
end

function BossAttackProcessor.exec_phase()

end

function BossAttackProcessor.process_despawn_attack()
    DebugHelper.print("Despawn Attack...")
    BossAttackProcessor.unset_attackable_entities_cache()
    local data = get_despawn_attack()
    for i = 1, data["spread"] do
        local position, artillery_mode = pick_near_by_player_entity_position(true)
        data["artillery_mode"] = artillery_mode
        data["position"] = position
        Cron.add_quick_queue("BossAttackProcessor.process_attack", table.deepcopy(data), true)
    end
end

function BossAttackProcessor.process_attack(data, force)
    if (force ~= true and (data == nil or not storage.boss or not storage.boss.entity or not storage.boss.entity.valid or not data["position"])) then
        return
    end

    process_attack(data)
end

return BossAttackProcessor