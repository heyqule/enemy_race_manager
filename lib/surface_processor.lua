---
--- Created by heyqule.
--- DateTime: 03/27/2021 3:16 PM
--- require("__enemyracemanager__/lib/global_config")
---

local GlobalConfig = require("__enemyracemanager__/lib/global_config")
local ForceHelper = require("__enemyracemanager__/lib/helper/force_helper")
local UtilHelper = require("__enemyracemanager__/lib/helper/util_helper")

local SurfaceProcessor = {}

SurfaceProcessor.get_gps_message = UtilHelper.get_gps_message

function SurfaceProcessor.init_globals()
    storage.enemy_surfaces = storage.enemy_surfaces or {}
    storage.total_enemy_surfaces = storage.total_enemy_surfaces or 0
    
    --- Use to store 3rd party surfaces that act as "planets"
    storage.external_planets = storage.external_planets or {}
end

local surfixes = {
    "enemy-base",
    "enemy_base"
}
local basegame_autoplaces = {
    gleba_enemy_base = true
}
function SurfaceProcessor.register_enemies(surface)

    if not ForceHelper.can_have_enemy_on(surface) then
        return
    end
    
    local map_gen_settings = surface.map_gen_settings
    local races_by_name = {}
    local races_by_key= {}
    if map_gen_settings and map_gen_settings.autoplace_controls then
        local autocontrols = map_gen_settings.autoplace_controls
        for key, _ in pairs(autocontrols) do
            for skey, surfix in pairs(surfixes) do
                if string.find(key, surfix, 1, true) or basegame_autoplaces[key] then
                    local index = string.find(key, surfix, 1, true)
                    local precheck_enemy_race = string.sub(key, 0, (string.len(surfix) + 2) * -1)
                    local enemy_race

                    if index and ForceHelper.is_enemy_force(precheck_enemy_race) then
                        enemy_race = precheck_enemy_race
                    else
                        enemy_race = MOD_NAME
                    end

                    if enemy_race then
                        races_by_name[enemy_race] = true
                        table.insert(races_by_key, enemy_race)
                    end
                end
            end
        end
    end

    if table_size(races_by_key) then
        storage.total_enemy_surfaces = storage.total_enemy_surfaces + 1
        storage.enemy_surfaces[surface.name] = {
            surface = surface,
            races_by_name = races_by_name,
            races_by_key = races_by_key,
            size = table_size(races_by_key)
        }
    end
end

function SurfaceProcessor.remove_enemies(surface)
    if storage.enemy_surfaces[surface.name] then
        storage.enemy_surfaces[surface.name] = nil
        storage.total_enemy_surfaces = storage.total_enemy_surfaces - 1
    end
end

function SurfaceProcessor.rebuild_race()
    if storage.enemy_surfaces == nil then
        return
    end

    ForceHelper.reset_surface_lists()

    for surface_index, race in pairs(storage.enemy_surfaces) do
        if game.surfaces[surface_index] == nil or
                (race ~= MOD_NAME and script.active_mods[race] == nil) or
                storage.active_races[race] == nil or
                not ForceHelper.can_have_enemy_on(game.surfaces[surface_index])
        then
            SurfaceProcessor.remove_enemies(game.surfaces[surface_index])
        end
    end

    for _, surface in pairs(game.surfaces) do
        if storage.enemy_surfaces[surface.name] == nil and ForceHelper.can_have_enemy_on(surface) then
            SurfaceProcessor.register_enemies(game.surfaces[surface.index])
        end
    end

    storage.total_enemy_surfaces = table_size(storage.enemy_surfaces)
end

function SurfaceProcessor.wander_unit_clean_up()
    local profiler = game.create_profiler()
    local unit_count = 0
    local checked_count = 0
    for _, surface in pairs(game.surfaces) do
        if surface.valid then
            local units = surface.find_entities_filtered({
                type = "unit",
                force = ForceHelper.get_enemy_forces(),
                
            })
            for _, unit in pairs(units) do
                checked_count = checked_count + 1
                if unit.valid and unit.unit_number and
                   unit.commandable and unit.commandable.spawner == nil and
                   unit.commandable.command and unit.commandable.command.type == defines.command.wander then
                    unit_count = unit_count + 1
                    local force_name = unit.force.name
                    local race_settings = storage.race_settings[force_name]
                    if force_name and race_settings and race_settings.attack_meter then
                        storage.race_settings[force_name].attack_meter = race_settings.attack_meter + 1
                    end
                    unit.destroy()
                end
            end
        end
    end
    profiler.stop()
    game.print({ "", "Clean up orphan wandering units. Refunded units to attack meter if applicable.", profiler })
    game.print({ "", "Checked: " .. checked_count .. " / Removed:" .. unit_count .. " " })
end

--- Returns race name
function SurfaceProcessor.get_enemy_on(surface_name)
    local surface_race_data = storage.enemy_surfaces[surface_name]
    if surface_race_data and surface_race_data.size > 0 then
        return surface_race_data.races_by_key[math.random(1, surface_race_data.size)]
    end

    return MOD_NAME
end

function SurfaceProcessor.get_all_enemies_on(surface_name)
    local surface_race_data = storage.enemy_surfaces[surface_name]
    if surface_race_data and surface_race_data.size > 0 then
        return surface_race_data.races_by_key
    end

    return nil
end

function SurfaceProcessor.get_attackable_surfaces()
    return storage.enemy_surfaces
end

function SurfaceProcessor.is_surface_attackable(surface_name)
    return storage.enemy_surfaces[surface_name] ~= nil
end


function SurfaceProcessor.register_external_planet(data)
    if not data.surface then
        error('Missing Luasurface')
    end

    data.radius = data.radius or 900000
    data.icon = data.icon or "[space-location=space-location-unknown]"
    
    if data.surface and data.surface.valid then
        storage.external_planets[data.surface.name] = data
    end
end

function SurfaceProcessor.get_planet_icon(surface_name)
    local surface_str
    if game.planets[surface_name] then
        surface_str = "[space-location="..surface_name.."] "
    elseif storage.external_planets[surface_name] then
        surface_str = storage.external_planets[surface_name].icon.." "
    else
        surface_str = "[space-location=space-location-unknown] "
    end
    return surface_str
end

return SurfaceProcessor