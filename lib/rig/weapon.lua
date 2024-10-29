---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/3/2021 10:21 PM
---
local util = require("util")
local ERM_WeaponRig = {}

function ERM_WeaponRig.get_bullet(category)
    local ammo_type = util.table.deepcopy(data.raw["ammo"]["firearm-magazine"]["ammo_type"])
    if category then
        ammo_type["category"] = category
    end
    return ammo_type
end

function ERM_WeaponRig.get_shotgun_bullet(category)
    local ammo_type = util.table.deepcopy(data.raw["ammo"]["shotgun-shell"]["ammo_type"])
    if category then
        ammo_type["category"] = category
    end
    return ammo_type
end

--- single target damage, small AOE
function ERM_WeaponRig.standardize_cannon_projectile(data, name)
    data["name"] = name
    data["piercing_damage"] = 5000
    data["action"]["action_delivery"]["target_effects"][1] = {
        type = "damage",
        damage = { amount = 5, type = "physical" }
    }
    data["action"]["action_delivery"]["target_effects"][2] = {
        type = "damage",
        damage = { amount = 2, type = "explosion" }
    }
    data["final_action"]["action_delivery"]["target_effects"][2] = {
        type = "nested-result",
        action = {
            type = "area",
            force = "not-same",
            radius = 2,
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "damage",
                        damage = { amount = 3, type = "explosion" }
                    }
                }
            }
        }
    }
    return data
end

--- small target damage, large AOE damage
function ERM_WeaponRig.standardize_explosive_cannon_projectile(data, name)
    data["name"] = name
    data["piercing_damage"] = 5000
    data["action"]["action_delivery"]["target_effects"][1] = {
        type = "damage",
        damage = { amount = 3.5, type = "explosion" }
    }
    data["final_action"]["action_delivery"]["target_effects"][2] = {
        type = "nested-result",
        action = {
            type = "area",
            force = "not-same",
            radius = 4,
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "damage",
                        damage = { amount = 6.5, type = "explosion" }
                    },
                    {
                        type = "create-entity",
                        entity_name = "explosion"
                    }
                }
            }
        }
    }

    return data
end

function ERM_WeaponRig.standardize_rocket_damage(data, name)
    data["name"] = name
    data["action"]["action_delivery"]["target_effects"][2] = {
        type = "damage",
        damage = { amount = 10, type = "explosion" }
    }
    return data
end

return ERM_WeaponRig