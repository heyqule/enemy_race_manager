
local TestShared = require('shared')
local AttackGroupBeaconProcessor = require('__enemyracemanager__/lib/attack_group_beacon_processor')



before_each(function()
    TestShared.prepare_the_factory()
    global.erm_unit_groups = {}

end)

after_each(function()
    TestShared.reset_the_factory()
    global.erm_unit_groups = {}

end)

describe("Interplanetary Attack", function()
    it("Interplanetary Attack: Attack Target", function()

    end)

    it("Interplanetary Attack: Partially Build Home", function()

    end)
end)