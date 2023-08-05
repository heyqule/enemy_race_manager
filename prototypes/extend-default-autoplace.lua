---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 8/4/2023 12:02 AM
---

local noise = require("noise")
local String = require('__stdlib__/stdlib/utils/string')
local AutoplaceHelper = require('__enemyracemanager__/lib/helper/autoplace_helper')
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local AutoplaceUtil = require('__enemyracemanager__/lib/enemy-autoplace-utils')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')

require('global')

if ErmConfig.mapgen_is_mixed() == false then
    return false
end

local statistic_separator = '::';

local tune_autoplace = function(v, is_turret, volume, mod_name, force_name, entity_filter, distance)
    if v.autoplace == nil then
        return
    end

    if String.find( v.name, mod_name, 1, true) == nil then
        return
    end

    if entity_filter ~= nil and String.find( v.name, entity_filter, 1, true) == nil then
        return
    end

    if is_turret then
        v.autoplace = AutoplaceUtil.enemy_worm_autoplace(distance, force_name, volume, 2)
    else
        v.autoplace = AutoplaceUtil.enemy_spawner_autoplace(0, force_name, volume, 2)
    end
end

local distances = {
    medium = 2,
    big = 5,
    behemoth = 8,
    leviathan = 16,
    mother = 32
}

--- only apply to enemy turret
local get_distance = function(v, force_name)
    if force_name ~= FORCE_NAME then
        return 0
    end

    for name, d in pairs(distances) do
        if String.find( v.name, name, 1, true) then
        return d
        end
    end

    return 0
end

--- ChatGPT function with some tweaks. XD
local rebalanceTables = function(...)
    local numTables = select("#", ...)
    local newTables = {}
    local totalSize = 0

    -- Calculate the total size of all tables
    for i = 1, numTables do
        local currentTable = select(i, ...)
        totalSize = totalSize + #currentTable
    end

    -- Calculate the target size for each table
    local targetSize = math.floor(totalSize / numTables)

    -- Calculate the number of tables that should have an extra element
    local numTablesWithExtraElement = totalSize % numTables

    -- Create a merged table from all original tables
    local mergedTable = {}
    for i = 1, numTables do
        local currentTable = select(i, ...)
        for j = 1, #currentTable do
            table.insert(mergedTable, currentTable[j])
        end
    end

    -- Create and populate the new tables
    local currentIndex = 1
    for i = 1, numTables do
        local newTable = {}
        local remainingSize = targetSize

        -- Distribute remaining elements among the first numTablesWithExtraElement tables
        if i <= numTablesWithExtraElement then
            remainingSize = remainingSize + 1
        end

        while remainingSize > 0 and currentIndex <= #mergedTable do
            table.insert(newTable, mergedTable[currentIndex])
            currentIndex = currentIndex + 1
            remainingSize = remainingSize - 1
        end

        table.insert(newTables, newTable)
    end

    return unpack(newTables)
end


local rearrange_specs = function()
    local statistic = {
        moisture_1 = {},
        moisture_2 = {},
        aux_1 = {},
        aux_2 = {},
        temperature_1 = {},
        temperature_2 = {},
        temperature_3 = {},
        elevation_1 = {},
        elevation_2 = {},
        elevation_3 = {},
    }

    for _, race_data in pairs(data.erm_spawn_specs) do
        local dataset = race_data.mod_name
        if race_data.entity_filter then
            dataset = dataset..statistic_separator..race_data.entity_filter
        end
        table.insert(statistic['moisture_'..race_data['moisture']], dataset)
        table.insert(statistic['aux_'..race_data['aux']], dataset)
        table.insert(statistic['temperature_'..race_data['temperature']], dataset)
        table.insert(statistic['elevation_'..race_data['elevation']], dataset)
    end

    ErmDebugHelper.print('Autoplace - statistic:')
    ErmDebugHelper.print(serpent.block(statistic))

    statistic.moisture_1, statistic.moisture_2 = rebalanceTables(statistic.moisture_1,statistic.moisture_2)
    statistic.aux_1, statistic.aux_2 = rebalanceTables(statistic.aux_1,statistic.aux_2)
    --statistic.temperature_1, statistic.temperature_2, statistic.temperature_3 =
    --    rebalanceTables(statistic.temperature_1, statistic.temperature_2, statistic.temperature_3)
    statistic.elevation_1, statistic.elevation_2, statistic.elevation_3 =
        rebalanceTables(statistic.elevation_1, statistic.elevation_2, statistic.elevation_3)

    ErmDebugHelper.print('Autoplace - After rebalanced statistic:')
    ErmDebugHelper.print(serpent.block(statistic))

    local updated_specs = data.erm_spawn_specs

    for key, data in pairs(statistic) do
        local token = String.split(key, '_')
        local volume_type = token[1]
        local volume_index = token[2]
        for _, data_item in pairs(data) do
            local datatoken = String.split(data_item, statistic_separator)
            local mod_name = datatoken[1]
            local mod_filter = datatoken[2]
            for spec_key, spec in pairs(updated_specs) do
                if spec.mod_name == mod_name and spec.entity_filter == mod_filter then
                    updated_specs[spec_key][volume_type] = tonumber(volume_index)
                end
            end
        end
    end

    ErmDebugHelper.print('Autoplace - Updated Specs')
    ErmDebugHelper.print(serpent.block(updated_specs))

    return updated_specs
end

