---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 1/1/2021 6:08 PM
---

-- FOR VANILLA ENEMIES / enemy forces.
MOD_NAME = "enemy"
FORCE_NAME = "enemy"

AUTOCONTROL_NAME = "enemy-base"

GLEBA_FORCE_NAME = "enemy_pentapod"

GLEBA_FORCE_AUTOCONTROL_NAME = "gleba_enemy_base"

--- [ MAKE SURE TO TURN THESE FLAG OFF BEFORE GO PROD ]
--- Enable this flag to enable debug features
DEBUG_MODE = true
--- Enable this flag when running tests.  It forces some chance based logics to run.
TEST_MODE = true
--- For debugging beacons
BEACON_SELECTABLE = false
--- Enable this flag if you want to sampling aux, moisture, elevation, and enemy probability.
SAMPLE_TILE_MODE = false
--- [/ MAKE SURE TO TURN THESE FLAG OFF BEFORE GO PROD ]

CONSTRUCTION_ATTACK = "embtr-con"
LOGISTIC_ATTACK = "embtr-log"
-- Super weapon: Nuke, ion cannon, iridium-piledriver.
PLAYER_SUPER_WEAPON_ATTACK = "emptk-sw"
-- Planet Purifier: SE"plague rocket, mirv
PLAYER_PLANET_PURIFIER_ATTACK = "emptk-pp"
-- Super Weapon: Counter attack
PLAYER_SUPER_WEAPON_COUNTER_ATTACK = "empck-sw"
-- Planet Purifier: Counter attack
PLAYER_PLANET_PURIFIER_COUNTER_ATTACK = "empck-pp"

ARMY_POPULATION_INCREASE = "empop-i"
ARMY_POPULATION_DECREASE = "empop-d"

ARMY_RALLYPOINT_DEPLOY = "emrpt-d"

ROCKET_SILO_PLACED = "emrs-p"
ROCKET_SILO_REMOVED  = "emrs-r"

TRIGGER_BOSS_DIES = "embss-die"

LAND_SCOUT_BEACON = "em-landsb"
AERIAL_SCOUT_BEACON = "em-airsb"

ALL_PLANETS = "All Planets"

ENVIRONMENTAL_ATTACK = "emev-atk"

CREEP_REMOVAL = "em-crprm"

--- Roll dice when unit/spawner/turrets spawns
QUALITY_DICE_ROLL = "em-dcrll"
--- Tall point on unit death
QUALITY_TALLY_POINT = "em-tllpt"

VANILLA_MAP_COLOR = { r = 224, g = 35, b = 33, a = 255 }


--- For Debug use
DEBUG_BEHAVIOUR_RESULTS = {
    [defines.behavior_result.in_progress] = "defines.behavior_result.in_progress",
    [defines.behavior_result.fail] = "defines.behavior_result.fail",
    [defines.behavior_result.success] = "defines.behavior_result.success",
    [defines.behavior_result.deleted] = "defines.behavior_result.deleted"
}

DEBUG_GROUP_STATES = {
    [defines.group_state.gathering] = "defines.group_state.gathering",
    [defines.group_state.moving] = "defines.group_state.moving",
    [defines.group_state.attacking_distraction] = "defines.group_state.attacking_distraction",
    [defines.group_state.attacking_target] = "defines.group_state.attacking_target",
    [defines.group_state.finished] = "defines.group_state.finished",
    [defines.group_state.pathfinding] = "defines.group_state.pathfinding",
    [defines.group_state.wander_in_group] = "defines.group_state.wander_in_group"
}

DEBUG_MOVING_STATES = {
    [defines.moving_state.stale] = "defines.moving_state.stale",
    [defines.moving_state.moving] = "defines.moving_state.moving",
    [defines.moving_state.adaptive] = "defines.moving_state.adaptive",
    [defines.moving_state.stuck] = "defines.moving_state.stuck",
}

DEBUG_COMMAND = {
    [defines.command.attack] = "defines.command.attack",
    [defines.command.go_to_location] = "defines.command.go_to_location",
    [defines.command.compound] = "defines.command.compound",
    [defines.command.group] = "defines.command.group",
    [defines.command.attack_area] = "defines.command.attack_area",
    [defines.command.wander] = "defines.command.wander",
    [defines.command.flee] = "defines.command.flee",
    [defines.command.stop] = "defines.command.stop",
    [defines.command.build_base] = "defines.command.build_base",
}