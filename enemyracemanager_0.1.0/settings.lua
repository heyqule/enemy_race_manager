local descript = "mod-setting-description.enemyracemanager-"

data:extend{
    {
        type = "bool-setting",
        name = "enemyracemanager-enable-bitters",
        setting_type = "startup",
        default_value = true,
        order = "enemyracemanager-b"
    },
    {
        type = "int-setting",
        name = "enemyracemanager-enemy-corpse-time",
        setting_type = "startup",
        default_value = 2,
        minimum_value = 1,
        maximum_value = 5,
        order = "enemyracemanager-b"
    }
}



