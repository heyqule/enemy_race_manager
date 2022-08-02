---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/24/2020 2:50 PM
--- require('__enemyracemanager__/lib/debug_helper')
---
local DebugHelper = {}

local titleCase = function(first, rest)
    return first:upper() .. rest:lower()
end

local fixName = function(name)
    local fixed_name = string.gsub(name, "(%a)([%w_']*)", titleCase)
    fixed_name = string.gsub(fixed_name, "_", " ")
    return fixed_name
end

function DebugHelper.print_translate_to_console(mode_name, name, level)
    -- Print translate to console
    log(mode_name .. '/' .. name .. '/' .. level .. '=' .. fixName(name) .. ' L' .. level)
end

function DebugHelper.print(message)
    if DEBUG_MODE then
        log(message)
    end
end

return DebugHelper