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
local util = require("util")

local ErmDataHelper = {}

ErmDataHelper.getFlyingCollisionMask = function()
    local air_collision_mask = util.table.deepcopy(data.raw['arrow']['collision-mask-flying-layer']['collision_mask'])
    Table.insert(air_collision_mask, 'not-colliding-with-itself')
    return air_collision_mask
end

ErmDataHelper.getFlyingLayerName = function()
    local air_collision_mask = util.table.deepcopy(data.raw['arrow']['collision-mask-flying-layer']['collision_mask'][1])
    return air_collision_mask
end

return ErmDataHelper