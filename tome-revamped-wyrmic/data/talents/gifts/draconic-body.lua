newTalent{
   name = "Wing Buffet", short_name = "REK_WYRMIC_BODY_WINGS",
   image= "talents/wing_buffet.png",
   type = {"wild-gift/draconic-body", 1},
   require = gifts_req1,
   points = 5,
   random_ego = "attack",
   equilibrium = 5,
   cooldown = 8,
   range = 0,
   getPassiveSpeed = function(self, t) return self:combatTalentScale(t, 0.08, 0.4, 0.7) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "movement_speed", t.getPassiveSpeed(self, t))
   end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.6) end,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
   direct_hit = true,
   tactical = { DEFEND = { knockback = 2 }, ESCAPE = { knockback = 2 } },
   requires_target = true,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, function(px, py, tg, self)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target ~= self then
			 local hit = self:attackTarget(target, DamageType.PHYSKNOCKBACK, self:combatTalentWeaponDamage(t, 1.1, 1.6), true)
		      end
      end)
      game:playSoundNear(self, "talents/breath")
      
      if core.shader.active(4) then
	 local bx, by = self:attachementSpot("back", true)
	 self:addParticles(Particles.new("shader_wings", 1, {life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
      end
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      local speed = t.getPassiveSpeed(self, t)
      return ([[You summon a powerful gust of wind, knocking back your foes within a radius of %d up to 3 tiles away and damaging them for %d%% weapon damage.
		
Passively increases Movement Speed by %d%%
]]):format(self:getTalentRadius(t),damage*100, speed*100)
   end,
}

newTalent{
   name = "Scaled Skin", short_name = "REK_WYRMIC_BODY_SCALES",
   image= "talents/icy_skin.png",
   type = {"wild-gift/draconic-body", 2},
   require = gifts_req2,
   mode = "sustained",
   points = 5,
   cooldown = 10,
   sustain_equilibrium = 10,
   range = 10,
   tactical = { ATTACK = { COLD = 1 }, DEFEND = 2 },
   getArmor = function(self, t) return self:combatTalentMindDamage(t, 5, 25) end,
   getArmorHardiness = function(self, t)
      return self:combatTalentLimit(t, 30, 10, 22)
   end,
   getResists = function(self, t) return self:combatTalentScale(t, 4, 15, 0.75, 0, 0, true) end,

   passives = function(self, t, p)
      self:talentTemporaryValue(p, "resists", {all = t.getResists(self, t)})
   end,
   
   activate = function(self, t)
      local ret = 
       {
	 hardiness = self:addTemporaryValue("combat_armor_hardiness", t.getArmorHardiness(self, t)*0.01),
	 armor = self:addTemporaryValue("combat_armor", t.getArmor(self, t)),
       }
      --Ice Aspect
      if self:knowTalent(self.T_REK_WYRMIC_COLD) and aspectIsActive(self, "Cold") then
	 ret["onhit"] = self:addTemporaryValue("on_melee_hit", {[DamageType.COLD]=self:callTalent(self.T_REK_WYRMIC_COLD, "getDamageOnMeleeHit")})
      end
      
      return ret
   end,
   deactivate = function(self, t, p)
      self:removeTemporaryValue("combat_armor_hardiness", p.hardiness)
      self:removeTemporaryValue("combat_armor", p.armor)
      if p.onhit then
	 self:removeTemporaryValue("on_melee_hit", p.onhit)
      end
      return true
   end,

   -- Force reactivation if you may have changed aspects, to update retaliation
   callbackOnTalentPost = function(self, t, ab)
      if ab.id == self.T_REK_WYRMIC_COLOR_PRIMARY or ab.id == self.T_REK_WYRMIC_MULTICOLOR then
	 self:forceUseTalent(self.T_REK_WYRMIC_BODY_SCALES, {ignore_energy=true, ignore_cooldown=true})
	 self:forceUseTalent(self.T_REK_WYRMIC_BODY_SCALES, {ignore_energy=true, ignore_cooldown=true})
      end
   end,
   
   info = function(self, t)
      return ([[Your skin forms a coat of scales and your flesh toughens, increasing your Armor Hardiness by %d%%, your Armour by %d.

Passively increeases resistance to all damage by %d%%
Mindpower: improves Armour.
]]):format(t.getArmorHardiness(self, t), t.getArmor(self, t), t.getResists(self, t))
   end,
}



-- Dragon's Heart, gives healmod, more the lower your health is, maybe also small health Regen

newTalent{
   name = "Drakeheart", short_name = "REK_WYRMIC_BODY_HEART",
   image= "talents/waters_of_life.png",
   type = {"wild-gift/draconic-body", 3},
   require = gifts_req3,
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

-- Lashing Tail, tries to knock enemies Off-balance with each hit.
newTalent{
   name = "Lashing Tail", short_name = "REK_WYRMIC_BODY_TAIL",
   image= "talents/windtouched_speed.png",
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
	 -- Poison check
	 if self:knowTalent(self.T_REK_WYRMIC_VENM) and aspectIsActive(self, "Nature") and target:canBe("poison") then
	    local dam = self:callTalent(self.T_REK_WYRMIC_VENM, "getDamageStinger")
	    target:setEffect(target.EFF_DEADLY_POISON, 3, {src=self, power=dam, max_power=dam*4, insidious=0, crippling=0, numbing=0, leeching=0, volatile=0, apply_power=self:combatAttack(), no_ct_effect=true})
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
