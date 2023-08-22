---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/19/2022 10:45 AM
---

require('util')

local super_weapon_attack_points = {
    type = "script",
    effect_id = PLAYER_SUPER_WEAPON_ATTACK,
}

local purifier_weapon_attack_points = {
    type = "script",
    effect_id = PLAYER_PLANET_PURIFIER_ATTACK
}

local super_weapon_counter_attack = {
    type = "script",
    effect_id = PLAYER_SUPER_WEAPON_COUNTER_ATTACK,
}

local purifier_weapon_counter_attack = {
    type = "script",
    effect_id = PLAYER_PLANET_PURIFIER_COUNTER_ATTACK
}

-- base-game Nuclear bomb Projectiles
if data.raw["projectile"]["atomic-rocket"] then
    local entity = util.table.deepcopy(data.raw["projectile"]["atomic-rocket"])
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_attack_points)

    local target_effect_num_7 = entity.action.action_delivery.target_effects[7]
    if target_effect_num_7 and
            target_effect_num_7.type == "damage"
    then
        entity.action.action_delivery.target_effects[7]
                      .damage.type = "radioactive"
    end

    data:extend({ entity })

    -- adjust radioactive damage type for atomic-wave
    local nukeWave = util.table.deepcopy(data.raw['projectile']['atomic-bomb-wave'])
    nukeWave.action[1].action_delivery.target_effects.damage.type = 'radioactive'
    data:extend({
        nukeWave,
    })
end

-- Ion Cannon
if mods['Kux-OrbitalIonCannon'] and data.raw["projectile"]["crosshairs"] then
    local entity = util.table.deepcopy(data.raw["projectile"]["crosshairs"])
    table.insert(entity['action'][1]['action_delivery']['target_effects'], super_weapon_attack_points)
    table.insert(entity['action'][1]['action_delivery']['target_effects'], super_weapon_counter_attack)

    -- (deal ~ 5K damage to lvl20 buildings)
    -- Laser damage
    entity['action'][3]['action_delivery']['target_effects'][1]['damage']['amount'] = math.max(entity['action'][3]['action_delivery']['target_effects'][1]['damage']['amount'], 15000)

    -- Explosion damage
    entity['action'][3]['action_delivery']['target_effects'][2]['damage']['amount'] = math.max(entity['action'][3]['action_delivery']['target_effects'][2]['damage']['amount'], 10000)

    data:extend({ entity })

    local dummy_entity = util.table.deepcopy(data.raw["projectile"]["dummy-crosshairs"])
    table.insert(dummy_entity['action'][1]['action_delivery']['target_effects'], super_weapon_attack_points)
    table.insert(dummy_entity['action'][1]['action_delivery']['target_effects'], super_weapon_counter_attack)

    -- (deal ~ 5K damage to lvl20 buildings)
    -- Laser damage
    dummy_entity['action'][1]['action_delivery']['target_effects'][1]['damage']['amount'] = math.max(dummy_entity['action'][1]['action_delivery']['target_effects'][1]['damage']['amount'], 15000)

    -- Explosion damage
    dummy_entity['action'][1]['action_delivery']['target_effects'][2]['damage']['amount'] = math.max(dummy_entity['action'][1]['action_delivery']['target_effects'][2]['damage']['amount'], 10000)
    data:extend({ dummy_entity })
end

-- MIRVs
if mods['MIRV'] and data.raw["ammo"]["mirv-ammo"] then
    local entity = util.table.deepcopy(data.raw["ammo"]["mirv-ammo"])
    table.insert(entity['ammo_type']['action']['action_delivery']['target_effects'], purifier_weapon_attack_points)
    table.insert(entity['ammo_type']['action']['action_delivery']['target_effects'], purifier_weapon_counter_attack)
    data:extend({ entity })

    -- (deal 1/2 to 2/3 to lvl20 buildings)
    for _, projectile in pairs(data.raw['artillery-projectile']) do
        if string.find(projectile.name, 'mirv-nuke-projectile', 1, true) then
            data.raw['artillery-projectile'][projectile.name]['action']['action_delivery']['target_effects'][1]
            ['action']['action_delivery']['target_effects'][2]['damage']['amount'] = 3000
            data.raw['artillery-projectile'][projectile.name]['action']['action_delivery']['target_effects'][1]
            ['action']['action_delivery']['target_effects'][2]['damage']['type'] = 'explosion'
        end
    end
end

-- Space Exploration
if mods['space-exploration'] and data.raw["projectile"]["se-plague-rocket"] then
    local entity = util.table.deepcopy(data.raw["projectile"]["se-iridium-piledriver"])
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_attack_points)
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_counter_attack)

    --Layer1 10K (30000 @ area 2) (4500 @ 85%)
    entity['action']['action_delivery']['target_effects'][1]['action']['action_delivery']['target_effects'][1]['damage']['amount'] = entity['action']['action_delivery']['target_effects'][1]['action']['action_delivery']['target_effects'][1]['damage']['amount'] * 3

    --Layer2 1000 (10000 @ area 4) (2000 @ 80%)
    entity['action']['action_delivery']['target_effects'][2]['action']['action_delivery']['target_effects'][1]['damage']['amount'] = entity['action']['action_delivery']['target_effects'][2]['action']['action_delivery']['target_effects'][1]['damage']['amount'] * 10

    --Layer3 500 (5000 @ area 8) (1000 @ 80%)
    entity['action']['action_delivery']['target_effects'][3]['action']['action_delivery']['target_effects'][1]['damage']['amount'] = entity['action']['action_delivery']['target_effects'][3]['action']['action_delivery']['target_effects'][1]['damage']['amount'] * 10

    --Layer4 200 (2000 @ area 16) (400 @ 80%)
    entity['action']['action_delivery']['target_effects'][4]['action']['action_delivery']['target_effects'][1]['damage']['amount'] = entity['action']['action_delivery']['target_effects'][4]['action']['action_delivery']['target_effects'][1]['damage']['amount'] * 10

    data:extend({ entity })

    local entity2 = util.table.deepcopy(data.raw["projectile"]["se-plague-rocket"])
    table.insert(entity2['action']['action_delivery']['target_effects'], purifier_weapon_attack_points)

    data:extend({ entity2 })
end

-- Atomic Artillery
if mods['AtomicArtillery'] and data.raw["artillery-projectile"]["atomic-artillery-projectile"] then
    local entity = util.table.deepcopy(data.raw["artillery-projectile"]["atomic-artillery-projectile"])
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_attack_points)
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_counter_attack)
    data:extend({ entity })
end

if mods['IndustrialRevolution'] and data.raw['artillery-projectile']['atomic-artillery-projectile'] then
    local entity = util.table.deepcopy(data.raw["artillery-projectile"]["atomic-artillery-projectile"])
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_attack_points)
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_counter_attack)
    data:extend({ entity })
end

-- K2 antimatter rocket, antimatter-artillery-projectile, atomic-artillery
if mods['Krastorio2'] then
    local entity = util.table.deepcopy(data.raw["artillery-projectile"]["atomic-artillery"])
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_attack_points)
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_counter_attack)
    data:extend({ entity })

    entity = util.table.deepcopy(data.raw["projectile"]["antimatter-rocket-projectile"])
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_attack_points)
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_counter_attack)
    data:extend({ entity })

    entity = util.table.deepcopy(data.raw["artillery-projectile"]["antimatter-artillery-projectile"])
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_attack_points)
    table.insert(entity['action']['action_delivery']['target_effects'], super_weapon_counter_attack)
    data:extend({ entity })
end






