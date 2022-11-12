#### Army Control Features

* Population limits.  Base MAX is 150.  It can increase with "Follower robot count" research.
  * Marine 1 pop
  * Tank/Wraith 2 pop
  * Battlecruise 5 pop
* Automated Army Deployment
   * 5MW constant power usage
   * Active deployment structure checks deploy every 5s
   * Auto disable after 3 deploy failures.
   * Limit of deployment building = max_pop / 10
* Unit teleportation beside command center.
   * 20MW constant power usage
   * Need to activate manually.
   * Once it's active, teleport 10 units to target location every 2 second
   * Auto disable in 60 seconds (can teleport 300 units / min)
   * Limit of command center = max_pop / 30

### Data Structures
```
Population Control
{
    [
        force_name = {
            max_pop = 200,
            current_pop = 150,
            current_unit = 52
            unit_types = {
                unit_name_1 = {count = 20, pop = 40},
                unit_name_2 = {count = 20, pop = 40}
            }      
        }
    ]
}
```

```
Registered Units
[unitname=pop_count, unitname=1, unitname2=2, unitname3=5]
```

```
Command Center List
[
    entity = command_center
    active = false
    target_location = location of other command_center
    duration_end = end_tick
]
```

```
Deployer List
[
    entity = command_center
    active = false
]
```

### UI
Unit detail dialog
- Show unit stats
Unit deployment dialog
- Show deployer data and settings
Command center dialog
- Show each command center settings



