newTalent{
   name = "Luxury is Life", short_name = "REK_WYRMIC_HOARD_LIL",
   type = {"wild-gift/hoarding", 1},
   require = gifts_req1,
   points = 5,
   mode = "passive",
   
   callbackOnRest = function(self, t)
      self:updateTalentPassives(t.id)
   end,

   getCurrentLuxury = function(self, t)
      local luxury_count = 0
      for inven_id, inven in pairs(self.inven) do
	 for item, o in ipairs(inven) do
	    if o and item and (o.unique or o.randart) then
	       luxury_count = luxury_count + 1
	    end
	 end
      end
      return luxury_count
   end,

   getPower = function(self, t)
      local luxPoints = t.getCurrentLuxury(self, t)
      return math.max(1, self:combatScale(luxPoints*self:getTalentLevel(t), 5, 1, 100, 250))
   end,
   
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "combat_mindpower", t.getPower(self, t))
      self:talentTemporaryValue(p, "combat_physicalpower", t.getPower(self, t))
   end,
   info = function(self, t)
      return ([[There are many things that are useful in the world, but you covet the real treasures.
Each artifact in your inventory increases your physical and mind power (currently %d), reaching its maximum at %d artifacts.
You require time to count your treaures.  The benefit updates when you Rest.

#{italic}#You don't have to *use* any of it.  It's enough to have it.#{normal}#]]):
	 format(t.getPower(self, t), 250 / math.max(1, self:getTalentLevel(t)))
   end,
}

newTalent{
   name = "Splendour is Strength", short_name = "REK_WYRMIC_HOARD_SIS",
   type = {"wild-gift/hoarding", 2},
   require = gifts_req2,
   points = 5,
   mode = "passive",
   no_npc_use = true,
   no_unlearn_last = true,
   on_learn = function(self, t)
      -- Reinitializing body will smash any existing gems in the slots, so unequip
      local gem = self:getInven("REK_WYRMIC_GEM") and self:getInven("REK_WYRMIC_GEM")[1] or false 
      if gem then
	 self:doTakeoff("REK_WYRMIC_GEM", 1, gem, false, self)
      end
      
      if self.body then
	 if not self.body.REK_WYRMIC_GEM then
	    self.body.REK_WYRMIC_GEM = 1
	 end
      else
	 self.body = { REK_WYRMIC_GEM = 1 }
      end
      
      if self:getTalentLevel(self.T_REK_WYRMIC_HOARD_SIS) >= 6 then

	 
	 if self.body then
	    self.body.REK_WYRMIC_GEM = 2
	 else
	    self.body = { REK_WYRMIC_GEM = 2 }
	 end
      end
      self:initBody()
   end,

   -- -- Unequip any gems you no longer qualify for
   -- on_unlearn = function(self, t)
   --    for inven_id, inven in pairs(self.inven) do
   -- 	 for i = #inven, 1, -1 do
   -- 	    local so = inven[i]
   -- 	    if so.material_level > math.floor(self:getTalentLevel(self.T_REK_WYRMIC_HOARD_SIS) or 0) then
   -- 	       local o = self:removeObject(inven, i, true)
   -- 	       self:addObject(self.INVEN_INVEN, o)
   -- 	    end
   -- 	 end
   --    end
   --    self:sortInven()
   -- end,
   
   -- If you wear an illegal gem, take it back off
   callbackOnWear = function(self, t, o, fBypass)
      local allowed = true
      if o.type ~= "gem" then return end
      if not self:knowTalent(self.T_REK_WYRMIC_HOARD_SIS) then
	 game.logPlayer(self, "Must know the Splendour is Strength talent")
	 allowed = false
      end 
      if not o.material_level then
	 game.logPlayer(self, "Impossible to use this gem")
	 allowed = false
      end
      if o.material_level > math.floor(self:getTalentLevel(self.T_REK_WYRMIC_HOARD_SIS)) then
	 game.logPlayer(self, "Splendour is Strength talent too low for this gem")
	 allowed = false
      end

      if not allowed then 
	 for inven_id, inven in pairs(self.inven) do
	    for i = #inven, 1, -1 do
	       local so = inven[i]
	       if so == o then
		  local o = self:removeObject(inven, i, true)
		  self:addObject(self.INVEN_INVEN, o)
		  self:sortInven()
	       end
	    end
	 end
      end
   end,
   
   info = function(self, t)
      return ([[As the dragons plate their underbellies with coats of crystal, so do you imbue yourself with the power of gems.

You can equip a gem (up to tier %d), activating its powers.
At talent level 6, you can equip a second gem. 
Warning: Ranking up this talent will unequip any currently equipped gems]]):format(math.floor(math.min(5,self:getTalentLevel(t))))
   end,
}

newTalent{
   name = "Greed is Good", short_name = "REK_WYRMIC_HOARD_GIG",
   type = {"wild-gift/hoarding", 3},
   require = gifts_req3,
   points = 5,
   mode = "passive",
   getMaxReduc = function(self, t) return self:combatTalentLimit(t, 50, 10, 50) end,
   getGold = function(self, t) return self:combatTalentLimit(t, 40, 85, 65) end, -- Limit > 40
   getReduction = function(self, t)
      local greedPoints = self.money / t.getGold(self, t)
      local scaledReduc = self:combatScale(greedPoints, 10, 1, 50, 50)
      return util.bound(scaledReduc, 0, t.getMaxReduc(self, t))
   end,

   callbackOnRest = function(self, t)
      self:updateTalentPassives(t.id)
   end,

   passives = function(self, t, p)
      self:talentTemporaryValue(p, "reduce_detrimental_status_effects_time", t.getReduction(self, t))
   end,
   info = function(self, t)
      return ([[A dragon's greed is limitless, there must always be more.  You ignore anything that could keep you from the pursuit of wealth.
All new detrimental effects on you have their duration reduced, based on the amount of gold you possess (currently %d%%), up to maximum at %d gold.
You require time to count your treaures.  The benefit updates when you Rest.

#{italic}#The more you have, the harder you fight for it!#{normal}#]]):
	 format(t.getReduction(self, t), t.getGold(self, t)*100)
   end,
}

newTalent{
   name = "Possession is Proficiency", short_name = "REK_WYRMIC_HOARD_PIP",
   type = {"wild-gift/hoarding", 4},
   require = gifts_req4,
   points = 5,
   mode = "passive",
   cdReduc = function(self, t) return self:combatTalentLimit(t, 100, 10, 35) end,
   recharge = function(self, t) return math.min(100, 25 + 15 * self:getTalentLevel(t)) end,

   on_learn = function(self, t)
      if not self:knowTalent(self.T_SWIFT_HANDS) then
	 if self:attr("quick_equip_cooldown") then
	    self:attr("quick_equip_cooldown", -1 * self:attr("quick_equip_cooldown") )
	 end
	 self:attr("quick_equip_cooldown", 1 / (t.recharge(self, t)*0.01))
      end
   end,
   on_unlearn = function(self, t)
      if self:attr("quick_equip_cooldown") > 0 and not self:knowTalent(self.T_SWIFT_HANDS) then	 
	 self:attr("quick_equip_cooldown", -1 * self:attr("quick_equip_cooldown"))
	 if self:getTalentLevel(t) > 0 then
	    self:attr("quick_equip_cooldown", 1 / (t.recharge(self, t)*0.01))
	 end

      end
   end,
   
   passives = function(self, t, p)
      if self:knowTalent(self.T_SWIFT_HANDS) then
	 self:talentTemporaryValue(p, "use_object_cooldown_reduce", t.cdReduc(self, t))
      end
   end,
   
   info = function(self, t)
      return ([[You know the workings of items in your hoard intimately.  When you equip a usable item, it is immediately charged by %d%% of its maximum power. Equipping it still takes time.

If you possess the Swift Hands prodigy, this talent instead reduces the cooldown and power cost of usable items by %d%%.]]):
	 format(t.recharge(self, t), t.cdReduc(self, t))
   end,
}
