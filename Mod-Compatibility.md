#### Resource Spawner Overhaul
- You have to enable "Use vanilla biter generation" in Startup tab and disable "Use RSO biter generation" in Map tab

#### Space Exploration
- Supports one race per planet!
- Randomly selects a race when a new planet/surface is created
- Change race for the planet you are on from UI

#### Krastorio2
- New races do not support creep generation unless author patches the creep generation code or its remote API.
    - https://mods.factorio.com/mod/Krastorio2/discussion/605d800cf3bb48c41a98cd6b
- turn on "Peaceful mode" in Krastorio2 setting to bypass the biomass requirements.
- More realistic weapons option must have "Auto-aim for MRW" enabled to hit air units.

#### Armoured Biters & Explosive Biters & Cold Biters
- All biters, worms and spawners support leveling.
- They join default enemy force, erm_vanilla.
- The biter mods' multiplier stacks with ERM's multiplier. I suggest leave them alone and adjust the multiplier in ERM.

#### Rampant AI (limited)
- It works with default settings.  However, its AI code only work for "enemy" force.  It does not affect custom enemy forces.
- Rampant enemies override default spawners. Enabling them may have odd behavior. They also don't support many features from ERM.

#### Other biter mods with tiers and level, like bobs enemy or natural evolution enemies.
- Not supported.  ERM override the biter spawners table.

#### New Game Plus
- When the game resets, attack meter also reset.
- When "reset evolution factor" is checked, level, tier and evolution points are preserved. Evolution factor and attack meter get reset.
- When "reset research" is checked, everything reset.