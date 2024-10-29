local control_name = 'enemy-base'




--[[
local function peak_to_noise_expression(variable, optimal, range)
  local distance_from_optimal = noise.ridge(variable - optimal, 0, math.huge)
  -- Idea is to have a plateau in the center of the rectangle,
  -- edges that taper off at a consistent slope for all rectangles (so that interactions between rectangles are predictable),
  return range - distance_from_optimal
end

local function plateau_peak_to_noise_expression(variable, optimal, range)
  -- Clamp rectangle-based peaks so that large rectangles don't become
  -- super powerful at their centers, because we want to be able to override
  -- them e.g. with beach peaks or whatever
  return noise.min(peak_to_noise_expression(variable, optimal, range) * 20, 1) * plateau_influence
end
]]
data:extend({
  {
    type = 'noise-function',
    name = 'erm_peak_to_noise_expression',
    parameters = {'variable', 'optimal', 'range'},
    expression = 'min(range - ridge( variable - optimal, 0, 100000), 10)',
    --expression = 'range - ridge( variable - optimal, 0, 100000)',
  },
  {
    type = 'noise-function',
    name = 'erm_plateau_peak_to_noise_expression',
    parameters = {'variable', 'optimal', 'range'},
    expression = 'min(erm_peak_to_noise_expression(variable, optimal, range) * 20, 1)',
  },
})
