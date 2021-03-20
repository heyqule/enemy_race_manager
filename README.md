# Enemy Race Manager
This mod aim to enhanced toughness of enemies with minimal overhead by adding levels to enemies. 
It also provide an easy to use [LuaRemote](https://lua-api.factorio.com/latest/LuaRemote.html) interface to add new enemy races. Please refer to the demos below.
**I hope someone with art skills can come up with some new original races.**

### New race demo
These mods are made as educational demos. They are not on Factorio Mod Portal due to copyrighted contents.

Download the zip and move it the mod folder. Please visit the following link for folder details.  https://wiki.factorio.com/index.php?title=Application_directory

The infamous zerg (1.3.0 / 2021-02-13) (It includes developer documentation, please take a look [DEV-README.md](https://github.com/heyqule/erm_zerg/blob/main/DEV-README.md))

* Release Page: https://github.com/heyqule/erm_zerg/releases/tag/1.3.0
* Download: https://github.com/heyqule/erm_zerg/releases/download/1.3.0/erm_zerg_1.3.0.zip
* Change Log: https://github.com/heyqule/erm_zerg/blob/main/changelog.txt

![Zerg](https://mods-data.factorio.com/assets/29e5f87b5fa05edefc8ac6d4a9d9ebc9aaa4addc.png "Zerg")

The godly protoss (1.3.0 / 2021-02-13)

* Release Page: https://github.com/heyqule/erm_toss/releases/tag/1.3.0
* Download: https://github.com/heyqule/erm_toss/releases/download/1.3.0/erm_toss_1.3.0.zip
* Change Log: https://github.com/heyqule/erm_toss/blob/main/changelog.txt

![Protoss](https://mods-data.factorio.com/assets/45b1471ea6121089d4163aa08157dd5292b9873f.png "Protoss")

Since P and Z has ganged up to wreck your base. Your engineer have innovated some new tech to counter them.

The terran, player support units (1.0.0 / 2021-02-13)

* Release Page: https://github.com/heyqule/erm_terran/releases/tag/1.0.0
* Download: https://github.com/heyqule/erm_terran/releases/download/1.0.0/erm_terran_1.0.0.zip
* Change Log: https://github.com/heyqule/erm_terran/blob/main/changelog.txt
* This demo requires https://mods.factorio.com/mod/Unit_Control

![Terran](https://mods-data.factorio.com/assets/697dc6bfcebe21989475ff15f83abbfddb7d98c0.png "Terran")

Youtube: https://www.youtube.com/watch?v=pcrFmtvNYTU 

Tips on defense: A LOT OF construction robots and repair kits. Mix all turrets. Uranium bullets are OP. 

### Features
3 difficulty levels 
  * Casual, max at level 5
  * Normal, max at level 10 (default, targets weapon lvl 15) 
  * Advance, max at level 20 (targets weapon lvl 25)

The difficulty levels are tested against piercing bullet for gun turret.  Uranium bullets melt everything. 

Adjustable max attack range for extra long range attack units
  * Normal, 14, default
  * Advanced, 20, outside of gun turret range. 

First 3 level is tied to force's evolution factor
  * {0.4, 0.8}

The next 15 level is tied to force's hidden evolution factors (time, pollution and kill spawner).
  * {20, 60, 100, 150, 200, 250, 300, 350, 400, 500, 600, 700, 900, 1100, 1350, 1750, 2500}
  * evolution_base_point + (evolution_factor_by_pollution + evolution_factor_by_time + evolution_factor_by_killing_spawners) * level_multiplier
  * evolution_base_point is used for specific customization, default is 0.
  * level_multiplier default to 1.

Manage new race as new enemy force.  Each race has its own force statistics

New races may have up to 3 tiers of unit-spawners and turrets
  * 0 - 0.4 evolution factor use tier 1 spawns
  * 0.4 adds tier 2
  * 0.8 adds tier 3

Artillery-Shell damage bonus now is part of infinite stronger-explosive upgrade.  
  * Added this due to structure resistance and health increase

GUI replace races on a surface

Level support for vanilla biter/spitters

Support grouping race spawns.    
  * race A spawns at positive axis, race B spawns at negative axis
  * race A spawns at positive axis, nothing spawns at negative axis.  
  * can be divided by either x or y axis.
  * races can expand into each other's territory.

![Special Spawn Layout](https://mods-data.factorio.com/assets/fe75ade7bf1ee69b37d6a4201e766239cde7bd15.png "Special Spawn Layout")

### Mod Compatibility

#####Resource Spawner Overhaul 
- You have to enable "Use vanilla biter generation" in Startup tab and disable "Use RSO biter generation" in Map tab

#####Armoured Biters
- Most snappers and spawner support leveling, except Leviathan Snapper. 
- They joined default enemy force, erm_vanilla.  
- The health setting stacks with this mod's multiplier.
- Buffed resistances and healing.
- up to 80 elemental and 90 physical resistance for most snappers.
- up to 80 elemental and 95 physical resistance for Leviathan snapper.

#####Explosive Biters
- Coming Soon

#####Cold Biters
- Coming Soon


### Known Issues
* Defense turrets from new force attack player in peaceful mode. If you know how to fix it, please message me.

### Console Commands
ERM_GetRaceSettings
  * Show race settings in json format.

ERM_LevelUpWithTech
  * Level up enemy based on your researched offensive tech.

### Custom Events
- erm_tier_went_up - this triggers after race tier level up.
- erm_level_went_up - this triggers after race level up.
- erm_race_setting_update - this triggers in prepare_world() during on_init and on_configuration_changed, use for updating race_settings

### Roadmap
Advanced Mapping
  * stylish expansion based on a set of "command center", "support structure" and "turrets" instructions

Angry meters
  * send enemy to your base @ night based on how many they have been killed

Surface based controls / compatibility with space exploration

### Uninstall
Please use the "Reset to default biters" button to replace ERM enemies with default biters before you remove the mod.  Otherwise, your map won't have any enemies on generated chucks as the ERM enemies are removed automatically.