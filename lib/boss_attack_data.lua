---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by heyqule.
--- DateTime: 8/28/2022 9:34 PM
---
local BossAttacksData = {}

--Example:
--BossAttacks.basic_attacks =
--{
--    projectile_name = {'blood-cloud','acid-cloud','blood-fire'},
--    projectile_type = {
--        ErmBossAttackProcessor.TYPE_PROJECTILE,
--        ErmBossAttackProcessor.TYPE_PROJECTILE,
--        ErmBossAttackProcessor.TYPE_PROJECTILE
--    },
--    projectile_chance = {25, 25, 100},
--    projectile_count = {1, 1, 1},
--    projectile_spread = {1, 1, 2},
--    projectile_use_multiplier = {false, false, true},
--    projectile_count_multiplier = {
--        {},
--        {},
--        {1, 1, 1, 2, 3}
--    },
--    projectile_spread_multiplier = {
--        {},
--        {},
--        {1, 1, 1, 1, 1}
--    },
--}
BossAttacksData.basic_attacks = {}
BossAttacksData.advanced_attacks = {}
BossAttacksData.super_attacks = {}
BossAttacksData.phases = {}

function BossAttacksData.get_attack_data()
    return {
      basic_attacks = BossAttacksData.basic_attacks,
      advanced_attacks = BossAttacksData.advanced_attacks,
      super_attacks = BossAttacksData.super_attacks,
      phases = BossAttacksData.phases,
    }
end

return BossAttacksData