#### Compatilbility for 2.0

For 1.1, see https://github.com/heyqule/enemy_race_manager/blob/1.22.6/Mod-Compatibility.md

Overhaul mod compatibility will be done when they become available.

#### Armoured Biters & Explosive Biters & Cold Biters & Toxic Biters

- All biters, worms and spawners supports quality spawning.
- They join default enemy force, enemy.
- The biter mods' multiplier stacks with ERM's multiplier. I suggest leave them alone and adjust the multiplier in ERM.
- ERM branded enemies have higher priority in autoplace control.  These spawners may not show up if there is conflict in the planet autoplace.

#### Bob Enemies
- Bob enemies can't spawn under ERM as it replace normal biter spawner & worm during runtime.
- ERM add bob enemies as part of ERM biter autoplace.  Expect rainbows and do not expect unit balance.
- ERM track bob enemies kills and attack points.  But Bobs enemies do not use ERM logics.
- It changed spawner_evolution_factor_health_modifier to 20. ERM reverts it back to 10 (game default) as it affects balance of all ERM spawners.
- Any mod that spawner_evolution_factor_health_modifier will revert back to 10 when they are enabled with ERM.

#### Other not mentioned enemy mods

- It may or may not work. Expect incompatibility.

#### Milestone
- Milestone for killing higher tier enemy command centers.
- Milestone for killing bosses

#### Super Weapon Attack Points / Counter Attack supported mods
- Ion Cannon [space-age]

## MODS with issues, but not considered conflicted
#### Resource Spawner Overhaul
- ERM forcefully enabled "Use vanilla biter generation" and disabled "Use RSO biter generation" setting and hide them.
- Requires 7.0.15+ for various compatibility fixes.

#### AAI programmable vehicle
- It has a feature that prevent player/enemy build too close to each other.
- This affects proxy builder units which they build too close to your defenses, and you can't replace destroyed
  buildings.
- Try set "Deadzone construction denial range" to 5 tiles or something low. It defaults to 50 tiles.

#### Rampant AI (limited, may have interferences)
- It works with default settings. However, its AI code only work for "enemy" force. It does not affect custom enemy forces.
- It may interfere with ERM custom attack groups.
- New enemies placement does not work.

#### Combat Mechanic Overhaul
- Have been causing unexpected issues.  Expect anomalies when you use it.
- I have fixed some of them. Such as turrets can't hit air unit or other ground structures.

#### Any mod that changes the properties of space-age planets (e.g Solar System ++)
- ERM uses Nauvis as default planet.  Any mod that hide nauvis may cause unintended behaviours.
- Change space-age planet may lead to missing features or crashes.  Use at your own risk.

## CONFLICTED MODS
These mods usually break many ERM's critical functions or/and cause indirect performance issues. Conflict mods may be lifted once it deemed to be compatible.

There are 2 ways for mods to avoid conflict with ERM.
1. Check whether the unit group is script driven.  If so, they should not apply their logic to the group.  Those is_script_driven groups are likely controlled by other mods. 
   - https://lua-api.factorio.com/latest/classes/LuaCommandable.html#is_script_driven
2. They may use remote.call("enemyracemanager", "is_erm_group", LuaCommandable) to check whether they are dealing with ERM unit group and avoid applying custom logic to prevent conflicts. 

#### Intelligent Enemy (as of 1.0.7)
- Incompatible.  It interferes ERM core functions.  
  - causes custom attack group behaviour anomalies.
