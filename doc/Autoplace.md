- [Factorio World](erm-base-world-data.lua)
- [Factorio Tile](erm-base-tiles-data.lua)
- [Factorio Alien Biomes World](erm-alien-biomes-world-data.lua)
- [Factorio Alien Biomes Tile](erm-alien-biomes-tiles-data.lua)

Vanilla Autoplace based on Moisture and Aux
```
Zerg 
    water_min = 0,
    water_max = 0.51,
    
    if MarsPeople & biter
        aux_min = 0.19,
        aux_max = 0.61,
    
    if only marspeople
        aux_min = 0,
        aux_max = 0.51

```    
```
Protoss:
    water_min = 0.49
    water_max = 1     
    
    if redarmy & biter:
        aux_min = 0.59,
        aux_max = 1,
        
    if only redarmy
        aux_min = 0.49,
        aux_max = 1        
```
```
Mars People: 
    water_min = 0,
    water_max = 0.51,
    
    if Zerg & biter
        aux_min = 0.59,
        aux_max = 1,
        
    if only zerg
        aux_min = 0.49,
        aux_max = 1           
```
```
Red Army:
    water_min = 0.49
    water_max = 1     
    
    if toss & biter:
        aux_min = 0.19,
        aux_max = 0.61,
        
    if only toss
        aux_min = 0,
        aux_max = 0.51   
```
```
Biters:
    if there are 2 or more erm_race
        aux_min = 0,
        aux_max = 0.2
    if there only one erm_race
        use opposite water_min & water_max
              
```
