---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 6/22/2024 10:10 PM
---

local SharedTabFunctions = require("__enemyracemanager__/gui/army_tabs/shared")

local ArmyHelpGUI = {}

ArmyHelpGUI.name = "help-pane"

function ArmyHelpGUI.update(player)
    local main_tab = SharedTabFunctions.get_main_tab(player)
    local name = ArmyHelpGUI.name
    SharedTabFunctions.clear_tab(main_tab, name)

    local pane = main_tab[name]
    local timeout = settings.startup["enemyracemanager-unit-framework-timeout"].value
    local auto_deploy = "off"
    if settings.startup["enemyracemanager-unit-framework-start-auto-deploy"].value then
        auto_deploy = "on"
    end

    pane.add { type = "label", caption = { "gui-army.deployer_title" }, style = "frame_title" }
    pane.add { type = "label", caption = { "gui-army.deployer_description0" } }
    pane.add { type = "label", caption = { "gui-army.deployer_description1", auto_deploy } }
    pane.add { type = "label", caption = { "gui-army.deployer_description2" } }
    pane.add { type = "label", caption = { "gui-army.deployer_description3" } }
    pane.add { type = "label", caption = { "gui-army.deployer_description4", timeout } }
    pane.add { type = "label", caption = { "gui-army.deployer_description5" } }
    pane.add { type = "label", caption = { "gui-army.deployer_description6" } }

    pane.add { type = "label", caption = { "gui-army.cc_title" }, style = "frame_title" }
    pane.add { type = "label", caption = { "gui-army.cc_description0" } }
    pane.add { type = "label", caption = { "gui-army.cc_description1" } }
    pane.add { type = "label", caption = { "gui-army.cc_description2" } }
    pane.add { type = "label", caption = { "gui-army.cc_description3", timeout } }
    pane.add { type = "label", caption = { "gui-army.cc_description4" } }

    pane.add { type = "label", caption = { "gui-army.deploy_planner_title" }, style = "frame_title" }
    pane.add { type = "label", caption = { "gui-army.deploy_planner_description0" } }
    pane.add { type = "label", caption = { "gui-army.deploy_planner_description1" } }
    pane.add { type = "label", caption = { "gui-army.deploy_planner_description2" } }
end

return ArmyHelpGUI