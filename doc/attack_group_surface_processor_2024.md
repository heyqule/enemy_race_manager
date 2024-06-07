# Surface  System
This replaces the old attack group surface system.

### When unit spawner dies

Tally death of unit spawner by surface and by force.

### Data-update.lua

Update all ERM spawner to support tally function.

```lua
global.dead_spawners = {
    by_enemy_force = {
        [force] = {
            [force_name] = 999,
        },
        [surfaces] = {
            [surface_name] = {
                currentDeath = 9999, 
                previousattack = 8999, 
                gap = 1000,   
            }
        }
    }
}
```

## Queue sorting events every 5 mins.
sort surface_index by value

## When processor starts
Processor starts when AttackGroupSurfaceProcessor.exec(race_name) is called.

Pick the highest death count by force
Pick the larget death gap death count by surface.
???
Profit.


