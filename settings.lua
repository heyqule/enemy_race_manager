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
        order = "enemyracemanager-101"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-level-curve-multiplier",
        description = "enemyracemanager-level-curve-multiplier",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 10,
        order = "enemyracemanager-102"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-max-attack-range",
        description = "enemyracemanager-max-attack-range",
        setting_type = "startup",
        default_value = ATTACK_RANGE_14,
        allowed_values = { ATTACK_RANGE_14, ATTACK_RANGE_20 },
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
        name = "enemyracemanager-max-gathering-groups",
        description = "enemyracemanager-max-gathering-groups",
        setting_type = "startup",
        default_value = 15,
        minimum_value = 1,
        maximum_value = 50,
        order = "enemyracemanager-110"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-max-group-size",
        description = "enemyracemanager-max-group-size",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 50,
        maximum_value = 1000,
        order = "enemyracemanager-111"
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
        type = "int-setting",
        name = "enemyracemanager-max-hitpoint-multipliers",
        description = "enemyracemanager-max-hitpoint-multipliers",
        setting_type = "startup",
        default_value = 10,
        minimum_value = 5,
        maximum_value = 100,
        order = "enemyracemanager-113"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-damage-multipliers",
        description = "enemyracemanager-damage-multipliers",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 10,
        order = "enemyracemanager-114"
    },
    {
        type = "double-setting",
        name = "enemyracemanager-running-speed-multipliers",
        description = "enemyracemanager-running-speed-multipliers",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 3,
        allowed_values = { 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3},
        order = "enemyracemanager-115"
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
        type = "string-setting",
        name = "enemyracemanager-2way-group-enemy-orientation",
        description = "enemyracemanager-2way-group-enemy-orientation",
        setting_type = "startup",
        default_value = X_AXIS,
        order = "enemyracemanager-202",
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
        order = "enemyracemanager-203",
    },
    {
        type = "string-setting",
        name = "enemyracemanager-2way-group-enemy-positive",
        description = "enemyracemanager-2way-group-enemy-positive",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-204",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },
    {
        type = "string-setting",
        name = "enemyracemanager-2way-group-enemy-negative",
        description = "enemyracemanager-2way-group-enemy-negative",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-205",
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
        name = "enemyracemanager-ground-weapon-hit-air",
        description = "enemyracemanager-ground-weapon-hit-air",
        setting_type = "startup",
        default_value = false,
        order = "enemyracemanager-400"
    },

    {
        type = "bool-setting",
        name = "enemyracemanager-ground-weapon-hit-air",
        description = "enemyracemanager-ground-weapon-hit-air",
        setting_type = "startup",
        default_value = false,
        order = "enemyracemanager-401"
    },

    {
        type = "int-setting",
        name = "enemyracemanager-attack-meter-group-interval",
        description = "enemyracemanager-attack-meter-group-interval",
        setting_type = "startup",
        default_value = 3,
        order = "enemyracemanager-500",
        allowed_values = { 1, 2, 3, 4, 5, 10 }
    },
    --- Map Settings Tab ---
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
            BUILDING_FORMATION_1_2_4,
            BUILDING_FORMATION_1_4_5,
            BUILDING_FORMATION_1_6_8,
            BUILDING_FORMATION_1_8_12,
            BUILDING_FORMATION_1_4_10,
            BUILDING_FORMATION_1_2_16,
            BUILDING_FORMATION_1_3_8,
            BUILDING_FORMATION_1_9_0,
            BUILDING_FORMATION_RANDOM
        },
        order = "enemyracemanager-101"
    },
    --- Evolution Point and level up ---
    {
        type = "bool-setting",
        name = "enemyracemanager-evolution-point-accelerator",
        description = "enemyracemanager-evolution-point-accelerator",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-200"
    },
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
        default_value = 1.5,
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
        type = "bool-setting",
        name = "enemyracemanager-precision-strike-flying-unit-enable",
        description = "enemyracemanager-precision-strike-flying-unit-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-404"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-precision-strike-flying-unit-chance",
        description = "enemyracemanager-precision-strike-flying-unit-chance",
        setting_type = "runtime-global",
        default_value = 25,
        allowed_values = { 10, 20, 25, 33, 50, 66, 75, 80, 90 },
        order = "enemyracemanager-405"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-precision-strike-warning",
        description = "enemyracemanager-precision-strike-warning",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-406"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-time-based-enable",
        description = "enemyracemanager-time-based-enable",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-420"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-time-based-points",
        description = "enemyracemanager-time-based-points",
        setting_type = "runtime-global",
        default_value = 2,
        allowed_values = {1, 2, 3, 5, 8, 10, 15, 20},
        order = "enemyracemanager-421"
    },
}



