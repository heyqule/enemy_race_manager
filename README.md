# Enemy Race Manager
This mod will aim to enhanced toughness of enemies with minimal overhead, also provide an easy to use [LuaRemote](https://lua-api.factorio.com/latest/LuaRemote.html) to add new enemy race.

### Features
- 2 difficulty levels 
  * Normal, max at level 10 (default, targets weapon lvl 15) 
  * Advance, max at level 20 (targets weapon lvl 25)
- First 5 level is tied to force's evolution factor
  * {0.25, 0.4, 0.65, 0.8}
- The next 15 level is tied to force's hidden evolution factors (time, pollution and kill spawner).
  * {120, 160, 200, 250, 300, 350, 400, 500, 600, 700, 900, 1100, 1350, 1750, 2500}
  * formular: evolution_base_point + (evolution_factor_by_pollution + evolution_factor_by_time + evolution_factor_by_killing_spawners) * level_multiplier
  * evolution_base_point is used for specific customization, default is 0.
  * level_multiplier default to 1.
- Manage new race as new enemy force.  Each race has its own force statistics
- New races may have up to 3 tiers of unit-spawners and turrets
  * 0 - 0.4 evolution factor use tier 1 spawns
  * 0.4 adds tier 2
  * 0.8 adds tier 3
- Artillery-Shell damage bonus now is part of infinite stronger-explosive upgrade.  
  * Added this due to structure resistance and health increase
- GUI to replace races on a surface
- Level support for vanilla biter/spitters

### New race demo
The infamous zerg
https://github.com/heyqule/erm_zerg/releases

Download the zip and move it the mod folder.  This will not be on Factorio Mod Portal due to copyrighted contents.

Youtube: https://www.youtube.com/watch?v=Zguo9pahy8E

New race units use more CPU resource than vanilla biters.  
It's great for defence focused death worlds. It's not ideal for computational resource limited giga bases. 

### Console Commands
ERM_GetRaceSettings
  * Show race settings in json format.

ERM_LevelUpWithTech
  * Level up enemy based on your researched offensive tech.

### Custom Events
- erm_tier_went_up - this triggers after race tier level up.
- erm_level_went_up - this triggers after race level up.

### Roadmap
* Advanced Mapping
  * stylish expansion based on a set of "command center", "support structure" and "turrets" instructions
* Angry meters
  * send enemy to your base @ night based on how many they have been killed
* Surface based controls / compatibility with space exploration