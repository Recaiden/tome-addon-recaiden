newTalent{
   name = "Devour", short_name = "REK_WYRMIC_COMBAT_BITE",
   image = "talents/swallow.png",
   type = {"wild-gift/draconic-combat", 1},
   require = gifts_req1,
   points = 5,
   --equilibrium = 4,
   --equilibrium = 0,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 4, 10, 7)) end,
   range = 1,
   no_message = true,
   tactical = { ATTACK = { weapon = 1 }, EQUILIBRIUM = 0.5},
   requires_target = true,
   no_npc_use = true,
   is_melee = true,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   maxSwallow = function(self, t, target) return -- Limit < 50%
	 self:combatLimit(self:getTalentLevel(t)*(self.size_category or 3)/(target.size_category or 3), 50, 13, 1, 25, 5)
   end,
   getPassiveCrit = function(self, t) return self:combatTalentScale(t, 2, 10, 0.5) end,
   on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
   on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "combat_physcrit", t.getPassiveCrit(self, t))
      self:talentTemporaryValue(p, "combat_mindcrit", t.getPassiveCrit(self, t))
      self:talentTemporaryValue(p, "combat_spellcrit", t.getPassiveCrit(self, t))
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      
      self:logCombat(target, "#Source# tries to swallow #Target#!")
      local hit = self:attackTarget(target, DamageType.NATURE, self:combatTalentWeaponDamage(t, 1.6, 2.5), true)
      if not hit then return true end
      
      if (target.life * 100 / target.max_life > t.maxSwallow(self, t, target)) and not target.dead then
	 return true
      end
      
      if (target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 15) or target.dead) and (target:canBe("instakill") or target.life * 100 / target.max_life <= 5) then
	 if not target.dead then target:die(self) end
	 world:gainAchievement("EAT_BOSSES", self, target)
	 self:incEquilibrium(-target.level - 5)
	 self:attr("allow_on_heal", 1)
	 self:heal(target.level * 2 + 5, target)
	 if core.shader.active(4) then
	    self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true ,size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
	    self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
	 end
	 self:attr("allow_on_heal", -1)
      else
	 game.logSeen(target, "%s resists being eaten!", target.name:capitalize())
      end
      return true
   end,
   info = function(self, t)
      return ([[Attack the target for %d%% Nature weapon damage.
		If the attack brings your target below %d%% life or kills it, you can try to swallow it, killing it automatically and regaining life and equilibrium depending on its level.
		The chance to swallow depends on your talent level and the relative size of the target.

Talent Level: Passively raises critical rate (by %d%%).
]]):
	 format(100 * self:combatTalentWeaponDamage(t, 1.6, 2.5), t.maxSwallow(self, t, self), t.getPassiveCrit(self, t))
   end,
}

newTalent{
   name = "Claw Sweep", short_name = "REK_WYRMIC_COMBAT_CLAW",
   image = "talents/ice_claw.png",
   type = {"wild-gift/draconic-combat", 2},
   require = gifts_req2,
   points = 5,
   random_ego = "attack",
   equilibrium = 3,
   cooldown = 7,
   range = 0,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
   direct_hit = true,
   requires_target = true,
   tactical = { ATTACK = { weapon = 1 } },
   is_melee = true,
   on_learn = function(self, t)
      self.combat_physresist = self.combat_physresist + 4
      self.combat_spellresist = self.combat_spellresist + 4
      self.combat_mentalresist = self.combat_mentalresist + 4
   end,
   on_unlearn = function(self, t)
      self.combat_physresist = self.combat_physresist - 4
      self.combat_spellresist = self.combat_spellresist - 4
      self.combat_mentalresist = self.combat_mentalresist - 4
   end,
   damagemult = function(self, t) return self:combatTalentScale(t, 1.6, 2.3) end,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local damtype = DamageType.PHYSICAL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 damtype = source.status
      end 
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, function(px, py, tg, self)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target ~= self then
			 local hit = self:attackTarget(target, damtype, self:combatTalentWeaponDamage(t, 1.6, 2.3), true)

			 -- Slash armor if in physical aspect
			 if hit and self:knowTalent(self.T_REK_WYRMIC_SAND) and aspectIsActive(self, "Physical") then
			    target:setEffect(target.EFF_SUNDER_ARMOUR, 3, {power=self:callTalent(self.T_REK_WYRMIC_SAND, "getPenetration"), apply_power=self:combatPhysicalpower()})
			 end
		      end
      end)
      game:playSoundNear(self, "talents/breath")
      return true
   end,
   info = function(self, t)
      local name = "Physical"
      local nameStatus = "Blinded"
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 name = source.name
	 nameStatus = source.nameStatus
      end
      return ([[You call upon the mighty claws of the drake and rake a wave of energy in front of you, doing %d%% weapon damage as %s damage in a cone of %d, with a chance that the target will be %s.
		
Raw Talent Level: Passively raises all saves by 4
]]):format(100 * t.damagemult(self, t), name, self:getTalentRadius(t), nameStatus)
   end,
}

