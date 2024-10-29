---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 10/23/2021 1:07 PM
---
local String = require("__stdlib__/stdlib/utils/string")
local WeaponHelper = require("prototypes.helper.weapon")

local projectiles = {
    { "pistol-ammo-", 2 },
    { "rifle-ammo-", 4 },
}

for _, projectile in pairs(projectiles) do
    for i = 1, projectile[2], 1 do
        if data.raw.projectile[projectile[1] .. tostring(i)] then
            WeaponHelper.add_air_layer_to_projectile(data.raw.projectile[projectile[1] .. tostring(i)])
        end
    end
end

local aoe_projectiles = {
    { "anti-material-rifle-ammo-", 4 },
}

for _, projectile in pairs(aoe_projectiles) do
    for i = 1, projectile[2], 1 do
        if data.raw.projectile[projectile[1] .. tostring(i)] then
            WeaponHelper.ignore_collision_for_area_damage(data.raw.projectile[projectile[1] .. tostring(i)]["action"]["action_delivery"]["target_effects"])
        end
    end
end



