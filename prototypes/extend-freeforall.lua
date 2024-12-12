---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/6/2022 7:38 PM
---
local GlobalConfig = require("__enemyracemanager__/lib/global_config")

local exclude_types = {
    ["tree"] = true,
    ["simple-entity"] = true,
    ["simple-entity-with-owner"] = true,
    ["simple-entity-with-force"] = true,
    ["rocket-silo-rocket-shadow"] = true,
    ["plant"] = true,
    ["asteroid"] = true,
    ["asteroid-chunk"] = true,
}

if settings.startup["enemyracemanager-free-for-all"].value then
    for type_name, types in pairs(data.raw) do
        if not exclude_types[type_name] then
            for entity_name, entity in pairs(types) do
                if type(entity) == "table" and entity.max_health and (entity.subgroup == nil or string.find(entity.subgroup, "enemies") == nil) then
                    -- Prevents a crash from some crazy mods that adds crazy high HP entity.  Ignore all health over 10 million
                    if entity.max_health <= 10000000 then
                        entity.max_health = entity.max_health * GlobalConfig.FFA_MULTIPLIER
                    end

                    if entity.repair_speed_modifier then
                        entity.repair_speed_modifier = entity.repair_speed_modifier * GlobalConfig.FFA_MULTIPLIER
                    else
                        entity.repair_speed_modifier = 1 * GlobalConfig.FFA_MULTIPLIER
                    end
                end

                -- Update vanilla energy shield and adaptive armour in SE
                if type_name == "energy-shield-equipment" and entity.max_shield_value then
                    entity.max_shield_value = entity.max_shield_value * GlobalConfig.FFA_MULTIPLIER

                    if entity.energy_per_shield then
                        local number, unit = string.match(entity.energy_per_shield,"^(%d+%.?%d*)(%a+)$")
                        entity.energy_per_shield = (number / GlobalConfig.FFA_MULTIPLIER) .. unit
                    end
                end

                -- Updates medpack in SE
                if string.find(entity_name, "medpack") ~= nil and entity["capsule_action"] then
                    entity["capsule_action"]["attack_parameters"]["ammo_type"]["action"]["action_delivery"]["target_effects"][2]["damage"]["amount"] = entity["capsule_action"]["attack_parameters"]["ammo_type"]["action"]["action_delivery"]["target_effects"][2]["damage"]["amount"] * GlobalConfig.FFA_MULTIPLIER
                end
            end            
        end
    end
end