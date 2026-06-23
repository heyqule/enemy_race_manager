These helpers should use minimal amount of require().  

These are designed to be included from multiple classes to avoid circular dependencies.

The following classes are designed to be included in other ERM mod directly.  Hence some function calls are using remote.call on enemyracemanager functions.
- custom_attack_helper.lua  (handles most ERM custom attack logic, ERM enemy mods may override its functions)
- custom_city_builder.lua  (handles blueprint town building for enemy)
