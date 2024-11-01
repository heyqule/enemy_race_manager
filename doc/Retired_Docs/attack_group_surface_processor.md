#Workflow

####Data Structure

```json
{
  "attack_group_surface_data": {
     "erm_vanilla": {
       "current_planet_pointer": null,
       "current_planet_name": "name",
       "current_cycle": 0
     }
  }
}
```

Processor starts when AttackGroupSurfaceProcessor.exec(race_name) is called.

- if surface pointer is found and current_cycle is less than cycle_threshold
    - return cached surface for that race

- check for next attack-able planet based on attack_group_spawnable_chunk data
    - cache and return surface if surface meets attack requirement.
    - reset current_cycle

- if surface is not found, reset race data and return nil
    - it will restart from beginning of attack_group_spawnable_chunk list in next time.

