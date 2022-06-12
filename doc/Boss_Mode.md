## Boss Mode 

- The Boss Base are discovered by sending PSI-Emitter satellites. 10% chance, not configurable.
- Only one boss base can exist in a game at a time, regardless of races / surfaces.
- Add BOSS_GROUP_SIZE setting (default 100)

## Boss Base functionalities
####When the psi-emitter launched
- Pick race location.
- Check path whether it's flying only.
- Once path is set, spawn the base.

####When the base spawns
- Send a boss attack group to player base. 
- Only one offense group exists at a time, tracks with boss_offense_group.
- This group is controlled by AI to attack various places until they are all killed.
- If group is unable to path, generate flying group, regardless of the flying setting.
- when the base is under certain % of health
  - If the group is alive, existing group recall to base and new reinforcement spawns. 
  - If the group is dead, new wave will spawn.


####When the base received damage
- It spawns boss defense group.
- Only one defense group exists at a time.
- Defense group work within 320 tiles of the base.
- Patrol with 128 tiles.
- Once they are all killed.  They have 1 nauvis day of cooldown before respawn (7 minutes)
- If the group is alive, full group reinforcement will spawn when the base is under 75%, 50% and 25% health.
- If the group is alive, 10% of the group reinforcement will spawn every half day, 

#### When the base is alive
- Spawn regular spawners / defenses every nauvis day.  within radius of 128.
- It will perform long range siege attack on player structures (miner, rocket-silos, artillery) every nauvis day.  A 5 radius attack that does 1000 damage.

#### When the base is despawned or dead.
- Boss base despawns after some time. It will send 3 nukes like attack around your base. (miner, rocket-silos, artillery) 
- Beating a boss group will spawn an unkillable infinite chest with low-mid level intermediate products for 30 nauvis days (210 minutes, 3 and half hours).

##Boss Tiers
- T1 
  - 1000000 HP (scales 10% of HP multiplier)
  - lvl 25 damage stats
  - 10 defense structures, 
  - despawn time: 25mins (~3.5 nauvis day)
  - attack group: [50%]
- T2 
  - 2000000 HP
  - lvl 35 damage stats
  - 15 defense structures
  - despawn time: 50mins (~7 nauvis day)
  - attack group: [66%, 33%]
- T3 
  - 4000000 HP
  - lvl 50 damage stats
  - 20 defense structures
  - despawn time: 75mins  (~10.5 nauvis day)
  - attack group: [75%, 50%, 25%]
- T4
  - 8000000 HP
  - lvl 70 damage stats
  - 30 defense structures
  - despawn time: 100mins (~14 nauvis day)
  - attack group: [80%, 60%, 40%, 20%]
- T5 
  - 16000000 HP
  - lvl 99 damage stats
  - 40 defense structures
  - 150mins (~21 nauvis day)
  - attack group: [85%, 70%, 55%, 40%, 25%, 10%]

Sub-tier boss group size affects
- MAX_GROUP_SIZE setting.  
- Base HP
- and defense structures

T1.1 - 100%, T1.2 - 150%, T1.3 - 200%


###Boss Spawn data structure

```json
{
  "race_setting": {
    "...": {
      "boss_tier": 1,
      "boss_subtier": 1
    }
  },
  "boss_base": {
    "entity": "luaEntity",
    "location": "position",
    "chunk": "chunk",
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