## Remote APIs

Remote APIs allow you to spawn an attack group or change the race settings in your mod or scenario.

## Race Setting API

#### Create or update race setting

```remote.call('enemyracemanager', 'register_race', {settings...})```

Please refer to the addRaceSettings() in controllers/initializer.lua for setting data structure.

##### Proper way to update race_setting in enemy mods

1. ```local race_settings = remote.call('enemyracemanager', 'get_race', 'erm_zerg')```
2. make change to the race settings
3. ```remote.call('enemyracemanager', 'update_race_setting', race_settings)```

#### Get race setting

```remote.call('enemyracemanager', 'get_race', 'erm_zerg')```

Returns the ERM settings of a race. This includes level, xp

#### Get race tier

```remote.call('enemyracemanager', 'get_race_tier', 'erm_zerg')```

#### Add point to attack meter of a race

```remote.call('enemyracemanager', 'add_points_to_attack_meter', 'erm_zerg', 5000)```

if the 3rd parameter is nil, a race will be randomly picked.

## Generate Attack Groups

The following APIs generate regular attack groups.

* 3rd param is race name.
* 4th param is optional group size.

#### Generate a mixed attack group

```remote.call('enemyracemanager', 'generate_attack_group', 'erm_zerg', 100)```

#### Generate a flying attack group

```remote.call('enemyracemanager', 'generate_flying_group', 'erm_zerg', 50)```

Default size: Max Group Size / 2

#### Generate a dropship attack group

``` remote.call('enemyracemanager', 'generate_dropship_group', 'erm_zerg', 20) ```

Default size: Max Group Size / 5

## Generate featured attack groups

The following APIs generate featured attack and elite groups.

* 3rd param is race name.
* 4th param is optional group size.
* 5th param is optional feature group ID. It randomly picks a group if value is nil.
    * Please refer to feature group table sections.

#### Generate a featured attack group

```remote.call('enemyracemanager', 'generate_featured_group', 'erm_zerg', 100, 1)```

#### Generate a featured flying attack group

```remote.call('enemyracemanager', 'generate_featured_flying_group', 'erm_zerg', 50, 1)```

#### Generate an elite attack group

```remote.call('enemyracemanager', 'generate_elite_featured_group', 'erm_zerg', 100, 1)```

#### Generate an elite flying attack group

```remote.call('enemyracemanager', 'generate_elite_featured_flying_group', 'erm_zerg', 50, 1)```

### Feature groups tables

Look for the following tables for each race.

```
race_settings.featured_groups = { ... }
race_settings.featured_flying_groups = { ... }
```

* [Biters](https://github.com/heyqule/enemy_race_manager/blob/main/controllers/initializer.lua#L80)
* [Zerg](https://github.com/heyqule/erm_zerg/blob/main/control.lua#L92)
* [Protoss](https://github.com/heyqule/erm_toss/blob/main/control.lua#L90)
* [Redarmy](https://github.com/heyqule/erm_redarmy/blob/main/control.lua#L90)
* [Marspeople](https://github.com/heyqule/erm_marspeople/blob/main/control.lua#L91)

## Assign unit group as an ERM attack group, which will managed by ERM group logics
```
remote.call('enemyracemanager', 'add_erm_attack_group', unit_group:LuaCommandable, target_force:LuaForce)
```

## Get ERM's custom event handler
```
remote.call('enemyracemanager', 'get_event_name', event_name)
```


## Check whether a LuaCommandable is an ERM group
```remote.call('enemyracemanager', 'generate_elite_featured_flying_group', unit_group:LuaCommandable)```


## Override attack strategy, Call this right after you call any of the generate group remote calls.
Example:
```
remote.call('enemyracemanager', 'generate_elite_featured_flying_group', 'erm_zerg', 50, 1)
remote.call('enemyracemanager', 'override_attack_strategy', 1)
```
Acceptable values:
- 1 / divert to left side of the target
- 2 / divert to right side of the target
- 3 / brutal force based on scout beacons

## Check whether a force is a valid ERM enemy force
```
remote.call('enemyracemanager', 'is_enemy_force', LuaForce)
```

## Register Army Units
Register all your unit and then run reindex in controller
```
remote.call('enemyracemanager', 'army_units_register', entity_name, population)
remote.call('enemyracemanager', 'army_reindex')
```

## Register Army Command Center for teleportation
```
remote.call('enemyracemanager', 'army_command_center_register', entity_name)
```
## Register Army Deployment for teleportation
```
remote.call('enemyracemanager', 'army_deployer_register', entity_name)
```

## Force a group to build an ERM base
```
remote.call("enemyracemanager", "build_base_formation", unit_group)
```

## Get quality point of a force on a planet
```
remote.call("enemyracemanager", "get_quality_point", force_name, planet_name)
```

## Roll quality for a force on a planet
```
local quality = remote.call("enemyracemanager", "get_quality_point", force_name, planet_name)
local entity_name = 'erm_zerg--zergling--'..quality
```

## Assign unit group to attack next target
```
remote.call("enemyracemanager", "process_attack_position", {
  group = group
})

Include other optional options
remote.call("enemyracemanager", "process_attack_position", {
  group = group
  --- Change distraction
  distraction = defines.distraction.by_enemy
  --- Find near by attackable entity to attack
  find_nearby = true
  --- Find new beacon
  new_beacon = true
  --- Make them target specific player force.
  target_force = LuaForce
})
```