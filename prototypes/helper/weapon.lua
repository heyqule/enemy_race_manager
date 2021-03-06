---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/1/2021 10:41 PM
---
local ERMDataHelper = require('__enemyracemanager__/lib/helper/data_helper')
local ERM_WeaponDataHelper = {}

-- Change rocket/cannon area explosives to hit all units
function ERM_WeaponDataHelper.ignore_collision_for_area_damage(target_effects)
    for i, effect in pairs(target_effects) do
        if effect['type'] == "nested-result" and effect['action']['type'] == 'area' then
            effect['action']['ignore_collision_condition'] = true
        end
    end
end

function ERM_WeaponDataHelper.add_air_layer_to_projectile(projectile)
    local air_layer = ERMDataHelper.getFlyingLayerName()
    if projectile['hit_collision_mask'] == nil then
        projectile['hit_collision_mask'] = { 'train-layer', 'player-layer', air_layer}
    else
        projectile['hit_collision_mask'] = table.insert(projectile['hit_collision_mask'], air_layer)
    end
end

function ERM_WeaponDataHelper.change_piercing_damage(projectile, value)
    projectile['piercing_damage'] = value
end

return ERM_WeaponDataHelper