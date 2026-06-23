local AirRaidRadar = require('lib/air_raid_radar')

script.on_event(defines.events.on_sector_scanned,
        AirRaidRadar.scan,
        {{filter = "name", name = "erm-air-raid-radar"}})