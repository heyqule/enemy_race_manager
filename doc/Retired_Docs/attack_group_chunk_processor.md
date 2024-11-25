## Attack Group Spawn Location Handling

###Data Structure

```json
{
  "attack_group_spawnable_chunk": {
    "{surface_name}": {
      "northwest": {
        "chunks": {
            "320/-320": {
              "x": 320,
              "y": -320,
              "next_node_name": null,
              "prev_node_name": null
            }
          },
        "head_node_name": "",
        "new_node_name": ""
      },
      "northeast": {
        "chunks": {},
        "head_node_name": "",
        "new_node_name": ""
      },
      "southeast": {
        "chunks": {},
        "head_node_name": "",
        "new_node_name": ""
      },
      "southwest": {
        "chunks": {},
        "head_node_name": "",
        "new_node_name": ""
      },
      "race_cursors": {
        "{race_name}": {
          "current_direction": 1,
          "rotatable_directions": [1, 2, 3, 4],
          "current_node_name": {
            "northwest": "{node_name}"
          }
        }
      }
    }
  } 
}
```

### Workflow

#### When a chunk has generated

- If it's at a chunk number x or y that modulus 10
- If it has a unit spawner
- Add that position to the chunk list in 1 of 4 area. (northeast, northwest, southeast, southwest)

#### When pick_spawn_location is called

- change current_direction to the next direction. e.g northeast to northwest
- take the next node in the list, retry up to 5 times in other directions
- select 10 spawner and randomly pick 1 of them to return
- if there isn't spawner, check whether there is unit-spawner from other enemy races.
    - If unit-spawner not found, remove chunk from the list.
    - return nil

# Attack Group Attack Location Handling

###Data Structure

```json
{
  "attack_group_attackable_chunk": {
    "{surface_name}": {
      "chunks": {
        "320/-320": {
          "x": 320,
          "y": -320,
          "next_node_name": null,
          "prev_node_name": null
        }
      },
      "current_node_name": "",
      "current_direction": 1,
      "head_node_name": "",
      "new_node_name": ""
    }
  }  
}
```

### Workflow

#### When player and bot has built a prerequisite entity

- Add the position node to the tracking list

#### When pick_attack_location is called

- Pick the next position node from the list.
- If any prerequisite entity exists in the node, return position
- If any prerequisite entity not found, remove node from the list and find the nearest enemy as target