--
-- Created by IntelliJ IDEA.
-- User: heyqule
-- Date: 12/17/2020
-- Time: 11:29 AM
-- To change this template use File | Settings | File Templates.
--
require('util')
require('global')

require('testcase')

local LevelProcessor = require('__enemyracemanager__/lib/level_processor')
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local BaseBuildProcessor = require('__enemyracemanager__/lib/base_build_processor')
local AttackMeterProcessor = require('__enemyracemanager__/lib/attack_meter_processor')
local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')
local AttackGroupProcessor = require('__enemyracemanager__/lib/attack_group_processor')
local AttackGroupPathingProcessor = require('__enemyracemanager__/lib/attack_group_pathing_processor')
local AttackGroupHeatProcessor = require('__enemyracemanager__/lib/attack_group_heat_processor')
local ArmyTeleportationProcessor = require('__enemyracemanager__/lib/army_teleportation_processor')
local BossProcessor = require('__enemyracemanager__/lib/boss_processor')
local BossGroupProcessor = require('__enemyracemanager__/lib/boss_group_processor')
local BossAttackProcessor = require('__enemyracemanager__/lib/boss_attack_processor')
local BossRewardProcessor = require('__enemyracemanager__/lib/boss_reward_processor')
local InterplanetaryAttacks = require('__enemyracemanager__/lib/interplanetary_attacks')

require('prototypes/compatibility/controls')

local RemoteApi = require('__enemyracemanager__/lib/remote_api')
remote.add_interface("enemyracemanager", RemoteApi)

local DebugRemoteApi = require('__enemyracemanager__/lib/debug_remote_api')
remote.add_interface("enemyracemanager_debug", DebugRemoteApi)

-- Register Cron Functions
cron_switch = {
    -- AttackGroupProcessor
    ['AttackGroupProcessor.add_to_group'] = function(args)
        AttackGroupProcessor.add_to_group_cron(args)
    end,
    ['AttackGroupProcessor.generate_group'] = function(args)
        AttackGroupProcessor.generate_group(unpack(args))
    end,
    ['AttackGroupProcessor.spawn_scout'] = function(args)
        AttackGroupProcessor.spawn_scout(unpack(args))
    end,
    ['AttackGroupProcessor.clear_invalid_erm_unit_groups'] = function(args)
        AttackGroupProcessor.clear_invalid_erm_unit_groups()
    end,
    ['AttackGroupProcessor.clear_invalid_scout_unit_name'] = function(args)
        AttackGroupProcessor.clear_invalid_scout_unit_name()
    end,
    -- AttackMeterProcessor
    ['AttackMeterProcessor.calculate_points'] = function(args)
        AttackMeterProcessor.calculate_points(unpack(args))
    end,
    ['AttackMeterProcessor.form_group'] = function(args)
        AttackMeterProcessor.form_group(unpack(args))
    end,
    -- AttackGroupPathingProcessor
    ['AttackGroupPathingProcessor.construct_side_attack_commands'] = function(args)
        AttackGroupPathingProcessor.construct_side_attack_commands(unpack(args))
    end,
    ['AttackGroupPathingProcessor.construct_brutal_force_commands'] = function(args)
        AttackGroupPathingProcessor.construct_brutal_force_commands(unpack(args))
    end,
    ['AttackGroupPathingProcessor.remove_old_nodes'] = function(args)
        AttackGroupPathingProcessor.remove_old_nodes()
    end,
    --AttackGroupHeatProcessor
    ['AttackGroupHeatProcessor.aggregate_heat'] = function(args)
        AttackGroupHeatProcessor.aggregate_heat(unpack(args))
    end,
    ['AttackGroupHeatProcessor.cooldown_heat'] = function(args)
        AttackGroupHeatProcessor.cooldown_heat(unpack(args))
    end,
    --AttackGroupBeaconProcessor
    ['AttackGroupBeaconProcessor.start_scout_scan'] = function(args)
        AttackGroupBeaconProcessor.start_scout_scan()
    end,
    ['AttackGroupBeaconProcessor.scout_scan'] = function(args)
        AttackGroupBeaconProcessor.scout_scan(unpack(args))
    end,
    --ArmyTeleportationProcessor
    ['ArmyTeleportationProcessor.teleport'] = function(args)
        ArmyTeleportationProcessor.teleport(unpack(args))
    end,
    ['ArmyTeleportationProcessor.scan_units'] = function(args)
        ArmyTeleportationProcessor.scan_units()
    end,
    --BaseBuildProcessor
    ['BaseBuildProcessor.build'] = function(args)
        BaseBuildProcessor.build(unpack(args))
    end,
    -- BossProcessor
    ['BossProcessor.check_pathing'] = function(args)
        BossProcessor.check_pathing()
    end,
    ['BossProcessor.heartbeat'] = function(args)
        BossProcessor.heartbeat()
    end,
    ['BossProcessor.units_spawn'] = function(args)
        BossProcessor.units_spawn()
    end,
    ['BossProcessor.support_structures_spawn'] = function(args)
        BossProcessor.support_structures_spawn()
    end,
    ['BossProcessor.remove_boss_groups'] = function(args)
        BossProcessor.remove_boss_groups(unpack(args))
    end,
    --BossAttackProcessor
    ['BossAttackProcessor.process_attack'] = function(args)
        BossAttackProcessor.process_attack(unpack(args))
    end,
    --BossGroupProcessor
    ['BossGroupProcessor.generate_units'] = function(args)
        BossGroupProcessor.generate_units(unpack(args))
    end,
    ['BossGroupProcessor.process_attack_groups'] = function(args)
        BossGroupProcessor.process_attack_groups()
    end,
    -- BossRewardProcessor
    ['BossRewardProcessor.clean_up'] = function(args)
        BossRewardProcessor.clean_up()
    end,
    --ForceHelper
    ['ForceHelper.refresh_all_enemy_forces'] = function(args)
        ForceHelper.refresh_all_enemy_forces()
    end,
    ['InterplanetaryAttacks.queue_scan'] = function(args)
        InterplanetaryAttacks.queue_scan()
    end,
    ['InterplanetaryAttacks.scan'] = function(args)
        InterplanetaryAttacks.scan(unpack(args))
    end,
    --LevelProcessor
    ['LevelProcessor.calculate_multiple_levels'] = function(args)
        LevelProcessor.calculate_multiple_levels()
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

--- Script Trigger for all functions
require('__enemyracemanager__/controllers/on_script_trigger_effects')


--- On Rocket Launch Events
require('__enemyracemanager__/controllers/on_rocket_launch')

require('__enemyracemanager__/controllers/debug_events')

-- Commands
require('__enemyracemanager__/controllers/commands')

-- Compatibility
require('__enemyracemanager__/controllers/compatibility/k2')

require('__enemyracemanager__/controllers/compatibility/mining_drone')

require('__enemyracemanager__/controllers/compatibility/space_exploration')