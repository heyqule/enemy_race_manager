local descript = "mod-setting-description.enemyracemanager-"

data:extend{
    {
        type = "bool-setting",
        name = "enemyracemanager-enable-bitters",
        description = "enemyracemanager-enable-bitters",
        setting_type = "startup",
        default_value = true,
        order = "enemyracemanager-a"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-enable-level",
        description = "enemyracemanager-enable-level",
        setting_type = "startup",
        default_value = false,
        order = "enemyracemanager-b"
    },
    {
        type = "bool-setting",
        name = "enemyracemanager-enable-advance-mapping",
        description = "enemyracemanager-enable-advance-mapping",
        setting_type = "startup",
        default_value = false,
        order = "enemyracemanager-c"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-enemy-corpse-time",
        description = "enemyracemanager-enemy-corpse-time",
        setting_type = "startup",
        default_value = 2,
        minimum_value = 1,
        maximum_value = 15,
        order = "enemyracemanager-b"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-level-multipliers",
        description = "enemyracemanager-level-multipliers",
        setting_type = "startup",
        default_value = 5,
        minimum_value = 3,
        maximum_value = 20,
        order = "enemyracemanager-b"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-max-hitpoint-multipliers",
        description = "enemyracemanager-max-hitpoint-multipliers",
        setting_type = "startup",
        default_value = 10,
        minimum_value = 5,
        maximum_value = 100,
        order = "enemyracemanager-b"
    },
}



