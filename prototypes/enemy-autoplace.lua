local control_name = 'enemy-base'

local function string_min(a, b)
  return 'min(' .. a .. ', '.. b .. ')'
end



--- Function Credit: Alien Biomes
--- 1.1 Base Game reference:
--- aux(desert - red sand): 0 - 1
--- water(moisture): 0 - 1
--- temperature: 12 - 18
--- elevation: -40 - 66
---
--- Alien Biomes reference:
--- aux(desert - red sand): 0 - 1
--- water(moisture): 0 - 1
--- temperature: -50 - 150
--- elevation: -40 - 66
--- +0.005 prevents probability falling below 0 when noise.var is at absolute end. e.g. moisture = 1 or 0
local function volume_to_noise_expression(volume)

  local result = nil
  if (volume['aux_min'] and  volume['aux_max']) then
    local aux_center = (volume['aux_min'] + volume['aux_max']) / 2
    local aux_range = math.abs(volume['aux_min'] - volume['aux_max']) / 2 + 0.005

    local aux_fitness = 'erm_plateau_peak_to_noise_expression(aux,'..aux_center..','..aux_range..')'
    result = aux_fitness
  end

  if (volume['moisture_min'] and  volume['moisture_max']) then
    local moisture_center = (volume['moisture_min'] + volume['moisture_max']) / 2
    local moisture_range = math.abs(volume['moisture_min'] - volume['moisture_max']) / 2 + 0.005
    local moisture_fitness = 'erm_plateau_peak_to_noise_expression(moisture,'..moisture_center..','..moisture_range..')'
    if(result == nil) then
      result = moisture_fitness
    else
      result = string_min(result, moisture_fitness)
    end
  end

  if (volume['temperature_min'] and  volume['temperature_max']) then
    local temperature_center = (volume['temperature_min'] + volume['temperature_max']) / 2
    local temperature_range = math.abs(volume['temperature_min'] - volume['temperature_max']) / 2
    local temperature_fitness = 'erm_plateau_peak_to_noise_expression(temperature,'..temperature_center..','..temperature_range..')'
    if(result == nil) then
      result = temperature_fitness
    else
      result = string_min(result, temperature_fitness)
    end
  end

  if (volume['elevation_min'] and  volume['elevation_max']) then
    local elevation_center = (volume['elevation_min'] + volume['elevation_max']) / 2
    local elevation_range = math.abs(volume['elevation_min'] - volume['elevation_max']) / 2

    local elevation_fitness = 'erm_plateau_peak_to_noise_expression(elevation,'..elevation_center..','..elevation_range..')'
    if(result == nil) then
      result = elevation_fitness
    else
      result = string_min(result, elevation_fitness)
    end
  end

  return result
end


local function enemy_autoplace(params)
  local force = params.force or 'enemy'
  local order = params.order or 'a['..force..']-autoplace'
  local final_expression
  if params.volume then
    local climate_controls = volume_to_noise_expression(params.volume)
    final_expression = 'min('..climate_controls..','.. params.probability_expression .. ')'
  else
    final_expression = params.probability_expression
  end
  return
  {
    control = params.control or control_name,
    order = order,
    force = force or 'enemy',
    probability_expression = final_expression,
    richness_expression = 1
  }
end

local function enemy_spawner_autoplace(probability_expression, force, volume)
  local autoplace_spec = {
    probability_expression = probability_expression,
    order = 'a['..force..']-a[spawner]',
    force = force
  }
  if volume then
    autoplace_spec.volume = volume
  end
  return enemy_autoplace(autoplace_spec)
end

local function enemy_worm_autoplace(probability_expression, force, volume)
  local autoplace_spec =  {
    probability_expression = '(' .. probability_expression .. ') * (1 - no_enemies_mode)',
    order = 'a['..force..']-a[worm]',
    force = force,
    is_turret = true
  }
  if volume then
    autoplace_spec.volume = volume
  end
  return enemy_autoplace(autoplace_spec)
end

return
{
  control_name = control_name,
  enemy_autoplace = enemy_autoplace,
  enemy_spawner_autoplace = enemy_spawner_autoplace,
  enemy_worm_autoplace = enemy_worm_autoplace
}
