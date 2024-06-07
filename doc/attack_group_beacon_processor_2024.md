# Beacon System
This replaces the old attack group attack system.

## New beacon
Added new "resource" entities for each enemy forces to use as beacon:

MOD_NAME/attacker_target_beacon
- govern 64 tiles
- only one beacon exists within this width
- This beacon tracks attack-able entity locations and target force.
- The amount of the resource tracks total number of attack-able entities.  (max 100, base on count_entities_filtered)
- When this beacon is picked, the processor pick it target and generate the attack 32 tiles wide AOE attack command.

MOD_NAME/attacker_land_defense_beacon
- govern 64 tiles wide
- only one beacon exists within this width
- This beacon tracks enemy's is_military structures for advanced pathing.
- The amount of resource tracks amount of turrets with the chunk. (max 100)
- Deploy by land scout units

MOD_NAME/attacker_air_defense_beacon
- govern 64 tiles wide
- only one beacon exists within this width
- This beacon tracks enemy's is_military structure for advanced pathing.
- The amount of resource tracks amount of turrets with the chunk. (max 100)
- Deploy by aerial scout units

MOD_NAME/spawn_beacon
- 320 tiles wide
- only one beacon exists within this width
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


 
## Workflow:
See attackgrou.drawio

it consist of the following workflow:
- When chunks generated and onBiterBaseBuilt
- When pick_spawn_location is called,
- When pick_attack_location is called