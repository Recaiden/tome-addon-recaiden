clearDirges = function(self)
   if self:hasEffect(self.EFF_FLN_DIRGE_LINGER_FAMINE) then
      self:removeEffect(self.EFF_FLN_DIRGE_LINGER_FAMINE)
   end
   if self:hasEffect(self.EFF_FLN_DIRGE_LINGER_CONQUEST) then
      self:removeEffect(self.EFF_FLN_DIRGE_LINGER_CONQUEST)
   end
   if self:hasEffect(self.EFF_FLN_DIRGE_LINGER_PESTILENCE) then
      self:removeEffect(self.EFF_FLN_DIRGE_LINGER_PESTILENCE)
   end
end

newTalent{
   name = "Dirge of Famine", short_name = "FLN_DIRGE_FAMINE",
   type = {"celestial/dirges", 1},
   require = cursed_wil_req1,
   points = 5,
   no_energy = true,
   cooldown = 12,
   sustain_slots = 'fallen_celestial_dirge',
   mode = "sustained",
   getRegen = function(self, t) return self:combatTalentScale(t, 2, 15, 0.75) end,
   getResist = function(self, t) return self:combatTalentScale(t, 5, 10) end,
   activate = function(self, t)
      game:playSoundNear(self, "talents/spell_generic2")
      
      local ret = {}
      --Basic effect
      self:talentTemporaryValue(ret, "life_regen", t.getRegen(self, t))
      self:talentTemporaryValue(ret, "resists", {all = t.getResist(self, t)})

      --Fire shield
      if self:knowTalent(self.T_FLN_DIRGE_INTONER) then
	 local t2 = self:getTalentFromId(self.T_FLN_DIRGE_INTONER)
	 self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.MIND]=t2.getDamageOnMeleeHit(self, t2)})
	 self:talentTemporaryValue(ret, "stun_immune", t2.getImmunity(self, t))
	 self:talentTemporaryValue(ret, "knockback_immune", t2.getImmunity(self, t))
      end

      --Nihil upgrade
      if self:knowTalent(self.T_FLN_DIRGE_NIHILIST) then
	 local t4 = self:getTalentFromId(self.T_FLN_DIRGE_NIHILIST)
	 self:talentTemporaryValue(ret, "flat_damage_armor", {all=t4.getArmor(self, t4)})
      end
      
      return ret
   end,
   deactivate = function(self, t, p)
      --self:removeParticles(p.particle)
      
      --Adept Upgrade
      if self:knowTalent(self.T_FLN_DIRGE_ADEPT) then
	 clearDirges(self)
	 local t3 = self:getTalentFromId(self.T_FLN_DIRGE_ADEPT)
	 self:setEffect(self.EFF_FLN_DIRGE_LINGER_FAMINE, t3.getDuration(self, t3), {src=self, heal=t.getRegen(self, t)})
      end
      
      return true
   end,
   info = function(self, t)
      return ([[Sing a song of wasting and desolation which sustains you in hard times.

This dirge increases your health regeneration by %d and your resistance to damage by %d%%]]):format(t.getRegen(self, t), t.getResist(self, t))
   end,
}

