# Planet Modding for ERM
ERM by default run on all planets with compatible "enemy" autoplaces. New enemies on a new planet which shares same "enemy" force are likely to run.

When a planet doesn't use compatible "enemy" autoplaces, it's automatically excluded from running ERM logics.

However, if you need to exclude your planets from ERM, then you'll have to add the following code to your mod.

## Step 1
Add enemyracemanager as your hidden optional dependency.
```json
"(?)enemyracemanager > 2.0.39"
```

## Step 2
### You want to exclude ERM to run on your planet.
```lua
# Add this to your data.lua

data.raw['mod-data']['ERM_surface_exclusions'].data['your_planet_prototype_name'] = true
```

### You want to exclude ERM's interplanetary attack to run on your planet.
```lua
# Add this to your data.lua

data.raw['mod-data']['ERM_interplanetary_attack_exclusions'].data['your_planet_prototype_name'] = true
```


### Sample Mod Example to fully disable ERM logic on a planet.
#### info.json
```json
{
    "name": "erm_exclude_planet_x",
    "version": "1.0.0",
    "date": "2026-01-01",
    "title": "Exclude Planet X from running ERM logic",
    "author": "heyqule",
    "description": "Description goes here",
    "factorio_version": "2.0",
    "dependencies": [
        "(?)enemyracemanager > 2.0.39"
    ]
} 
```

#### data.lua
```lua
data.raw['mod-data']['ERM_surface_exclusions'].data['your_planet_prototype_name'] = true
data.raw['mod-data']['ERM_interplanetary_attack_exclusions'].data['your_planet_prototype_name'] = true
```