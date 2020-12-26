local noise = require("noise")
local EventLog = require('__stdlib__/stdlib/misc/logger').new('Event', true)
local Table = require('__stdlib__/stdlib/utils/table')

local zero_probability_expression = function()

    local probability = noise.var("enemy_base_probability")
    return
    {
        control = 'enemy-base',
        order = 'b[enemy]-misc',
        force = "enemy",
        probability_expression = noise.min(probability, 0),
        richness_expression = noise.to_noise_expression(1)
    }
end

-- Remove Vanilla Bitter
if settings.startup['enemyracemanager-enable-bitters'].value == false then
    data.raw['unit-spawner']['biter-spawner']['autoplace'] = zero_probability_expression()
    data.raw['unit-spawner']['spitter-spawner']['autoplace'] = zero_probability_expression()
    data.raw['turret']['behemoth-worm-turret']['autoplace'] = zero_probability_expression()
    data.raw['turret']['big-worm-turret']['autoplace'] = zero_probability_expression()
    data.raw['turret']['medium-worm-turret']['autoplace'] = zero_probability_expression()
    data.raw['turret']['small-worm-turret']['autoplace'] = zero_probability_expression()
end

Table.insert(data.raw['technology']['stronger-explosives-7']['effects'],
    {
        type = "ammo-damage",
        ammo_category = "artillery-shell",
        modifier = 0.2
    }
)