newTalent{
   name = "Dirge of Conquest", short_name = "FLN_DIRGE_CONQUEST",
   type = {"celestial/dirges", 1},
   require = cursed_wil_req1,
   points = 5,
   no_energy = true,
   cooldown = 12,
   sustain_slots = 'fallen_celestial_dirge',
   mode = "sustained",
   getHeal = function(self, t) return self:combatTalentScale(t, 5, 30) end,
   callbackOnCrit = function(self, t)
      if self.turn_procs.fallen_conquest_on_crit then return end
      self.turn_procs.fallen_conquest_on_crit = true
      
      self:heal(self:mindCrit(t.getHeal(self, t)), self)
      if core.shader.active(4) then
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
      end
   end,
   callbackOnKill = function(self, t)
      if self.turn_procs.fallen_conquest_on_kill then return end
      self.turn_procs.fallen_conquest_on_kill = true
      
      self:heal(self:mindCrit(t.getHeal(self, t)), self)
      if core.shader.active(4) then
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
      end
   end,
   activate = function(self, t)
      game:playSoundNear(self, "talents/spell_generic2")
      
      local ret = {}
      --Basic effect is in callbacks
      
      --Fire shield
      if self:knowTalent(self.T_FLN_DIRGE_INTONER) then
	 local t2 = self:getTalentFromId(self.T_FLN_DIRGE_INTONER)
	 self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.MIND]=t2.getDamageOnMeleeHit(self, t2)})
	 self:talentTemporaryValue(ret, "stun_immune", t2.getImmunity(self, t))
	 self:talentTemporaryValue(ret, "knockback_immune", t2.getImmunity(self, t))
      end

      --Nihil upgrade
      if self:knowTalent(self.T_FLN_DIRGE_NIHILIST) then
	 local t4 = self:getTalentFromId(self.T_FLN_DIRGE_NIHILIST)
	 self:talentTemporaryValue(ret, "flat_damage_armor", {all=t4.getArmor(self, t4)})
      end
      
      return ret
   end,
   deactivate = function(self, t, p)
      --self:removeParticles(p.particle)
      
      --Adept Upgrade
      if self:knowTalent(self.T_FLN_DIRGE_ADEPT) then
	 clearDirges(self)
	 local t3 = self:getTalentFromId(self.T_FLN_DIRGE_ADEPT)
	 self:setEffect(self.EFF_FLN_DIRGE_LINGER_CONQUEST, t3.getDuration(self, t3), {src=self, heal=t.getRegen(self, t)})
      end
      
      return true
   end,
   info = function(self, t)
      local heal = t.getHeal(self, t)
      return ([[Sing a song of violence and victory (mostly violence) and sustain yourself through cruelty.
Each time you deal a critical strike you gain %d life (only once per turn).
Each time you kill a creature you gain %d life (only once per turn).
		
This healing can critically strike based on your mental critical rate.
]]):format(heal, heal)
   end,
}

newTalent{
   name = "Dirge of Pestilence", short_name = "FLN_DIRGE_PESTILENCE",
   type = {"celestial/dirges", 1},
   require = cursed_wil_req1,
   points = 5,
   no_energy = true,
   cooldown = 12,
   sustain_slots = 'fallen_celestial_dirge',
   mode = "sustained",
   getShield = function(self, t) return self:combatTalentScale(t, 3, 7.5, 0.75) end,
   --TODO callback
   activate = function(self, t)
      game:playSoundNear(self, "talents/spell_generic2")
      
      local ret = {}
      --Basic effect is in callbacks
      
      --Fire shield
      if self:knowTalent(self.T_FLN_DIRGE_INTONER) then
	 local t2 = self:getTalentFromId(self.T_FLN_DIRGE_INTONER)
	 self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.MIND]=t2.getDamageOnMeleeHit(self, t2)})
	 self:talentTemporaryValue(ret, "stun_immune", t2.getImmunity(self, t))
	 self:talentTemporaryValue(ret, "knockback_immune", t2.getImmunity(self, t))
      end

      --Nihil upgrade
      if self:knowTalent(self.T_FLN_DIRGE_NIHILIST) then
	 local t4 = self:getTalentFromId(self.T_FLN_DIRGE_NIHILIST)
	 self:talentTemporaryValue(ret, "flat_damage_armor", {all=t4.getArmor(self, t4)})
      end
      
      return ret
   end,
   deactivate = function(self, t, p)
      --self:removeParticles(p.particle)
      
      --Adept Upgrade
      if self:knowTalent(self.T_FLN_DIRGE_ADEPT) then
	 clearDirges(self)
	 local t3 = self:getTalentFromId(self.T_FLN_DIRGE_ADEPT)
	 self:setEffect(self.EFF_FLN_DIRGE_LINGER_PESTILENCE, t3.getDuration(self, t3), {src=self, heal=t.getRegen(self, t)})
      end
      
      return true
   end,
   info = function(self, t)
      return ([[In-progress]]):
	 format()
   end,
}


