## Boss Mode 

- The Boss Base are discovered by sending PSI-Emitter satellites. [Done]
- Only one boss base can exist in a game at a time, regardless of races / surfaces. [Done]
- Add BOSS_GROUP_SIZE setting (default 100, range 50 - 500) [Done]
- Boss building spawn table uses ErmConfig.MAX_LEVEL [Done]

## Boss Base functionalities
####When the psi-emitter launched
- Pick a spawn location. [Done]
- Spawn the base and reveal the area [Done]
- Check path whether it's flying only.


####When the base spawns
- pave [-32,-32] to [32, 32] landfill tile to be walkable ground.
- Send a boss attack group to player base. 
- tracks with boss_offense_group attribute.
- This group is controlled by AI to attack various places until they are all killed.
- If group is unable to path, generate flying group, regardless of the flying setting.
- Every midnight on a surface,
  - If the group is alive, sned new reinforcement to join the group. 
  - If the group is dead, new wave will spawn.


####When the base received damage
- It spawns boss defense group.
- Only one defense group exists at a time.
- Defense group work within 320 tiles of the base.
- Patrol with 128 tiles.
- Once they are all killed.  They have 1 nauvis day of cooldown before respawn (7 minutes)
- Check every 3 minutes on defense group (half day)
- If the group is alive, full group reinforcement will spawn when the base is under 75%, 50% and 25% health.
- If the group is alive, 10% of the group reinforcement will spawn every half day,

#### When the base is alive
- Spawn regular spawners / defenses every nauvis day.  within radius of 128.
- It will perform long range siege attack on player structures (miner, rocket-silos, artillery) every nauvis day.  A 5 radius attack that does 1000 damage.

#### When the base is despawned
- Boss base despawns after some time. It will spawn 3 full size group to attack your base.

#### When the base is killed by force
- Beating a boss group will spawn an unkillable infinite chest with low-mid level intermediate products for 14 nauvis days (97mins, one and half hours).

##Boss Tiers
- T1 
  - 2000000 HP (scales 10% of HP multiplier)
  - lvl 25 damage stats
  - 10 defense structures, 
  - despawn time: 30mins
  - 67K / min
  - 50% 1 infinite chest drop
  - rewards tier 1 items
- T2 
  - 4000000 HP
  - lvl 35 damage stats
  - 20 defense structures
  - despawn time: 45mins
  - 88K / min
  - 100% 1 infinite chest drop
  - rewards tier 1, 2 items
- T3 
  - 8000000 HP
  - lvl 50 damage stats
  - 30 defense structures
  - despawn time: 60mins
  - 133K / min
  - 20% 2 infinite chest drop, with 100% 1 drop.
  - rewards tier 1, 2 items
- T4
  - 16000000 HP
  - lvl 70 damage stats
  - 40 defense structures
  - despawn time: 90mins
  - 177K / min
  - 50% 1 infinite chest drop, with 100% 1 drop
  - rewards tier 1, 2, 3 items
- T5 
  - 32000000 HP
  - lvl 99 damage stats
  - 50 defense structures
  - despawn time: 120 mins
  - 267K per minutes
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