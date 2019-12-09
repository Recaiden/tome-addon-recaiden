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

upgradeDirgeActivate = function(self, t, ret)
   --Fire shield
   if self:knowTalent(self.T_FLN_DIRGE_INTONER) then
      local t2 = self:getTalentFromId(self.T_FLN_DIRGE_INTONER)
      self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.MIND]=t2.getDamageOnMeleeHit(self, t2)})
      self:talentTemporaryValue(ret, "stun_immune", t2.getImmunity(self, t))
      self:talentTemporaryValue(ret, "knockback_immune", t2.getImmunity(self, t))
   end
   
   --Adept Upgrade
   if self:knowTalent(self.T_FLN_DIRGE_ADEPT) then
      local t3 = self:getTalentFromId(self.T_FLN_DIRGE_ADEPT)
      self:talentTemporaryValue(ret, "fear_immune", t3.getImmune(self, t3))
      self:talentTemporaryValue(ret, "confusion_immune", t3.getImmune(self, t3))
   end
   
   --Nihil upgrade
   if self:knowTalent(self.T_FLN_DIRGE_NIHILIST) then
      local t4 = self:getTalentFromId(self.T_FLN_DIRGE_NIHILIST)
      self:talentTemporaryValue(ret, "flat_damage_armor", {all=t4.getArmor(self, t4)})
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
   getRegen = function(self, t) return self:combatTalentScale(t, 2, 6, 0.75) * math.sqrt(self.level) end,
   getResist = function(self, t) return self:combatTalentScale(t, 5, 10) end,
   activate = function(self, t)
      game:playSoundNear(self, "talents/spell_generic2")
      
      local ret = {}
      --Basic effect
      self:talentTemporaryValue(ret, "life_regen", t.getRegen(self, t))
      self:talentTemporaryValue(ret, "resists", {all = t.getResist(self, t)})

      upgradeDirgeActivate(self, t, ret)
      
      return ret
   end,
   deactivate = function(self, t, p)
      --self:removeParticles(p.particle)
      
      --Adept Upgrade
      if self:knowTalent(self.T_FLN_DIRGE_ADEPT) then
	 clearDirges(self)
	 local t3 = self:getTalentFromId(self.T_FLN_DIRGE_ADEPT)
	 self:setEffect(self.EFF_FLN_DIRGE_LINGER_FAMINE, t3.getDuration(self, t3), {src=self, heal=t.getRegen(self, t), resist=t.getResist(self, t)})
      end
      
      return true
   end,
   info = function(self, t)
      return ([[Sing a song of wasting and desolation which sustains you in hard times.

This dirge increases your health regeneration by %d and your resistance to damage by %d%%.  The regeneration will increase with your level.]]):format(t.getRegen(self, t), t.getResist(self, t))
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
   --getHeal = function(self, t) return self:combatTalentScale(t, 5, 30) end,
   callbackOnCrit = function(self, t)
      if self.turn_procs.fallen_conquest_on_crit then return end
      self.turn_procs.fallen_conquest_on_crit = true
      
      self.energy.value = self.energy.value + 100
      if core.shader.active(4) then
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
      end
   end,
   callbackOnKill = function(self, t)
      if self.turn_procs.fallen_conquest_on_kill then return end
      self.turn_procs.fallen_conquest_on_kill = true
      
      self.energy.value = self.energy.value + 500
      if core.shader.active(4) then
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
	 self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
      end
   end,
   activate = function(self, t)
      game:playSoundNear(self, "talents/spell_generic2")
      
      local ret = {}
      --Basic effect is in callbacks
      
      upgradeDirgeActivate(self, t, ret)
      
      return ret
   end,
   deactivate = function(self, t, p)
      --self:removeParticles(p.particle)
      
      --Adept Upgrade
      if self:knowTalent(self.T_FLN_DIRGE_ADEPT) then
	 clearDirges(self)
	 local t3 = self:getTalentFromId(self.T_FLN_DIRGE_ADEPT)
	 self:setEffect(self.EFF_FLN_DIRGE_LINGER_CONQUEST, t3.getDuration(self, t3), {src=self})
      end
      
      return true
   end,
   info = function(self, t)
      return ([[Sing a song of violence and victory (mostly violence) and sustain yourself through cruelty.
Each time you deal a critical strike you gain 10%% of a turn (only once per turn).
Each time you kill a creature you gain 50%% of a turn (only once per turn).
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
   callbackOnTemporaryEffectAdd = function(self, t, eff_id, e_def, eff)      
      if e_def.status == "detrimental" and e_def.type ~= "other" then
         self:setEffect(self.EFF_DAMAGE_SHIELD, eff.dur, {color={0xff/255, 0x3b/255, 0x3f/255}, power=self:spellCrit(t.getShield(self, t))})
      end
   end,
   activate = function(self, t)
      game:playSoundNear(self, "talents/spell_generic2")
      
      local ret = {}
      --Basic effect is in callbacks
      
      upgradeDirgeActivate(self, t, ret)
      
      return ret
   end,
   deactivate = function(self, t, p)
      --self:removeParticles(p.particle)
      
      --Adept Upgrade
      if self:knowTalent(self.T_FLN_DIRGE_ADEPT) then
	 clearDirges(self)
	 local t3 = self:getTalentFromId(self.T_FLN_DIRGE_ADEPT)
	 self:setEffect(self.EFF_FLN_DIRGE_LINGER_PESTILENCE, t3.getDuration(self, t3), {src=self, heal=t.getShield(self, t)})
      end
      
      return true
   end,
   info = function(self, t)
      return ([[Sing a song of decay and defiance and sustain yourself through spite.
Each time you suffer a detrimental effect, you gain a shield with strength %d, that lasts as long as the effect would.]]):format(t.getShield(self, t))
   end,
}


newTalent{
   name = "Dirge Acolyte", short_name = "FLN_DIRGE_ACOLYTE",
   type = {"celestial/dirge", 1},
   require = divi_req1,
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

   callbackOnMove = function(self, t, moved, force, ox, oy, x, y)
      if moved and not self:knowTalentType("cursed/cursed-aura") and self.chooseCursedAuraTree then
         if self.player then
            -- function placed in defiling touch where cursing logic exists
            local t = self:getTalentFromId(self.T_DEFILING_TOUCH)
            if t.chooseCursedAuraTree(self, t) then
               self.chooseCursedAuraTree = nil
            end
         end
      end   
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
   require = divi_req2,
   points = 5,
   mode = "passive",
   getDamageOnMeleeHit = function(self, t) return self:combatTalentMindDamage(t, 5, 50) * (1 + (1 + self.level)/40) end,
   getImmunity = function(self, t) return math.min(1, self:combatTalentScale(t, 0.05, 0.45, 0.5)) end,
   info = function(self, t)
      local damage = t.getDamageOnMeleeHit(self, t)
      local nostun = t.getImmunity(self, t)
      return ([[Your dirges carry the pain within you, which threatens to swallow those who come too close.  Anyone who hits you in melee suffers %d mind damage.
You, on the other hand, are steadied by the song.  Your dirges increase your resistance to stun and knockback by %d%%.

Mindpower: increases damage.
Level: increases damage.]]):format(damage, nostun)
   end,
}

newTalent{
   name = "Dirge Adept", short_name = "FLN_DIRGE_ADEPT",
   type = {"celestial/dirge", 3},
   require = divi_req3,
   points = 5,
   mode = "passive",
   getDuration = function(self, t) return self:getTalentLevel(t) end,
   getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.5) end,
   info = function(self, t)
      return ([[Your dirges echo mournfully through the air.  When you end a dirge, you continue to gain its acolyte-level effects for %d turns.  You can only benefit from one such lingering dirge at a time.

Furthermore, you are given focus by the song.  Your dirges increase your resistance to confusion and fear by %d%%.]]):format(t.getDuration(self, t), t.getImmune(self, t)*100)
   end,
}

newTalent{
   name = "Dirge Nihilist", short_name = "FLN_DIRGE_NIHILIST",
   type = {"celestial/dirge", 4},
   require = divi_req4,
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
