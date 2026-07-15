# Planet Modding for ERM
ERM by default run on all planets with compatible "enemy" autoplaces. When new enemies that share same "enemy" force are added to a new planet, ERM logics are likely to run on that new planet.

When a planet doesn't use compatible "enemy" autoplaces, it's automatically excluded from running ERM logics.

## Exclude a planet from ERM
You can fine tune what ERM can run on your planet.   Please add the following as you see fit to your data.lua.

### Step 1
Add enemyracemanager as your hidden optional dependency.
```json
"(?)enemyracemanager > 2.1.0"
```

### Step 2
#### Fully exclude ERM to run on your planet.
```lua
-- Add this to your data.lua

data.raw['mod-data']['ERM_surface_exclusions'].data['your_planet_prototype_name'] = true
```

#### Exclude ERM's interplanetary attack to run on your planet.
```lua
-- Add this to your data.lua

data.raw['mod-data']['ERM_interplanetary_attack_exclusions'].data['your_planet_prototype_name'] = true
```

#### Disable ERM's bridge building mechanic on your planet
```lua
-- Add this to your data.lua

data.raw['mod-data']['ERM_bridge_ignore_surfaces'].data['your_planet_prototype_name'] = true
```

Notes:
- This method can not disable bridges in ERM enemies' home planets. e.g Aiur, Char and Earth.
- Bridge building was added to prevent water/island abuse.  It can cause performance issues when enemy could not path to your base.  Use at your own risk.

#### Sample Mod Example to fully disable ERM logic on a planet.
##### info.json
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

##### data.lua
```lua
data.raw['mod-data']['ERM_surface_exclusions'].data['your_planet_prototype_name'] = true
data.raw['mod-data']['ERM_interplanetary_attack_exclusions'].data['your_planet_prototype_name'] = true
```

## How to include ERM enemy autoplace to your planet / surface.
If you need to include an ERM enemy for your planet, you'll have to add the autoplace to your planet or surface.

Here are the available enemy autoplaces from base game and ERM mods.  3rd party enemy may have their own autoplace.
- enemy-base - Enemy autoplace
- gleba_enemy_base - Gleba spider autoplace
- enemy_erm_redarmy-enemy-base - Red Army autoplace
- enemy_erm_protoss-enemy-base - Protoss autoplace
- enemy_erm_zerg-enemy-base - Zerg autoplace

You should double check the pollution property of the planet.  It wouldn't make sense to put pollution dependent enemy on a planet that produce pollen.


### Changing enemy on planet prototype in space age.
```lua
local nauvis_planet = data.raw.planet.nauvis
local map_gen_settings = nauvis_planet.map_gen_settings
if map_gen_settings then
    local nauvis_autocontrols = map_gen_settings.autoplace_controls
    nauvis_autocontrols['enemy-base'] = nil
    nauvis_autocontrols['enemy_erm_protoss-enemy-base'] = {}
end 
```

### Changing the enemy autoplace on a revealed surface or when surface created on a non space age game.
```lua
local surface = game.surfaces[1] --- change to the index/name of your targeted surface
local map_gen_settings = surface.map_gen_settings
--- Disable biter and enable erm_protoss
map_gen_settings.autoplace_controls['enemy-base'] = nil
map_gen_settings.autoplace_controls['enemy_erm_protoss-enemy-base'] = {}
game.surfaces[1].map_gen_settings = map_gen_settings
```
Running above code via /c should generate new protoss enemy on new map chunk.  It does not existing enemies. 

If you are not using space age, you can use this code on_surface_created event to replace enemy.