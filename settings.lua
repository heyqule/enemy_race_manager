require 'global'

data:extend {
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
        default_value = "Normal - Max L10",
        allowed_values = { "Casual - Max L5", "Normal - Max L10", "Advanced - Max L20" },
        order = "enemyracemanager-02"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-max-attack-range",
        description = "enemyracemanager-max-attack-range",
        setting_type = "startup",
        default_value = "Normal - 14",
        allowed_values = { "Normal - 14", "Advanced - 20" },
        order = "enemyracemanager-03"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-enemy-corpse-time",
        description = "enemyracemanager-enemy-corpse-time",
        setting_type = "startup",
        default_value = 5,
        minimum_value = 1,
        maximum_value = 15,
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
        type = "bool-setting",
        name = "enemyracemanager-enable-2way-group-enemy",
        description = "enemyracemanager-2way-group-enemy",
        setting_type = "startup",
        default_value = false,
        order = "enemyracemanager-201"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-2way-group-enemy-orientation",
        description = "enemyracemanager-2way-group-enemy-orientation",
        setting_type = "startup",
        default_value = 'x-axis',
        order = "enemyracemanager-202",
        allowed_values = { 'x-axis', 'y-axis' }
    },
    {
        type = "string-setting",
        name = "enemyracemanager-2way-group-enemy-positive",
        description = "enemyracemanager-2way-group-enemy-positive",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-203",
        allowed_values = { 'empty', MOD_NAME }
    },
    {
        type = "string-setting",
        name = "enemyracemanager-2way-group-enemy-negative",
        description = "enemyracemanager-2way-group-enemy-negative",
        setting_type = "startup",
        default_value = MOD_NAME,
        order = "enemyracemanager-204",
        allowed_values = { 'empty', MOD_NAME }
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-enhance-defense",
        description = "enemyracemanager-enhance-defense",
        setting_type = "startup",
        default_value = true,
        order = "enemyracemanager-300"
    },
}