--- Another ChatGPT function with some tweaks lol.
local balance_volumes = function(data)
    -- Create a table to store the unique (moisture_min, moisture_max) pairs as keys
    local uniqueMoisturePairs = {}

    -- Find the unique (moisture_min, moisture_max) pairs
    for _, elementData in ipairs(data) do
        local key = elementData.moisture_min .. "-" .. elementData.moisture_max
        if not uniqueMoisturePairs[key] then
            uniqueMoisturePairs[key] = {}
        end
        table.insert(uniqueMoisturePairs[key], elementData)
    end
    local offset = 0.01
    -- Calculate the auxInterval for each unique (moisture_min, moisture_max) pair
    for _, elements in pairs(uniqueMoisturePairs) do
        local count = #elements
        local auxInterval = 1 / count

        -- Distribute aux_min and aux_max values evenly for each same (moisture_min, moisture_max) pair
        for index, elementData in ipairs(elements) do
            elementData.aux_min = math.max(auxInterval * (index - 1) - offset, 0)
            elementData.aux_max = math.min(auxInterval * index + offset, 1)
        end
    end

    ErmDebugHelper.print('Autoplace - uniqueMoisturePairs:')
    ErmDebugHelper.print(serpent.block(uniqueMoisturePairs))

    for uniqueIndex, element in pairs(uniqueMoisturePairs) do
        for key, dataItem in pairs(data) do
            if  element.moisture_min == dataItem.moisture_min and
                element.moisture_max == dataItem.moisture_max and
                element.aux_min ~= dataItem.aux_min and
                element.aux_max ~= dataItem.aux_max
            then
                data[key] = element
                table.remove(uniqueMoisturePairs, uniqueIndex)
                break
            end
        end
    end

    return data
end


------------
---moisture, -- 1 = Dry and 2 = Wet, {0 - 0.51, 0.49 - 1}
---aux, 1 = red desert, 2 = sand,  {0 - 0.51, 0.49 - 1}
---elevation, 1,2,3 (1 low elevation, 2. medium, 3 high elavation)
---temperature, 1,2,3 (1 cold, 2. normal, 3 hot)
-------------
local moisture_ranges = {{0, 0.51},{0.49, 1}}
local aux_ranges = {{0, 0.51},{0.49, 1}}
local temperature_ranges = {{12,16}, {13,17}, {14,18}}
local elevation_ranges = {{0,30},{20,50},{40,70}}
if mods['alien-biomes'] then
    temperature_ranges = {{-20,40},{25,100},{85,150}}
end

local erm_race_data = data.erm_spawn_specs
local total_active_specs = table_size(erm_race_data)
local active_races = {}

ErmDebugHelper.print('Autoplace - Specs:')
ErmDebugHelper.print(serpent.block(erm_race_data))

for _, race in pairs(erm_race_data) do
    active_races[race.mod_name] = true
end

local total_active_races = table_size(active_races)

ErmDebugHelper.print('Autoplace - Active Races:')
ErmDebugHelper.print(serpent.block(active_races))

if total_active_races < 2 then
    return
end

local updated_specs = rearrange_specs()

local volumes = {}
for key, race_data in pairs(updated_specs) do
    local volume = {}
    volume['mod_name'] = race_data.mod_name

    if total_active_races > 1 then
        volume['moisture_min'] = moisture_ranges[race_data.moisture][1]
        volume['moisture_max'] = moisture_ranges[race_data.moisture][2]
    end

    if total_active_races > 2 then
        volume['aux_min'] = aux_ranges[race_data.aux][1]
        volume['aux_max'] = aux_ranges[race_data.aux][2]
    end

    if total_active_races >= 4 then
        if total_active_specs > 4 then
            volume['temperature_min'] = temperature_ranges[race_data.temperature][1]
            volume['temperature_max'] = temperature_ranges[race_data.temperature][2]
        end

        if total_active_specs > 10 then
            volume['elevation_min'] = elevation_ranges[race_data.elevation][1]
            volume['elevation_min'] = elevation_ranges[race_data.elevation][2]
        end
    end

    if race_data.enforce_temperature then
        volume['temperature_min'] = temperature_ranges[race_data.temperature][1]
        volume['temperature_max'] = temperature_ranges[race_data.temperature][2]
    end

    if race_data.enforce_elevation then
        volume['elevation_min'] = elevation_ranges[race_data.elevation][1]
        volume['elevation_max'] = elevation_ranges[race_data.elevation][2]
    end

    volumes[key] = volume
end

ErmDebugHelper.print('Autoplace - Volumes:')
ErmDebugHelper.print(serpent.block(volumes))
volumes = balance_volumes(volumes)

if table_size(volumes) == 3 and total_active_races == 3 then
    volumes[1].aux_min = 0
    volumes[1].aux_max = 0.34
    volumes[1].moisture_min = 0
    volumes[1].moisture_max = 1
    volumes[2].aux_min = 0.32
    volumes[2].aux_max = 1
    volumes[3].aux_min = 0.32
    volumes[3].aux_max = 1
end

ErmDebugHelper.print('Autoplace - After Balancing Volumes:')
ErmDebugHelper.print(serpent.block(volumes))

for key, race_data in pairs(updated_specs) do
    local volume = volumes[key]
    if volume then
        if race_data.entity_filter then
            ErmDebugHelper.print('Autoplace - '..race_data.mod_name..'/'..race_data.entity_filter..' Volume:')
        else
            ErmDebugHelper.print('Autoplace - '..race_data.mod_name..' Volume:')
        end

        ErmDebugHelper.print(serpent.block(volume))
        for _, v in pairs(data.raw["unit-spawner"]) do
            tune_autoplace(
                v, false, volume,
                race_data.mod_name, race_data.force_name,
                race_data.entity_filter
            )
        end

        for _, v in pairs(data.raw["turret"]) do
            tune_autoplace(
                v, true, volume,
                race_data.mod_name, race_data.force_name,
                race_data.entity_filter,
                get_distance(v, race_data.force_name)
            )
        end
    end
end
