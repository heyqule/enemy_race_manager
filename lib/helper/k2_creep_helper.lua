---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 7/29/2021 11:46 PM
---
local ForceHelper = require('__enemyracemanager__/lib/helper/force_helper')
local RaceSettingsHelper = require('__enemyracemanager__/lib/helper/race_settings_helper')

local K2CreepHelper = {}

function K2CreepHelper.generate_creep(surface, entity)
    local race_name = ForceHelper.extract_race_name_from(entity.force.name)
    local k2_enable = RaceSettingsHelper.k2_creep_enabled(race_name)
    if k2_enable then
        remote.call('kr-creep','spawn_creep_at_position', surface, entity.position)
    end
end

function K2CreepHelper.onChunkGenerated(event)
    local nests = event.surface.find_entities_filtered({
        type = "unit-spawner",
        area = event.area,
        force = ForceHelper.get_all_enemy_forces(),
    })

    for _, nest in pairs(nests) do
        K2CreepHelper.generate_creep(event.surface, nest)
    end
end

function K2CreepHelper.onSpawnerBuilt(event)
    local entity = event.entity

    if entity and entity.valid and entity.type == "unit-spawner" then
        K2CreepHelper.generate_creep(event.entity.surface, event.entity)
    end
end

return K2CreepHelper