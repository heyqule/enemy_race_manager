local descript = "mod-setting-description.enemyracemanager-"

data:extend{
    {
        type = "bool-setting",
        name = "enemyracemanager-enable-bitters",
        description = "enemyracemanager-enable-bitters",
        setting_type = "startup",
        default_value = true,
        order = "enemyracemanager-1"
    },
    {
        type = "string-setting",
        name = "enemyracemanager-max-level",
        description = "enemyracemanager-max-level",
        setting_type = "startup",
        default_value = "Normal - Max L10",
        allowed_values = {"Normal - Max L10", "Advanced - Max L20"},
        order = "enemyracemanager-2"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-enable-advance-mapping",
        description = "enemyracemanager-enable-advance-mapping",
        setting_type = "startup",
        default_value = false,
        order = "enemyracemanager-3"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-enemy-corpse-time",
        description = "enemyracemanager-enemy-corpse-time",
        setting_type = "startup",
        default_value = 5,
        minimum_value = 1,
        maximum_value = 15,
        order = "enemyracemanager-4"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-level-multipliers",
        description = "enemyracemanager-level-multipliers",
        setting_type = "startup",
        default_value = 5,
        minimum_value = 3,
        maximum_value = 20,
        order = "enemyracemanager-5"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-max-hitpoint-multipliers",
        description = "enemyracemanager-max-hitpoint-multipliers",
        setting_type = "startup",
        default_value = 10,
        minimum_value = 5,
        maximum_value = 100,
        order = "enemyracemanager-6"
    },
    {
        type = "double-setting",
        name = "enemyracemanager-score-multipliers",
        description = "enemyracemanager-score-multipliers",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 10,
        order = "enemyracemanager-7"
    },
}



