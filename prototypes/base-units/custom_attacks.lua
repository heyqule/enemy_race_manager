---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 12/23/2020 8:27 PM
---

local CustomAttackHelper = require('__enemyracemanager__/lib/helper/custom_attack_helper')

local CustomAttacks = {}

CustomAttacks.valid = CustomAttackHelper.valid

function CustomAttacks.process_logistic(event)
    local race_settings = CustomAttackHelper.get_race_settings(MOD_NAME)
    CustomAttackHelper.drop_unit(event, MOD_NAME, CustomAttackHelper.get_unit(MOD_NAME, 'droppable_units'), 2)
    if CustomAttackHelper.can_spawn(75) then
        CustomAttackHelper.drop_unit(event, MOD_NAME, CustomAttackHelper.get_unit(MOD_NAME, 'droppable_units'))
    end
    if race_settings.tier == 3 and CustomAttackHelper.can_spawn(40) then
        CustomAttackHelper.drop_unit(event, MOD_NAME, CustomAttackHelper.get_unit(MOD_NAME, 'droppable_units'), 2)
        if CustomAttackHelper.can_spawn(25) then
            CustomAttackHelper.drop_unit(event, MOD_NAME, CustomAttackHelper.get_unit(MOD_NAME, 'droppable_units'), 1)
        end
    end
end

function CustomAttacks.process_constructor(event)
    CustomAttackHelper.drop_unit(event, MOD_NAME, CustomAttackHelper.get_unit(MOD_NAME, 'construction_buildings'))
    event.source_entity.destroy()
end

return CustomAttacks