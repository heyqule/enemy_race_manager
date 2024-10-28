---
--- Created by IntelliJ IDEA.
--- User: heyqule
--- Date: 12/15/2020
--- Time: 9:59 PM
--- To change this template use File | Settings | File Templates.
--- require('__enemyracemanager__/lib/rig/unit_tint')
---
require('__stdlib__/stdlib/utils/defines/color')
local ERM_UnitTint = {}

function ERM_UnitTint.tint_shadow()
    return { r = 0, g = 0, b = 0, a = 192 }
end

function ERM_UnitTint.tint_dragoon_ball_light()
    return { r = 135, g = 206, b = 235, a = 255 }
end

function ERM_UnitTint.tint_plane_burner()
    return { r = 255, g = 179, b = 39, a = 255 }
end

function ERM_UnitTint.tint_blue_flame_burner()
    return { r = 110, g = 210, b = 255, a = 255 }
end

function ERM_UnitTint.tint_archon_light()
    return { r = 0, g = 100, b = 255, a = 255 }
end

function ERM_UnitTint.tint_darkarchon_light()
    return { r = 255, g = 80, b = 0, a = 1 }
end

function ERM_UnitTint.tint_cold()
    return { r = 153, g = 250, b = 220, a = 85 }
end

function ERM_UnitTint.tint_acid()
    return { r = 143, g = 254, b = 9, a = 85 }
end

function ERM_UnitTint.tint_cold_explosion()
    return { r = 153, g = 250, b = 220, a = 255 }
end

function ERM_UnitTint.tint_acid_explosion()
    return { r = 143, g = 254, b = 9, a = 255 }
end

function ERM_UnitTint.tint_red()
    return { r = 255, g = 0, b = 0, a = 255 }
end

function ERM_UnitTint.tint_red_madder()
    return { r = 165, g = 0, b = 33, a = 255 }
end

function ERM_UnitTint.tint_red_crimson()
    return { r = 220, g = 20, b = 60, a = 255 }
end

function ERM_UnitTint.tint_army_color()
    return { r = 69, g = 225, b = 27, a = 255 }
end

function ERM_UnitTint.tint_green()
    return { r = 0, g = 255, b = 0, a = 255 }
end

function ERM_UnitTint.tint_purple()
    return { r = 128, g = 0, b = 128, a = 255 }
end

function ERM_UnitTint.mask_tint(layer, color)
    layer['tint'] = color
    layer['apply_runtime_tint'] = false
end

return ERM_UnitTint