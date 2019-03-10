newTalent{
   name = "Imposing Presence", short_name = "REK_WYRMIC_PREDATOR_AURA",
   type = {"wild-gift/apex-predator", 1},
   points = 5,
   require = gifts_req1,
   range = 3,
   mode = "passive",
   getChance = function(self, t)
      return self:combatLimit(self:getTalentLevel(t)^.5, 100, 7, 1, 15.65, 2.23)
   end, -- Limit < 100%
   callbackOnActBase = function(self, t)
      -- all gloom effects are handled here
      local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
      for x, yy in pairs(grids) do
	 for y, _ in pairs(grids[x]) do
	    local target = game.level.map(x, y, Map.ACTOR)
	    if target and self:reactionToward(target) < 0 then
	       if self:getTalentLevel(t) > 0 and rng.percent(t.getChance(self, t)) and target:checkHit(self:combatMindpower(), target:combatMentalResist(), 5, 95, 15) then
		  -- stun
		  if target:canBe("stun") and not target:hasEffect(target.EFF_STUNNED) then
		     target:setEffect(target.EFF_STUNNED, 3, {})
		  end
	       end
	    end
	 end
      end
   end,
   
   info = function(self, t)
      return ([[Your image strikes fear into the heart of your enemies.  Each turn, those caught within radius 3 have a %d%% chance to be stunned (#SLATE#Mindpower vs. Mental#LAST#) for 3 turns.]]):
	 format(t.getChance(self, t))
   end,
}

newTalent{
   name = "Jeweled Hide", short_name = "REK_WYRMIC_PREDATOR_GEM",
   type = {"wild-gift/apex-predator", 2},
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
      
      if self:getTalentLevel(t) >= 6 then	 
	 if self.body then
	    self.body.REK_WYRMIC_GEM = 2
	 else
	    self.body = { REK_WYRMIC_GEM = 2 }
	 end
      end
      self:initBody()
   end,
   
   -- If you wear an illegal gem, take it back off
   callbackOnWear = function(self, t, o, fBypass)
      local allowed = true
      if o.type ~= "gem" then return end
      if not self:knowTalent(self.T_REK_WYRMIC_HOARD_SIS) then
	 game.logPlayer(self, "Must know the Jeweled Hide talent")
	 allowed = false
      end 
      if not o.material_level then
	 game.logPlayer(self, "Impossible to use this gem")
	 allowed = false
      end
      if o.material_level > math.floor(self:getTalentLevel(self.T_REK_WYRMIC_HOARD_SIS)) then
	 game.logPlayer(self, "Jeweled Hide talent too low for this gem")
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
   name = "Confounding Roar", short_name = "REK_WYRMIC_PREDATOR_ROAR",
   type = {"wild-gift/apex-predator", 3},
   require = gifts_req3,
   points = 5,
   random_ego = "attack",
   message = "@Source@ roars!",
   equilibrium = 8,
   cooldown = 20,
   range = 0,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
   getConfusePower = function(self, t)
      return math.min(50, 20 + 8 * self:getTalentLevel(t))
   end,
   getDuration = function(self, t)
      return 3 + math.floor(self:combatTalentScale(t, 0, 4))
   end,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
   end,
   tactical = { DEFEND = 1, DISABLE = { confusion = 3 } },
   requires_target = true,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      self:project(tg, self.x, self.y, DamageType.CONFUSION, {
		      dur=t.getDuration(self, t),
		      dam=t.getConfusePower(self, t),
		      power_check=function() return self:combatPhysicalpower() end,
		      resist_check=self.combatMentalResist,
      })
      game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0, gM=0, bm=0.1, bM=0.2, am=0.4, aM=0.6})

      return true
   end,
   info = function(self, t)
      local radius = self:getTalentRadius(t)
      local power = t.getConfusePower(self, t)
      local duration = t.getDuration(self, t)
      return ([[You let out a powerful roar that sends your foes into utter confusion (%d power, (#SLATE#Physical power vs. Mental#LAST#)) for %d turns in a radius of %d.]]):format( power, duration, radius )
   end,
}


newTalent{
   name = "Sense Weakness", short_name = "REK_WYRMIC_PREDATOR_EXECUTE",
   type = {"wild-gift/apex-predator", 4},
   require = gifts_req4,
   mode = "passive",
   points = 5,
   getThreshold = function(self,t)
      return math.min(self:combatTalentScale(t, 10, 50), 50)
   end, -- Limit 50%
   
   callbackOnDealDamage = function(self, t, val, target, dead, death_note)
      if target.life < target.max_life * t.getThreshold(self, t) / 100 then
	 return val*1.2
      end
      return val
   end,
   
   info = function(self, t)
      local thresh = t.getThreshold(self, t)
      return ([[You capitalize on the weakness in your injured foes to finish them off.  You deal 20%% more damage to foes with less than %d%% life remaining.]]):format(thresh)
   end,
}


-- newTalent{
--    name = "Terrorize", short_name = "REK_WYRMIC_PREDATOR_TRACK",
--    type = {"wild-gift/apex-predator", 4},
--    require = gifts_req_4,
--    random_ego = "utility",
--    mode = "passive",
--    points = 5,
   
--    getThreshold = function(self,t) return self:combatTalentLimit(t, 10, 45, 25) end, -- Limit >10%

--    getFailChance = function(self, t)
--       return math.min(50, self:combatTalentMindDamage(t, 20, 45))
--    end,

--    callbackOnDealDamage = function(self, t, val, target, dead, death_note)    
--       if 100 * val / target.max_life >= t.getThreshold(self, t) and not dead then
-- 	 target:setEffect(target.EFF_TERRIFIED, 3, {actionFailureChance=t.getFailChance(self, t)})
--       end
      
--    end,
   
--    info = function(self, t)
--       local thresh = t.getThreshold(self, t)
--       local fail = t.getFailChance(self, t)
--       return ([[Your deadly strikes inspire utter terror in your foes. Any damage you do that deals more than %d%% of the target's maximum life terrifies them for 3 turns, giving them a %d%% chance each turn to fail to take action.]]):format(thresh, fail)
--    end,
-- }


-- newTalent{
--    name = "Trace", short_name = "REK_WYRMIC_PREDATOR_TRACK",
--    type = {"wild-gift/apex-predator", 4},
--    require = gifts_req_4,
--    random_ego = "utility",
--    cooldown = 20,
--    radius = function(self, t) return math.floor(self:combatScale(self:getCun(10, true) * self:getTalentLevel(t), 5, 0, 55, 50)) end,
--    getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
--    no_npc_use = true,
--    no_break_stealth = true,
--    action = function(self, t)
--       local rad = self:getTalentRadius(t)
--       self:setEffect(self.EFF_SENSE, t.getDuration(self, t), {
-- 			range = rad,
-- 			actor = 1,
--       })
--       return true
--    end,
--    info = function(self, t)
--       local rad = self:getTalentRadius(t)
--       return ([[Sense foes around you in a radius of %d for %d turns.
-- 		The radius will increase with your Cunning.]]):format(rad, t.getDuration(self, t))
--    end,
-- }



-- newTalent{
--    name = "Hypervigilance", short_name = "REK_WYRMIC_PREDATOR_SENSES",
--    type = {"wild-gift/apex-predator", 1},
--    points = 5,
--    no_energy = true,
--    range = 10,
--    requires_target = true,
--    equilibrium = 3,
--    cooldown = 20,
--    target = function(self, t) return {type="hit", pass_terrain = true, range=self:getTalentRange(t)} end,
--    sense = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
--    seePower = function(self, t) return math.max(0, self:combatScale(self:getCun(15, true)*self:getTalentLevel(t), 10, 1, 100, 75, 0.25)) end,
--    trapDetect = function(self, t) return math.max(0, self:combatScale(self:getTalentLevel(t) * self:getCun(25, true), 10, 3.75, 75, 125, 0.25)) end, -- same as HS
--    callbackOnStatChange = function(self, t, stat, v)
--       if stat == self.STAT_CUN then
-- 	 self:updateTalentPassives(t)
--       end
--    end,
--    passives = function(self, t, p)
--       self:talentTemporaryValue(p, "see_invisible", t.seePower(self, t))
--       self:talentTemporaryValue(p, "see_stealth", t.seePower(self, t))
--       self:talentTemporaryValue(p, "see_traps", t.trapDetect(self, t))
--    end,

--    action = function(self, t)
--       local tg = self:getTalentTarget(t)
--       local x, y, target = self:getTarget(tg)
--       if not target or not self:canProject(tg, x, y) then return nil end
      
--       self:project(tg, x, y, engine.DamageType.BREAK_STEALTH, {power=t.seePower(self, t), turns=10})
--       return true
--    end,
   
--    autolearn_talent = "T_DISARM_TRAP",
--    info = function(self, t)
--       return ([[You notice the slightest traces of your prey, giving you the ability to detect traps (+%d detect 'power').
-- You can focus your attention on an enemy, reducing their stealth power and invisibility by %d for 10 turns.
-- 		The detection abilities improve with Cunning.]]):
-- 	 format(t.trapDetect(self, t), t.seePower(self,t))
--    end,
-- }
