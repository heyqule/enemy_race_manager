
local EventLog = require('__stdlib__/stdlib/misc/logger').new('Event', true)
local Table = require('__stdlib__/stdlib/utils/table')

-- Remove Vanilla Bitter
print('-----')
print(settings.startup['enemyracemanager-enable-bitters'].value == false)
print(Table.size(data.raw['unit-spawner']) > 2)
print(Table.size(data.raw['turret']) > 4)
print('-----')
if settings.startup['enemyracemanager-enable-bitters'].value == false and
        Table.size(data.raw['unit-spawner']) > 2 and
        Table.size(data.raw['turret']) > 4 then

    data.raw['unit-spawner']['biter-spawner'] = nil
    data.raw['unit-spawner']['spitter-spawner'] = nil

    data.raw['turret']['behemoth-worm-turret'] = nil
    data.raw['turret']['big-worm-turret'] = nil
    data.raw['turret']['medium-worm-turret'] = nil
    data.raw['turret']['small-worm-turret'] = nil
end


