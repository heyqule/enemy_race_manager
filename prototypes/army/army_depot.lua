local subgroup_name = "player--erm_controllable"
local hit_effects = require ("__base__/prototypes/entity/hit-effects")
local sounds = require ("__base__/prototypes/entity/sounds")
local ERM_UnitTint = require("__enemyracemanager__/lib/rig/unit_tint")

--- Pulled from Klonan Combat drone
local is_sprite_def = function(array)
  return array.width and array.height and (array.filename or array.stripes or array.filenames)
end
util.is_sprite_def = is_sprite_def

local recursive_hack_scale
recursive_hack_scale = function(array, scale)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if is_sprite_def(v) then
        v.scale = (v.scale or 1) * scale
        if v.shift then
          v.shift[1], v.shift[2] = v.shift[1] * scale, v.shift[2] * scale
        end
      end
      if v.source_offset then
        v.source_offset[1] = v.source_offset[1] * scale
        v.source_offset[2] = v.source_offset[2] * scale
      end
      if v.projectile_center then
        v.projectile_center[1] = v.projectile_center[1] * scale
        v.projectile_center[2] = v.projectile_center[2] * scale
      end
      if v.projectile_creation_distance then
        v.projectile_creation_distance = v.projectile_creation_distance * scale
      end
      recursive_hack_scale(v, scale)
    end
  end
end
util.recursive_hack_scale = recursive_hack_scale

local recursive_hack_shift
recursive_hack_shift = function(array, shift)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if is_sprite_def(v) then
        if not v.shift then
          v.shift = shift
        else
          v.shift = {v.shift[1]+ shift[1], v.shift[2] + shift[2]}
        end
      end
      recursive_hack_shift(v, shift)
    end
  end
end
util.recursive_hack_shift = recursive_hack_shift

local base_layers =
{
  {
    filename = "__base__/graphics/entity/artillery-turret/artillery-turret-base.png",
    priority = "high",
    line_length = 1,
    width = 207,
    height = 199,
    frame_count = 1,
    repeat_count = 33,
    direction_count = 1,
    shift = {0.1, 1},
    scale = 0.5
  },
  {
    filename = "__base__/graphics/entity/artillery-turret/artillery-turret-base-shadow.png",
    priority = "high",
    line_length = 1,
    width = 277,
    height = 149,
    frame_count = 1,
    repeat_count = 33,
    direction_count = 1,
    shift = util.by_pixel(21, 42),
    draw_as_shadow = true,
    scale = 0.5
  }
}
util.recursive_hack_scale(base_layers, 1.2)

local on_animation =
{
  layers =
  {
    -- USE DEEPCOPY HERE
    util.table.deepcopy(base_layers[1]),
    util.table.deepcopy(base_layers[2]),
    {
      filename = "__enemyracemanager_assets__/graphics/depot/lab-red.png",
      width = 194,
      height = 174,
      frame_count = 33,
      line_length = 11,
      animation_speed = 1,
      shift = util.by_pixel(0, 1.5),
      scale = 0.5
    },
    {
      filename = "__base__/graphics/entity/lab/lab-integration.png",
      width = 242,
      height = 162,
      frame_count = 1,
      line_length = 1,
      repeat_count = 33,
      animation_speed = 1,
      shift = util.by_pixel(0, 15.5),
      scale = 0.5
    },
    {
      filename = "__enemyracemanager_assets__/graphics/depot/lab-red-light.png",
      blend_mode = "additive",
      draw_as_light = true,
      width = 216,
      height = 194,
      frame_count = 33,
      line_length = 11,
      animation_speed = 1,
      shift = util.by_pixel(0, 0),
      scale = 0.5
    },
    {
      filename = "__base__/graphics/entity/lab/lab-shadow.png",
      --width = 242,
      --height = 136,
      width = 1,
      height = 1,
      frame_count = 1,
      line_length = 1,
      repeat_count = 33,
      animation_speed = 1,
      shift = util.by_pixel(13, 11),
      scale = 0.5,
      draw_as_shadow = true
    }
  }
}

