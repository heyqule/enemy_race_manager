# Enemy Race Manager
This mod will aim to enhanced toughness of enemies, also provide an easy to use [LuaRemote](https://lua-api.factorio.com/latest/LuaRemote.html) to manage new races.

### Features

- 3 tiers of enemy spawns 
  * 0 - 0.4 evolution factor use tier 1 spawns
  * 0.4 adds tier 2 
  * 0.8 adds tier 3)
- 2 difficulty levels 
  * Normal, max at level 10 (targets weapon lvl 15) 
  * Advance, max at level 20 (targets weapon lvl 25)
- First 5 level is tied to your evolution factor
  * {0.25, 0.4, 0.65, 0.8}
- The next 15 level is tied to your hidden evolution factor, such as time, pollution and kill spawner.  It also tied to your weapon damage upgrades.
  * e.g if your physical-damage bonus is leveled up to 15, the level 9 enemy base will level up to 10 and existing level 9 base are replaced with the leveled 10 version.
- it uses default autoplace spawner algo.
- it adds new race as new enemy force.  Each race has its own force statistics
- Artillery-Shell damage bonus now is part of infinite stronger-explosive upgrade.  
  * Added this due to structure resistance and health increase

### Console Commands

ERM_RegenerateEnemy
  * Replace existing biter when new enemy

ERM_ResetEnemyLevel
  * Raplace existing ERM enemy to match its race level.

ERM_GetRaceSettings
  * Show race settings in json format.


### Custom Events
erm_tier_went_up - this should trigger after race tier level up.
erm_level_went_up - this should trigger after race level up.


### Roadmap
* Add levels to original biters
* Advanced Mapping
  * new stylish expansion based on a set of "command center", "support structure" and "turrets" instructions
* Angry meters
  * send enemy to your base @ night based on how many they have been killed
