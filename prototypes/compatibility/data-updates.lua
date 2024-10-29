---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 3/16/2021 9:33 PM
---
local version = require('__stdlib__/stdlib/vendor/version')

if mods['ArmouredBiters'] then
    require 'ArmouredBiters/biter'
    require 'ArmouredBiters/spawner'
end

if mods['Cold_biters'] then
    require 'Cold_Biters/biter'
    require 'Cold_Biters/spawner'
    require 'Cold_Biters/worm'
end

if mods['Explosive_biters'] then
    require 'Explosive_Biters/biter'
    require 'Explosive_Biters/spawner'
    require 'Explosive_Biters/worm'
end

if mods['Toxic_biters'] then
    require 'Toxic_Biters/biter'
    require 'Toxic_Biters/spawner'
    require 'Toxic_Biters/worm'
end

if mods['IndustrialRevolution'] then
    require 'IndustrialRevolution/projectile'
end

if mods['IndustrialRevolution3'] then
    require 'IndustrialRevolution/projectile'
    require 'IndustrialRevolution3/projectile'
    require 'IndustrialRevolution3/recipe'
end

if mods['Krastorio2'] and version(mods['Krastorio2']) >= version('1.2.0') then
    require 'K2/projectile'
end

if mods['space-exploration'] then
    require 'SpaceExploration/meteorites.lua'
end

require 'shared/resistance'