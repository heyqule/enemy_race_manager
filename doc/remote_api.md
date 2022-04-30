## Remote API

#### Create or update race setting
```remote.call('enemy_race_manager', 'register_race', {settings...})```

Please refer to addRaceSettings() for setting data structure.

#### Return race setting
```remote.call('enemy_race_manager', 'get_race', 'erm_zerg')```

#### Return race tier
```remote.call('enemy_race_manager', 'get_race_tier', 'erm_zerg')```

#### Return race level
```remote.call('enemy_race_manager', 'get_race_level', 'erm_zerg')```


#### Proper way to update race_setting in enemy mods
1. ```local race_settings =  remote.call('enemy_race_manager', 'get_race', 'erm_zerg')```
2. make change to race_settings
3. ```remote.call('enemy_race_manager', 'update_race_setting', race_settings)```

#### Generate a mixed attack group
```remote.call('enemy_race_manager', 'generate_attack_group', 'erm_zerg', 100)```

#### Generate a flying attack group
```remote.call('enemy_race_manager', 'generate_flying_group', 'erm_zerg', 100)```

#### Generate a dropship attack group
``` remote.call('enemy_race_manager', 'generate_dropship_group', 'erm_zerg', 100) ```

#### Generate a featured attack group 
```remote.call('enemy_race_manager', 'generate_featured_group', 'erm_zerg', 50, 1)```

This call ignores race tier 3 requirement

#### Generate a featured flying attack group
```remote.call('enemy_race_manager', 'generate_featured_flying_group', 'erm_zerg', 50, 1)```

This call ignores race tier 3 requirement

#### Generate an elite attack group
```remote.call('enemy_race_manager', 'generate_elite_featured_group', 'erm_zerg', 100, 1)```

This call ignores race tier 3 requirement

#### Generate an elite flying attack group
```remote.call('enemy_race_manager', 'generate_elite_featured_flying_group', 'erm_zerg', 50, 1)```

This call ignores race tier 3 requirement