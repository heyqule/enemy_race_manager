# Beacon System
This replaces the old attack group attack system.

## New beacon
Added new "resource" entities for each enemy forces to use as beacon:

MOD_NAME/attacker_target_beacon
- govern 96 tiles chunk
- only one beacon exists in one beacon chunk
- This beacon tracks attack-able entity locations and target force.
- The amount of the resource tracks total number of attack-able entities.  (max 100, base on count_entities_filtered)
- When this beacon is picked, the processor pick it target and generate the attack 32 tiles wide AOE attack command.

MOD_NAME/attacker_land_defense_beacon
- govern 96 tiles wide chunk
- only one land/air beacon exists in one beacon chunk
- This beacon tracks enemy's is_military structures for advanced pathing.
- The amount of resource tracks amount of turrets with the chunk. (max 100)
- Deploy by land scout units

MOD_NAME/attacker_air_defense_beacon
- govern 96 tiles wide chunk
- only one beacon exists in one beacon chunk
- This beacon tracks enemy's is_military structure for advanced pathing.
- The amount of resource tracks amount of turrets with the chunk. (max 100)
- Deploy by aerial scout units

MOD_NAME/spawn_beacon
- 320 tiles wide
- only one land/air beacon exists in one beacon chunk
- This beacon tracks enemy's spawn structure for spawner finding.
- The amount of resource track amount of unit-spawner within the chunk. (max 100)


## Beacon Data
```lua
---Data Structure to store additional data.
global.spawn_beacon = {
    [force_name] = {
        [surface_name] = {
            {
              beacon = beacon,
              position = beacon.position,
              created = game.tick,
              updated = game.tick,
              other_data = other_data
            }
        },
    }
}

global.land_defense_beacon = {
    [surface_name] = {
        [target_force] = {
          {
            beacon = beacon,
            position = beacon.position,
            created = game.tick,
            updated = game.tick,
            other_data = other_data
          }
        }
    },
}

global.aerial_defense_beacon = {
    [surface_name] = {
        [target_force] = {
          {
            beacon = beacon,
            position = beacon.position,
            created = game.tick,
            updated = game.tick,
            other_data = other_data
          }
        }
    },
}
global.attackable_entity_beacon = {
    [surface_name] = {
        [target_force] = {
          {
            beacon = beacon,
            position = beacon.position,
            created = game.tick,
            updated = game.tick,
            other_data = other_data
          }
        }
    },
}

```

## Each race has 2 new scout units.
- One land unit and one for aerial unit.
- They have 100 HP and don't attack from distraction.
- When they die, they emit the attacker_target_beacon or attacker_defense_beacon if it meets criteria.

## When you build mining drill entity, the perimeter of your base updates   

this is used to use for picking spawn point. 
```lua
---Data Structure to store 4 position points and spawn point.
global.player_base_diameters = {
    [force_name] = {
        [spawn_point] = {
          surface = surface_name,
          position = {x,y},
        },
        [surface_name] = {
            [northeast] = {
                x = 0,
                y = 0
            },
            [northwest] = {
              x = 0,
              y = 0
            },
            [southeast] = {
              x = 0,
              y = 0
            },
            [northwest] = {
              x = 0,
              y = 0
            }
        }
    }
} 
```
 
## Workflow:

#### When chunks generated and onBiterBaseBuilt
- If a beacon doesn't exist within 320 radius
- If it has a command center unit spawner.
- If it doesn't have command center, use regular spawner.
- Place spawn beacon on target.

#### When pick_spawn_location is called,
- Pick attack location first and then use cross search to pick spawn location.
- If spawner not found within beacon radius, remove beacon.

#### When pick_attack_location is called

- Start from force spawn, do a cross search to find next attack location in clockwise. 
  - 1280 tile, 3200 tile, and 6400 tile length.
  - 320 tile, 640 tile and 1280 tile wide.
- If any prerequisite entity exists in the node, return position and record it as previous search.
- If any prerequisite entity not found, remove node from attack beacon.
  - find the nearest enemy as target or set auto