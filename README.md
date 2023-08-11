# Enemy Race Manager
This mod adds support to have multiple races of enemies with distinct looks & abilities. It also adds various enhancements to enemy races.  Such as enemy leveling, enemy base rapid expansion, custom enemy attack groups such as flyers squad and dropship squad.

Discord:  [https://discord.gg/BwWXygyEyQ](https://discord.gg/BwWXygyEyQ)

### Feature Videos:
- ERM - Features Reel: [https://www.youtube.com/watch?v=phLRReAjxHA](https://www.youtube.com/watch?v=phLRReAjxHA)
- ERM - Free For All Mode: [https://www.youtube.com/watch?v=fOj4gU1q7Pk](https://www.youtube.com/watch?v=fOj4gU1q7Pk)
- ERM - Featured Attack Groups: [https://www.youtube.com/watch?v=LDdkzwMX73s](https://www.youtube.com/watch?v=LDdkzwMX73s)
- ERM - Terran Control Tutorial: [https://youtu.be/MzDwGJ3OOGY](https://youtu.be/MzDwGJ3OOGY)

### 1.19 Changes
- Default mapping method overhaul.  It's now compatible with unlimited races. (8 races at the moment).
- Moisture & Temperature based autoplace function.
- New way for race mods to register to ERM's data and control stage. It no longer depends on erm_ prefix.
- Eliminated an ancient bug where high level may spawn at low level.
- Custom biters(armour/cold/explosive/toxic) now supports map color change.

### Zerg and Protoss
- Additional remaster graphic changes for Zerg and Protoss!  Special thanks SHlNZ0U to prepare the graphics!
- Terran asset pack is now available. (Playable Terran will upgrade in a later date.)
- All remaster asset files are now final.  Additional assets may add in later version.

### Download New race demo
These race mods are made as educational demos. You'll have to download them separately.

Youtube: [https://youtu.be/phLRReAjxHA?t=180](https://youtu.be/phLRReAjxHA?t=180)

New Enemy Races:

* [Zerg - Garm Brood](https://mods.factorio.com/mod/erm_zerg)
  * [Zerg HD](https://mods.factorio.com/mod/erm_zerg_hd) - Remaster Graphic support
* [Protoss - Akilea Tribe](https://mods.factorio.com/mod/erm_toss) 
  * [Protoss HD](https://mods.factorio.com/mod/erm_toss_hd) - Remaster Graphic support
* [RedArmy](https://mods.factorio.com/mod/erm_redarmy)
* [Mars People](https://mods.factorio.com/mod/erm_marspeople)

The following races are made by [5hinzou](https://mods.factorio.com/user/5hinzou). These only use remaster graphics.
They have different spawn table and unit properties.  They can play together with my version, e.g Zerg vs Zerg FFA :)
* [>>>>Zerg - Jormungand Brood<<<<](https://mods.factorio.com/mod/erm_zerg_exp)
* [>>>>Protoss - Velari Tribe<<<<](https://mods.factorio.com/mod/erm_toss_exp)
* [>>>>Terran - United Earth Directorate<<<<](https://mods.factorio.com/mod/erm_terran_exp)

Player Controllable Units:

[>>>>Terran<<<<](https://mods.factorio.com/mod/erm_terran)

ERM - Terran Control Tutorial: [https://youtu.be/MzDwGJ3OOGY](https://youtu.be/MzDwGJ3OOGY)

**Tips on defense:**
- A LOT OF construction robots and repair kits. Automate repair network ASAP.  Mix all turrets.  Uranium bullets are OP.
- Build multiple layers of turrets in early game.  Repairing can be tedious without automated bot repairs.
- You may add "Robot World Continued" or "Nanobots: Early Bots" to automate repairs in early game.

Do you want to create your new race?  Please refer to this doc [New-Race-DEV-README.md](https://github.com/heyqule/enemy_race_manager/blob/main/doc/New-Race-DEV-README.md) and join my discord for additional help.

### Features
#### New enemies are added as new forces

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
* New 26, 32, 40 range

#### Enemy Unit Leveling
The evolution points is tied to force's hidden evolution factors (time, pollution and enemy kills).

* {1, 3, 6, 10, 15, 21, 28, 38, 50, 70, 100, 150, 210, 280, 360, 450, 550, 700, 1000}
* killing unit and turret also contribute to these points

Leveling support for base game biter/spitters, Armoured Biters, Explosive Biters & Cold Biters and all ERM races.

#### Tiered unit spawns
New races may have up to 3 tiers of unit-spawners, turrets and unit. 

* 0 - 0.4 evolution factor uses tier 1 units & spawns
* 0.4 adds tier 2
* 0.8 adds tier 3

#### Defense Enhancement

* Artillery-Shell damage bonus now is part of infinite stronger-explosive upgrade.
    * Added this due to structure resistance and health increase
* New tier of defense structures with higher HP and resistances.

#### GUI to view each race's stats.
* replace races on a surface
* adjust enemy level mid-game.
* adjust enemy evolution mid-game.

#### Custom enemy base autoplace
This defines how enemy bases are generated when a new chunk is charted.

Youtube: [https://youtu.be/phLRReAjxHA?t=12](https://youtu.be/phLRReAjxHA?t=12)

- Default
    - Moisture or/and temperature based spawns.  Protoss and cold biter spawn in cold/wet climate, zerg and explosive biter spawn in hot/dry climate.
- 2 ways split
- 4 ways split
- One race per surface/planet
    - randomly assign a race for each surface / planet.
    - Designed for Space Exploration.
    - The race of a planet can be changed using replace race button from UI.

![Enemy Autoplace](https://assets-mod.factorio.com/assets/9d1adb9316bbed9d83a373f8ff713745fd4580f8.png "Enemy Autoplace")

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

* Each enemy kill worth some points.
* Enemy will send out an army to attack when the killed points threshold is reached.
* These attack groups are independent of pollution.
* The default threshold is around 3000 points(~120 units) per attack group. 
    - The threshold is configurable.
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
* When this group is on its way to the target, the units ignore any attack distraction.
* They target area with rocket-silo, artillery-turret and mining-drill.  Defend them at all cost!
* Dropship group always based on this group.
* This feature can be enabled for flying attack group.  Default to ON.
* Early attack warning on mini map. Default to ON.

##### Time based attack wave (ON be default)
* Time based attack wave starts after enemy level reach 3. Default to ON
    * It adds points to attack meter every minute.
    * The points to add can be adjusted 1% to 90% of next attack threshold. It takes about 1.5hr to 5 minutes respectively to reach next wave.
    * Default setting is 2% of the threshold per minute.

##### Featured Groups and Elite Featured Groups
* Featured group are groups with predefined unit types. Please watch the following video for examples.
* [https://www.youtube.com/watch?v=LDdkzwMX73s](https://www.youtube.com/watch?v=LDdkzwMX73s)
* Elite featured groups have the enemy level of current level + 2 by default
    * It can be set up to 5 level higher, which is up to level 25.  HP and damages at level 25 are about 20-30% more than level 20.
    * They spawn based on accumulated attack points.  Default is every 60000 points.

### Free for all 
This can be enabled in startup setting tab.

* Player entity health multiplied by 12.5x
* Enemy damage multiplied by 10x.
* The multiplier is to balance the time enemy units take to kill each other.

ERM - Free For All Mode: [https://www.youtube.com/watch?v=fOj4gU1q7Pk](https://www.youtube.com/watch?v=fOj4gU1q7Pk)

### Advanced Army Controls (Only for ERM - Terran, or other compatible mods)
- Army controls enhancements 
    - Dedicated unit assembly lines.  Regular assembly machines can no longer build terran units.
    - Automated unit deployment.
    - Unit Teleportation between 2 areas, including between planets/surfaces.
    - Unit Population Control

ERM - Terran Control Tutorial: [https://youtu.be/MzDwGJ3OOGY](https://youtu.be/MzDwGJ3OOGY)

### Remote API Support
* [Remote API Doc](https://github.com/heyqule/enemy_race_manager/blob/main/doc/remote_api.md)

### Known Issues
* Defense turrets from new force attack player in peaceful mode.

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

#### Armoured Biters & Explosive Biters & Cold Biters & Toxic Biters

Please visit https://github.com/heyqule/enemy_race_manager/blob/main/Mod-Compatibility.md for full compatibility details.


### Roadmap
https://github.com/users/heyqule/projects/1

### Uninstall
Please use the "Reset to default biters" button to replace ERM enemies with default biters before you remove the mod.  Otherwise, your map won't have any enemies on generated chucks as the ERM enemies are removed automatically.

### SPECIAL THANKS TO ALL CROWDIN TRANSLATORS
- UK: Yuriy
- DE: PatrickBlack
- ES: Jose Eduardo
- FR: Wiwok, Daiky Raraga
- RU: SeptiSe7en, Misha Mitchell

You can help translate this mod directly online by going to the following link and finding "ERM" or "Enemy Race Manager":

https://crowdin.com/project/factorio-mods-localization

New translation will be released in the next version.