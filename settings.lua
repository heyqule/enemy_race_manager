require "global"
require("setting-constants")

data:extend {
    {
        type = "string-setting",
        name = "enemyracemanager-nauvis-enemy",
        description = "enemyracemanager-nauvis-enemy",
        setting_type = "startup",
        default_value = 'enemy',
        allowed_values = { NAUVIS_MIXED, NAUVIS_2_WAY, NAUVIS_4_WAY, 'enemy' },
        order = "enemyracemanager-100"
    },
    --- Biter related
    {
        type = "int-setting",
        name = "enemyracemanager-max-attack-range",
        description = "enemyracemanager-max-attack-range",
        setting_type = "startup",
        default_value = ATTACK_RANGE_14,
        allowed_values = { ATTACK_RANGE_14, ATTACK_RANGE_20, ATTACK_RANGE_26, ATTACK_RANGE_32, ATTACK_RANGE_40 },
        order = "enemyracemanager-104"
    },

    {
        type = "int-setting",
        name = "enemyracemanager-max-hitpoint-multipliers",
        description = "enemyracemanager-max-hitpoint-multipliers",
        setting_type = "startup",
        default_value = 20,
        minimum_value = 10,
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
        default_value = 0.2,
        allowed_values = { 0, 0.05, 0.1, 0.2 },
        order = "enemyracemanager-117"
    },
    --- Startup: Map Generation

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
        type = "string-setting",
        name = "enemyracemanager-4way-northeast",
        description = "enemyracemanager-4way-northeast",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-222",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },
    {
        type = "string-setting",
        name = "enemyracemanager-4way-northwest",
        description = "enemyracemanager-4way-northwest",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-223",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },
    {
        type = "string-setting",
        name = "enemyracemanager-4way-southwest",
        description = "enemyracemanager-4way-southwest",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-224",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },
    {
        type = "string-setting",
        name = "enemyracemanager-4way-southeast",
        description = "enemyracemanager-4way-southeast",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-225",
        allowed_values = { RACE_EMPTY, MOD_NAME }
    },

    --- Startup: Defense
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
        order = "enemyracemanager-301"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-rail-entities-indestructible",
        description = "enemyracemanager-rail-entities-indestructible",
        setting_type = "startup",
        default_value = true,
        allowed_values = false,
        order = "enemyracemanager-302",
    },
    {
        type = "string-setting",
        name = "enemyracemanager-rail-entities-indestructible-planets",
        description = "enemyracemanager-rail-entities-indestructible-planets",
        setting_type = "startup",
        default_value = "fulgora",
        order = "enemyracemanager-302"
    },
    --- Startup: Free for All
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
    --- Startup: Boss
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
        name = "enemyracemanager-attacks-unit-spawn-size",
        description = "enemyracemanager-attacks-unit-spawn-size",
        setting_type = "startup",
        default_value = BOSS_SPAWN_SQUAD,
        allowed_values = { BOSS_SPAWN_SQUAD, BOSS_SPAWN_PATROL, BOSS_SPAWN_PLATOON },
        order = "enemyracemanager-701",
    },
    --- Startup: RTS Unit framework
    {
        type = "int-setting",
        name = "enemyracemanager-unit-deployer-timeout",
        description = "enemyracemanager-unit-deployer-timeout",
        setting_type = "startup",
        default_value = 15,
        allowed_values = { 5, 15, 30, 60, 1440, 43200 },
        order = "enemyracemanager-801",
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-unit-deployer-auto-start",
        description = "enemyracemanager-unit-start-auto-deploy",
        setting_type = "startup",
        default_value = false,
        order = "enemyracemanager-802",
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
    --- Army related
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
        name = "enemyracemanager-difficulty",
        description = "enemyracemanager-difficulty",
        setting_type = "runtime-global",
        default_value = QUALITY_NORMAL,
        allowed_values = { QUALITY_CASUAL, QUALITY_NORMAL, QUALITY_ADVANCED, QUALITY_HARDCORE, QUALITY_FIGHTER, QUALITY_CRUSADER, QUALITY_THEONE },
        order = "enemyracemanager-004"
    },
    {
        type = "double-setting",
        name = "enemyracemanager-advancement",
        description = "enemyracemanager-advancement",
        setting_type = "runtime-global",
        default_value = 1,
        allowed_values = { 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2 },
        order = "enemyracemanager-005"
    },
    --- Custom base style
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
    --- Attack Meters and custom attack groups ---
    {
        type = "double-setting",
        name = "enemyracemanager-attack-meter-threshold",
        description = "enemyracemanager-attack-meter-threshold",
        setting_type = "runtime-global",
        default_value = 1.25,
        minimum_value = 1,
        maximum_value = 10,
        order = "enemyracemanager-300"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-attack-meter-threshold-deviation",
        description = "enemyracemanager-attack-meter-threshold-deviation",
        setting_type = "runtime-global",
        default_value = 10,
        allowed_values = { 5, 10, 15, 20, 25 },
        order = "enemyracemanager-301"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-attack-meter-collector-multiplier",
        description = "enemyracemanager-attack-meter-collector-multiplier",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 10,
        order = "enemyracemanager-302"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-attack-point-spawner-kills-deduction",
        description = "enemyracemanager-attack-point-spawner-kills-deduction",
        setting_type = "runtime-global",
        default_value = false,
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
        default_value = 20,
        minimum_value = 10,
        maximum_value = 1000,
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
        maximum_value = 1000,
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
    --- Time based Raids
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
        allowed_values = { 1, 2, 3, 5, 8, 10, 15, 20, 33, 50},
        order = "enemyracemanager-451"
    },

    --- Interplanetary Raids
    {
        type = "bool-setting",
        name = "enemyracemanager-interplanetary-raids",
        description = "enemyracemanager-interplanetary-raids",
        setting_type = "runtime-global",
        default_value = true,
        order = "enemyracemanager-910",
    },
    {
        type = "int-setting",
        name = "enemyracemanager-interplanetary-raids-spawn-chance",
        description = "enemyracemanager-interplanetary-raids-spawn-chance",
        setting_type = "runtime-global",
        default_value = 20,
        allowed_values = {5, 10, 20, 25, 33, 50},
        order = "enemyracemanager-910",
    },
    {
        type = "int-setting",
        name = "enemyracemanager-interplanetary-raids-build-base-chance",
        description = "enemyracemanager-interplanetary-raid-build-base-chance",
        setting_type = "runtime-global",
        default_value = 25,
        allowed_values = {5, 10, 20, 25, 33, 50},
        order = "enemyracemanager-911"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-enemy-corpse-time",
        description = "enemyracemanager-enemy-corpse-time",
        setting_type = "startup",
        default_value = 15,
        minimum_value = 1,
        maximum_value = 60,
        order = "enemyracemanager-980"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-auto-creep-removal",
        description = "enemyracemanager-auto-creep-removal",
        setting_type = "startup",
        default_value = true,
        order = "enemyracemanager-981"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-factoriopedia-level",
        default_value = 1,
        setting_type = "startup",
        allowed_values = { 1, 2, 3, 4, 5 },
        order = "enemyracemanager-982"
    },
    {
        type = "color-setting",
        name = "enemy-map-color",
        description = "enemy-map-color",
        setting_type = "startup",
        default_value = VANILLA_MAP_COLOR,
        order = "enemyracemanager-991"
    },
}



