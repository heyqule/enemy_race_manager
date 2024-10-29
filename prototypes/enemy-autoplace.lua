local control_name = "enemy-base"

local function enemy_autoplace(params)
  local force = params.force or 'enemy'
  local order = params.order or "a["..force.."]-autoplace"
  return
  {
    control = params.control or control_name,
    order = order,
    force = force or 'enemy',
    probability_expression = params.probability_expression,
    richness_expression = 1
  }
end

local function enemy_spawner_autoplace(probability_expression, force)
  return enemy_autoplace {
    probability_expression = probability_expression,
    order = "a["..force.."]-a[spawner]",
    force = force
  }
end

local function enemy_worm_autoplace(probability_expression, force)
  return enemy_autoplace {
    probability_expression = "(" .. probability_expression .. ") * (1 - no_enemies_mode)",
    order = "a["..force.."]-a[worm]",
    force = force
  }
end

return
{
  control_name = control_name,
  enemy_autoplace = enemy_autoplace,
  enemy_spawner_autoplace = enemy_spawner_autoplace,
  enemy_worm_autoplace = enemy_worm_autoplace
}
