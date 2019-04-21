newTalent{
   name = "Devour", short_name = "REK_WYRMIC_COMBAT_BITE",
   type = {"wild-gift/draconic-combat", 1},
   require = techs_req1,
   points = 5,
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
      local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1.6, 2.5), true)
      if not hit then return true end
      -- Regain EQ on hit
      self:incEquilibrium(-5)
      
      -- Slash armor if in physical aspect
      if self:knowTalent(self.T_REK_WYRMIC_SAND) then
	 target:setEffect(target.EFF_SUNDER_ARMOUR, 3, {power=self:callTalent(self.T_REK_WYRMIC_SAND, "getPenetration"), apply_power=self:combatPhysicalpower()})
      end
      
      if (target.life * 100 / target.max_life > t.maxSwallow(self, t, target)) and not target.dead then
	 return true
      end
      
      if (target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 15) or target.dead) and (target:canBe("instakill") or target.life * 100 / target.max_life <= 5) then
	 if not target.dead then target:die(self) end
	 world:gainAchievement("EAT_BOSSES", self, target)
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
      return ([[Attack the target for %d%%  weapon damage.  This predatory act reinforces your place in nature, regenerating 5 equilibrium if you hit.
		If the attack brings your target below %d%% life or kills it, you can try (#SLATE#Physical vs. Physical#LAST#)to swallow it, killing it automatically and regaining life depending on its level.
		The chance to swallow depends on your talent level and the relative size of the target.

Passively raises critical rate (by %d%%).
]]):
	 format(100 * self:combatTalentWeaponDamage(t, 1.6, 2.5), t.maxSwallow(self, t, self), t.getPassiveCrit(self, t))
   end,
}

newTalent{
   name = "Scaled Skin", short_name = "REK_WYRMIC_COMBAT_SCALES",
   type = {"wild-gift/draconic-combat", 2},
   require = techs_req2,
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
   activate = function(self, t)
      local ret = 
	 {
	    hardiness = self:addTemporaryValue("combat_armor_hardiness", t.getArmorHardiness(self, t)),
	    armor = self:addTemporaryValue("combat_armor", t.getArmor(self, t)),
	 }
      
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
	 self:forceUseTalent(self.T_REK_WYRMIC_COMBAT_SCALES, {ignore_energy=true, ignore_cooldown=true})
	 self:forceUseTalent(self.T_REK_WYRMIC_COMBAT_SCALES, {ignore_energy=true, ignore_cooldown=true})
      end
   end,
   
   info = function(self, t)
      return ([[Your skin forms a coat of scales and your flesh toughens, increasing your Armor Hardiness by %d%%, your Armour by %d.

Mindpower: improves Armour.
]]):format(t.getArmorHardiness(self, t), t.getArmor(self, t))
   end,
}

newTalent{
   name = "Claw Sweep", short_name = "REK_WYRMIC_COMBAT_CLAW",
   type = {"wild-gift/draconic-combat", 3},
   require = techs_req3,
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
   damagemult = function(self, t) return self:combatTalentWeaponDamage(t, 1.6, 2.3) end,
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
		      local damage = t.damagemult(self, t)
		      if target and target ~= self then
			 local hit = self:attackTarget(target, damtype, damage, true)

			 -- Slash armor if in physical aspect
			 if hit and self:knowTalent(self.T_REK_WYRMIC_SAND) then
			    target:setEffect(target.EFF_SUNDER_ARMOUR, 3, {power=self:callTalent(self.T_REK_WYRMIC_SAND, "getPenetration"), apply_power=self:combatPhysicalpower()})
			 end
		      end
      end)
      game:playSoundNear(self, "talents/breath")
      return true
   end,
   info = function(self, t)
      local name = "Physical"
      local nameStatus = "unaffected otherwise (you don't have an aspect)"
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 --name = source.name
	 name = DamageType:get(source.damtype).text_color..DamageType:get(source.damtype).name.."#LAST#"
	 nameStatus = source.nameStatus
      end
      return ([[You call upon the mighty claws of the drake and rake the enemies in front of you, doing %d%% weapon damage as %s in a cone of %d, with a 25%% chance that the target will be %s.
]]):format(100 * t.damagemult(self, t), name, self:getTalentRadius(t), nameStatus)
   end,
}


newTalent{
   name = "Overwhelm", short_name = "REK_WYRMIC_COMBAT_DISSOLVE",
   type = {"wild-gift/draconic-combat", 4},
   require = techs_req4,
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

      local s = self.rek_wyrmic_dragon_damage or
	 {
	    name="Physical",
	    damtype=DamageType.PHYSICAL,
	    nameStatus="Blinded",
	    status=DamageType.REK_WYRMIC_SAND
	 }
      local damtype = s.damtype
      local numAttacks = 4

      while numAttacks > 0 do
	 local hit = self:attackTarget(target, s.status, self:combatTalentWeaponDamage(t, 0.1, 0.60), true)
	 -- Slash armor if in physical aspect
	 if hit and self:knowTalent(self.T_REK_WYRMIC_SAND) then
	    target:setEffect(target.EFF_SUNDER_ARMOUR, 3, {power=self:callTalent(self.T_REK_WYRMIC_SAND, "getPenetration"), apply_power=self:combatPhysicalpower()})
	 end
	 numAttacks = numAttacks - 1
      end

      return true
   end,

   info = function(self, t)
      local name = "Physical"
      local nameStatus = "unaffected otherwise (you don't have an aspect)"
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 name = DamageType:get(source.damtype).text_color..DamageType:get(source.damtype).name.."#LAST#"
	 nameStatus = source.nameStatus
      end
      return ([[You strike the enemy with a rain of four fast blows doing %d%% weapon damage as %s each, with a chance that the enemy will be %s.
		
]]):format(100 * self:combatTalentWeaponDamage(t, 0.1, 0.6), name, nameStatus)
   end,
}