local off_animation =
{
  layers =
  {
    -- USE DEEPCOPY HERE TOO
    util.table.deepcopy(base_layers[1]),
    util.table.deepcopy(base_layers[2]),
    {
      filename = "__enemyracemanager_assets__/graphics/depot/lab-red.png",
      width = 194,
      height = 174,
      frame_count = 1,
      repeat_count = 33,
      shift = util.by_pixel(0, 1.5),
      scale = 0.5
    },
    {
      filename = "__base__/graphics/entity/lab/lab-integration.png",
      width = 242,
      height = 162,
      frame_count = 1,
      repeat_count = 33,
      shift = util.by_pixel(0, 15.5),
      scale = 0.5
    },
    {
      filename = "__base__/graphics/entity/lab/lab-shadow.png",
      --width = 242,
      width = 1,
      --height = 136,
      height = 1,
      frame_count = 1,
      repeat_count = 33,
      shift = util.by_pixel(13, 11),
      draw_as_shadow = true,
      scale = 0.5
    }
  }
}

util.recursive_hack_scale(on_animation, 1.6)
util.recursive_hack_scale(off_animation, 1.6)
util.recursive_hack_shift(off_animation, {0, -1.5})
util.recursive_hack_shift(on_animation, {0, -1.5})

local army_depot =
{
  type = "assembling-machine",
  name = "army-depot",
  localised_name = {"entity-name.army-depot"},
  icon = "__enemyracemanager_assets__/graphics/depot/infantry-depot-item-icon.png",
  icon_size = 64,
  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  minable = {mining_time = 3, result = "army-depot"},
  max_health = 1500,
  --corpse = "medium-remnants",
  --dying_explosion = "assembling-machine-1-explosion",
  collision_box = {{-2.75, -2.75}, {2.75, 2.75}},
  selection_box = {{-3, -3}, {3, 3}},
  --collision_mask = {"object-layer", "water-tile"},
  --damaged_trigger_effect = hit_effects.entity(),
  --fast_replaceable_group = "assembling-machine",
  --next_upgrade = "assembling-machine-2",
  --alert_icon_shift = util.by_pixel(-3, -12),
  graphics_set = {
    animation = on_animation,
    idle_animation = off_animation,
  },
  damaged_trigger_effect = hit_effects.entity(),
  open_sound = sounds.machine_open,
  close_sound = sounds.machine_close,
  vehicle_impact_sound = sounds.generic_impact,
  working_sound =
  {
    sound =
    {
      {
        filename = "__base__/sound/assembling-machine-t3-1.ogg",
        volume = 0.45
      }
    },
    audible_distance_modifier = 0.5,
    fade_in_ticks = 4,
    fade_out_ticks = 20
  },
  crafting_categories = {subgroup_name},
  crafting_speed = 1,
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = { pollution = 2 }
  },
  energy_usage = "100kW",
  scale_entity_info_icon = true,
  entity_info_icon_shift = {0, -1},
  map_color = ERM_UnitTint.tint_army_color(),
  enemy_map_color = { r=1, b=0, g=0 },
}

local corpse =
{
  type = "corpse",
  name = "army-depot-corpse",
  flags = {"placeable-off-grid"},
  animation = util.empty_sprite(),
  remove_on_entity_placement = false,
  remove_on_tile_placement = false
}

local item =
{
  name = "army-depot",
  type = "item",
  stack_size = 5,
  icon = army_depot.icon,
  icon_size = army_depot.icon_size,
  subgroup = "erm_controllable_buildings",
  place_result = "army-depot"
}

local recipegroup = {
  type = "recipe-category",
  name = subgroup_name
}
local itemsubgroup = {
  type = "item-subgroup",
  name = subgroup_name ,
  group = "army",
  order = subgroup_name
}

local depot_recipe =
{
  type = "recipe",
  name = "army-depot",
  results = {
    {type = "item", name = "army-depot", amount = 1}
  },
  energy_required = 10,
  ingredients =
  {
    {type = "item", name = "iron-plate", amount = 100},
    {type = "item", name = "iron-gear-wheel", amount = 50},
    {type = "item", name = "electronic-circuit", amount = 50},
  },
  enabled = false
}

local base_tech =
{
  type = "technology",
  name = "army-depot",
  localised_name = {"technology-name.army-depot"},
  icon = "__enemyracemanager_assets__/graphics/depot/infantry-depot-item-icon.png",
  icon_size = 64,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = "army-depot"
    },
  },
  unit =
  {
    count = 100,
    ingredients =
    {
      {"automation-science-pack", 1},
    },
    time = 45
  },
  order = "i-a"
}

data:extend
{
  recipegroup,
  itemsubgroup,
  army_depot,
  item,
  corpse,
  depot_recipe,
  base_tech
}