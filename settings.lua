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
        order = "enemyracemanager-01"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-max-level",
        description = "enemyracemanager-max-level",
        setting_type = "startup",
        default_value = MAX_LEVEL_10,
        allowed_values = { MAX_LEVEL_5, MAX_LEVEL_10, MAX_LEVEL_20 },
        order = "enemyracemanager-02"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-max-attack-range",
        description = "enemyracemanager-max-attack-range",
        setting_type = "startup",
        default_value = ATTACK_RANGE_14,
        allowed_values = { ATTACK_RANGE_14, ATTACK_RANGE_20 },
        order = "enemyracemanager-03"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-enemy-corpse-time",
        description = "enemyracemanager-enemy-corpse-time",
        setting_type = "startup",
        default_value = 15,
        minimum_value = 1,
        maximum_value = 60,
        order = "enemyracemanager-04"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-max-gathering-groups",
        description = "enemyracemanager-max-gathering-groups",
        setting_type = "startup",
        default_value = 15,
        minimum_value = 5,
        maximum_value = 50,
        order = "enemyracemanager-15"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-max-group-size",
        description = "enemyracemanager-max-group-size",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 50,
        maximum_value = 250,
        order = "enemyracemanager-16"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-level-multipliers",
        description = "enemyracemanager-level-multipliers",
        setting_type = "startup",
        default_value = 5,
        minimum_value = 3,
        maximum_value = 20,
        order = "enemyracemanager-100"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-max-hitpoint-multipliers",
        description = "enemyracemanager-max-hitpoint-multipliers",
        setting_type = "startup",
        default_value = 10,
        minimum_value = 5,
        maximum_value = 100,
        order = "enemyracemanager-101"
    },
    {
        type = "double-setting",
        name = "enemyracemanager-score-multipliers",
        description = "enemyracemanager-score-multipliers",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 10,
        order = "enemyracemanager-102"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-mapping-method",
        description = "enemyracemanager-mapping-method",
        setting_type = "startup",
        default_value = MAP_GEN_DEFAULT,
        allowed_values = { MAP_GEN_DEFAULT, MAP_GEN_2_RACES_SPLIT, MAP_GEN_1_RACE_PER_SURFACE },
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
        order = "enemyracemanager-500"
    },

    --- Map Settings Tab ---
    {
        type = "string-setting",
        name = "enemyracemanager-build-style",
        description = "enemyracemanager-build-style",
        setting_type = "runtime-global",
        default_value = BUILDING_DEFAULT,
        allowed_values = { BUILDING_DEFAULT, BUILDING_EXPAND_ON_CMD, BUILDING_A_TOWN, BUILDING_EXPAND_ON_ARRIVAL },
        order = "enemyracemanager-100"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-build-formation",
        description = "enemyracemanager-build-formation",
        setting_type = "runtime-global",
        default_value = BUILDING_FORMATION_1_2_4,
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
}



