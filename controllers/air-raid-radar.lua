local AirRaidRadar = {}

local Position = require("__erm_libs__/stdlib/position")
local Config = require("__enemyracemanager__/lib/global_config")
local SurfaceProcessor = require("__enemyracemanager__/lib/surface_processor")

local draw_text = rendering.draw_text
local max_distance = Config.AIR_RAID_RADAR_RANGE

local kill_tags = function(group_data)  
    for tag_id, tag in pairs(group_data.tags) do
        if tag.entity and tag.entity.valid then
            tag.entity.destroy()
        end
        group_data.tags[tag_id] = nil
    end
end

local get_combinators = function(radar)
    local control_behavior = radar.get_control_behavior()
    if not control_behavior then return end

    -- Check for circuit network connection
    local circuit_network = control_behavior.get_circuit_network(defines.wire_connector_id.circuit_red)
    if not circuit_network then
        circuit_network = control_behavior.get_circuit_network(defines.wire_connector_id.circuit_green)
    end

    if not circuit_network then return end

    -- Find constant combinators connected to the same circuit network
    local constant_combinators = {}
    -- Reduced search area for better performance
    local search_area = {
        {radar.position.x - 8, radar.position.y - 8},
        {radar.position.x + 8, radar.position.y + 8}
    }

    for _, entity in pairs(radar.surface.find_entities_filtered{
        area = search_area,
        type = "constant-combinator"
    }) do
        if entity.valid then
            local cb = entity.get_control_behavior()
            if cb then
                local red_network = cb.get_circuit_network(defines.wire_connector_id.circuit_red)
                local green_network = cb.get_circuit_network(defines.wire_connector_id.circuit_green)

                if (red_network and red_network.network_id == circuit_network.network_id) or
                        (green_network and green_network.network_id == circuit_network.network_id) then
                    table.insert(constant_combinators, entity)
                end
            end
        end
    end
    
    return constant_combinators
end

-- Set erm-air-raid-signal signal to nearby combinators
local set_radar_signal = function(radar)
    local constant_combinators = get_combinators(radar)
    if not constant_combinators then return end
    for _, combinator in pairs(constant_combinators) do
        local cb = combinator.get_control_behavior()
        if cb and cb.type == defines.control_behavior.type.constant_combinator then
            -- Ensure we have at least one section
            if cb.sections_count == 0 then
                cb.add_section()
            end

            if cb.sections_count > 0 then
                local section = cb.get_section(1)
                if section and section.is_manual then
                    section.set_slot(1, {
                        value = {type = "item", name = "erm-air-raid-radar", quality="normal"},
                        min = 1,
                        max = 1
                    })
                end
            end
        end
    end

end

--Clear signal to nearby combinators
local clear_radar_signal = function(radar)
    local constant_combinators = get_combinators(radar)
    if not constant_combinators then return end
    -- Clear slot 1
    for _, combinator in pairs(constant_combinators) do
        local cb = combinator.get_control_behavior()
        if cb and cb.type == defines.control_behavior.type.constant_combinator then
            if cb.sections_count > 0 then
                local section = cb.get_section(1)
                if section and section.is_manual then
                    section.clear_slot(1)
                end
            end
        end
    end
end

local increase_radar_tracking_count = function(radar_number)
    if storage.active_air_raid_radars[radar_number] then
        storage.active_air_raid_radars[radar_number] = storage.active_air_raid_radars[radar_number] + 1
    else
        storage.active_air_raid_radars[radar_number] = 1
    end
end

local decrease_radar_tracking_count = function(radar_number)
    if storage.active_air_raid_radars[radar_number] then
        storage.active_air_raid_radars[radar_number] = storage.active_air_raid_radars[radar_number] - 1
        if storage.active_air_raid_radars[radar_number] <= 0 then
            storage.active_air_raid_radars[radar_number] = nil
        end
    end
end

AirRaidRadar.scan = function(event)
    local radar = event.radar

    if radar and radar.valid then
        --local profiler = game.create_profiler()
        local radar_number = radar.unit_number
        local surface = radar.surface
        local force = radar.force
        local flying_tracker = storage.flying_groups_tracker[surface.index]
        if flying_tracker and next(flying_tracker) then
            local signal_set = false  -- Track if we've set the signal to avoid redundant operations
            for group_id, group_data in pairs(flying_tracker) do
                local group = group_data.group
                if group.valid then
                    local distance = Position.distance(group.position, radar.position)
                    if distance < max_distance then
                        kill_tags(group_data)
                        local text = "✈✈"
                        if group_data.is_precision_attack == true then
                            text = "✈✈✈✈"
                        end
                        local draw_obj = draw_text({
                            text = "[virtual-signal=signal-skull]"..text,
                            color = {r = 1, g = 1, b = 1},
                            force = {force},
                            scale = 1.5,
                            target = group.position,
                            surface = surface,
                            render_mode = "chart",
                            use_rich_text = true,
                            scale_with_zoom = true,
                            time_to_live = 10 * second
                        })

                        table.insert(storage.flying_groups_tracker[surface.index][group_id].tags, {entity = draw_obj, tick = event.tick})

                        -- Set radar signal only once per scan, not for each group
                        if not signal_set then
                            set_radar_signal(radar)
                            signal_set = true
                        end

                        if group_data.is_precision_attack == true and
                                group_data.showed_warning == false and
                                Config.precision_strike_warning()
                        then
                            local group_position = group.position
                            group.surface.print({
                                "description.message-incoming-precision-attack",
                                SurfaceProcessor.get_gps_message(
                                        group_position.x,
                                        group_position.y,
                                        group.surface.name
                                ),
                            }, { r = 1, g = 0, b = 0 })
                            group_data.showed_warning = true
                        end
                        
                        increase_radar_tracking_count(radar_number)
  
                    else
                        kill_tags(group_data)
                        decrease_radar_tracking_count(radar_number)
                    end
                else
                    kill_tags(group_data)
                    decrease_radar_tracking_count(radar_number)
                    storage.flying_groups_tracker[surface.index][group_id] = nil
                end
            end
        end
        
        if not storage.active_air_raid_radars[radar_number] then
            clear_radar_signal(radar)
        end

        --profiler.stop()
        --log({ "", "AirRaid Scanner: ", profiler })
    end
end


script.on_event(defines.events.on_sector_scanned,
        function(event) AirRaidRadar.scan(event) end,
        {{filter = "name", name = "erm-air-raid-radar"}})