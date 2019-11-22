newTalent{
   name = "Self-Harm", short_name = "FLN_SELFHATE_HARM",
   type = {"cursed/self-hatred", 1},
   require = cursed_wil_req1,
   points = 5,
   no_energy = true,
   hate = -10,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 14, 6)) end,
   getDamage = function(self, t)
      return self.max_life / math.ceil(self:combatTalentLimit(t, 100, 10, 50))
   end,
   getHate = function(self, t) return 2 end,
   action = function(self, t)
      local damage = t.getDamage(self, t)
      self:setEffect(self.EFF_CUT, 5, {src=self, power=damage/5, no_ct_effect=true, unresistable=true})
      return true
   end,
   callbackOnActBase = function(self, t)
      for eff_id, p in pairs(self.tmp) do
	 local e = self.tempeffect_def[eff_id]
	 if e.subtype.bleed and e.status == "detrimental" then
	    hateGain = t.getHate(self, t)
	    self:incHate(hateGain)
	    break
	 end
      end
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      local regen = t.getHate(self, t)
      return ([[Quickly draw a blade across your skin, bleeding yourself for a small portion of your maximum life (%d damage) over the next 5 turns.

At the start of each turn, if you're bleeding, you gain %d hate.

#{italic}#Pain is just about the only thing you can still feel.#{normal}#]]):format(damage, regen)
   end,
}

newTalent{
   name = "Self-Loathing", short_name = "FLN_SELFHATE_LOATHING",
   type = {"cursed/self-hatred", 2},
   require = cursed_wil_req2,
   points = 5,
   mode = "passive",
   critChance = function(self, t) return self:combatTalentScale(t, 3, 10, 0.75) end,
   critPower = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
   passives = function(self, t, p)
      local power = t.critPower(self, t) * getHateMultiplier(self, 0.2, 2.0, false)
      self:talentTemporaryValue(p, "combat_generic_crit", t.critChance(self, t))
      self:talentTemporaryValue(p, "combat_critical_power", power)
   end,
   callbackOnAct = function(self, t)
      self:updateTalentPassives(t.id)
   end,
   info = function(self, t)
      return ([[Increases critical chance by %d%% (at all times) and critical strike power by up to %d%% (based on hate).

#{italic}#Anger makes you strong.  And you're always angry.#{normal}#]]):format(t.critChance(self, t), t.critPower(self, t)*2)
   end,
}

newTalent{
   name = "Self-Destruction", short_name = "FLN_SELFHATE_DESTRUCTION",
   type = {"cursed/self-hatred", 3},
   require = cursed_wil_req3,
   points = 5,
   no_energy = true,
   cooldown = 40,
   mode = "sustained",
   getPrice = function(self, t) return self:combatTalentLimit(t, 5, 15, 7.5) end,
   surge = function(self, t)
      -- Clear status
      local effs = {}
      for eff_id, p in pairs(self.tmp) do
	 local e = self.tempeffect_def[eff_id]
	 if e.status == "detrimental" and e.type ~= "other" then
	    local e2 = self.tmp[eff_id]
	    e2.dur = e2.dur - 1
	    if e2.dur <= 0 then self:removeEffect(eff) end
	 end
      end

      -- Reduce cooldowns
      for tid, _ in pairs(self.talents_cd) do
	 local t = self:getTalentFromId(tid)
	 if t and not t.fixed_cooldown then
	    self.talents_cd[tid] = self.talents_cd[tid] - 1
	 end
      end
   end,
   activate = function(self, t)
      t.surge(self, t)
      return {}
   end,
   deactivate = function(self, t, p)
      return true
   end,
   callbackOnActBase = function(self, t)
      -- Pay life
      local price = t.getPrice(self, t)
      self:takeHit(self.max_life * price / 100, self, {special_death_msg="tore themself apart"})
      t.surge(self, t)
   end,
   
   info = function(self, t)
      local price = t.getPrice(self, t)
      return ([[Call upon your deepest reserves of strength to win no matter the cost.  
Immediately upon activation and every turn while this talent is active, your detrimental effects expire and your talents cool down as if an extra turn had passed.  
This bonus cooldown occurs even if your talents would not normally cool down (such as while stunned).
This strength comes at a cost: you lose %d%% of your maximum life every turn.

#{italic}#If you're lucky, this will take everything you've got.#{normal}#]]):format(price)
   end,
}

newTalent{
   name = "Self-Judgement", short_name = "FLN_SELFHATE_JUDGEMENT",
   type = {"cursed/self-hatred", 4},
   require = cursed_wil_req4,
   points = 5,
   mode = "passive",
   getTime = function(self, t) return self:combatTalentScale(t, 3, 5) end,
   getThreshold = function(self, t) return self:combatTalentLimit(t, 10, 30, 15) end,
   callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
      if dam < 0 then return {dam = dam} end
      if not state then return {dam = dam} end
      if self:attr("invulnerable") then return {dam = dam} end
      
      local psrc = src.__project_source
      if psrc then
	 local kind = util.getval(psrc.getEntityKind)
	 if kind == "projectile" or kind == "trap" or kind == "object" then
	 else
	    return
	 end
      end
      
      local lt = t.getThreshold(self, t)/100
      if dam > self.max_life*lt then
	 local reduce = dam - lt
	 local length = t.getTime(self, t)
	 if src.logCombat then src:logCombat(self, "#CRIMSON##Target# suffers from %s from #Source#, mitigating the blow!#LAST#.", is_attk and "an attack" or "damage") end
	 dam = dam - reduce

	 self:setEffect(self.EFF_FLN_JUDGEMENT_BLEED, length, {power=reduce/length})
	 
	 local d_color = DamageType:get(type).text_color or "#CRIMSON#"
	 game:delayedLogDamage(src, self, 0, ("%s(%d bled out#LAST#%s)#LAST#"):format(d_color, reduce, d_color), false)
	 return {dam = dam}
      end
   end,
   info = function(self, t)
      local time = t.getTime(self, t)
      local threshold = t.getThreshold(self, t)
      return ([[Any direct damage that exceeds %d%% of your maximum life has the excess damage converted to a shallow wound that bleeds over the next %d turns.  This bleed cannot be resisted or removed, but can be reduced by Bloodstained.

#{italic}#You can't just die.  That would be too easy.  You deserve to die slowly.#{normal}#]]):format(threshold, time)
   end,
}