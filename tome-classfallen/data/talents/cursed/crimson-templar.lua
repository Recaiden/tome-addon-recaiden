newTalent{
   name = "Shared Agony", short_name = "FLN_TEMPLAR_SHARED_AGONY",
   type = {"cursed/crimson-templar", 4},
   require = cursed_wil_req_high1,
   points = 5,
   mode = "sustained",
   cooldown = 10,
   range = 5,
   tactical = { BUFF = 2, DEFEND = 2 },
   getShrug = function(self, t) return self:combatTalentLimit(t, 50, 10, 25) end,
   getAmp = function(self, t) return self:combatTalentLimit(t, 300, 130, 200) end,
   callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
      -- Displace Damage
      if dam > 0 and src ~= self and not state.no_reflect then
	 
	 -- find available targets
	 local tgts = {}
	 local grids = core.fov.circle_grids(self.x, self.y, 5, true)
	 for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
	       local a = game.level.map(x, y, Map.ACTOR)
	       if a and self:reactionToward(a) < 0 then
		  for eff_id, p in pairs(a.tmp) do
		     local e = target.tempeffect_def[eff_id]
		     if e.subtype.bleed and e.status == "detrimental" then
			tgts[#tgts+1] = a
			break
		     end
		  end
	       end
	 end end
	 
	 -- Displace the damage
	 local a = rng.table(tgts)
	 if a then
	    local displace = dam * t.getShrug(self, t)
	    dam = dam - displace
	    displace = displace * t.getAmp(self, t) / 100
	    state.no_reflect = true
	    DamageType.defaultProjector(self, a.x, a.y, type, displace, state)
	    state.no_reflect = nil

	    game:delayedLogDamage(src, self, 0, ("%s(%d shared agony)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", displace), false)
	 end
      end
      
      return {dam=dam}
   end,
   info = function(self, t)
      local shrug = t.getShrug(self, t)
      local amp = t.getAmp(self, t)
      return ([[You displace %d%% of any damage you receive onto a random bleeding enemy within range 5.  This redirected damage is amplified by %d%%.

#{italic}#All living things are linked by blood.  It is one river, flowing through all.#{normal}#]]):format(shrug, amp)
   end,
}

newTalent{
   name = "Splatter Sigils", short_name = "FLN_TEMPLAR_SPLATTER_SIGILS",
   type = {"cursed/crimson-templar", 4},
   require = cursed_wil_req_high2,
   points = 5,
   mode = "passive",
   info = function(self, t)
      return ([[In progress...

   On-kill, mark the ground with a ring
   Ring provides (+) and health regen and slows enemies
   Activate to spend a bit of your life to do the same.]]):format()
   end,
}

newTalent{
   name = "Mark of the Vampire", short_name = "FLN_TEMPLAR_MARK_OF_THE_VAMPIRE",
   type = {"cursed/crimson-templar", 4},
   require = cursed_wil_req_high3,
   points = 5,
   mode = "passive",
   info = function(self, t)
      return ([[In progress...
Hate Cost, high uptime if you can afford it
   Make someone suffer larger bleeds, bleed when they spend a resoure]]):format()
   end,
}

newTalent{
   name = "Rosebloom", short_name = "FLN_TEMPLAR_ROSEBLOOM",
   type = {"cursed/crimson-templar", 4},
   require = cursed_wil_req_high4,
   points = 5,
   range = 0,
   radius = 10, 
   getExtension = function(self, t) return 2 end,
   getConversion = function(self, t) return 0.20 end,
   getInsomniaPower= function(self, t)
      local t = self:getTalentFromId(self.T_SANDMAN)
      local reduction = t.getInsomniaPower(self, t)
      return 20 - reduction
   end,
   getMinHeal = function(self, t) return self:combatTalentScale(t, 10, 25) end,
   getSleepPower = function(self, t) 
      local power = self:combatTalentSpellDamage(t, 5, 25)
      if self:knowTalent(self.T_SANDMAN) then
	 local t = self:getTalentFromId(self.T_SANDMAN)
	 power = power * t.getSleepPowerBonus(self, t)
      end
      return math.ceil(power)
   end,
   target = function(self, t) return {type="cone", radius=self:getTalentRange(t), range=0, talent=t, selffire=false} end,

   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end

      --Restless?
      local is_waking =0
      if self:knowTalent(self.T_RESTLESS_NIGHT) then
	 local t = self:getTalentFromId(self.T_RESTLESS_NIGHT)
	 is_waking = t.getDamage(self, t)
      end

      -- Store up blood
      local drain = 0
      local conversion = t.getConversion(self, t)
      local healMin = t.getMinHeal(self, t)
      
      local power = self:spellCrit(t.getSleepPower(self, t))      
      self:project(tg, x, y, function(tx, ty)
		      local target = game.level.map(tx, ty, Map.ACTOR)
		      if target then

			 local bleeding = false
			 local dur = 0
			 for eff_id, p in pairs(target.tmp) do
			    local e = target.tempeffect_def[eff_id]
			    if e.subtype.bleed and e.status == "detrimental" then
			       bleeding = true
			       local eff = target.tmp[eff_id]
			       drain = drain + math.max(eff.power*eff.dur*conversion,
							healMin)
			       dur = math.max(dur, eff.dur)
			    end
			 end
			 
			 
			 if bleeding and target:canBe("sleep") then
			    target:setEffect(target.EFF_SLEEP, dur+t.getExtension(self, t), {src=self, power=power, contagious=0, waking=is_waking, insomnia=t.getInsomniaPower(self, t), no_ct_effect=true, apply_power=self:combatSpellpower()})
			 else
			    game.logSeen(self, "%s resists the sleep!", target.name:capitalize())
			 end
		      end
      end)

      -- Drain the blood to heal
      self:attr("allow_on_heal", 1)
      self:heal(t.getHeal(self, t), self) -- don't crit, would double dip crit bleeds
      self:attr("allow_on_heal", -1)
      
      game:playSoundNear(self, "talents/dispel")
      return true
   end,
	
   info = function(self, t)
      local conversion = t.getConversion(self, t)*100
      local minimum = t.getMinHeal(self, t)
      local extension = t.getExtension(self, t)
      local sleep = t.getSleepPower(self, t)
      return ([[Draw out the wounds of nearby enemies, healing yourself and putting them into a merciful sleep.
		Enemies within range have their bleed effects removed.  You are healed for %d%% of the remaining damage (minimum %d per target).  Enemies fall asleep for %d turns longer than they would have bled, rendering them unable to act. Every %d points of damage the target suffers will reduce the sleep duration by one turn.

When Sleep ends, the target will benefit from Insomnia for a number of turns equal to the amount of time it was asleep (up to ten turns max), granting it 50%% sleep immunity for the duration Insomnia effect.]]):format(conversion, minimum, extension, sleep)
   end,
}
