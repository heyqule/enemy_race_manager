--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/17/2020
-- Time: 11:29 AM
-- To change this template use File | Settings | File Templates.
--

if script.active_mods["factorio-test"] then
    local config = require('__stdlib__/stdlib/config')
    config.skip_script_protections = true

    require("__factorio-test__/init")({
        "tests/data_check",
        "tests/attack_beacon"
    })
    -- the first argument is a list of test files (require paths) to run
end


require('__stdlib__/stdlib/utils/defines/time')
require('global')

local ErmLevelProcessor = require('lib/level_processor')
local ErmForceHelper = require('lib/helper/force_helper')
local ErmBaseBuildProcessor = require('lib/base_build_processor')
local ErmAttackMeterProcessor = require('lib/attack_meter_processor')
local ErmAttackGroupProcessor = require('lib/attack_group_processor')
local ErmAttackGroupSurfaceProcessor = require('lib/attack_group_surface_processor')
local ErmBossProcessor = require('lib/boss_processor')
local ErmBossGroupProcessor = require('lib/boss_group_processor')
local ErmBossAttackProcessor = require('lib/boss_attack_processor')
local ErmBossRewardProcessor = require('lib/boss_reward_processor')
local ErmArmyTeleportationProcessor = require('lib/army_teleportation_processor')

local AttackGroupBeaconProcessor = require('lib/attack_group_beacon_processor')

require('prototypes/compatibility/controls')

local ErmRemoteApi = require('lib/remote_api')
remote.add_interface("enemyracemanager", ErmRemoteApi)

local ErmDebugRemoteApi = require('lib/debug_remote_api')
remote.add_interface("enemyracemanager_debug", ErmDebugRemoteApi)

-- Establish Cron Switches
cron_switch = {
    ['AttackGroupProcessor.add_to_group'] = function(args)
        ErmAttackGroupProcessor.add_to_group_cron(args)
    end,
    ['AttackGroupProcessor.generate_group'] = function(args)
        -- When args[7] presents, it's treated as retry group
        ErmAttackGroupProcessor.generate_group(args[1],args[2],args[3],args[4],args[5],args[6],args[7])
    end,
    ['BaseBuildProcessor.build'] = function(args)
        ErmBaseBuildProcessor.build_cron(args)
    end,
    ['LevelProcessor.calculateMultipleLevels'] = function(args)
        ErmLevelProcessor.calculateMultipleLevels()
    end,
    ['ForceHelper.refresh_all_enemy_forces'] = function(args)
        ErmForceHelper.refresh_all_enemy_forces()
    end,
    ['AttackMeterProcessor.calculate_points'] = function(args)
        ErmAttackMeterProcessor.calculate_points(args[1])
    end,
    ['AttackMeterProcessor.form_group'] = function(args)
        ErmAttackMeterProcessor.form_group(args[1], args[2])
    end,
    ['AttackGroupSurfaceProcessor.exec'] = function(args)
        ErmAttackGroupSurfaceProcessor.exec(args[1])
    end,
    ['BossProcessor.check_pathing'] = function(args)
        ErmBossProcessor.check_pathing()
    end,
    ['BossProcessor.heartbeat'] = function(args)
        ErmBossProcessor.heartbeat()
    end,
    ['BossProcessor.units_spawn'] = function(args)
        ErmBossProcessor.units_spawn()
    end,
    ['BossProcessor.support_structures_spawn'] = function(args)
        ErmBossProcessor.support_structures_spawn()
    end,
    ['BossProcessor.remove_boss_groups'] = function(args)
        ErmBossProcessor.remove_boss_groups(args[1])
    end,
    ['BossGroupProcessor.generate_units'] = function(args)
        ErmBossGroupProcessor.generate_units(args[1], args[2])
    end,
    ['BossGroupProcessor.process_attack_groups'] = function(args)
        ErmBossGroupProcessor.process_attack_groups()
    end,
    ['BossAttackProcessor.process_attack'] = function(args)
        ErmBossAttackProcessor.process_attack(args[1], args[2])
    end,
    ['ArmyTeleportationProcessor.teleport'] = function(args)
        ErmArmyTeleportationProcessor.teleport(args[1], args[2], args[3])
    end,
    ['ArmyTeleportationProcessor.scan_units'] = function(args)
        ErmArmyTeleportationProcessor.scan_units()
    end,
}

require('__enemyracemanager__/controllers/initializer')

require('__enemyracemanager__/controllers/unit_control')

require('__enemyracemanager__/controllers/army_population')

require('__enemyracemanager__/controllers/army_teleportation')

require('__enemyracemanager__/controllers/army_deployment')

--- GUIs
require('__enemyracemanager__/controllers/gui')

require('__enemyracemanager__/controllers/custom-input')

--- Race Data Events
require('__enemyracemanager__/controllers/race_management')

--- Map Processing Events
require('__enemyracemanager__/controllers/map_management')

--- Attack points & group events
require('__enemyracemanager__/controllers/attack_group_management')

require('__enemyracemanager__/controllers/attack_group_beacon')



--- CRON Events
require('__enemyracemanager__/controllers/cron')

--- Script Trigger for attacks
require('__enemyracemanager__/controllers/on_script_trigger_effects_biter')

require('__enemyracemanager__/controllers/on_script_trigger_effects_general')

require('__enemyracemanager__/controllers/on_script_trigger_effects_player')

--- On Rocket Launch Events
require('__enemyracemanager__/controllers/on_rocket_launch')

require('__enemyracemanager__/controllers/debug_events')

-- Commands
require('__enemyracemanager__/controllers/commands')

-- Compatibility
require('__enemyracemanager__/controllers/compatibility/k2')

require('__enemyracemanager__/controllers/compatibility/mining_drone')