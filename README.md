# Enemy Race Manager
This mod adds support to have multiple races of enemies with distinct looks & abilities. It also adds various enhancements to enemy races.  Such as enemy leveling, enemy base rapid expansion, enemy attack waves such as flyers squad and dropship squad.

It also provide an easy to use [LuaRemote](https://lua-api.factorio.com/latest/LuaRemote.html) interface to add new enemy races. Please refer to the demos below.

**I hope someone with art skills can come up with some new original races.**

Discord:  [https://discord.gg/BwWXygyEyQ](https://discord.gg/BwWXygyEyQ)

ERM - Features Reel: [https://www.youtube.com/watch?v=phLRReAjxHA](https://www.youtube.com/watch?v=phLRReAjxHA)

ERM - Free For All Mode: [https://www.youtube.com/watch?v=fOj4gU1q7Pk](https://www.youtube.com/watch?v=fOj4gU1q7Pk)

### 1.12.0 feature highlight
  - FREE FOR ALL Mode (BETA)
    - When FFA mode is enabled:
    - Player entity health multiplied by 8x
    - Enemy damage also multiplied by 8x.
    - The multiplier is to balance the time enemy units take to kill each other.
  - When attack group can't find attack path, it will automatically destroy and refund some attack points. (performance tweak)
  - All default weapons can now hit air. Removed Allow ground weapons to hit air units setting
  - Added a slider to adjust evolution factor in enemy detail GUI.

### Race mode Updates
  - Adjusted unit spawner to balance free for all mode
  - Protoss and Marspeople have slower spawn rate.

### New race demo
These race mods are made as educational demos. You'll have to download them separately.

Youtube: (WIP)

Tips on defense: A LOT OF construction robots and repair kits. Automate repair network ASAP.  Mix all turrets.  Uranium bullets are OP.

New Enemy Races:

[>>>>Zerg<<<<](https://mods.factorio.com/mod/erm_zerg)

[>>>>Protoss<<<<](https://mods.factorio.com/mod/erm_toss)

[>>>>RedArmy<<<<](https://mods.factorio.com/mod/erm_redarmy)

[>>>>Mars People<<<<](https://mods.factorio.com/mod/erm_marspeople)

Player Controllable Units:
[>>>>Terran<<<<](https://mods.factorio.com/mod/erm_terran)

### Features
#### New enemies can be added as new forces

Manage new race as new enemy force.  Each race has its own force statistics


#### 4 difficulty levels
* Casual, max at level 5 (weapon lvl 6, pre-infinite research)
* Normal, max at level 10 (default, weapon lvl 11)
* Advance, max at level 15 (weapon lvl 16)
* Hardcore, max at level 20 (weapon lvl 20)

#### Adjustable max attack range for extra long range attack units
* Normal, 14, default
* Advanced, 20, outside of gun turret range.

#### Enemy Unit Leveling
The evolution points is tied to force's hidden evolution factors (time, pollution and kill spawner).

* {1, 3, 6, 10, 15, 21, 28, 38, 50, 70, 100, 150, 210, 280, 360, 450, 550, 700, 1000}
* evolution_base_point + (evolution_factor_by_pollution + evolution_factor_by_time + evolution_factor_by_killing_spawners) * level_multiplier
* evolution_base_point is used for evolution point accelerator, which killing turret and units also count toward evolution.
* level_multiplier default to 1. 

Level Curve Multiplier
* You should consider changing "Level Curve Multiplier" to higher value if you are using expensive recipes or any big mod that makes weapon tech harder to research like Space Exploration.**
* Space Exploration players may want to use 3 - 5 as level curve multiplier, since weapon tech upgrades require more advanced recipes and takes longer to upgrade.**

Leveling support for base game biter/spitters, Armoured Biters, Explosive Biters & Cold Biters.

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
* adjust enemy level mid-game.

#### Custom enemy base autoplace
This defines how enemy bases are generated when a new chunk is charted.

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
* The race of a planet can be changed using replace function from UI.

![One race per surface/planet](https://mods-data.factorio.com/assets/0da5fad0ee211f160a359e8b994e80269716a56e.png "One race per surface")

#### Custom enemy base expansion
This defines how enemy expand into new area.  In base game, each building group build one building at a time.  This feature changes that they build several buildings at one time with specified formation.

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
* Each enemy kill worth some points. Attack meter tallies the points for each race every minute. 1 point for unit, 10 points for turret, 50 points for spawners.
* Enemy will send out an army to attack when a killed threshold is reached.  The check happens every 5mins.
* These attack groups are independent of pollution.
* The default threshold is around 3000 points(~150 units) per attack group. The threshold is configurable.
* When mapping method is set to "one race per surface/planet", custom attack group can spawn on SE's planets.
* More features and specialized attack groups are coming in later releases.

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
* Time based attack wave after enemy level to 3. Default to ON
    * It adds points to attack meter every minute.
    * The points to add can be adjusted 1% to 20% of next attack threshold. It takes about 1.5hr to 5mins respectively to reach next wave.
    * Default setting, 2%, takes about 50 mins if you are playing defensively.

### Free for all [Experimental]
/ERM_FFA command enable Free For All mode.  It can be toggle on and off.  Enemy races will fight each other to death.
* This feature will have performance implication.
* This command limits to max enemy level 5 and 10.
* High level units are excluded because unit spawns quicker than they die and cause performance issue.
* Not recommend to use FFA on a death world map. They may never stop fighting and kill your performance.
* When toogle off, all units in enemy forces are killed.

** Player building health and enemy damage will need to re-balance for this mode in a future release **

### Mod Compatibility

#### Resource Spawner Overhaul
* You have to enable "Use vanilla biter generation" in Startup tab and disable "Use RSO biter generation" in Map tab

#### Space Exploration
* Supports one race per planet!

#### Krastorio2 (Requires 1.2+, in beta atm)
* New races support creep generation
* Custom bullets can hit air

#### Rampant AI (limited)
* It works with default settings.  However, its AI code only work for "enemy" force.  It does not affect custom enemy forces.
* Rampant enemies override ERM enemies!  DO NOT enable them.

#### Armoured Biters & Explosive Biters & Cold Biters

#### New Game Plus

Please visit https://github.com/heyqule/enemy_race_manager/blob/main/Mod-Compatibility.md for full compatibility details.

### Commands
* /ERM_GetRaceSettings

### Known Issues
* Defense turrets from new force attack player in peaceful mode. If you know how to fix it, please message me.

### Roadmap after 1.0
ERM_RedArmy - Heavy firepower on single target - Done

ERM_MarsPeople - Mars people from metal slugs series - Beta

### Uninstall
Please use the "Reset to default biters" button to replace ERM enemies with default biters before you remove the mod.  Otherwise, your map won't have any enemies on generated chucks as the ERM enemies are removed automatically.