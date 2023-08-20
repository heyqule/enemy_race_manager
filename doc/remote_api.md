## Remote APIs

Remote APIs allow you to spawn an attack group or change the race settings in your mod or scenario.

## Race Setting API

#### Create or update race setting

```remote.call('enemy_race_manager', 'register_race', {settings...})```

Please refer to the addRaceSettings() in controllers/initializer.lua for setting data structure.

##### Proper way to update race_setting in enemy mods

1. ```local race_settings = remote.call('enemy_race_manager', 'get_race', 'erm_zerg')```
2. make change to the race settings
3. ```remote.call('enemy_race_manager', 'update_race_setting', race_settings)```

#### Get race setting

```remote.call('enemy_race_manager', 'get_race', 'erm_zerg')```

Returns the ERM settings of a race. This includes level, xp

#### Get race tier

```remote.call('enemy_race_manager', 'get_race_tier', 'erm_zerg')```

Return the unit tier of a race.

#### Get race level

```remote.call('enemy_race_manager', 'get_race_level', 'erm_zerg')```

Return the level of a race.

#### Add point to attack meter of a race

```remote.call('enemy_race_manager', 'add_points_to_attack_meter', 'erm_zerg', 5000)```

if the 3rd parameter is nil, a race will be randomly picked.

## Generate Attack Groups

The following APIs generate regular attack groups.

* 3rd param is race name.
* 4th param is optional group size.

#### Generate a mixed attack group

```remote.call('enemy_race_manager', 'generate_attack_group', 'erm_zerg', 100)```

#### Generate a flying attack group

```remote.call('enemy_race_manager', 'generate_flying_group', 'erm_zerg', 50)```

Default size: Max Group Size / 2

#### Generate a dropship attack group

``` remote.call('enemy_race_manager', 'generate_dropship_group', 'erm_zerg', 20) ```

Default size: Max Group Size / 5

## Generate featured attack groups

The following APIs generate featured attack and elite groups.

* 3rd param is race name.
* 4th param is optional group size.
* 5th param is optional feature group ID. It randomly picks a group if value is nil.
    * Please refer to feature group table sections.

#### Generate a featured attack group

```remote.call('enemy_race_manager', 'generate_featured_group', 'erm_zerg', 100, 1)```

#### Generate a featured flying attack group

```remote.call('enemy_race_manager', 'generate_featured_flying_group', 'erm_zerg', 50, 1)```

#### Generate an elite attack group

```remote.call('enemy_race_manager', 'generate_elite_featured_group', 'erm_zerg', 100, 1)```

#### Generate an elite flying attack group

```remote.call('enemy_race_manager', 'generate_elite_featured_flying_group', 'erm_zerg', 50, 1)```

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