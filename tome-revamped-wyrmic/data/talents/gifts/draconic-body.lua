newTalent{
   name = "Racing Wings", short_name = "REK_WYRMIC_BODY_WINGS",
   type = {"wild-gift/draconic-body", 1},
   require = gifts_req1,
   points = 5,
   random_ego = "attack",
   equilibrium = 10,
   cooldown = 8,
   range = 0,
   tactical = { CLOSEIN = 2, ESCAPE = 2 },
   no_energy = true,
   getPassiveSpeed = function(self, t) return self:combatTalentScale(t, 0.08, 0.4, 0.7) end,
   getSpeed = function(self, t) return self:combatTalentScale(t, 470, 750, 0.75) end,
   getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 1.1, 3.1)) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "movement_speed", t.getPassiveSpeed(self, t))
   end,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   on_pre_use = function(self, t)
      if self:attr("never_move") then return false end
      return true
   end,

   callbackOnTalentPost = function(self, t, ab)
      if ab.id ~= self.T_REK_WYRMIC_BODY_WINGS then
	 if self:hasEffect(self.EFF_REK_LIGHTNING_SPEED) then
	    self:removeEffect(self.EFF_REK_LIGHTNING_SPEED)
	 end
      end
   end,

   action = function(self, t)
      self:setEffect(self.EFF_REK_LIGHTNING_SPEED, self:mindCrit(t.getDuration(self, t)), {power=t.getSpeed(self, t)})
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 --self:addParticles(Particles.new("shader_wings", 1, {life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
      end
      return true
   end,
   
   info = function(self, t)
      local speed = t.getPassiveSpeed(self, t)
      return ([[Take to the skies with your wings, moving %d%% faster for %d game turns, during which you will have an additional 30%% physical damage resistance.
		Any actions other than moving will stop this effect.
		Note: since you will be moving very fast, game turns will pass very slowly.
		
Passively increases Movement Speed by %d%%
]]):format(t.getSpeed(self, t), t.getDuration(self, t), speed*100)
   end,
}


-- Dragon's Heart, gives healmod, more the lower your health is, maybe also small health Regen

newTalent{
   name = "Drakeheart", short_name = "REK_WYRMIC_BODY_HEART",
   type = {"wild-gift/draconic-body", 2},
   require = gifts_req2,
   mode = "passive",
   points = 5,
   getHealing = function(self, t) return self:combatTalentMindDamage(t, 30, 75) end,

   callbackOnActBase = function(self, t)
      self:updateTalentPassives(t.id)
   end,

   passives = function(self, t, p)
      local missing_percent = (self.max_life - math.max(0, self.life)) / self.max_life
      self:talentTemporaryValue(p, "healing_factor", t.getHealing(self, t ) * ((missing_percent / 2) + 0.5) / 100)
   end,

   info = function(self, t)
      return ([[Your body is as strong and resilient as the great wyrms.  Your healing factor is increased by %d%% (at 100%% health) to %d%% (at 0 health), growing stronger the lower your health is as you desperately cling to life.

Mindpower: improves healing factor.]]):format(t.getHealing(self, t) / 2, t.getHealing(self, t))
   end,
}

newTalent{
   name = "Dragon's Scorn", short_name = "REK_WYRMIC_BODY_CLEANSE",
   type = {"wild-gift/draconic-body", 3},
   require = gifts_req3,
   points = 5,
   equilibrium = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 15)) end,
   range = 1,
   no_energy = true,
   getCleanseDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6.5)) end,
   getCleanseNb = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 1, 3)) end,
   action = function(self, t)
      local effs = {}
      local max_nb = t.getCleanseNb(self, t)
      local dur = t.getCleanseDuration(self, t)
      for eff_id, p in pairs(self.tmp) do
	 local e = self.tempeffect_def[eff_id]
	 if e.status == "detrimental" and e.type ~= "other" and not e.subtype["cross tier"] then
	    effs[#effs+1] = eff_id
	 end
      end
      
      for i = 1, t.getCleanseNb(self, t) do
	 if #effs == 0 then break end
	 local eff = rng.tableRemove(effs)
	 
	 local e2 = self.tmp[eff]
	 local odur = e2.dur
	 e2.dur = e2.dur - t.getCleanseDuration(self, t)
	 if e2.dur <= 0 then self:removeEffect(eff) end
      end

      game:playSoundNear(self, "talents/devouringflame")

      return true
   end,
   info = function(self, t)
      local duration = t.getCleanseDuration(self, t)
      local number = t.getCleanseNb(self, t)
      return ([[Your mind is as strong and resilient as the great wyrms.  You reduce the duration of up to %d detrimental effects by %d turns.
]]):format(number, duration)
   end,
}

-- Lashing Tail, tries to knock enemies Off-balance with each hit.
newTalent{
   name = "Lashing Tail", short_name = "REK_WYRMIC_BODY_TAIL",
   type = {"wild-gift/draconic-body", 4},
   require = gifts_req4,
   mode = "sustained",
   points = 5,
   cooldown = 10,
   sustain_equilibrium = 8,
   tactical = { ATTACK = { COLD = 1 }, DEFEND = 2 },
   getPowerBonus = function(self, t) return self:combatTalentMindDamage(t, 3, 80) end,

   callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
      if hitted then
	 if target:checkHit(self:combatPhysicalpower(1, weapon, t.getPowerBonus(self, t )), target:combatPhysicalResist(), 0, 95, 15) then
	    target:crossTierEffect(
	       target.EFF_OFFBALANCE,
	       self:combatPhysicalpower(1, weapon, t.getPowerBonus(self, t )))
	 end
      end
   end,
   
   activate = function(self, t)
      return {}
   end,
   deactivate = function(self, t, p)
      return true
   end,
   info = function(self, t)
      return ([[A dragon's twisting tail helps them manipulate the flow of a fight.  Whenever you deal damage in melee, you attempt to throw an enemy Off-Balance, using %d additional physical power.

Mindpower: improves the power bonus.]]):format(t.getPowerBonus(self, t))
   end,
}
