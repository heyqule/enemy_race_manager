## Remote APIs

Remote APIs allow you to spawn an attack group or change the race settings in your mod or scenario.

## Race Setting API

#### Create or update race setting

```lua
remote.call('enemyracemanager', 'register_race', {settings...})
```

Please refer to the addRaceSettings() in controllers/initializer.lua for setting data structure.

##### Proper way to update race_setting in enemy mods

1. ```local race_settings = remote.call('enemyracemanager', 'get_race', 'enemy_erm_zerg')```
2. make change to the race settings
3. ```remote.call('enemyracemanager', 'update_race_setting', race_settings)```

#### Get race setting

```lua
remote.call('enemyracemanager', 'get_race', 'enemy_erm_zerg')
```
Returns the ERM settings of a race. This includes level, xp and other data.

#### Get race tier

```lua
remote.call('enemyracemanager', 'get_race_tier', 'enemy_erm_zerg')
```
Return unit tier

#### Add 3rd party entity to attackable entity list

```lua
remote.call("enemyracemanager", "add_attack_group_attackable_entity", entity_name)
```

return boolean

#### Add point to attack meter of a race

```lua
remote.call('enemyracemanager', 'add_points_to_attack_meter', 'enemy_erm_zerg', 5000)
```

if the 3rd parameter is nil, a force will be randomly picked.

## Generate Attack Groups

The following APIs generate regular attack groups.

* 3rd param is force name.
* 4th param is optional group size.

#### Generate a mixed attack group

```lua
remote.call('enemyracemanager', 'generate_attack_group', 'enemy_erm_zerg', 100)
```

#### Generate a flying attack group

```lua
remote.call('enemyracemanager', 'generate_flying_group', 'enemy_erm_zerg', 50)
```

Default size: Max Group Size / 2

#### Generate a dropship attack group

```lua
 remote.call('enemyracemanager', 'generate_dropship_group', 'enemy_erm_zerg', 20) 
```

Default size: Max Group Size / 5

## Generate featured attack groups

The following APIs generate featured attack and elite groups.

* 3rd param is force name.
* 4th param is optional group size.
* 5th param is optional feature group ID. It randomly picks a group if value is nil.
    * Please refer to feature group table sections.

#### Generate a featured attack group

```lua
remote.call('enemyracemanager', 'generate_featured_group', 'enemy_erm_zerg', 100, 1)
```

#### Generate a featured flying attack group

```lua
remote.call('enemyracemanager', 'generate_featured_flying_group', 'enemy_erm_zerg', 50, 1)
```

#### Generate an elite attack group

```lua
remote.call('enemyracemanager', 'generate_elite_featured_group', 'enemy_erm_zerg', 100, 1)
```

#### Generate an elite flying attack group

```lua
remote.call('enemyracemanager', 'generate_elite_featured_flying_group', 'enemy_erm_zerg', 50, 1)
```

### Feature groups tables

Look for the following tables for each race.

```lua
race_settings.featured_groups = { ... }
race_settings.featured_flying_groups = { ... }
```

* [Biters](https://github.com/heyqule/enemy_race_manager/blob/main/controllers/initializer.lua#L80)
* [Zerg](https://github.com/heyqule/erm_zerg/blob/main/control.lua#L92)
* [Protoss](https://github.com/heyqule/erm_toss/blob/main/control.lua#L90)
* [Redarmy](https://github.com/heyqule/erm_redarmy/blob/main/control.lua#L90)
* [Marspeople](https://github.com/heyqule/erm_marspeople/blob/main/control.lua#L91)

### Override attack strategy, Call this right after you call any of the generate group remote calls.
Example:
```lua
remote.call('enemyracemanager', 'generate_elite_featured_flying_group', 'erm_zerg', 50, 1)
remote.call('enemyracemanager', 'override_attack_strategy', 1)
```
Acceptable values:
- 1 / divert to left side of the target
- 2 / divert to right side of the target
- 3 / brutal force based on scout beacons

### Assign unit group as an ERM attack group, which will managed by ERM group logics
```lua
remote.call('enemyracemanager', 'add_erm_attack_group', LuaCommandable, LuaForce)
```


### Get ERM's custom event handler
```lua
remote.call('enemyracemanager', 'get_event_name', event_name)
```

### Check whether a LuaCommandable is an ERM group
```lua
remote.call('enemyracemanager', 'is_erm_group', LuaCommandable)
```

### Check whether a force is a valid ERM enemy force
```lua
remote.call('enemyracemanager', 'is_enemy_force', LuaForce)
```

### Register Army Units
Register all your unit and then run reindex in controller
```lua
remote.call('enemyracemanager', 'army_units_register', entity_name, population)
remote.call('enemyracemanager', 'army_reindex')
```

### Register Army Command Center for teleportation
```lua
remote.call('enemyracemanager', 'army_command_center_register', entity_name)
```
### Register Army Deployment for teleportation
```lua
remote.call('enemyracemanager', 'army_deployer_register', entity_name)
```

### Force a group to build an ERM base
```lua
remote.call("enemyracemanager", "build_base_formation", unit_group)
```

### Get quality point of a force on a planet
```lua
remote.call("enemyracemanager", "get_quality_point", force_name (string), planet_name (string))
```

### Skip rolling quality when spawning an ERM entity
```lua
remote.call("enemyracemanager", "skip_roll_quality")
surface.create({...})
```
You have to set this before creating any ERM entity. The flag reset after entity creation.

### Roll quality for a force on a planet
```lua
local quality = remote.call("enemyracemanager", "roll_quality", force_name (string), planet_name (string))
local entity_name = 'erm_zerg--zergling--'..quality
```

### Assign unit group to attack next target
```lua
remote.call("enemyracemanager", "process_attack_position", {
  group = group
})

--- Include other optional options
remote.call("enemyracemanager", "process_attack_position", {
  group = group,
  --- Change distraction
  distraction = defines.distraction.by_enemy,
  --- Find near by attackable entity to attack
  find_nearby = true,
  --- Find new beacon
  new_beacon = true,
  --- Make them target specific player force.
  target_force = LuaForce
})
```

### Register an external planet for non space age game.
```lua
remote.call("enemyracemanager", "register_external_planet", {
  surface=luaSurface, 
  icon="icon_path", -- Optional
  radius=90000,  -- Optional
  type='planet' --Optional
}
```

### Get list of enemies on a surface
```lua 
remote.call("enemyracemanager", "get_all_enemies_on", surface_name)
```

### Randomly pick an enemy on a surface
```lua
remote.call("enemyracemanager", "get_enemy_on", surface_name)
```

### Set custom interplanetary attack intel
It's usually determinal automatically by InterplanetaryAttacks.determine_planet_details(surface_index).  This API allow override it.

```lua
remote.call("enemyracemanager", "interplanetary_attacks_set_intel", surface_index, {
  radius = 900000,
  type = "planet",  -- for tracking only, not use on any function.
  updated = game.tick,
  defense = 0, -- the score of player defense.  Up to 20% reduction on spawn chance.
  has_player_entities = false,
})
```