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
These mods usually break ERM's critical functions. Conflict mods may be lifted once it deemed to be compatible.

Conflict mods may use remote.call("enemyracemanager", "is_erm_group") to check whether they are dealing with ERM unit group and avoid applying custom logic to prevent conflicts. 

#### Intelligent Enemy
- Incompatible.  It interferes ERM core functions and causes massive lag spikes.
