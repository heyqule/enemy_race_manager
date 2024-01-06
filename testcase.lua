---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/5/2024 12:10 AM
---

if script.active_mods["factorio-test"] then
    local config = require('__stdlib__/stdlib/config')
    config.skip_script_protections = true

    local tests = {
        "tests/data_check",
        "tests/attack_beacon",
        "tests/level_and_tier"
    }

    require("__factorio-test__/init")(tests)
    -- the first argument is a list of test files (require paths) to run
end