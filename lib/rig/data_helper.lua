---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/21/2020 3:16 PM
--- require("__enemyracemanager__/lib/global_config")
---

local DataHelper = {}

DataHelper.getFlyingCollisionMask = function()
    return {layers={flying = true}, not_colliding_with_itself = true}
end

DataHelper.getFlyingLayerName = function()
    return "flying"
end

return DataHelper