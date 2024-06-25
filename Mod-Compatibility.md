#### Resource Spawner Overhaul

- You have to enable "Use vanilla biter generation" in Startup tab and disable "Use RSO biter generation" in Map tab

#### Space Exploration

- Supports one race per planet!  Default generator work great too with its temperature algorithm.
- Randomly selects a race when a new planet/surface is created
- Change race for the planet you are on from UI

#### Krastorio2 (Requires 1.2+)

* New races support creep generation, can be changed on each race.
* Custom bullets can hit air

#### Industrial Revolution

- Custom bullets can hit air

#### Armoured Biters & Explosive Biters & Cold Biters & Toxic Biters

- All biters, worms and spawners support leveling.
- They join default enemy force, erm_vanilla.
- The biter mods' multiplier stacks with ERM's multiplier. I suggest leave them alone and adjust the multiplier in ERM.

#### Rampant AI (limited, may have interferences)

- It works with default settings. However, its AI code only work for "enemy" force. It does not affect custom enemy
  forces.
- It may interfere with ERM custom attack groups.
- Rampant enemies override ERM enemies!  DO NOT enable them.

#### Bobs enemies or natural evolution enemies.

- Playable without crash under default spawn.  (e.g Bobs Enemies & Natural Evolution Enemy)
- Not balanced for ERM specific playstyle. e.g leveling or free for all play.
- Only support default spawn. Can't use with 2ways,4ways or one race / planet.

#### Other not mentioned enemy mods

- It may or may not work. Expect incompatibility.

#### New Game Plus

- When the game resets, attack meter also reset.
- When "reset evolution factor" is checked, level, tier and evolution points are preserved. Evolution factor and attack
  meter get reset.
- When "reset research" is checked, everything reset.

#### AAI programmable vehicle

- It has a feature that prevent player/enemy build too close to each other.
- This affects proxy builder units which they build too close to your defenses, and you can't replace destroyed
  buildings.
- Try set "Deadzone construction denial range" to 5 tiles or something low. It defaults to 50 tiles.

#### Milestone

- Milestone for killing level 5/10/15/20 enemy command centers.
- Milestone for killing bosses

#### Super Weapon Attack Points / Counter Attack supported mods

- space exploration: Irdium Driver(Super weapon), Plague Rocket (Purifier type weapon)
- AtomicArtillery
- M.I.R.V (Purifier type weapon)
- Ion Cannon SE
- Kastorio2: Atomic Bomb, Atomic Artillery Shell, Antimatter Bomb, Antimatter Artillery Shell
- Industrial Revolution: Atomic Artillery Shell

### Team Competitions or any mod that adds new enemy forces
ERM logics do not affect on custom enemy forces which created by other mods.
In Team Competitions', I recommended to turn off its "Multiple Alien Forces" option. Otherwise, the enemy stays at level 1 and none of the advance logic work.