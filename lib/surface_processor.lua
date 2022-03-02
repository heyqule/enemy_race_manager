---
--- Created by heyqule.
--- DateTime: 03/27/2021 3:16 PM
--- require('__enemyracemanager__/lib/global_config')
---

local Table = require('__stdlib__/stdlib/utils/table')
local ErmDebugHelper = require('__enemyracemanager__/lib/debug_helper')
local ErmConfig = require('__enemyracemanager__/lib/global_config')
local ErmForceHelper = require('__enemyracemanager__/lib/helper/force_helper')

local SurfaceProcessor = {}

function SurfaceProcessor.init_globals()
    global.enemy_surfaces = global.enemy_surfaces or {}
end

function SurfaceProcessor.assign_race(surface, race_name)

    if not ErmForceHelper.can_have_enemy_on(surface) then
        return
    end

    local races = ErmConfig.get_enemy_races()
    local max_num = Table.size(races)
    if max_num == 0 then
        return
    end

    local race = nil
    if race_name then
        for k, v in pairs(races) do
            if v == race_name then
                race = v
                break
            end
        end
    else
        race = races[math.random(1, max_num)]
    end

    global.enemy_surfaces[surface.name] = race
end

function SurfaceProcessor.remove_race(surface)
    if global.enemy_surfaces[surface.name] ~= nil then
        global.enemy_surfaces[surface.name] = nil
    end
end

function SurfaceProcessor.rebuild_race()
    if global.enemy_surfaces == nil then
        return
    end

    ErmForceHelper.reset_surface_lists()

    for surface_index, race in pairs(global.enemy_surfaces) do
        if game.surfaces[surface_index] == nil or
                (race ~= MOD_NAME and game.active_mods[race] == nil) or
                not ErmForceHelper.can_have_enemy_on(game.surfaces[surface_index])
        then
            SurfaceProcessor.remove_race(game.surfaces[surface_index])
        end
    end

    for _, surface in pairs(game.surfaces) do
        if global.enemy_surfaces[surface.name] == nil then
            SurfaceProcessor.assign_race(game.surfaces[surface.index])
        end
    end
end

function SurfaceProcessor.numeric_to_name_conversion()
    local tmpSurfaces = {}
    for surface_index, race in pairs(global.enemy_surfaces) do
        tmpSurfaces[game.surfaces[surface_index].name] = race
    end
    global.enemy_surfaces = tmpSurfaces
end

function SurfaceProcessor.wander_unit_clean_up()
    local profiler = game.create_profiler()
    local unit_count = 0
    local checked_count = 0
    for _, surface in pairs(game.surfaces) do
        if surface.valid then
            local units = surface.find_entities_filtered({
                type = "unit",
                force = ErmForceHelper.get_all_enemy_forces(),
            })
            for _, unit in pairs(units) do
                checked_count = checked_count + 1
                if unit.valid and unit.unit_number and unit.spawner == nil and unit.command and unit.command.type == defines.command.wander then
                    unit_count = unit_count + 1
                    local race_name = ErmForceHelper.extract_race_name_from(unit.force.name)
                    if global.race_settings[race_name].attack_meter then
                        global.race_settings[race_name].attack_meter = global.race_settings[race_name].attack_meter + 1
                    end
                    unit.destroy()
                end
            end
        end
    end
    profiler.stop()
    game.print({'', 'Clean up orphan wandering units. Refunded units to attack meter if applicable.', profiler})
    game.print({'', 'Checked: '..checked_count..' / Removed:'..unit_count..' '})
end

function SurfaceProcessor.get_enemy_on(surface_name)
    if(ErmConfig.mapgen_is_one_race_per_surface()) then
        return global.enemy_surfaces[surface_name]
    end

    local races = ErmConfig.get_enemy_races()
    return races[math.random(1, ErmConfig.get_enemy_races_total())]
end

return SurfaceProcessor