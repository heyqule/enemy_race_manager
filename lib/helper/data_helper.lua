---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/21/2020 3:16 PM
--- require('__enemyracemanager__/lib/global_config')
---
require('__stdlib__/stdlib/utils/defines/time')
require('__enemyracemanager__/setting-constants')

local String = require('__stdlib__/stdlib/utils/string')
local Table = require('__stdlib__/stdlib/utils/table')

local ErmDataHelper = {}

ErmDataHelper.getFlyingCollisionMask = function()
    local air_collsion_mask = data.raw['arrow']['collision-mask-flying-layer']['collision_mask']
    table.insert(air_collsion_mask, 'not-colliding-with-itself')
    return air_collsion_mask
end

ErmDataHelper.getFlyingLayerName = function()
    local air_collsion_mask = data.raw['arrow']['collision-mask-flying-layer']['collision_mask'][1]
    return air_collsion_mask
end


return ErmDataHelper