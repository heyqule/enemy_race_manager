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
- Spawn a 120(configurable) units group to attack your base. [Done]
- A new batch of units spawn every 15sec, start with 10(configurable) units per cycle.　Once it ticks 12 cycles(3 and half minutes), it will send to your base.[Done]


####When the base received damage
- It may spawn 5(configurable) defense units　[Done]
- New units join existing attack group.　[Done]
- It may spawn regular spawner / defenses [Done]
- Perform normal defense attack
- It may perform nearby attacks (80% of the time when your military units are near)
- It may perform artillery attacks (20% of the time when your military units are near, 100% when your entity are in its range)
- When it takes huge amount of damage, it may perform more devastating attacks.


#### When the base is alive
- Spawn regular spawners / defenses every nauvis day.  within radius of 64. [Done]
- perform long range siege attack on player structures every attack cycle (3 minutes). 
- Targets: miners, rocket-silos, artillery and turrets

#### When the base is despawned
- Boss base despawns after some time. It will spawn up to 3 full size groups to attack your base.

#### When the base is killed
- Beating a boss group will spawn 1-2 unkillable infinite chest with intermediate products for (90 minutes).

##Boss Tiers
- T1 
  - 10000000 HP
  - lvl 25 damage stats
  - 10 defense structures, 
  - despawn time: 45mins
  - 222222 / min
  - 100% 1 infinite chest drop
  - rewards tier 1 items
- T2 
  - 20000000 HP
  - lvl 35 damage stats
  - 20 defense structures
  - despawn time: 45mins
  - 444444 / min
  - 100% 1 infinite chest drop
  - rewards tier 1(50%), 2(50%) items
- T3 
  - 32000000 HP
  - lvl 50 damage stats
  - 30 defense structures
  - despawn time: 60mins
  - 533333 / minute
  - 33% 2 infinite chest drop, with 100% 1 drop.
  - rewards tier 1(20%), 2(80%) items
- T4
  - 50000000 HP
  - lvl 70 damage stats
  - 40 defense structures
  - despawn time: 75 minute
  - 666666 / minute
  - 66% 1 infinite chest drop, with 100% 1 drop
  - rewards tier 1(20%), 2(60%), 3(20%) items
- T5 
  - 99999999 HP
  - lvl 99 damage stats
  - 50 defense structures
  - despawn time: 99 minute
  - 1010101 / minute
  - 100% 2 infinite chest drop
  - rewards tier 1(10%), 2(50%), 3(40%) items

New tier can only be unlocked when you defeat the current tier. 

You will not advance to new tier automatically.  You set it in the UI.

Once you are on new tier, you will not able to spawn lower tier.





Tier 1 items
   - plates
   - brick
   - crude oil
   
Tier 2 items
   - plastic
   - steel,
   - Iron gear wheel
   - gas
   - Heavy Oil
   - Light Oil
   - Gas
   - wall
   - explosive,
   - concrete
   - red bullet
   - green chip
   - rail,
   - yellow belt,
   - yellow inserter,
   - engine,
   - landfill
   - Sulfur
   - solid fuel
   - Repair pack
   - Radar

Tier 3 items 
   - red chips,
   - electric engine, 
   - battery,
   - Uranium-238
   - Flying robot frame
   - Speed module
   - Productivity module
   - Artillery shell


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