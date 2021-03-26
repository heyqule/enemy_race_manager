---
--- Created by IntelliJ IDEA.
--- User: heyqule
--- Date: 12/15/2020
--- Time: 9:59 PM
--- To change this template use File | Settings | File Templates.
--- require('__enemyracemanager__/lib/unit_tint')
---
require('__stdlib__/stdlib/utils/defines/color')
local ERM_UnitTint = {}

function ERM_UnitTint.tint_shadow()
    return { r = 0, g = 0, b = 0, a = 0.5 }
end

function ERM_UnitTint.tint_dragoon_ball_light()
    return { r = 135, g = 206, b = 235, a = 1 }
end

function ERM_UnitTint.tint_plane_burner()
    return { r = 255, g = 179, b = 39, a = 1 }
end

function ERM_UnitTint.tint_blue_flame_burner()
    return { r = 110, g = 210, b = 255, a = 1 }
end

return ERM_UnitTint