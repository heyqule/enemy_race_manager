# Enemy Race Manager
This mod aim to enhanced toughness of enemies with minimal overhead by adding levels to enemies.
It also provide an easy to use [LuaRemote](https://lua-api.factorio.com/latest/LuaRemote.html) interface to add new enemy races. Please refer to the demos below.

**I hope someone with art skills can come up with some new original races.**

Discord:  [https://discord.gg/BwWXygyEyQ](https://discord.gg/BwWXygyEyQ)

### 1.6.0 release
- Compatibility for New Game Plus
  - When the game resets, attack meter also reset.
  - When "reset evolution factor" is checked, level, tier and evolution points are preserved. Evolution factor and attack meter get reset.
  - When "reset research" is checked, everything reset.
- Add "level up accelerator" option to accelerate level up by killing unit and turrets. It defaults to ON.
- New experience curve for Level 4 - 20. 
- Evolution points: 12, 25, 45, 70, 115, 175, 250, 350, 450, 600, 750, 900, 1200, 1600, 2200, 3000, 4000


### New race demo
These mods are made as educational demos.

Youtube: https://www.youtube.com/watch?v=pcrFmtvNYTU

Tips on defense: A LOT OF construction robots and repair kits. Automate repair network ASAP.  Mix all turrets.  Uranium bullets are OP.

New Enemy Races:
[>>>>Zerg<<<<](https://mods.factorio.com/mod/erm_zerg)
![Zerg](https://mods-data.factorio.com/assets/d5713783b19c4ba3ca97ab578182e61c72ec11a0.png "Zerg")

[>>>>Protoss<<<<](https://mods.factorio.com/mod/erm_toss)
![Protoss](https://mods-data.factorio.com/assets/01f1d66653ee245f5abe8d5bacf6d359bb6e9c97.png "Protoss")

[>>>>RedArmy<<<<](https://mods.factorio.com/mod/erm_redarmy)
![RedArmy](https://mods-data.factorio.com/assets/d46b286c763a8b9fdbab23eb8bea2dee905a701f.png "RedArmy")

Defense Units:
[>>>>Terran<<<<](https://mods.factorio.com/mod/erm_terran)
![Terran](https://mods-data.factorio.com/assets/8edb5f447c0a754f1071256c950107fcae32bfa0.png "Terran")

### Features
#### 3 difficulty levels
* Casual, max at level 5
* Normal, max at level 10 (default, targets weapon lvl 15)
* Advance, max at level 20 (targets weapon lvl 25)

The difficulty levels are tested against piercing bullet for gun turret.  Uranium bullets melt everything.

#### Adjustable max attack range for extra long range attack units
* Normal, 14, default
* Advanced, 20, outside of gun turret range.

#### Enemy Unit Leveling
First 3 level is tied to force's evolution factor

* {0.4, 0.8}

The next 15 level is tied to force's hidden evolution factors (time, pollution and kill spawner).

* { 12, 25, 45, 70, 115, 175, 250, 350, 450, 600, 750, 900, 1200, 1600, 2200, 3000, 4000 }
* evolution_base_point + (evolution_factor_by_pollution + evolution_factor_by_time + evolution_factor_by_killing_spawners) * level_multiplier
* evolution_base_point is used for specific customization, default is 0.
* level_multiplier default to 1.

Leveling support for base game biter/spitters, Armoured Biters, Explosive Biters & Cold Biters.

#### New enemies can be added as new forces

Manage new race as new enemy force.  Each race has its own force statistics

#### Tiered unit spawns
New races may have up to 3 tiers of unit-spawners and turrets.  This applies to enemy base expansion.

* 0 - 0.4 evolution factor use tier 1 spawns
* 0.4 adds tier 2
* 0.8 adds tier 3

#### Artillery-Shell damage buff
Artillery-Shell damage bonus now is part of infinite stronger-explosive upgrade.

* Added this due to structure resistance and health increase

#### GUI to view each race's stats.
* replace races on a surface

#### Custom enemy base autoplace
This defines how enemy bases are generated when a new chunk is charted.

Default
- using base game autoplace. All races are mixed together.

2 races split

- race A spawns at positive axis, race B spawns at negative axis
- can be divided by (X-axis) East/West or (Y-axis) North/South.
- Example:When you choose Y-axis, Zerg (Race A) will spawn North, Protoss (Race B) will spawn South.


![2 races split](https://mods-data.factorio.com/assets/4a18da6eda30b7f3e8bc3c1dea98f42115b90eaa.png "2 races split")

One race per surface/planet

* randomly assign a race for each surface / planet.
* It's for Space Exploration.
* The race of a planet can be changed using replace function from UI.

![One race per surface/planet](https://mods-data.factorio.com/assets/0da5fad0ee211f160a359e8b994e80269716a56e.png "One race per surface")

#### Custom enemy base expansion
This defines how enemy expand into new area.  In base game, each building group build one building at a time.  This feature changes that they build several buildings at one time with specified formation.

* Default
  - build one at a time
* Command Center
  - When the unit group base builds a command center type spawner, it triggers "Build A Town" logic. Otherwise, it's default logic
* Build A Town
  - Always use build formation option to build the base.
* Full Expansion
  - When the first biter builds, everyone from the group will build based on "Build A Town" logic.

You can change the build formation option. For example:

* 1 cc, 2 support spawner, 4 turrets
* 1 cc, 4 support spawner, 5 turrets
* and more

Partial formation is build based on cc > support > turret priority.

![1-4-5 Formation](https://mods-data.factorio.com/assets/42b016483f30cb37d009e59b417a82e1c4a362b9.png "1-4-5 Formation")

### Attack meters / Custom Attack Squad (Beta Feature)
- Each enemy kill worth some points. Attack meter tallies the points for each race every minute. 1 point for unit, 10 points for turret, 50 points for spawners.
- Enemy will send out an army to attack when a killed threshold is reached.  The check happens every 5mins.
- These attack groups are independent from pollution.
- The default threshold is around 3000 points(~150 units) per attack group. The threshold is configurable.
- Each unit in attack group consumes 20 points.
- This only supports planet nauvis at the moment.  Not yet compatible in other planets for SE.
- More features and specialized attack groups are coming in later release.

##### Flying attack groups (OFF by default during beta)
- When "Flying Groups" is enabled, enemy may send out dedicate flying attackers to your base.
- Each unit in this group consumes 75 points. Team size is around 40 units with default attack meter threshold.

### Mod Compatibility

#### Resource Spawner Overhaul
- You have to enable "Use vanilla biter generation" in Startup tab and disable "Use RSO biter generation" in Map tab

#### Space Exploration
- Supports one race per planet!
- Randomly selects a race when a new planet/surface is created
- Change race for the planet you are on from UI

#### Krastorio2
- New races do not support creep generation unless author patches the creep generation code.
  - https://mods.factorio.com/mod/Krastorio2/discussion/605d800cf3bb48c41a98cd6b

#### Rampant AI
- It works with default settings.  However, its AI code only work for "enemy" force.  It does not affect custom enemy forces.
- It is NOT compatible with its custom biters at the moment.  Enabling them may crash the game.  I have not tested this.

#### Armoured Biters & Explosive Biters & Cold Biters
- All biters, worms and spawners support leveling.
- They join default enemy force, erm_vanilla.
- The health setting stacks with this mod's multiplier.
- Biters do not heal, spawner and worm do.

#### New Game Plus
- When the game resets, attack meter also reset.
- When "reset evolution factor" is checked, level, tier and evolution points are preserved. Evolution factor and attack meter get reset.
- When "reset research" is checked, everything reset.

For more compatibility details, please visit https://github.com/heyqule/enemy_race_manager/blob/main/README.md#mod-compatibility

### Commands
- /ERM_GetRaceSettings
- /ERM_levelup race_name,level  (/ERM_levelup erm_vanilla,8)

### Known Issues
* Defense turrets from new force attack player in peaceful mode. If you know how to fix it, please message me.

### Roadmap after 1.0
ERM_RedArmy - Heavy firepower on single target - Done (Beta)

ERM_SuicideSquad - E-x-p-l-o-s-i-v-e-s

### Uninstall
Please use the "Reset to default biters" button to replace ERM enemies with default biters before you remove the mod.  Otherwise, your map won't have any enemies on generated chucks as the ERM enemies are removed automatically.