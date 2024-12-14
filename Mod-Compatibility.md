#### Compatilbility for 2.0

For 1.1, see https://github.com/heyqule/enemy_race_manager/blob/1.22.6/Mod-Compatibility.md

Overhaul mod compatibility will be done when they become available.

#### Armoured Biters & Explosive Biters & Cold Biters & Toxic Biters

- All biters, worms and spawners supports quality spawning.
- They join default enemy force, enemy.
- The biter mods' multiplier stacks with ERM's multiplier. I suggest leave them alone and adjust the multiplier in ERM.
- ERM branded enemies have higher priority in autoplace control.  These spawners may not show up if there is conflict in the planet autoplace.

#### Other not mentioned enemy mods

- It may or may not work. Expect incompatibility.

#### Milestone

- Milestone for killing higher tier enemy command centers.
- Milestone for killing bosses

#### Super Weapon Attack Points / Counter Attack supported mods
- Ion Cannon [space-age]

## MODS with issues, but not considered conflicted
#### Distant Misfires
- It messed up bullet collision layers.  Their bullets can't hit air units.

#### Enable All Feature Flags
- Misuse of feature flags.  It enables space_travel flag when space-age mod is disabled and cause startup crashes.
- Don't disable space-age mod when using this mod.

#### Resource Spawner Overhaul
- You have to enable "Use vanilla biter generation" in Startup tab and disable "Use RSO biter generation" in Map tab

#### AAI programmable vehicle

- It has a feature that prevent player/enemy build too close to each other.
- This affects proxy builder units which they build too close to your defenses, and you can't replace destroyed
  buildings.
- Try set "Deadzone construction denial range" to 5 tiles or something low. It defaults to 50 tiles.

## CONFLICTED MODS
These mods usually break many ERM's critical functions or/and cause indirect performance issues. Conflict mods may be lifted once it deemed to be compatible.

There are 2 ways for mods to avoid conflict with ERM.
1. Check whether the unit group is script driven.  If so, they should not apply their logic to the group.  Those is_script_driven groups are likely controlled by other mods.
   - Enemy AI mods should track their own groups and avoid apply change to other enemy mod's AI group. 
   - https://lua-api.factorio.com/latest/classes/LuaCommandable.html#is_script_driven
2. They may use remote.call("enemyracemanager", "is_erm_group", LuaCommandable) to check whether they are dealing with ERM unit group and avoid applying custom logic to prevent conflicts. 

#### Intelligent Enemy (as of 1.0.7)
- Incompatible.  It interferes ERM core functions.  
  - causes custom attack group behaviour anomalies.
