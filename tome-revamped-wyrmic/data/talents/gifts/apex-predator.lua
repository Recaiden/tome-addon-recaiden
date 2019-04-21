newTalent{
   name = "Imposing Presence", short_name = "REK_WYRMIC_PREDATOR_AURA",
   type = {"wild-gift/apex-predator", 1},
   points = 5,
   require = gifts_req1,
   range = 3,
   mode = "passive",
   getChance = function(self, t)
      return self:combatLimit(self:getTalentLevel(t)^.5, 100, 5, 1, 12.65, 2.23)
   end, -- Limit < 100%
   callbackOnActBase = function(self, t)
      local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
      for x, yy in pairs(grids) do
	 for y, _ in pairs(grids[x]) do
	    local target = game.level.map(x, y, Map.ACTOR)
	    if target and self:reactionToward(target) < 0 then
	       if self:getTalentLevel(t) > 0 and rng.percent(t.getChance(self, t)) and target:checkHit(self:combatMindpower(), target:combatPhysicalResist(), 5, 95, 15) then
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
      return ([[Your image strikes fear into the heart of your enemies, and they dare not approach.  Each turn, those caught within radius 3 have a %d%% chance to be stunned (#SLATE#Mindpower vs. Physical#LAST#) for 3 turns.]]):
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
      if gem and self:getTalentLevel(t) < 6 then
	 return true
      end
      
      if self.body then
	 if not self.body.REK_WYRMIC_GEM then
	    self.body.REK_WYRMIC_GEM = 1
	 end
      else
	 self.body = { REK_WYRMIC_GEM = 1 }
      end
      
      if self:getTalentLevel(t) >= 6 then
	 if gem then
	    self:doTakeoff("REK_WYRMIC_GEM", 1, gem, false, self)
	 end
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
      if not self:knowTalent(self.T_REK_WYRMIC_PREDATOR_GEM) then
	 game.logPlayer(self, "Must know the Jeweled Hide talent")
	 allowed = false
      end 
      if not o.material_level then
	 game.logPlayer(self, "Impossible to use this gem")
	 allowed = false
      end
      if o.material_level > math.floor(self:getTalentLevel(self.T_REK_WYRMIC_PREDATOR_GEM)) then
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
Warning: Ranking up to talent level 6 will unequip any currently equipped gems]]):format(math.floor(math.min(5,self:getTalentLevel(t))))
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
      game:playSoundNear(self, "talents/rek_wyrmic_roar")
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
   getDurationBoost = function(self, t) return 1 end,
   getSufferChance = function(self, t) return self:combatTalentLimit(t, 50, 5, 20) end,
   callbackOnDealDamage = function(self, t, val, target, dead, death_note)
      if dead then return val end
      
      local nb = 0
      local effs = {}
      for eff_id, p in pairs(target.tmp) do
	 local e = target.tempeffect_def[eff_id]
	 if (e.subtype.stun or e.subtype.blind or e.subtype.pin or e.subtype.disarm  or e.subtype.confusion) then
	    nb = nb + 1
	    effs[#effs+1] = eff_id
	 end
      end
      
      if nb > 0 then
	 --Increase duration
	 if not self.turn_procs.rek_wyrmic_sense_weakness then
	    local chance = t.getSufferChance(self,t)
	    local boost = t.getDurationBoost(self, t)
	    if rng.percent(chance) then
	       self.turn_procs.rek_wyrmic_sense_weakness = true
	        local eff = rng.tableRemove(effs)
		local e2 = target.tmp[eff]
		e2.dur = e2.dur + boost
	    end
	 end
      end
      return val
   end,
   
   info = function(self, t)
      local boost = t.getDurationBoost(self, t)
      local chance = t.getSufferChance(self,t)
      return ([[Once your prey has shown any vulnerability, it's as good as dead.  When you damage an enemy with a disabling condition, (Stun, Frozen, Daze, Blind, Disarm, Pin, Confused), you have a %d%% chance to increase the duration of one of their disabling conditions by %d (no more than once per turn).]]):format(chance, boost)
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
