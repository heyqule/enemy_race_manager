---
--- require('__enemyracemanager__/lib/enemy-autoplace-utils')

local noise = require("noise")
local AutoplaceHelper = require('__enemyracemanager__/lib/helper/autoplace_helper')
local expression_to_ascii_math = require("__core__/lualib/noise/expression-to-ascii-math")

local tne = noise.to_noise_expression
local control_name = 'enemy-base'

local enemy_random_seed = 1
local function new_random_seed()
    enemy_random_seed = enemy_random_seed + 1
    return enemy_random_seed
end

local function enemy_autoplace(params)
    local distance_factor = params.distance_factor or 1
    local order = params.order or "b[enemy]-misc"
    local is_turret = params.is_turret or false
    local force = params.force or 'enemy'

    local distance_unit = 312
    local distance_outside_starting_area = noise.var("distance") - noise.var("starting_area_radius")

    -- Units with a higher distance_factor will appear farther out by one
    -- distance_unit per distance_factor
    local distance_height_multiplier = noise.max(0, 1 + (distance_outside_starting_area - distance_unit * distance_factor) * 0.002 * distance_factor)

    local probability_expression = nil
    if params.volume then
        probability_expression = AutoplaceHelper.volume_to_noise_expression(params.volume)
        probability_expression = noise.min(probability_expression, noise.var("enemy_base_probability") * distance_height_multiplier)
    else
        probability_expression = noise.var("enemy_base_probability") * distance_height_multiplier
    end

    -- limit probability so that it never quite reaches 1,
    -- because that would result in stupid-looking squares of biter bases:
    probability_expression = noise.min(probability_expression, 0.25 + distance_factor * 0.05)
    -- Add randomness to the probability so that there's a little bit of a gradient
    -- between different units:
    --log("Probability expression for " .. params.order .. "#" .. distance_factor .. ":")
    --log(tostring(expression_to_ascii_math(probability_expression)))

    probability_expression = noise.random_penalty(probability_expression, 0.1, {
        x = noise.var("x") + new_random_seed(), -- Include distance_factor in random seed!
    })

    local richness_expression = tne(1)


    return
    {
        control = control_name,
        order = order,
        force = force,
        probability_expression = probability_expression,
        richness_expression = richness_expression
    }
end

local function enemy_spawner_autoplace(distance, force, volume)
    local params = {
        distance_factor = distance,
        order = "b[enemy]-a[spawner]",
        force = force
    }
    if volume then
        params['volume'] = volume
    end
    local result = enemy_autoplace(params)
    return result
end

local function enemy_worm_autoplace(distance, force, volume)
    local params = {
        distance_factor = distance,
        order = "b[enemy]-b[worm]",
        is_turret = true,
        force = force
    }
    if volume then
        params['volume'] = volume
    end
    local result = enemy_autoplace(params)
    return result
end

return
{
    control_name = control_name,
    enemy_autoplace = enemy_autoplace,
    enemy_spawner_autoplace = enemy_spawner_autoplace,
    enemy_worm_autoplace = enemy_worm_autoplace
}
