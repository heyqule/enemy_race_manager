# Enemy Race Manager
This mod aim to enhanced toughness of enemies with minimal overhead by adding levels to enemies. 
It also provide an easy to use [LuaRemote](https://lua-api.factorio.com/latest/LuaRemote.html) interface to add new enemy races. Please refer to the demos below.

**I hope someone with art skills can come up with some new original races.**

### 0.7.0 Release / 1.4.0 release for races ###
This should be the final major release before 1.0.  It has various new features and performance improvement.
- **2 races split enable option is now an option in "Enemy Mapping Method", instead of checkbox.  Please select "2 races split" before continue your save if you are using this option.**
- Added one race per surface support.
  - Each Space Exploration planet will have a random race.
  - UI shows the race that resides on the surface.
- Added an optional stylized base builder.
  - Enemy base can build must quicker in a configurable formation, instead of 1 building per build command.
- Tuned base builder groups to improve overall enemy units performance.

###### Race Mods 1.4.0 / 1.1.0  
- Fix unit spawns function on Drone/Probe wasting cpu cycles.
- Change various unit spawn requirements.
- Add one or 2 weakness resistances to each race. The weakness resistance is 85, instead of 90.
- Toss weak to acid.  Zerg weak to cold and electric.
- Terran added acid/cold damage dealer. Existing units have various buffs.


### New race demo
These mods are made as educational demos. They are not on Factorio Mod Portal due to copyrighted contents.

Download the zip and move it the mod folder. Please visit the following link for folder details.  https://wiki.factorio.com/index.php?title=Application_directory

The infamous zerg (1.4.0 / 2021-04-03) (It includes developer documentation, please take a look [DEV-README.md](https://github.com/heyqule/erm_zerg/blob/main/DEV-README.md))

* Release Page: https://github.com/heyqule/erm_zerg/releases/tag/1.4.0
* Download: https://github.com/heyqule/erm_zerg/releases/download/1.4.0/erm_zerg_1.4.0.zip
* Change Log: https://github.com/heyqule/erm_zerg/blob/main/changelog.txt

![Zerg](https://mods-data.factorio.com/assets/29e5f87b5fa05edefc8ac6d4a9d9ebc9aaa4addc.png "Zerg")

The godly protoss (1.4.0 / 2021-04-03)

* Release Page: https://github.com/heyqule/erm_toss/releases/tag/1.4.0
* Download: https://github.com/heyqule/erm_toss/releases/download/1.4.0/erm_toss_1.4.0.zip
* Change Log: https://github.com/heyqule/erm_toss/blob/main/changelog.txt

![Protoss](https://mods-data.factorio.com/assets/45b1471ea6121089d4163aa08157dd5292b9873f.png "Protoss")

Since P and Z has ganged up to wreck your base. Your engineer have innovated some new tech to counter them.

The terran, player support units (1.1.0 / 2021-04-03)

* Release Page: https://github.com/heyqule/erm_terran/releases/tag/1.1.0
* Download: https://github.com/heyqule/erm_terran/releases/download/1.1.0/erm_terran_1.1.0.zip
* Change Log: https://github.com/heyqule/erm_terran/blob/main/changelog.txt
* This demo requires https://mods.factorio.com/mod/Unit_Control

![Terran](https://mods-data.factorio.com/assets/697dc6bfcebe21989475ff15f83abbfddb7d98c0.png "Terran")

Youtube: https://www.youtube.com/watch?v=pcrFmtvNYTU 

Tips on defense: A LOT OF construction robots and repair kits. Mix all turrets. Uranium bullets are OP. 

### Features
###### 3 difficulty levels 
  * Casual, max at level 5
  * Normal, max at level 10 (default, targets weapon lvl 15) 
  * Advance, max at level 20 (targets weapon lvl 25)

The difficulty levels are tested against piercing bullet for gun turret.  Uranium bullets melt everything. 

###### Adjustable max attack range for extra long range attack units
  * Normal, 14, default
  * Advanced, 20, outside of gun turret range. 

###### Enemy Unit Leveling
First 3 level is tied to force's evolution factor
  * {0.4, 0.8}

The next 15 level is tied to force's hidden evolution factors (time, pollution and kill spawner).
  * {20, 60, 100, 150, 200, 250, 300, 350, 400, 500, 600, 700, 900, 1100, 1350, 1750, 2500}
  * evolution_base_point + (evolution_factor_by_pollution + evolution_factor_by_time + evolution_factor_by_killing_spawners) * level_multiplier
  * evolution_base_point is used for specific customization, default is 0.
  * level_multiplier default to 1.

Leveling support for base game biter/spitters, Armoured Biters, Explosive Biters & Cold Biters.

###### New enemies can be added as new forces

Manage new race as new enemy force.  Each race has its own force statistics

###### Tiered unit spawns
New races may have up to 3 tiers of unit-spawners and turrets.  This applies to enemy base expansion.
  * 0 - 0.4 evolution factor use tier 1 spawns
  * 0.4 adds tier 2
  * 0.8 adds tier 3

###### Artillery-Shell damage buff
Artillery-Shell damage bonus now is part of infinite stronger-explosive upgrade.  
  * Added this due to structure resistance and health increase

###### GUI to view each race and its stats.
- replace races on a surface

###### Custom enemy base autoplace
Default 
  - using base game autoplace. All races are mixed.

2 races split
  * race A spawns at positive axis, race B spawns at negative axis
  * race A spawns at positive axis, nothing spawns at negative axis.  
  * can be horizontally or vertically divided. 
  * races can expand into each other's territory.

![Special Spawn Layout](https://mods-data.factorio.com/assets/fe75ade7bf1ee69b37d6a4201e766239cde7bd15.png "Special Spawn Layout")

One race per surface
* randomly assign a race for each surface / planet.
* It's for Space Exploration.
* The race of a planet can be changed using replace function from UI.

###### Custom enemy base expansion
In base game, each building group build one building at a time.  This feature changes that they build several building at one time with specified formation.
* Default
  * build one at a time
* Command Center
  * When the unit group base builds a command center type spawner, it triggers "Build A Town" logic. Otherwise, it's default logic
* Build A Town
  * Always use build formation option to build the base.
* Full Expansion
  * When the first biter builds, everyone from the group will build based on "Build A Town" logic.
  
You can change the build formation option. For example: 
* 1 cc, 2 support spawner, 4 turrets
* 1 cc, 4 support spawner, 5 turrets
* and more

Partial formation is build based on cc > support > turret priority.


### Mod Compatibility

##### Resource Spawner Overhaul 
- You have to enable "Use vanilla biter generation" in Startup tab and disable "Use RSO biter generation" in Map tab

##### Space Exploration
- Supports one race per planet!
- Randomly selects a race when a new planet/surface is created
- Change race for the planet you are on from UI

##### Krastorio2   
- New races do not support creep generation unless author patches the creep generation code.
    - https://mods.factorio.com/mod/Krastorio2/discussion/605d800cf3bb48c41a98cd6b

##### Rampant AI
- It works with default settings.  However, its AI code only work for "enemy" force.  It does not affect custom enemy forces.
- It is NOT compatible with its custom biters at the moment.  Enabling them may crash the game.  I have not tested this.

##### Armoured Biters & Explosive Biters & Cold Biters
- All biters, worms and spawners support leveling.
- They joined default enemy force, erm_vanilla.
- The health setting stacks with this mod's multiplier.
- Biters do not heal, spawner and worm do.

For more compatibility details, please visit https://github.com/heyqule/enemy_race_manager/blob/main/README.md

### Known Issues
* Defense turrets from new force attack player in peaceful mode. If you know how to fix it, please message me.

### Roadmap after 1.0
Angry meters
  * send enemy to your base @ night based on how many they have been killed

Flying units attack squads
  * nuff said

### Uninstall
Please use the "Reset to default biters" button to replace ERM enemies with default biters before you remove the mod.  Otherwise, your map won't have any enemies on generated chucks as the ERM enemies are removed automatically.