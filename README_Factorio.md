# Enemy Race Manager
This mod aim to enhanced toughness of enemies with minimal overhead by adding levels to enemies.
It also provide an easy to use [LuaRemote](https://lua-api.factorio.com/latest/LuaRemote.html) interface to add new enemy races. Please refer to the demos below.

**I hope someone with art skills can come up with some new original races.**

### 1.0.0 Release
This release focused on minor bug fix and code refactor.  I also added a command to override level.
```
/ERM_levelup race_name,level  (/ERM_levelup erm_vanilla,8)
```
This lets you fight harder enemy without changing the level multiplier midgame.  You can also change back to the evolution point calculated level if the override level is too hard to handle.

- The enemy is at level 3 based on evolution points, you can change it to higher level and then set it back to 3.
- You can not set the level to 2 because the progressed level is at 3.


### New race demo
These mods are made as educational demos.

Youtube: https://www.youtube.com/watch?v=pcrFmtvNYTU

New Enemy Races:
[>>>>Zerg<<<<](https://mods.factorio.com/mod/erm_zerg)
![Zerg](https://mods-data.factorio.com/assets/515e5390e5d7d8ad2135fb9e6604a995566204ee.png "Zerg")

[>>>>Protoss<<<<](https://mods.factorio.com/mod/erm_toss)
![Protoss](https://mods-data.factorio.com/assets/656569de2ac0658bd1907a5a8c71f4553a952d6b.png "Protoss")

Defense Units:
[>>>>Terran<<<<](https://mods.factorio.com/mod/erm_terran)
![Terran](https://mods-data.factorio.com/assets/15b0714cb3f3a01e371c9db36e12b3393f3429a2.png "Terran")

Tips on defense: A LOT OF construction robots and repair kits. Mix all turrets. Uranium bullets are OP.

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

* {20, 60, 100, 150, 200, 250, 300, 350, 400, 500, 600, 700, 900, 1100, 1350, 1750, 2500}
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

* using base game autoplace. All races are mixed.

2 races split

* race A spawns at positive axis, race B spawns at negative axis
* race A spawns at positive axis, nothing spawns at negative axis.
* can be horizontally or vertically divided.
* races can expand into each other's territory.

![2 races split](https://mods-data.factorio.com/assets/4a18da6eda30b7f3e8bc3c1dea98f42115b90eaa.png "2 races split")

One race per surface/planet

* randomly assign a race for each surface / planet.
* It's for Space Exploration.
* The race of a planet can be changed using replace function from UI.

![One race per surface/planet](https://mods-data.factorio.com/assets/0da5fad0ee211f160a359e8b994e80269716a56e.png "One race per surface")

#### Custom enemy base expansion
This defines how enemy expand into new area.  In base game, each building group build one building at a time.  This feature changes that they build several buildings at one time with specified formation.

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

![1-4-5 Formation](https://mods-data.factorio.com/assets/42b016483f30cb37d009e59b417a82e1c4a362b9.png "1-4-5 Formation")

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

For more compatibility details, please visit https://github.com/heyqule/enemy_race_manager/blob/main/README.md#mod-compatibility

### Known Issues
* Defense turrets from new force attack player in peaceful mode. If you know how to fix it, please message me.

### Roadmap after 1.0
ERM_RedArmy
- engineers with various weapons
- machine gun car
- machine gun, cannon tank
- laser and rocket plane

Angry meters

* send enemy to your base @ night based on how many they have been killed

Flying units attack squads

* nuff said

### Uninstall
Please use the "Reset to default biters" button to replace ERM enemies with default biters before you remove the mod.  Otherwise, your map won't have any enemies on generated chucks as the ERM enemies are removed automatically.