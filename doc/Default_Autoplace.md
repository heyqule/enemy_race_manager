#### Autoplace Algo for default placement

[prototypes/extend-default-autoplace.lua]([prototypes/extend-default-autoplace.lua]) This files has the logic to
determine the parameter for spawner and turrent autoplace under default condition. So that a race can spawn in close
proximity.

Each enemy race require to have the following code to determine the spawn condition and register ERM races for data
stage.

```lua
--- Required Parameters
data.erm_spawn_specs = data.erm_spawn_specs or {}
table.insert(data.erm_spawn_specs, {
    mod_name=MOD_NAME,
    force_name=FORCE_NAME,
    moisture=1, -- 1 = Dry and 2 = Wet
    aux=1, -- 1 = red desert, 2 = sand
    elevation=1, --1,2,3 (1 low elevation, 2. medium, 3 high elavation)
    temperature=2, --1,2,3 (1 cold, 2. normal, 3 hot)
})

--- With optional parameters and wider range for elevation / temperature
data.erm_spawn_specs = data.erm_spawn_specs or {}
table.insert(data.erm_spawn_specs, {
    mod_name=MOD_NAME,
    force_name=FORCE_NAME,
    moisture=1, -- 1 = Dry and 2 = Wet
    aux=1, -- 1 = red desert, 2 = sand
    elevation=1, --1,2,3 (1 low elevation, 2. medium, 3 high elavation)
    temperature=2, --1,2,3 (1 cold, 2. normal, 3 hot)
    entity_filter = 'cold', -- this filter entities by string.find
    enforce_temperature = false, -- enforce temperature filter
})


------------
---Value References:
---moisture, -- 1 = Dry and 2 = Wet, {0 - 0.51, 0.49 - 1}
---aux, 1 = red desert, 2 = sand,  {0 - 0.51, 0.49 - 1}
---elevation, 1,2,3 (1 low elevation, 2. medium, 3 high elavation)
---temperature, 1,2,3 (1 cold, 2. normal, 3 hot)
-------------
local moisture_ranges = {{0, 0.51},{0.49, 1}}
local aux_ranges = {{0, 0.51},{0.49, 1}}
local temperature_ranges = {{12,14.01}, {13.99,16.01}, {15.99,18}}
local elevation_ranges = {{-1,26},{24,49},{47,70}}
if mods['alien-biomes'] then
    temperature_ranges = {{-21,35},{33,97},{95,151}}
end
```

### How this works:

When there are 2 active spawn specification, Moisture will determine how the race place. If the race place in the same
slot, one of them will move one to another slot

When there are 3-4 active spawn specification, Moisture and Aux will determine how the race spawns. If there are race in
the same slot, move one to an empty slot.

When more specification are added to the active races, temperature and elevation will take into consideration.

Spawn probability balancing uses moisture by default. But when temperature or enforce_temperature is used, it balanced
by temperature.

elevation balancing is only used when there are more than a dozen specifications, using generic balancing function. The
game doesn't extensively utilize elevation tho.
If it does in the future, I may add balanced by elevation

### World Data:

- [Factorio World](erm-base-world-data.lua)
- [Factorio Tile](erm-base-tiles-data.lua)
- [Factorio Alien Biomes World](erm-alien-biomes-world-data.lua)
- [Factorio Alien Biomes Tile](erm-alien-biomes-tiles-data.lua)

This is gathered by using the event in controller/debug_event.lua. The script records the tile of the world and fix the
min/max for specified properties.
The above list are sampled over a large area of the map. appox 5KM by 5KM.