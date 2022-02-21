---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 2/19/2022 10:45 AM
---

require('util')

local super_custom_attack = {
    type = "script",
    effect_id = PLAYER_SUPER_WEAPON_ATTACK,
}

local purifier_custom_attack = {
    type = "script",
    effect_id = PLAYER_PLANET_PURIFIER_ATTACK
}

-- base-game Nuclear bomb Projectiles
if data.raw["projectile"]["atomic-rocket"] then
    local entity = util.table.deepcopy(data.raw["projectile"]["atomic-rocket"])
    table.insert(entity['action']['action_delivery']['target_effects'], super_custom_attack)
    data:extend({entity})
end

-- Ion Cannon
if mods['Kux-OrbitalIonCannon'] and data.raw["projectile"]["crosshairs"] then
    local entity = util.table.deepcopy(data.raw["projectile"]["crosshairs"])
    table.insert(entity['action'][1]['action_delivery']['target_effects'], super_custom_attack)
    data:extend({entity})
end

-- MIRVs
if mods['MIRV'] and data.raw["ammo"]["mirv-ammo"] then
    local entity = util.table.deepcopy(data.raw["ammo"]["mirv-ammo"])
    table.insert(entity['ammo_type']['action']['action_delivery']['target_effects'], purifier_custom_attack)
    data:extend({entity})
end

-- Space Exploration
if mods['space-exploration'] and data.raw["projectile"]["se-plague-rocket"] then
    local entity = util.table.deepcopy(data.raw["projectile"]["se-iridium-piledriver"])
    table.insert(entity['action']['action_delivery']['target_effects'], super_custom_attack)
    data:extend({entity})

    local entity2 = util.table.deepcopy(data.raw["projectile"]["se-plague-rocket"])
    table.insert(entity2['action']['action_delivery']['target_effects'], purifier_custom_attack)
    data:extend({entity2})
end

-- Atomic Artillery
if mods['AtomicArtillery'] and data.raw["artillery-projectile"]["atomic-artillery-projectile"] then
    local entity = util.table.deepcopy(data.raw["artillery-projectile"]["atomic-artillery-projectile"])
    table.insert(entity['action']['action_delivery']['target_effects'], super_custom_attack)
    data:extend({entity})
end






