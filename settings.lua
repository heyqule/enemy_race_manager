require 'global'
require('setting-constants')

data:extend {
    --- Startup Tab
    {
        type = "bool-setting",
        name = "enemyracemanager-enable-bitters",
        description = "enemyracemanager-enable-bitters",
        setting_type = "startup",
        default_value = true,
        order = "enemyracemanager-100"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-max-level",
        description = "enemyracemanager-max-level",
        setting_type = "startup",
        default_value = MAX_LEVEL_10,
        allowed_values = { MAX_LEVEL_5, MAX_LEVEL_10, MAX_LEVEL_15, MAX_LEVEL_20 },
        order = "enemyracemanager-102"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-max-attack-range",
        description = "enemyracemanager-max-attack-range",
        setting_type = "startup",
        default_value = ATTACK_RANGE_14,
        allowed_values = { ATTACK_RANGE_14, ATTACK_RANGE_20, ATTACK_RANGE_26, ATTACK_RANGE_32, ATTACK_RANGE_40 },
        order = "enemyracemanager-103"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-enemy-corpse-time",
        description = "enemyracemanager-enemy-corpse-time",
        setting_type = "startup",
        default_value = 15,
        minimum_value = 1,
        maximum_value = 60,
        order = "enemyracemanager-104"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-level-multipliers",
        description = "enemyracemanager-level-multipliers",
        setting_type = "startup",
        default_value = 5,
        minimum_value = 3,
        maximum_value = 20,
        order = "enemyracemanager-112"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-evolution-point-ll-express",
        description = "enemyracemanager-evolution-point-ll-express",
        setting_type = "startup",
        order = "enemyracemanager-113",
        default_value = LEVEL_MODE_REGULAR,
        allowed_values = { LEVEL_MODE_REGULAR, LEVEL_MODE_EXPRESS, LEVEL_MODE_SHINKANSEN},
    },
    {
        type = "int-setting",
        name = "enemyracemanager-max-hitpoint-multipliers",
        description = "enemyracemanager-max-hitpoint-multipliers",
        setting_type = "startup",
        default_value = 10,
        minimum_value = 5,
        maximum_value = 100,
        order = "enemyracemanager-114"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-damage-multipliers",
        description = "enemyracemanager-damage-multipliers",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 10,
        order = "enemyracemanager-115"
    },
    {
        type = "double-setting",
        name = "enemyracemanager-running-speed-multipliers",
        description = "enemyracemanager-running-speed-multipliers",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 3,
        allowed_values = { 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3 },
        order = "enemyracemanager-116"
    },
    {
        type = "double-setting",
        name = "enemyracemanager-pollution-to-attack-multipliers",
        description = "enemyracemanager-pollution-to-attack-multipliers",
        setting_type = "startup",
        default_value = 0.025,
        allowed_values = { 0, 0.01, 0.025, 0.05 },
        order = "enemyracemanager-117"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-mapping-method",
        description = "enemyracemanager-mapping-method",
        setting_type = "startup",
        default_value = MAP_GEN_DEFAULT,
        allowed_values = { MAP_GEN_DEFAULT, MAP_GEN_2_RACES_SPLIT, MAP_GEN_4_RACES_SPLIT, MAP_GEN_1_RACE_PER_SURFACE },
        order = "enemyracemanager-201"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-default_enforce_temperature",
        description = "enemyracemanager-default_enforce_temperature",
        setting_type = "startup",
        default_value = false,
        order = "enemyracemanager-202",
    },
    {
        type = "string-setting",
        name = "enemyracemanager-2way-group-enemy-orientation",
        description = "enemyracemanager-2way-group-enemy-orientation",
        setting_type = "startup",
        default_value = X_AXIS,
        order = "enemyracemanager-205",
        allowed_values = { X_AXIS, Y_AXIS }
    },
    {
        type = "int-setting",
        name = "enemyracemanager-2way-group-split-point",
        description = "enemyracemanager-2way-group-split-point",
        setting_type = "startup",
        default_value = 0,
        minimum_value = -900000,
        maximum_value = 900000,
        order = "enemyracemanager-206",
    },
    {
        type = "string-setting",
        name = "enemyracemanager-2way-group-enemy-positive",
        description = "enemyracemanager-2way-group-enemy-positive",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-207",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },
    {
        type = "string-setting",
        name = "enemyracemanager-2way-group-enemy-negative",
        description = "enemyracemanager-2way-group-enemy-negative",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-208",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },
    {
        type = "int-setting",
        name = "enemyracemanager-4way-x-axis",
        description = "enemyracemanager-4way-x-axis",
        setting_type = "startup",
        default_value = 0,
        minimum_value = -900000,
        maximum_value = 900000,
        order = "enemyracemanager-220",
    },
    {
        type = "int-setting",
        name = "enemyracemanager-4way-y-axis",
        description = "enemyracemanager-4way-y-axis",
        setting_type = "startup",
        default_value = 0,
        minimum_value = -900000,
        maximum_value = 900000,
        order = "enemyracemanager-221",
    },
    {
        type = "string-setting",
        name = "enemyracemanager-4way-top-left",
        description = "enemyracemanager-4way-top-left",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-222",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },
    {
        type = "string-setting",
        name = "enemyracemanager-4way-top-right",
        description = "enemyracemanager-4way-top-right",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-223",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },
    {
        type = "string-setting",
        name = "enemyracemanager-4way-bottom-right",
        description = "enemyracemanager-4way-bottom-right",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-224",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },
    {
        type = "string-setting",
        name = "enemyracemanager-4way-bottom-left",
        description = "enemyracemanager-4way-bottom-left",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-225",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-enhance-defense",
        description = "enemyracemanager-enhance-defense",
        setting_type = "startup",
        default_value = true,
        order = "enemyracemanager-300"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-disable-friendly-fire",
        description = "enemyracemanager-disable-friendly-fire",
        setting_type = "startup",
        default_value = true,
        order = "enemyracemanager-300"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-attack-meter-group-interval",
        description = "enemyracemanager-attack-meter-group-interval",
        setting_type = "startup",
        default_value = 3,
        order = "enemyracemanager-500",
        allowed_values = { 1, 2, 3, 4, 5, 6, 7, 10 }
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-free-for-all",
        description = "enemyracemanager-free-for-all",
        setting_type = "startup",
        default_value = false,
        order = "enemyracemanager-601",
    },
    {
        type = "int-setting",
        name = "enemyracemanager-free-for-all-multiplier",
        description = "enemyracemanager-free-for-all-multiplier",
        setting_type = "startup",
        default_value = 10,
        allowed_values = { 5, 8, 10, 12, 15 },
        order = "enemyracemanager-602",
    },
    {
        type = "string-setting",
        name = "enemyracemanager-boss-difficulty",
        description = "enemyracemanager-boss-difficulty",
        setting_type = "startup",
        default_value = BOSS_NORMAL,
        allowed_values = { BOSS_NORMAL, BOSS_HARD, BOSS_GODLIKE },
        order = "enemyracemanager-700",
    },
    {
        type = "string-setting",
        name = "enemyracemanager-boss-unit-spawn-size",
        description = "enemyracemanager-boss-unit-spawn-size",
        setting_type = "startup",
        default_value = BOSS_SPAWN_SQUAD,
        allowed_values = { BOSS_SPAWN_SQUAD, BOSS_SPAWN_PATROL, BOSS_SPAWN_PLATOON },
        order = "enemyracemanager-701",
    },
    {
        type = "int-setting",
        name = "enemyracemanager-unit-framework-timeout",
        description = "enemyracemanager-unit-framework-timeout",
        setting_type = "startup",
        default_value = 15,
        allowed_values = { 5, 15, 30, 60, 1440, 43200 },
        order = "enemyracemanager-801",
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-unit-framework-start-auto-deploy",
        description = "enemyracemanager-unit-start-auto-deploy",
        setting_type = "startup",
        default_value = false,
        order = "enemyracemanager-802",
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-menu-replacement-framework",
        description = "enemyracemanager-menu-replacement-framework",
        setting_type = "startup",
        default_value = true,
        order = "enemyracemanager-1100"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-menu-replacement-race",
        description = "enemyracemanager-menu-replacement-race",
        setting_type = "startup",
        default_value = MOD_NAME,
        allowed_values = {MOD_NAME},
        order = "enemyracemanager-1100"
    },
    --- Range 1000 to 1100 reserve for map color changes
    {
        type = "color-setting",
        name = "erm_vanilla-map-color",
        description = "erm_vanilla-map-color",
        setting_type = "startup",
        default_value = VANILLA_MAP_COLOR,
        order = "enemyracemanager-1001"
    },
    --- Map Settings Tab ---
    {
        type = "int-setting",
        name = "enemyracemanager-max-gathering-groups",
        description = "enemyracemanager-max-gathering-groups",
        setting_type = "runtime-global",
        default_value = 30,
        minimum_value = 10,
        maximum_value = 100,
        order = "enemyracemanager-001"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-max-group-size",
        description = "enemyracemanager-max-group-size",
        setting_type = "runtime-global",
        default_value = 100,
        minimum_value = 50,
        maximum_value = 1000,
        order = "enemyracemanager-002"
    },
    {
        type = "double-setting",
        name = "enemyracemanager-army-limit-multiplier",
        description = "enemyracemanager-army-limit-multiplier",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 5,
        allowed_values = { 1, 1.25, 1.33, 1.5, 2, 2.5, 3, 4, 5 },
        order = "enemyracemanager-003"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-build-style",
        description = "enemyracemanager-build-style",
        setting_type = "runtime-global",
        default_value = BUILDING_A_TOWN,
        allowed_values = { BUILDING_DEFAULT, BUILDING_EXPAND_ON_CMD, BUILDING_A_TOWN, BUILDING_EXPAND_ON_ARRIVAL },
        order = "enemyracemanager-100"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-build-formation",
        description = "enemyracemanager-build-formation",
        setting_type = "runtime-global",
        default_value = BUILDING_FORMATION_1_4_5,
        allowed_values = {
            BUILDING_FORMATION_1_1_2,
            BUILDING_FORMATION_1_2_4,
            BUILDING_FORMATION_1_3_8,
            BUILDING_FORMATION_1_4_5,
            BUILDING_FORMATION_1_4_15,
            BUILDING_FORMATION_1_6_8,
            BUILDING_FORMATION_1_8_11,
            BUILDING_FORMATION_1_9_0,
            BUILDING_FORMATION_1_9_10,
            BUILDING_FORMATION_RANDOM
        },
        order = "enemyracemanager-101"
    },
    --- Evolution Point and level up ---
    {
        type = "double-setting",
        name = "enemyracemanager-evolution-point-multipliers",
        description = "enemyracemanager-evolution-point-multipliers",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 0.1,
        maximum_value = 10,
        order = "enemyracemanager-201"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-evolution-point-spawner-kills-deduction",
        description = "enemyracemanager-evolution-point-spawner-kills-deduction",
        setting_type = "runtime-global",
        default_value = false,
        order = "enemyracemanager-202"
    },
    --- Attack Meters ---
    {
        type = "bool-setting",
        name = "enemyracemanager-attack-meter-enable",
        description = "enemyracemanager-attack-meter-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-300"
    },
    {
        type = "double-setting",
        name = "enemyracemanager-attack-meter-threshold",
        description = "enemyracemanager-attack-meter-threshold",
        setting_type = "runtime-global",
        default_value = 1.25,
        minimum_value = 1,
        maximum_value = 10,
        order = "enemyracemanager-301"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-attack-meter-threshold-deviation",
        description = "enemyracemanager-attack-meter-threshold-deviation",
        setting_type = "runtime-global",
        default_value = 10,
        allowed_values = { 5, 10, 15, 20, 25 },
        order = "enemyracemanager-302"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-attack-meter-collector-multiplier",
        description = "enemyracemanager-attack-meter-collector-multiplier",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 10,
        order = "enemyracemanager-303"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-rocket-attack-point-enable",
        description = "enemyracemanager-rocket-attack-point-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-310"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-rocket-attack-point",
        description = "enemyracemanager-rocket-attack-point",
        setting_type = "runtime-global",
        default_value = 200,
        minimum_value = 100,
        maximum_value = 10000,
        order = "enemyracemanager-311"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-super-weapon-attack-point-enable",
        description = "enemyracemanager-super-weapon-attack-point-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-312"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-super-weapon-attack-point",
        description = "enemyracemanager-super-weapon-attack-point",
        setting_type = "runtime-global",
        default_value = 300,
        minimum_value = 100,
        maximum_value = 10000,
        order = "enemyracemanager-313"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-super-weapon-counter-attack-enable",
        description = "enemyracemanager-super-weapon-counter-attack-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-314"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-flying-squad-enable",
        description = "enemyracemanager-flying-squad-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-400"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-flying-squad-chance",
        description = "enemyracemanager-flying-squad-chance",
        setting_type = "runtime-global",
        default_value = 25,
        allowed_values = { 10, 20, 25, 33, 50, 66, 75, 80, 90 },
        order = "enemyracemanager-401"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-dropship-squad-enable",
        description = "enemyracemanager-dropship-squad-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-402"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-dropship-squad-chance",
        description = "enemyracemanager-dropship-squad-chance",
        setting_type = "runtime-global",
        default_value = 25,
        allowed_values = { 10, 20, 25, 33, 50, 66, 75, 80, 90 },
        order = "enemyracemanager-403"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-featured-squad-chance",
        description = "enemyracemanager-featured-squad-chance",
        setting_type = "runtime-global",
        default_value = 33,
        allowed_values = { 10, 20, 25, 33, 50, 66, 75, 80, 90 },
        order = "enemyracemanager-405"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-elite-squad-enable",
        description = "enemyracemanager-elite-squad-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-407"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-elite-squad-attack-points",
        description = "enemyracemanager-elite-squad-attack-points",
        setting_type = "runtime-global",
        default_value = 45000,
        minimum_value = 10000,
        maximum_value = 100000,
        order = "enemyracemanager-408"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-elite-squad-level",
        description = "enemyracemanager-elite-squad-level",
        setting_type = "runtime-global",
        default_value = 2,
        allowed_values = {1,2,3,4,5},
        order = "enemyracemanager-409"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-precision-strike-flying-unit-enable",
        description = "enemyracemanager-precision-strike-flying-unit-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-440"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-precision-strike-flying-unit-chance",
        description = "enemyracemanager-precision-strike-flying-unit-chance",
        setting_type = "runtime-global",
        default_value = 25,
        allowed_values = { 10, 20, 25, 33, 50, 66, 75, 80, 90 },
        order = "enemyracemanager-441"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-precision-strike-warning",
        description = "enemyracemanager-precision-strike-warning",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-442"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-time-based-enable",
        description = "enemyracemanager-time-based-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-450"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-time-based-points",
        description = "enemyracemanager-time-based-points",
        setting_type = "runtime-global",
        default_value = 2,
        allowed_values = { 1, 2, 3, 5, 8, 10, 15, 20, 33, 50, 75 },
        order = "enemyracemanager-451"
    },
}



