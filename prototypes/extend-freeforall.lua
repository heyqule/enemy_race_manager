---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/6/2022 7:38 PM
---
local ErmConfig = require('__enemyracemanager__/lib/global_config')

if settings.startup['enemyracemanager-free-for-all'].value then
    for type_name, types in pairs(data.raw) do
        for entity_name, entity in pairs(types) do
            if type(entity) == 'table' and entity.max_health and (entity.subgroup == nil or string.find(entity.subgroup, 'enemies') == nil) then
                -- Prevents a crash from some crazy mod with crazy high HP entity.  Ignore all health over 10 million
                if entity.max_health <= 10000000 then
                    entity.max_health = entity.max_health * ErmConfig.FFA_MULTIPLIER * 1.25
                end

                if  entity.repair_speed_modifier then
                    entity.repair_speed_modifier = entity.repair_speed_modifier * ErmConfig.FFA_MULTIPLIER
                else
                    entity.repair_speed_modifier = 1 * ErmConfig.FFA_MULTIPLIER
                end
            end

            -- Update vanilla energy shield and adaptive armour in SE
            if type_name == 'energy-shield-equipment' and entity.max_shield_value then
                entity.max_shield_value = entity.max_shield_value * ErmConfig.FFA_MULTIPLIER

                if entity.energy_per_shield then
                    local energy_per_shield = tonumber(string.sub(entity.energy_per_shield, 1, string.len(entity.energy_per_shield) - 2))
                    local energy_unit = string.sub(entity.energy_per_shield,  string.len(entity.energy_per_shield) - 1)
                    entity.energy_per_shield = (energy_per_shield / ErmConfig.FFA_MULTIPLIER)..energy_unit
                end
            end

            -- Updates medpack in SE
            if string.find(entity_name,"medpack") ~= nil and entity['capsule_action'] then
                entity['capsule_action']['attack_parameters']['ammo_type']['action']['action_delivery']['target_effects'][2]['damage']['amount']
                    = entity['capsule_action']['attack_parameters']['ammo_type']['action']['action_delivery']['target_effects'][2]['damage']['amount'] * ErmConfig.FFA_MULTIPLIER
            end
        end
    end


end