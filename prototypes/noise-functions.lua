local control_name = "enemy-base"

--[[
local function peak_to_noise_expression(variable, optimal, range)
  local distance_from_optimal = noise.ridge(variable - optimal, 0, math.huge)
  -- Idea is to have a plateau in the center of the rectangle,
  -- edges that taper off at a consistent slope for all rectangles (so that interactions between rectangles are predictable),
  return range - distance_from_optimal
end

local function plateau_peak_to_noise_expression(variable, optimal, range)
  -- Clamp rectangle-based peaks so that large rectangles don"t become
  -- super powerful at their centers, because we want to be able to override
  -- them e.g. with beach peaks or whatever
  return noise.min(peak_to_noise_expression(variable, optimal, range) * 20, 1) * plateau_influence
end
]]
data:extend({
  {
    type = "noise-function",
    name = "erm_peak_to_noise_expression",
    parameters = {"variable", "optimal", "range"},
    --expression = "range - min(ridge( variable - optimal, 0, inf ), 10)",
    expression = "range - ridge( variable - optimal, 0, 100000)",
  },
  {
    type = "noise-function",
    name = "erm_plateau_peak_to_noise_expression",
    parameters = {"variable", "optimal", "range"},
    expression = "min(erm_peak_to_noise_expression(variable, optimal, range) * 20, 1)",
  },

  --- 2 way splits
  {
    type = "noise-function",
    name = "x_axis_positive_2_way_split",
    parameters = {"custom_enemy_probability_expression", "main_gap"},
    expression = "if(x >= main_gap, custom_enemy_probability_expression, 0)"
  },
  {
    type = "noise-function",
    name = "x_axis_negative_2_way_split",
    parameters = {"custom_enemy_probability_expression", "main_gap"},
    expression = "if(x <= neg_main_gap, custom_enemy_probability_expression, 0)",
    local_expressions = {
      neg_main_gap = "main_gap * -1"
    }
  },
  {
    type = "noise-function",
    name = "y_axis_positive_2_way_split",
    parameters = {"custom_enemy_probability_expression", "main_gap"},
    expression = "if(y >= main_gap, custom_enemy_probability_expression, 0)"
  },
  {
    type = "noise-function",
    name = "y_axis_negative_2_way_split",
    parameters = {"custom_enemy_probability_expression", "main_gap"},
    expression = "if(y <= neg_main_gap, custom_enemy_probability_expression, 0)",
    local_expressions = {
      neg_main_gap = "main_gap * -1"
    }
  },
  
  --- 4 way splits
  {
    type = "noise-function",
    name = "northeast_4_way_split",
    parameters = {"custom_enemy_probability_expression", "main_gap"},
    expression = "if(y <= neg_main_gap, if(x <= neg_main_gap, custom_enemy_probability_expression, 0) , 0)",
    local_expressions = {
      neg_main_gap = "main_gap * -1"
    }
  },
  {
    type = "noise-function",
    name = "northwest_4_way_split",
    parameters = {"custom_enemy_probability_expression", "main_gap"},
    expression = "if(y <= neg_main_gap, if(x >= main_gap, custom_enemy_probability_expression, 0), 0)",
    local_expressions = {
      neg_main_gap = "main_gap * -1"
    }
  },
  {
    type = "noise-function",
    name = "southwest_4_way_split",
    parameters = {"custom_enemy_probability_expression", "main_gap"},
    expression = "if(y >= main_gap, if(x >= main_gap, custom_enemy_probability_expression, 0), 0)",
  },
  {
    type = "noise-function",
    name = "southeast_4_way_split",
    parameters = {"custom_enemy_probability_expression", "main_gap"},
    expression = "if(y >= main_gap, if(x <= neg_main_gap, custom_enemy_probability_expression, 0), 0)",
    local_expressions = {
      neg_main_gap = "main_gap * -1"
    }
  },
})
