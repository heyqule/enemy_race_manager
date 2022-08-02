## Boss Mode 

- The Boss Base are discovered by sending PSI-Emitter satellites. [Done]
- Only one boss base can exist in a game at a time, regardless of races / surfaces. [Done]
- Add Boss Spawn size setting [Done]
- Boss building spawn table uses ErmConfig.MAX_LEVEL [Done]

## Boss Base functionalities
####When the psi-emitter launched
- Pick a spawn location. [Done]
- Spawn the base and reveal the area [Done]
- Check path whether it's flying only. [Done]


####When the base spawns
- Spawn a group of regular size * 12 group to attack. [Done]
- A new group spawn after 15sec, start with X regular spawn unit


####When the base received damage
- Spawn X defense units for every 10K damage
- New units joins existing forming group.


#### When the base is alive
- Spawn regular spawners / defenses every nauvis day.  within radius of 128.
- perform long range siege attack on player structures every attack cycle (3 minutes). 
- Targets: miners, rocket-silos, artillery or closest turrets

#### When the base is despawned
- Boss base despawns after some time. It will spawn 3 full size group to attack your base.

#### When the base is killed by force
- Beating a boss group will spawn an unkillable infinite chest with low-mid level intermediate products for 14 nauvis days (97mins, one and half hours).

##Boss Tiers
- T1 
  - 8000000 HP (scales 10% of HP multiplier)
  - lvl 25 damage stats
  - 10 defense structures, 
  - despawn time: 30mins
  - 266667 / min
  - 50% 1 infinite chest drop
  - rewards tier 1 items
- T2 
  - 16000000 HP
  - lvl 35 damage stats
  - 20 defense structures
  - despawn time: 45mins
  - 355555 / min
  - 100% 1 infinite chest drop
  - rewards tier 1, 2 items
- T3 
  - 32000000 HP
  - lvl 50 damage stats
  - 30 defense structures
  - despawn time: 60mins
  - 533333 / min
  - 20% 2 infinite chest drop, with 100% 1 drop.
  - rewards tier 1, 2 items
- T4
  - 64000000 HP
  - lvl 70 damage stats
  - 40 defense structures
  - despawn time: 90mins
  - 711111 / min
  - 50% 1 infinite chest drop, with 100% 1 drop
  - rewards tier 1, 2, 3 items
- T5 
  - 128000000 HP
  - lvl 99 damage stats
  - 50 defense structures
  - despawn time: 120 mins
  - 1066666 per minutes
  - 100% 2 infinite chest drop
  - rewards tier 2, 3 items

Once a tier is unlock, it can be set in race details.  

New tier can only be unlocked when defeat the highest tier.

Tier 1 items 
   - ores
Tier 2 items 
   - plates, 
   - steel, 
   - plastic, 
   - explosive, 
   - red bullet
Tier 3 items 
   - green/red chips, 
   - engine, 
   - electric engine, 
   - battery, 
   - rail, 
   - belt, 
   - inserter, 
   - green bullet


###Boss Spawn data structure

```json
{
  "race_setting": {
    "...": {
      "boss_building": "hive",
      "boss_tier": 1
    }
  },
  "boss_base": {
    "entity": "luaEntity",
    "entity_name": "",
    "location": "position",
    "flying_only": false,
    "boss_artillery_target": "position,  rotate every minute based on attackable chunk",
    "spawned_tick": 0
  },
  "boss_offense_group": {
    "group": "luaGroup",
    "position": "position",
    "unable_to_path": false
  },
  "boss_defense_group": {
    "group": "luaGroup",
    "position": "position",
    "on_cooldown": false,
    "cooldown_tick": 0,
    "respawn_tick": 0
  }
}
```


Island test map seed
```
>>>eNpjZGBksGUAAwcHBoYDDhwsyfmJOQwMDfYwzJWcX1CQWqSbX
5SKLMyZXFSakqqbn4mqODUvNbdSNymxOBVkGlAIhO05Movy89BNY
C0uyc9DFSkpSk0tRhbhLi1KzMsszUXXy8D41Wd5SkOLHAMI/69nU
Pj/H4SBrAdAv4AwA2MDyFcMjEAxGGBNzslMS2NgUHAEYieQQYyMj
NUi69wfVk2xZ4So0XOAMj5ARQ4kwUQ8YQw/B5xSKjCGCZI5xmDwG
YkBsbQEaAVUFYcDggGRbAFJMjL2vt264PuxC3aMf1Z+vOSblGDPa
Ogq8u6D0To7oCQ7yJ9McGLWTBDYCfMKA8zMB/ZQqZv2jGfPgMAbe
0ZWkA4REOFgASQOeDMzMArwAVkLeoCEggwDzGl2MGNEHBjTwOAbz
CePYYzL9uj+AAaEDchwORBxAkSALYS7jBHCdOh3YHSQh8lKIpQA9
RsxILshBeHDkzBrDyPZj+YQzIhA9geaiIoDlmjgAlmYAideMMNdA
wzPC+wwnsN8B0ZmEAOk6gtQDMIDJz6oURBawAEc3MwMCABMG0J3W
VoAguahAA==<<<
```