newTalent{
   name = "Dirge Acolyte", short_name = "FLN_DIRGE_ACOLYTE",
   type = {"celestial/dirge", 1},
   require = cursed_wil_req1,
   points = 5,
   mode = "passive",
   no_unlearn_last = true,
   on_learn = function(self, t)
      self:learnTalent(self.T_FLN_DIRGE_FAMINE, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_FLN_DIRGE_CONQUEST, true, nil, {no_unlearn=true})
      self:learnTalent(self.T_FLN_DIRGE_PESTILENCE, true, nil, {no_unlearn=true})
   end,
   on_unlearn = function(self, t)
      self:unlearnTalent(self.T_FLN_DIRGE_FAMINE)
      self:unlearnTalent(self.T_FLN_DIRGE_CONQUEST)
      self:unlearnTalent(self.T_FLN_DIRGE_PESTILENCE)
   end,
   info = function(self, t)
      local ret = ""
      local old1 = self.talents[self.T_FLN_DIRGE_FAMINE]
      local old2 = self.talents[self.T_FLN_DIRGE_CONQUEST]
      local old3 = self.talents[self.T_FLN_DIRGE_PESTILENCE]
      self.talents[self.T_FLN_DIRGE_FAMINE] = (self.talents[t.id] or 0)
      self.talents[self.T_FLN_DIRGE_CONQUEST] = (self.talents[t.id] or 0)
      self.talents[self.T_FLN_DIRGE_PESTILENCE] = (self.talents[t.id] or 0)
      pcall(function()
	    local t1 = self:getTalentFromId(self.T_FLN_DIRGE_FAMINE)
	    local t2 = self:getTalentFromId(self.T_FLN_DIRGE_CONQUEST)
	    local t3 = self:getTalentFromId(self.T_FLN_DIRGE_PESTILENCE)
	    ret = ([[Even now, something compels you to sing.
			Dirge of Famine: Increases health regen by %d.
			Dirge of Conquest: Heals you for %d on critical or kill.
			Dirge of Pestilence: Shields you for %d when you suffer a detrimental effect.
			You may only have one Dirge active at a time.]]):
	       format(t1.getRegen(self, t1), t2.getHeal(self, t2), t3.getShield(self, t3))
      end)
      self.talents[self.T_FLN_DIRGE_FAMINE] = old1
      self.talents[self.T_FLN_DIRGE_CONQUEST] = old2
      self.talents[self.T_FLN_DIRGE_PESTILENCE] = old3
      return ret
   end,
}

newTalent{
   name = "Dirge Intoner", short_name = "FLN_DIRGE_INTONER",
   type = {"celestial/dirge", 2},
   require = cursed_wil_req2,
   points = 5,
   no_energy = true,
   cooldown = 15,
   getDamageOnMeleeHit = function(self, t) return self:combatTalentMindDamage(t, 5, 50) * (1 + (1 + self.level)/40) end,
   getImmunity = function(self, t) return math.min(1, self:combatTalentScale(t, 0.05, 0.45, 0.5)) end,
   action = function(self, t)
      return true
   end,
   info = function(self, t)
      local damage = t.getDamageOnMeleeHit(self, t)
      local nostun = t.getImmunity(self, t)
      return ([[Your dirges carry the pain within you, which threatens to swallow those who come to close.  Anyone who hits you in melee suffers %d mind damage.
You, on the other hand, are steadied.  Your dirges increase your resistance to stun and knockback by %d%%.

Mindpower: increases damage.
Level: increases damage.]]):format(damage, nostun)
   end,
}

newTalent{
   name = "Dirge Adept", short_name = "FLN_DIRGE_ADEPT",
   type = {"celestial/dirge", 3},
   require = cursed_wil_req3,
   points = 5,
   mode = "passive",
   info = function(self, t)
      return ([[Your dirges echo mournfully through the air.  When you end a dirge, you continue to gain its acolyte-level effects for %d turns.  You can only benefit from one such lingering dirge at a time.]]):format( self:getTalentLevel(t))
   end,
}

newTalent{
   name = "Dirge Nihilist", short_name = "FLN_DIRGE_NIHILIST",
   type = {"celestial/dirge", 4},
   require = cursed_wil_req4,
   points = 5,
   mode = "passive",
   getArmor = function(self, t) return self:combatTalentSpellDamage(t, 2, 40) end,
   action = function(self, t)
      return true
   end,
   info = function(self, t)
      return ([[Your dirges deaden you to the outside world, reducing all incoming damage by %d.

Spellpower: improves the damage reduction]]):format(t.getArmor(self, t))
   end,
}
