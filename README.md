# Enemy Race Manager
This mod adds support to have multiple races of enemies with distinct looks & abilities. It also adds various enhancements to enemy races.  Such as enemy leveling, enemy base rapid expansion, custom enemy attack groups such as flyers squad and dropship squad.

Discord:  [https://discord.gg/BwWXygyEyQ](https://discord.gg/BwWXygyEyQ)

### Feature Videos:
- ERM - Features Reel: [https://www.youtube.com/watch?v=phLRReAjxHA](https://www.youtube.com/watch?v=phLRReAjxHA)
- ERM - Free For All Mode: [https://www.youtube.com/watch?v=fOj4gU1q7Pk](https://www.youtube.com/watch?v=fOj4gU1q7Pk)
- ERM - Featured Attack Groups: [https://www.youtube.com/watch?v=LDdkzwMX73s](https://www.youtube.com/watch?v=LDdkzwMX73s)

### 1.15.0 feature highlight
- Featured and Elite Featured Groups
  - [https://www.youtube.com/watch?v=LDdkzwMX73s](https://www.youtube.com/watch?v=LDdkzwMX73s)
  - Elite group units can be adjusted up to level 25.
- Increased explosive research bonus on artillery from 25% damage to 33% damage
- Increased vehicles health, lowered resistances.
- Re-added "nuke biter" button to kill bugged very high level units in early game.
- Adjusted unit health algo. levels 2 - 4 health have lowered to balance health raise between levels. Level 5 - 19 have approx +/- 5% changes. Level 20 stays the same.
- Remote API enhancement and [API doc](https://github.com/heyqule/enemy_race_manager/blob/main/doc/remote_api.md)


### Download New race demo
These race mods are made as educational demos. You'll have to download them separately.

Youtube: [https://youtu.be/phLRReAjxHA?t=180](https://youtu.be/phLRReAjxHA?t=180)

New Enemy Races:

[>>>>Zerg<<<<](https://mods.factorio.com/mod/erm_zerg)

[>>>>Protoss<<<<](https://mods.factorio.com/mod/erm_toss)

[>>>>RedArmy<<<<](https://mods.factorio.com/mod/erm_redarmy)

[>>>>Mars People<<<<](https://mods.factorio.com/mod/erm_marspeople)

Player Controllable Units:
[>>>>Terran<<<<](https://mods.factorio.com/mod/erm_terran)

Tips on defense:
- A LOT OF construction robots and repair kits. Automate repair network ASAP.  Mix all turrets.  Uranium bullets are OP.
- Build multiple layers of turrets in early game.  Repairing can be tedious without automated bot repairs.
- You may add "Robot World Continued" or "Nanobots: Early Bots" to automate repairs in early game.

### Features
#### New enemies can be added as new forces

Manage new race as new enemy force.  Each race has its own force statistics

#### 4 difficulty levels

Youtube: [https://youtu.be/phLRReAjxHA?t=78](https://youtu.be/phLRReAjxHA?t=78)

* Casual, max at level 5 (weapon lvl 6, pre-infinite research)
* Normal, max at level 10 (default, weapon lvl 11)
* Advance, max at level 15 (weapon lvl 16)
* Hardcore, max at level 20 (weapon lvl 20)

#### Adjustable max attack range for extra long range attack units
* Normal, 14, default
* Advanced, 20, outside of gun turret range.

#### Enemy Unit Leveling
The evolution points is tied to force's hidden evolution factors (time, pollution and enemy kills).

* {1, 3, 6, 10, 15, 21, 28, 38, 50, 70, 100, 150, 210, 280, 360, 450, 550, 700, 1000}
* evolution_base_point + (evolution_factor_by_pollution + evolution_factor_by_time + evolution_factor_by_killing_spawners) * level_multiplier
* evolution_base_point is used for evolution point accelerator, which killing turret and units also count toward evolution.
* level_multiplier default to 1.

Leveling support for base game biter/spitters, Armoured Biters, Explosive Biters & Cold Biters.

#### Tiered unit spawns
New races may have up to 3 tiers of unit-spawners and turrets. 

* 0 - 0.4 evolution factor uses tier 1 units & spawns
* 0.4 adds tier 2
* 0.8 adds tier 3

#### Artillery-Shell damage buff
Artillery-Shell damage bonus now is part of infinite stronger-explosive upgrade.

* Added this due to structure resistance and health increase

#### GUI to view each race's stats.
* replace races on a surface
* adjust enemy level mid-game.
* adjust enemy evolution mid-game.

#### Custom enemy base autoplace
This defines how enemy bases are generated when a new chunk is charted.

Youtube: [https://youtu.be/phLRReAjxHA?t=12](https://youtu.be/phLRReAjxHA?t=12)

Default
* using base game autoplace. All races are mixed together.

2 races split

* race A spawns at positive axis, race B spawns at negative axis
* can be divided by (X-axis) East/West or (Y-axis) North/South.
* Example:When you choose Y-axis, Zerg (Race A) will spawn North, Protoss (Race B) will spawn South.

4 races split

* One race in each area of top left, top right, bottom left and bottom right.

![2 races split](https://mods-data.factorio.com/assets/4a18da6eda30b7f3e8bc3c1dea98f42115b90eaa.png "2 races split")


One race per surface/planet

* randomly assign a race for each surface / planet.
* It's for Space Exploration.
* The race of a planet can be changed using replace race button from UI.

![One race per surface/planet](https://mods-data.factorio.com/assets/0da5fad0ee211f160a359e8b994e80269716a56e.png "One race per surface")

#### Custom enemy base expansion
This defines how enemy expand into new area.  In base game, each building group build one building at a time.  This feature changes that they build several buildings at one time with specified formation.

Youtube: [https://youtu.be/phLRReAjxHA?t=88](https://youtu.be/phLRReAjxHA?t=88)

* Default
    - build one building at a time
* Command Center
    - When the unit group base builds a command center type spawner, it triggers "Build A Town" logic. Otherwise, it's default logic
* Build A Town (default)
    - Always use build formation option to build the base.
* Full Expansion
    - When the first biter builds, everyone from the group will build based on "Build A Town" logic.

You can change the build formation option. For example:

* 1 cc, 2 support spawners, 4 turrets
* 1 cc, 4 support spawners, 5 turrets (default)
* and more

Partial formation is build based on cc > support > turret priority.

![1-4-5 Formation](https://mods-data.factorio.com/assets/42b016483f30cb37d009e59b417a82e1c4a362b9.png "1-4-5 Formation")

### Attack meters / Custom Attack Squad

Youtube: [https://youtu.be/phLRReAjxHA?t=102](https://youtu.be/phLRReAjxHA?t=102)

* Each enemy kill worth some points. Attack meter tallies the points for each race every minute. 1 point for unit, 10 points for turret, 50 points for spawners.
* Enemy will send out an army to attack when a killed threshold is reached.  The check happens every few minutes.
* These attack groups are independent of pollution.
* The default threshold is around 3000 points(~150 units) per attack group. 
    - The threshold is configurable.
    - The threshold randomly reset after each attack.
* When mapping method is set to "one race per surface/planet", custom attack group can spawn on SE's planets with player structure.
* Launching rockets and using super weapons may increase attack points.
* There are multiple types of attack groups.

##### General attack groups 
* This group includes all available units.

##### Flying attack groups (ON by default)
* When "Flying Squad" is enabled, enemy may send out dedicate flying attackers to your base.

##### Dropship groups (ON by default)
* When "Dropship Squad" is enabled, enemy may send out dedicate dropship to drop units in your base.

##### Precision strike groups (ON by default)
* When this group goes to its target, the units ignore any attack distraction.
* They target area with rocket-silo, artillery-turret and mining-drill.  Defend them at all cost!
* Dropship group always based on this group.
* This feature can be enabled for flying attack group.  Default to ON.
* Early attack warning on mini map. Default to ON.

##### Time based attack wave (ON be default)
* Time based attack wave starts after enemy level reach 3. Default to ON
    * It adds points to attack meter every minute.
    * The points to add can be adjusted 1% to 20% of next attack threshold. It takes about 1.5hr to 5 minutes respectively to reach next wave.
    * Default setting is 2%, takes about 50 minutes if you are playing peacefully.

##### Featured Groups and Elite Featured Groups
* Featured group are groups with predefined unit types. Please watch the following video for examples.
* [https://www.youtube.com/watch?v=LDdkzwMX73s](https://www.youtube.com/watch?v=LDdkzwMX73s)
* Elite featured groups have the enemy level of current level + 2 by default
    * It can be set up to 5 level higher, which is level 25 max.  HP and damages at level 25 are about 20-30% more than level 20.
    * They spawn based on accumulated attack points.  Default is every 60000 points.

### Free for all 
This can be enabled in startup setting tab.

* Player entity health multiplied by 12.5x
* Enemy damage multiplied by 10x.
* The multiplier is to balance the time enemy units take to kill each other.

ERM - Free For All Mode: [https://www.youtube.com/watch?v=fOj4gU1q7Pk](https://www.youtube.com/watch?v=fOj4gU1q7Pk)

### Commands
* /ERM_GetRaceSettings - show detailed race settings

### Remote API Support
* [Remote API Doc](https://github.com/heyqule/enemy_race_manager/blob/main/doc/remote_api.md)

### Known Issues
* Defense turrets from new force attack player in peaceful mode.
    * If you know how to fix it, please message me.
* High level units rarely escape the async level processing matrix.
    * Some players treat them as early bosses. :)
    * If you can't defeat them, please use the nuke biter button in ERM UI to kill it.

### Mod Compatibility

#### Resource Spawner Overhaul
* You have to enable "Use vanilla biter generation" in Startup tab and disable "Use RSO biter generation" in Map tab

#### Space Exploration
* Supports one race per planet!

#### Krastorio2 (Requires 1.2+)
* New races support creep generation

#### Rampant AI (limited, not properly tested)
* It works with default settings.  However, its AI code only work for "enemy" force.  It does not affect custom enemy forces.
* May have interference with ERM custom attack groups.
* Rampant enemies override ERM enemies!  DO NOT enable them.

#### Armoured Biters & Explosive Biters & Cold Biters

#### New Game Plus and more

Please visit https://github.com/heyqule/enemy_race_manager/blob/main/Mod-Compatibility.md for full compatibility details.


### Roadmap
https://github.com/heyqule/enemy_race_manager/projects/1

### Uninstall
Please use the "Reset to default biters" button to replace ERM enemies with default biters before you remove the mod.  Otherwise, your map won't have any enemies on generated chucks as the ERM enemies are removed automatically.

### SPECIAL THANKS TO ALL CROWDIN TRANSLATORS