---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/1/2024 3:58 PM
---
---

for name, node in pairs(data.raw["projectile"]) do
    if string.find(name, "se-falling-meteor",1,true) then
        table.insert(node["action"]["action_delivery"]["target_effects"],  {
            type = "script",
            effect_id = ENVIRONMENTAL_ATTACK
        })
    end
end