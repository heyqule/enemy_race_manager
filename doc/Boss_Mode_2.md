## Boss Mode Discovery

- Build PSI Radar.
- PSI Radar chart for 30 chunk radius. 1MW, 10s chart timers.
- Once radar chart 20 chunks away.  It has 33% to spawn boss if the chunk has enemy.
- When boss is found, notify everyone.


### Boss Base functionalities

#### When Boss is found 

- Spawn the base and reveal the area [Done]
- Check path whether it's flying only. [Done]

#### When boss is idle (you are not attacking it) 

- Call for arm every minutes.
  - Send regular group from another area to attack radar or main base
  - Cast artillery projectiles to attack radar or main base
  - Build new bases toward radar
- Cast direct attacks @ radar every 2 minutes when it's not taking damage.

#### Boss spawner

- Spawn rate 2 seconds. Boss variant units has its own multipliers (1x - 5x). 
- Can host [50,60,70,85,100] Boss variant units
- Boss Variant, Same Base HP
### Boss Difficulty
- [1x, 1.5x, 2x] host
- [1x, 1.5x, 2x] damage

#### When the base received damage

- It may spawn 5(configurable) defense units[Done]
- New units join existing attack group.[Done]
- It may spawn regular spawner / defenses [Done]
- Perform normal defense attack [DONE]
- It may perform nearby advanced attacks (80% of the time when your military units are near) [DONE]
- It may perform artillery advanced attacks (20% of the time when your military units are near, 100% when your entity
  are in its range) [TO DO]
- When it takes huge amount of damage, it may perform more devastating attacks. [DONE]

#### When the base is alive

- Spawn regular spawners / defenses every nauvis day. within radius of 64. [Done]
- perform long range siege attack on player structures every attack cycle (3 minutes).[TO DO]
- Targets: miners, rocket-silos, artillery and turrets [Done]

#### When the base is despawned

- Boss base despawns after some time. It will launch x amount of super attack your base before it despawn. [WIP]

#### When the base is killed

- Beating a boss group will spawn 1-2 unkillable infinite chest with intermediate products for (90 minutes). [Done]
- Each chest can drop up to 5 types of items, it changes every 5 minutes. 

###Boss Tiers [WIP]
Boss Structure
- T1
    - 10000000 HP
    - Normal legendary unit
    - 100% 1 infinite chest drop
    - rewards tier 1 items
- T2
    - 20000000 HP
    - lvl 35 damage stats
    - 100% 1 infinite chest drop
    - rewards tier 1(50%), 2(50%) items
- T3
    - 32000000 HP
    - 25% 2 infinite chest drop, with 100% 1 drop.
    - rewards tier 1(30%), 2(70%) items
- T4
    - 50000000 HP
    - 50% 2 infinite chest drop, with 100% 1 drop
    - rewards tier 1(30%), 2(60%), 3(10%) items
- T5
    - 99999999 HP
    - 100% 2 infinite chest drops
    - rewards tier 1(20%), 2(50%), 3(30%) items

### GUI [WIP]

- A dialog will show whether you want to advance to next tier once you defeat a boss.  [DONE]
    - once you are on new tier, you will not able to spawn lower tier. [DONE]
- Each race will track its victory best time.
- Each race will have achievements when you beat max tier on each difficulty.
- Add boss event log to track each boss encounter. [Done]
    - Race, Tier, Location, Win/Loss, Start time, Time End. Boss difficulty, Squad Size
- Changing boss difficulty or boss squad size
    - reset the best timers. [Done]

##### Base-game items

Tier 1 items

- plates
- brick
- Iron gear wheel
- green chip
- yellow bullets

Tier 2 items

- plastic
- steel,
- Light Oil
- wall
- explosive,
- concrete
- red bullet
- rail,
- yellow belt,
- yellow inserter,
- engine,
- landfill
- sulfur
- solid fuel
- repair pack
- red chips,

Tier 3 items

- blue chips,
- electric engine,
- battery,
- Speed module 1
- Productivity module 1
- low density structure,
- Heavy Oil

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