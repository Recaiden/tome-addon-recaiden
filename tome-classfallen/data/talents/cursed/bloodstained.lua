newTalent{
   name = "Blood Clot", short_name = "FLN_BLEED_RESIST",
   type = {"cursed/other", 1},
   points = 1,
   mode = "passive",
   callbackOnTemporaryEffectAdd = function(self, t, eff_id, e_def, eff)
      if e_def.subtype.bleed and e_def.type ~= "other" then
	 local diminishment = math.min((
	       self:getTalentLevelRaw(self.T_FLN_BLOODSTAINED_RUSH)
		  + self:getTalentLevelRaw(self.T_FLN_BLOODSTAINED_FURY)
		  + self:getTalentLevelRaw(self.T_FLN_BLOODSTAINED_BATH)
		  + self:getTalentLevelRaw(self.T_FLN_BLOODSTAINED_THIRST))*2, 90)
         if eff.dam then
            eff.dam = eff.dam * (100-diminishment) / 100
         elseif eff.power then
            eff.power = eff.power * (100-diminishment) / 100
         end
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
   positive = -5,
   hate = 4,
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
   on_pre_use = function(self, t)
      if self:attr("never_move") then return false end
      return true
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end

      -- skip teleport if already adjacent
      if core.fov.distance(self.x, self.y, target.x, target.y) ~= 1 then

         --check if landing space is avilable
         fx, fy = util.findFreeGrid(x, y, 1, false, {[Map.ACTOR]=true})
         if not fx or not fy then game.logSeen(self, "Nowhere to appear!") return false end
         
         if not self:teleportRandom(x, y, 0) then game.logSeen(self, "The bloodrush fizzles!") return true end
         game:playSoundNear(self, "talents/teleport")
      end
      
      -- Attack
      if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
	 target:setEffect(target.EFF_FLN_RUSH_MARK, 6, {src=self})
	 local hit = self:attackTarget(target, nil, 1, true)
         if hit then
            if target.dead then
               game:onTickEnd(function() 
                                 self:alterTalentCoolingdown(t.id, -12)
                              end)
            end
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
   fixed_cooldown = true,
   hate = 10,
   positive = -10,
   tactical = { ATTACK = 2 },
   range = 1,
   requires_target = true,
   is_melee = true,
   getBleedMult = function(self, t) return self:combatTalentScale(t, 1.4, 2.8)-1 end,
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
   getBleed = function(self, t) return self:combatTalentScale(t, 0.25, 0.95) end,
   on_learn = function(self, t) self:learnTalent(self.T_FLN_BLEED_RESIST, true) end,
   on_unlearn = function(self, t) self:unlearnTalent(self.T_FLN_BLEED_RESIST) end,
   activate = function(self, t)
      local ret = {}
      return ret
   end,
   deactivate = function(self, t, p)
      return true
   end,
   callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam) 
      if not target then return end
      if not hitted then return end
      if target:canBe('cut') then
	 target:setEffect(target.EFF_CUT, 5, {power=dam * t.getBleed(self, t) / 5, src=self})
      end
   end,
   info = function(self, t)
      return ([[Your melee attacks also cause the target to bleed (#SLATE#Physical power vs. Physical#LAST#) for %d%% of the damage dealt over five turns.

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
      local cap = self.max_life / 6
      local used = self.turn_procs.rek_fallen_thirst_heal or 0
      if used > 0 then cap = cap - used end
      if used < cap then
         local leech = t.getLeech(self, t) * getHateMultiplier(self, 0.3, 1.5, false) * val / 100
         if leech > cap then leech = cap end
         self:heal(leech, self)
         self.turn_procs.rek_fallen_thirst_heal = leech + used
      end
   end,
   info = function(self, t)
      return ([[Your hunger for violence and suffering sustains you.  All damage you do heals you for a portion of the damage done, from %d%% (at 0 Hate to) %d%% (at max Hate).  You can recover no more than 1/6 of your max life each turn this way.

Each level in Bloodstained talents reduces the amount of damage you take from bleed effects by 2%%]]):
	 format(t.getLeech(self, t)*0.3, t.getLeech(self,t)*1.5)
   end,
}
