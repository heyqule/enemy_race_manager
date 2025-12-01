local AirRaidRadar = require('lib/air_raid_radar')

script.on_event(defines.events.on_sector_scanned,
        function(event) AirRaidRadar.scan(event) end,
        {{filter = "name", name = "erm-air-raid-radar"}})