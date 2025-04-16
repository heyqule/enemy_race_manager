# Enemy Race Manager

This mod aims provide a RTS experience with Factorio logistics.  It works best with other ERM branded mods.  Base game biters are also enhanced with new features.

Discord:  [https://discord.gg/BwWXygyEyQ](https://discord.gg/BwWXygyEyQ)

### Feature Videos:

- ERM - 2.0 Features Reel: Coming Soon

### What's new in 2.0.26
#### ERM economy [space-age] only
- [space-age] Zerg, Protoss, Redarmy drop loots on "Great" or higher tier.
- [space-age] New recipes to turn those loots into biter egg or other items.  This replaces the existing captive spawner workflow for those races.
- [space-age] New resources, mineral and geysers, on planet Aiur and Char.
- [space-age] Zerg and Protoss controllable units.
- Improvements and Bugfixes

Note 1: 2.0.x are all experimental release.  Expect crashes and unit imbalance. Most things are subjected to change. 2.1 will be the first stable release.

Note 2: Support for base game will be limited to shared features and fixing crashes.  This mod is now focus on warfare with space logistic.


### Download New race demo

These race mods are made as educational demos. You'll have to download them separately.

New Enemy Races:
* [Zerg - Garm Brood](https://mods.factorio.com/mod/erm_zerg)
* [Protoss - Akilea Tribe](https://mods.factorio.com/mod/erm_toss)
* [RedArmy](https://mods.factorio.com/mod/erm_redarmy)

Player Controllable Units: (WIP for 2.0)

[>>>>Terran<<<<](https://mods.factorio.com/mod/erm_terran)

Special Thanks to [_jo.nat_](https://mods.factorio.com/user/_jo.nat_) as he did the remaster graphics!

**Tips on defense:**

- A LOT OF construction robots and repair kits. Automate repair network ASAP. Mix all turrets. Uranium bullets and flamethrowers are OP.
- Build multiple layers of turrets and walls in early game.  Don't bother repairing without automated bot repairs.  Replace the damage turret with new one and build wall after it destroyed.

Do you want to create your new race? Please refer to this doc [New-Race-DEV-README.md](https://github.com/heyqule/enemy_race_manager/blob/main/doc/2.0-New-Race-Design.md) and join my discord for additional help.

# New Features

### Custom Enemy Evolution & Difficulty
Enemy evolution is based on Force's evolution factor and kills.  When enemy evolves, they pick a higher tier of the same units. The enemy evolve independently on each planet.  The more you kill, the quicker they evolve. 

There are total of 5 tier for each enemy entity, from normal, great, exceptional, epic and legendary.  Which tier can you handle?

### New Unit Types
- Aerial units.
- Dropships, flying unit that spawn other units.
- Carriers, Unit that spawn other smaller units in a batch
- Builders, unit that builds spawner or turret on the spot.
- Invisible units, unit that can only be seen by certain turrets.
- Suicidal units, which kill themselves to cause massive damage.

### Custom Attack Groups & Attack Points
Custom attack groups are generated by attack points.  Everything you kill worth some attack points.  Once it hit a threshold, the enemy will send a wave of custom attack group to your base. They spawn on top of the base game's pollution based attacks.

There are various types of attack groups. Ground attack, Arial attack, dropships, stealth attacks. See in-game tip and tricks for details.  

### Custom Base Expansion
Enemy expansion are no longer build one structure at a time.  They build several spawners and turrets to have the best defense. 

### Environmental Attacks
Some enemy may parasitize another unit to spawn them.  Other may be practising quantum teleportation with lightnings.

### Free for all
This is currently only work for non Space Age game.  You'll have to select "Mixed mode" in Nauvis enemy and enable "Free for all" to active this feature.

When this is enabled, player entity health and enemy damage multiplied by 10x. The multipliers are to balance the time enemy units take to kill each other.

### New planets and space routes with tougher enemies.
Some enemy force have their home planet.  They are home to their Legendary forces.

### Advanced Army Controls (Only for ERM - Terran, or other compatible mods)
  - Dedicated unit assembly lines. 
  - Set up rally point for automated unit deployment.
  - Unit teleportation between 2 areas, including between planets/surfaces.
  - Unit population control

ERM - Terran Control Tutorial: [https://youtu.be/MzDwGJ3OOGY](https://youtu.be/MzDwGJ3OOGY)

### ERM Economy
Zerg, Protoss and Redarmy spawners drop loots.  Those loots are used for new recipes and new army units.  They can also convert to biter eggs.  

When you are not playing with biter, you don't have to capture the "spawner" to get biter eggs.    

Planet Aiur and Char use new minerals and geyser nodes.  They offer slightly different manufacture workflow.

### Remote API Support

* [Remote API Doc](https://github.com/heyqule/enemy_race_manager/blob/main/doc/remote_api.md)

### Known Issues

* Not support peaceful mode. :)

### Mod Compatibility

Please see https://github.com/heyqule/enemy_race_manager/blob/main/Mod-Compatibility.md for full compatibility
details.

### Roadmap
https://github.com/users/heyqule/projects/1


### SPECIAL THANKS TO ALL CROWDIN TRANSLATORS

- UK: Yuriy, Met_en_Bouldry, ExexDiablo
- DE: PatrickBlack, Spiti6910, Batrick
- ES: Jose Eduardo
- FR: Wiwok, Daiky Raraga
- RU: SeptiSe7en, Misha Mitchell, oZeDo, X-0D, Alaar
- HU: CsokiHUN
- CH-zn: Tanvec

You can help translate this mod directly online by going to the following link and finding "ERM" or "Enemy Race
Manager":

https://crowdin.com/project/factorio-mods-localization

New translation will be released in the next version.