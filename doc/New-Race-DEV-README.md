New Race developer guide line
--------------------
This readme should be gives you a general start to create your new race.

#### global.lua

defines mod constants. Many constants are used as function proxy keys.

If you copy this file from the another mod and plan to use same variable name for trigger events,
you have to change all values which are unique to your mod.

```lua
from
OVERLORD_DROP_ATTACK = 'emzrg-ovl'
to
OVERLORD_DROP_ATTACK = 'yourmodecode-ovl'
```

Example: [global.lua](https://github.com/heyqule/erm_zerg/blob/main/global.lua)

#### setting-update.lua

add your race to ERM settings' dropdowns

Example: [settings-updates.lua](https://github.com/heyqule/erm_zerg/blob/main/settings-updates.lua)

#### data.lua

Use this file to add unit, spawner and other data entities to the game.

The following is **REQUIRED** to register ERM races in data stage.

```
data.erm_registered_race = data.erm_registered_race or {}
data.erm_registered_race[MOD_NAME] = true
```

This is required for tuning "default" autoplace function to use as reference.
[Default_Autoplace.md](https://github.com/heyqule/erm_zerg/blob/main/doc/Default_Autoplace.lua)

```
data.erm_spawn_specs = data.erm_spawn_specs or {}
table.insert(data.erm_spawn_specs, {
  mod_name=MOD_NAME,
  force_name=FORCE_NAME,
  moisture=2, -- 1 = Dry and 2 = Wet
  aux=2, -- 1 = red desert, 2 = sand
  elevation=2, --1,2,3 (1 low elevation, 2. medium, 3 high elavation)
  temperature=2, --1,2,3 (1 cold, 2. normal, 3 hot)
})
```

Example: [data.lua](https://github.com/heyqule/erm_zerg/blob/main/data.lua)

#### control.lua

Use this file to hook up the race data and control any custom parameters.

Example: [control.lua](https://github.com/heyqule/erm_zerg/blob/main/control.lua)

Point of interests:

* createRace()
    * This defines the force in-game.
* addRaceSettings()
    * This function set up race specific settings.
    * [__enemyracemanager
      __/lib/remote_api.lua](https://github.com/heyqule/enemy_race_manager/blob/main/lib/remote_api.lua)

* Event.register(defines.events.on_script_trigger_effect, function(event) end
    * handles custom attacks

* Register required function in remote.lua (See below)

#### scripts/remote.lua

[remote.lua](https://github.com/heyqule/erm_zerg/blob/main/scripts/remote.lua)

* RemoteAPI.milestones_preset_addons()
    * This function registers Milestone objective

* RemoteAPI.register_new_enemy_race()
    * This function is **REQUIRED** to register your race with ERM in control stage.

#### scripts/custom_attacks.lua

[custom_attacks.lua](https://github.com/heyqule/erm_zerg/blob/main/scripts/custom_attacks.lua)

This file handles custom attack for dropships and alike.

#### scripts/boss_attacks.lua

[custom_attacks.lua](https://github.com/heyqule/erm_zerg/blob/main/scripts/custom_attacks.lua)

This file registers boss attacks

#### Units & Buildings:

##### Units and Buildings collisions:

```
Unit collision box / selection box:
local collision_box = { { -1, -1 }, {1, 1 } }
local selection_box = { { -1.25, -1.25 }, { 1.25, 1.25 } }

Building collision / selection / map bounding box
local collision_box = { { -3, -3.5 }, { 3.25, 2.75 } }
local map_generator_bounding_box = { { -4, -4.5 }, { 4.25, 3.75 } }
local selection_box = { { -3, -3.5 }, { 3.25, 2.75 } }
```

collsion_box for unit should be under 2 tiles, under { { -1, -1 }, {1, 1 } } in most cases. The gap between building is
designed to be 2 tiles, check collision_box and map_generator_bounding_box in buildings.  
Any number larger will make them stuck inside the base. However, you can change the selection box to match unit's size
since it won't affect how unit behave.

If you wish to keep a larger collision box, you will have to tweak your building's map_generator_bounding_box to have a
wider gap.

##### Unit abilities:

Many of the units have unique abilities, please refer to the lua files for reference

* Melee: [Zergling](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/zergling.lua)
* Melee AOE: [Ultralisk](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/ultralisk.lua)
* Range: [Hydralisk](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/hydralisk.lua)
* AOE Range:  [Lurker](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/lurker.lua)
* Flying Unit: [Mutalisk](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/mutalisk.lua)
* Max range attack: [Guardian](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/guardian.lua)
* Slow attack: [Devourer](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/devourer.lua)
* AOE Slow: [Queen](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/queen.lua)
* AOE healing: [Defiler](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/defiler.lua)
    * note that you can not do single unit healing because they can't target friendly unit.

These units' attacks are handled via on_script_trigger_effect events

* Self destruct unit: [Infested](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/infested.lua)
* Dropping new units: [Overlord](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/overlord.lua)
* Construct new building with self
  destruct: [Drone](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/drone.lua)
* Timed Units (they die after 2 minutes of spawn from another
  unit): [Broodling](https://github.com/heyqule/erm_zerg/blob/main/prototypes/enemy/broodling.lua)

###### Default File to include:

```lua
require('__stdlib__/stdlib/utils/defines/time')  --Handle date/time definies
local Sprites = require('__stdlib__/stdlib/data/modules/sprites') --Handle empty sprites

local ERM_UnitHelper = require('__enemyracemanager__/lib/unit_helper') -- Unit Helper functions, use for calculating health, damage and etc.
local ERM_UnitTint = require('__enemyracemanager__/lib/unit_tint') -- Unit tint functions, use for tinting air unit exhaust and shadows.
local ERM_DebugHelper = require('__enemyracemanager__/lib/debug_helper') -- some debug function
local ERM_Config = require('__enemyracemanager__/lib/global_config') -- Get proper settings for max level, max range and etc.

-- If you group all sound / other asset in a single file, you'll include those like the following.
local ZergSound = require('__erm_zerg__/prototypes/sound') -- All sounds are handled in single lua file.  It's easier to modify.
```

## Name Convention

Unit and building enemy have to be in this format.

```lua
name = MOD_NAME .. '/' .. name .. '/' .. level,
localised_name = { 'entity-name.' .. MOD_NAME .. '/' .. name, level },
```

* MOD_NAME is defined in global.lua
* name is the unit name

Other support entities, (explosion, projectile and etc) should use the follow convention to avoid name collision.

```lua
name = MOD_NAME .. '/' .. entity_name
```

Name collision cause mod conflict and make game to crash at startup.

#### Unit Spawners:

Please see [prototype/building/hive.lua](https://github.com/heyqule/erm_zerg/blob/main/prototypes/building/hive.lua) for
details.

#### Turrets:

It feels more balance to have both splitter acid and direct attack for base defense.

* Spitter Acid
  attack: [prototype/building/spore_colony.lua](https://github.com/heyqule/erm_zerg/blob/main/prototypes/building/spore_colony.lua)
* Direct
  Attack: [prototype/building/sunker_colony.lua](https://github.com/heyqule/erm_zerg/blob/main/prototypes/building/sunker_colony.lua)

##### HP @ L20, Guideline:

Unit HP:

* level 1 are under 500, median none
* level 10 are 1000 - 5000, median 1500-2500
* level 20 are 2500 - 10000, median 3000-5000

Spawner/Turret HP @ L20:

* turrets are 4000 - 8000
* proxy spawners are usually 5000 - 8000 health
* support spawner are 6000 - 12000
* command center 12000+

##### Max Resistance Guideline:

Unit Resistance:

* Max Physical: 95%
* Elemental: 90%
* Weak Elemental: 85%

Spawner/Turret Resistance:

* Max Physical: 85%
* Elemental: 80%
* Weak Elemental: 75%

##### Damage Guideline:

* level 1: 10 - 50 DPS (damage per second)
* level 10: 30 - 100 DPS
* level 20:  80 - 200 DPS

AOE units usually use a lower value than above damage guideline. But you take the cooldown interval into consideration
as well.

When designing top damage dealer, an attack is likely too powerful if it does 1000 damage, but only attack once every
5s. That's still 200 DPS range.  
When there are a few of these units in the group, they can one shot reinforced turrets.

A reinforced gun turret (1600HP with 33% resistances) should be able to survive about 10 shots from top damage dealers.

##### Movement Speed Guideline:

(level 1 to 20)
Slow Ground: (21-27) - (37-43)km/s

```lua
local base_movement_speed = 0.1
local incremental_movement_speed = 0.1
```

Fast Ground: (27-37) - (48-54) km/s

```lua
local base_movement_speed = 0.15
local incremental_movement_speed = 0.1
```

Normal Flyer: 32 - 59km/s

```lua
local base_movement_speed = 0.15
local incremental_movement_speed = 0.125
```

Fast Flyer: 43 - 75km/s

```lua
local base_movement_speed = 0.2
local incremental_movement_speed = 0.15
```

##### Attack Speed Guideline:

Fastest attack speed for all units is 0.25s / attack. (4 attacks / second)

L20 attack speed range from 3s / attack to 4 attacks/s depending on unit design.

##### Attack Range Guideline:

Meele: 1

* Dropship: ERM_Config.get_max_attack_range()
* Short Range: ERM_Config.get_max_attack_range() * 0.25
* Medium Range: ERM_Config.get_max_attack_range() * 0.5
* Long Range: ERM_Config.get_max_attack_range() * 0.75
* Max Range: ERM_Config.get_max_attack_range()

get_max_attack_range() is depends on the startup setting. Gun turret may not able to attack range 20 enemy.

The max range of a unit should not be further than the longest range of player turret.

Otherwise, it will just annoy players and break the flow of the game.

min_attack_distance, a parameter to randomize attack distance

- (unit_range - 2) if short range
- (unit_range - 3) if medium Range
- (unit_range - 4) if long range to max range

##### pollution_to_join_attack Guideline:

* Tier 1: 5 - 50
* Tier 2: 50 - 200
* Tier 3: 100 - 500
* Dropship / Drone: 200

AOE units are in higher range. Tier 3 AOE units generally take 300-400 range.

##### vision_distance Guideline:

minimum 32 or Attack Range + 8

##### Projectile max range

call ERM_Config.get_max_projectile_range(). Default is 64 without multiplier. The following example returns 128.

```
  action_delivery = {
      type = "projectile",
      projectile = "scout-rocket",
      starting_speed = 0.3,
      max_range = ERM_Config.get_max_projectile_range(2),
  }
```

##### How to balance between other races?

I do unit balance in free for all mode. If a race have a fair fight with other races in 2 or 4 race split setting, then
the unit balance is good enough.

- Set up your race settings in startup settings.
- Enable DEBUG_MODE flag in global.lua in ERM's core mod.
- Load up the "Enemy race manager/General debug" scenario.
- Load "ERM Debug" map setting (400% enemy)
- disable water and tree
- Start the game.
- set "/c game.speed = 1000" to ERM work its magic.
- Go out for a walk for half hours and view the result.