require "busted.runner"({["output"] = "gtest"})

dofile(".specs/AddonLoader.lua")

local Utils

describe("#Utils :CheckOutdatedVersion", function()

   before_each(function()
      Utils = RCLootCouncil.Utils
   end)

   it("should exist", function()
      assert.is.Function(Utils.CheckOutdatedVersion)
   end)

   it("should not crash", function()
      assert.has_no.errors(function() Utils:CheckOutdatedVersion("","") end)
   end)

   it("should report equal version", function()
      local res = Utils:CheckOutdatedVersion("2.15.0","2.15.0")
      assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
      res = Utils:CheckOutdatedVersion("2.15.1","2.15.1")
      assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
      res = Utils:CheckOutdatedVersion("3.0.0","3.0.0")
      assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
      res = Utils:CheckOutdatedVersion("999.999.999","999.999.999")
      assert.are.equal(res, RCLootCouncil.VER_CHECK_CODES[1])
   end)

   it("should default to addon version", function()
      RCLootCouncil.version = "2.14.0"
      assert.are.equal(Utils:CheckOutdatedVersion(nil, "2.14.0"), RCLootCouncil.VER_CHECK_CODES[1])
   end)

   it("should report not-outdated versions", function()
      assert.are.equal(Utils:CheckOutdatedVersion("2.14.1", "2.14.0"), RCLootCouncil.VER_CHECK_CODES[1])
      assert.are.equal(Utils:CheckOutdatedVersion("2.15.1", "2.14.20"), RCLootCouncil.VER_CHECK_CODES[1])
      assert.are.equal(Utils:CheckOutdatedVersion("3.0.0", "2.14.20"), RCLootCouncil.VER_CHECK_CODES[1])
   end)

   it("should report outdated versions", function()
      assert.are.equal(Utils:CheckOutdatedVersion("2.14.2", "2.14.3"), RCLootCouncil.VER_CHECK_CODES[2])
      assert.are.equal(Utils:CheckOutdatedVersion("2.14.2", "2.15.1"), RCLootCouncil.VER_CHECK_CODES[2])
      assert.are.equal(Utils:CheckOutdatedVersion("2.14.2", "3.0.0"), RCLootCouncil.VER_CHECK_CODES[2])
   end)

   it("should handle test versions", function()
      assert.has_no.errors(function() Utils:CheckOutdatedVersion("2.0.0", "2.1.0", "Alpha.1", "Alpha.1") end)
   end)

   it("should handles outdated test versions", function()
      assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Alpha.2"), RCLootCouncil.VER_CHECK_CODES[3])
      assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Beta.1"), RCLootCouncil.VER_CHECK_CODES[3])
   end)

   it("should handle non-outdated test versions", function()
      assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.2", "Alpha.1"), RCLootCouncil.VER_CHECK_CODES[1])
   end)

   it("should handle equal test versions", function()
      assert.are.equal(Utils:CheckOutdatedVersion("2.0.0", "2.0.0", "Alpha.1", "Alpha.1"), RCLootCouncil.VER_CHECK_CODES[1])
      assert.are.equal(Utils:CheckOutdatedVersion("2.15.0", "2.15.0", "Alpha.1", "Alpha.1"), RCLootCouncil.VER_CHECK_CODES[1])
      assert.are.equal(Utils:CheckOutdatedVersion("2.15.0", "2.15.0", "Alpha.10", "Alpha.10"), RCLootCouncil.VER_CHECK_CODES[1])
   end)
end)

describe("#Utils functions", function()
   describe("DiscardWeaponCorruption", function()
      it("should remove correct bonusID", function()
         local itemWith = "|cffa335ee|Hitem:172200::::::::120:104::5:7:4823:6572:6578:6579:1502:4786:6513:::|h[Sk'shuul~`Vaz]|h|r"
         local itemWithout = "|cffa335ee|Hitem:172200::::::::120:104::5:7:4823:6572:6578:6579:1502:4786:::|h[Sk'shuul~`Vaz]|h|r"
         assert.are.equal(itemWithout, Utils:DiscardWeaponCorruption(itemWith))
      end)

      it("should compare without numBonuses", function()
         local itemWith = "|cffa335ee|Hitem:172200::::::::120:104::5:7:4823:6572:6578:6579:1502:4786:6513:::|h[Sk'shuul~`Vaz]|h|r"
         local itemWithout = "|cffa335ee|Hitem:172200::::::::120:104::5:6:4823:6572:6578:6579:1502:4786:::|h[Sk'shuul~`Vaz]|h|r"
         assert.is_true(RCLootCouncil:ItemIsItem(itemWith, itemWithout))
      end)

      it("shouldn't touch others", function()
         local item = "|cffa335ee|Hitem:174117::::::::120:256::5:5:4823:1502:4786:6509:4775:::|h[Spaulders of Miasmic Mycelia]|h|r"
         assert.are.equal(item, Utils:DiscardWeaponCorruption(item))
      end)

      it("should handle nils", function()
         assert.has_no.errors(function()
            assert.is_nil(Utils:DiscardWeaponCorruption(nil))
         end)
      end)
   end)
end)
