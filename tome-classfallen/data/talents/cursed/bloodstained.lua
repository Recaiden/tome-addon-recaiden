newTalent{
   name = "Blood Clot", short_name = "FLN_BLEED_RESIST",
   type = {"cursed/other", 1},
   points = 1,
   mode = "passive",
   callbackOnTemporaryEffectAdd = function(self, t, eff_id, e_def, eff)
      if e_def.subtype.bleed and e_def.type ~= "other" then
	 local diminishment = math.min((
	       self:getTalentLevelRaw(self.T_FLN_BLOODSTINED_RUSH)
		  + self:getTalentLevelRaw(self.T_FLN_BLOODSTINED_FURY)
		  + self:getTalentLevelRaw(self.T_FLN_BLOODSTINED_BATH)
		  + self:getTalentLevelRaw(self.T_FLN_BLOODSTINED_THIRST))*2, 90)
	 eff.power = eff.power * (100-diminishment) / 100
      end
   end,
   info = function(self, t)
      return ([[Reduces the damage you take from bleeds]]):
	 format()
   end,
}

newTalent{
   name = "Blood Rush", short_name = "FLN_BLOODSTAINED_RUSH",
   type = {"cursed/bloodstained", 1},
   require = cursed_str_req1,
   points = 5,
   cooldown = 12,
   positive = -5.2,
   hate = 3,
   tactical = { ATTACK = 2, CLOSEIN = 1 },
   range = 8,
   requires_target = true,
   is_melee = true,
   is_teleport = true,
   getBleedDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.7, 2.1) end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
   target = function(self, t) return {type="hit", pass_terrain = true, range=self:getTalentRange(t)} end,
   on_learn = function(self, t) self:learnTalent(self.T_FLN_BLEED_RESIST, true) end,
   on_unlearn = function(self, t) self:unlearnTalent(self.T_FLN_BLEED_RESIST) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      
      if not self:teleportRandom(x, y, 0) then game.logSeen(self, "The bloodrush fizzles!") return true end
      
      game:playSoundNear(self, "talents/teleport")
      -- Attack
      if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
	 target:setEffect(target.EFF_FLN_RUSH_MARK, 6, {src=self})
	 self:attackTarget(target, nil, 1, true)
	 if target:canBe('cut') then
	    local sw = self:getInven("MAINHAND")
	    if sw then
	       sw = sw[1] and sw[1].combat
	    end
	    sw = sw or self.combat
	    local dam = self:combatDamage(sw)
	    local damrange = self:combatDamageRange(sw)
	    dam = rng.range(dam, dam * damrange)
	    dam = dam * t.getBleedDamage(self, t)
	    target:setEffect(target.EFF_CUT, 5, {power=dam / 5, src=self, apply_power=self:combatPhysicalpower()})
	 end
      end
      
      return true
   end,
   info = function(self, t)
      local damage = t.getBleedDamage(self, t)
      return ([[Teleport to an enemy, striking them for 100%% weapon damage, bleeding them for %d%% weapon damage over five turns, and marking them for six turns.

When the marked enemy dies, the cooldown of this talent will be reduced by two turns for every turn the mark had remaining.

Each level in Bloodstained talents reduces the amount of damage you take from bleed effects by 2%%]]):
	 format(100 * damage)
   end,
}

newTalent{
   name = "Blood Fury", short_name = "FLN_BLOODSTAINED_FURY",
   type = {"cursed/bloodstained", 2},
   require = cursed_str_req2,
   points = 5,
   cooldown = 8,
   hate = 10,
   positive = -10.4,
   tactical = { ATTACK = 2 },
   range = 1,
   requires_target = true,
   is_melee = true,
   getBleedMult = function(self, t) return self:combatTalentScale(t, 2, 4) end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 2.0) end,
   on_learn = function(self, t) self:learnTalent(self.T_FLN_BLEED_RESIST, true) end,
   on_unlearn = function(self, t) self:unlearnTalent(self.T_FLN_BLEED_RESIST) end,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
      
      if hit then
	 for eff_id, p in pairs(target.tmp) do
	    local e = target.tempeffect_def[eff_id]
	    if e.subtype.bleed and e.status == "detrimental" then
	       local eff = target.tmp[eff_id]
	       eff.power = eff.power * t.getBleedMult(self, t)
	       break
	    end
	 end
      end
      
      return true
   end,
   info = function(self, t)
      local dam = t.getDamage(self, t)*100
      local mult = t.getBleedMult(self, t)*100
      return ([[Cut into an enemy and twist the blade, dealing %d%% damage and increasing the intensity of their existing bleed effects by %d%%.

Each level in Bloodstained talents reduces the amount of damage you take from bleed effects by 2%%]]):
	 format(dam, mult)
   end,
}

newTalent{
   name = "Blood Bath", short_name = "FLN_BLOODSTAINED_BATH",
   type = {"cursed/bloodstained",3},
   require = cursed_str_req3,
   points = 5,
   mode = "sustained",
   sustain_positive = 20,
   getBleed = function(self, t) return self:combatTalentScale(t, 0.3, 1) end,
   on_learn = function(self, t) self:learnTalent(self.T_FLN_BLEED_RESIST, true) end,
   on_unlearn = function(self, t) self:unlearnTalent(self.T_FLN_BLEED_RESIST) end,
   activate = function(self, t)
      local ret = {}
      return ret
   end,
   deactivate = function(self, t, p)
      return true
   end,
   callbackOnMeleeHit = function(self, t, target, dam)
      if not target then return end
      if target:canBe('cut') then
	 target:setEffect(target.EFF_CUT, 5, {power=dam * t.getBleed(self, t), src=self, apply_power=self:combatPhysicalpower()})
      end
   end,
   info = function(self, t)
      return ([[Your melee attacks also cause the target to bleed for %d%% of the damage dealt over five turns.

Each level in Bloodstained talents reduces the amount of damage you take from bleed effects by 2%%]]):
	 format(t.getBleed(self, t)*100)
   end,
}

newTalent{
   name = "Blood Thirst", short_name = "FLN_BLOODSTAINED_THIRST",
   type = {"cursed/bloodstained", 4},
   require = cursed_str_req4,
   points = 5,
   mode = "passive",
   on_learn = function(self, t) self:learnTalent(self.T_FLN_BLEED_RESIST, true) end,
   on_unlearn = function(self, t) self:unlearnTalent(self.T_FLN_BLEED_RESIST) end,
   getLeech = function(self, t) return self:combatTalentScale(t, 3, 8) end,
   callbackOnDealDamage = function(self, t, val, target, dead, death_note)
      local leech = t.getLeech(self, t) * getHateMultiplier(self, 0.3, 1.5, false)
      self:heal(leech * val / 100, self)
   end,
   info = function(self, t)
      return ([[Your hunger for violence and suffering sustains you.  All damage you do heals you for a portion of the damage done, from %d%% (at 0 Hate to) %d%% (at max Hate)

Each level in Bloodstained talents reduces the amount of damage you take from bleed effects by 2%%]]):
	 format(t.getLeech(self, t)*0.3, t.getLeech(self,t)*1.5)
   end,
}