newTalent{
   name = "Bellowing Roar", short_name = "REK_WYRMIC_COMBAT_ROAR",
   image = "talents/bellowing_roar.png",
   type = {"wild-gift/draconic-combat", 3},
   require = gifts_req2,
   points = 5,
   random_ego = "attack",
   message = "@Source@ roars!",
   equilibrium = 8,
   cooldown = 20,
   range = 0,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
   getConfusePower = function(self, t) return 20 + 6 * self:getTalentLevel(t) end,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
   end,
   tactical = { DEFEND = 1, DISABLE = { confusion = 3 } },
   requires_target = true,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      self:project(tg, self.x, self.y, DamageType.PHYSICAL, self:mindCrit(self:combatTalentStatDamage(t, "str", 30, 380)))
      self:project(tg, self.x, self.y, DamageType.CONFUSION, {
		      dur=3,
		      dam=t.getConfusePower(self, t),
		      power_check=function() return self:combatPhysicalpower() end,
		      resist_check=self.combatPhysicalResist,
      })
      game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0, gM=0, bm=0.1, bM=0.2, am=0.4, aM=0.6})

      -- Cleanse if you know Fire Aspect
      if self:knowTalent(self.T_REK_WYRMIC_FIRE) and aspectIsActive(self, "Fire") then
	 local effs = {}
	 local max_nb = self:callTalent(self.T_REK_WYRMIC_FIRE, "getCleanseNb")
	 local dur = self:callTalent(self.T_REK_WYRMIC_FIRE, "getCleanseDuration")
	 for eff_id, p in pairs(self.tmp) do
	    local e = self.tempeffect_def[eff_id]
	    if e.status == "detrimental" and e.type ~= "other" and not e.subtype["cross tier"] then
	       effs[#effs+1] = eff_id
	    end
	 end
	 
	 for i = 1, t.getNb(self, t) do
	    if #effs == 0 then break end
	    local eff = rng.tableRemove(effs)
	    
	    local e2 = self.tmp[eff]
	    local odur = e2.dur
	    e2.dur = e2.dur - t.getDuration(self, t)
	    if e2.dur <= 0 then self:removeEffect(eff) end
	 end
      end
      
      return true
   end,
   info = function(self, t)
      local radius = self:getTalentRadius(t)
      local power = t.getConfusePower(self, t)
      return ([[You let out a powerful roar that sends your foes into utter confusion (%d power) for 3 turns in a radius of %d.
		The sound wave is so strong, your foes also take %0.2f physical damage.
		The damage improves with your Strength.]]):format( power, radius, self:combatTalentStatDamage(t, "str", 30, 380))
   end,
}


newTalent{
   name = "Overwhelm", short_name = "REK_WYRMIC_COMBAT_DISSOLVE",
   image = "talents/dissolve.png",
   type = {"wild-gift/draconic-combat", 4},
   require = gifts_req3,
   points = 5,
   random_ego = "attack",
   equilibrium = 10,
   cooldown = 12,
   range = 1,
   is_melee = true,
   tactical = { ATTACK = { weapon = 2 } },
   requires_target = true,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end

      local actives = self.rek_wyrmic_dragon_type or {{
	    name="Physical",
	    damtype=DamageType.PHYSICAL,
	    nameStatus="Blinded",
	    status=DamageType.REK_WYRMIC_SAND
						     }}
      local s = rng.table(actives)
      local numAttacks = 4
      local statusAttacks = math.floor(self:getTalentLevel(t)/2)

      while numAttacks > 0 do
	 self:attackTarget(target, (statusAttacks > 0) and s.status or s.damType, self:combatTalentWeaponDamage(t, 0.1, 0.60), true)
	 numAttacks = numAttacks - 1
	 statusAttacks = statusAttacks - 1
	 local s = rng.table(actives)
      end
      return true
   end,
   info = function(self, t)
      return ([[You strike the enemy with a rain of four fast blows of a random active element. Every blow does %d%% damage.
		Every two talent levels, one of your strikes also attempts to inflict the associated status effect of its element.
]]):format(100 * self:combatTalentWeaponDamage(t, 0.1, 0.6))
   end,
}
