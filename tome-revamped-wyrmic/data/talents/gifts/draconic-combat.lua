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
   is_melee = true,
   speed = "weapon",
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   maxSwallow = function(self, t, target) return -- Limit < 50%
	 self:combatLimit(self:getTalentLevel(t)*(self.size_category or 3)/(target.size_category or 3), 50, 13, 1, 25, 5)
   end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.6, 2.5) end,
   -- getPassiveCrit = function(self, t) return self:combatTalentScale(t, 2, 10, 0.5) end,
   -- passives = function(self, t, p)
   --    self:talentTemporaryValue(p, "combat_physcrit", t.getPassiveCrit(self, t))
   --    self:talentTemporaryValue(p, "combat_mindcrit", t.getPassiveCrit(self, t))
   --    self:talentTemporaryValue(p, "combat_spellcrit", t.getPassiveCrit(self, t))
   -- end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      
      self:logCombat(target, "#Source# tries to swallow #Target#!")
      local shield, shield_combat = self:hasShield()
      local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
      local hit = false
      if not shield then
         hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
      else
         hit = self:attackTargetWith(target, weapon, nil, t.getDamage(self, t))
         if self:attackTargetWith(target, shield_combat, nil, t.getDamage(self, t)) or hit then hit = true end
      end
      
      if not hit then return true end
      -- Regain resources on hit
      self:incEquilibrium(-5)
      if self:knowTalent(self.T_RAZE) then self:incSoul(1) end
      
      -- Slash armor if in physical aspect
      if self:knowTalent(self.T_REK_WYRMIC_SAND) then
	 target:setEffect(target.EFF_SUNDER_ARMOUR, 3, {power=self:callTalent(self.T_REK_WYRMIC_SAND, "getPenetration"), apply_power=self:combatPhysicalpower()})
      end

      -- Attempt to swallow
      if (target.life * 100 / target.max_life > t.maxSwallow(self, t, target)) and not target.dead then
	 return true
      end
      if (target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 15) or target.dead)
          and (target:canBe("instakill") or target.dead) then
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
      local resourceData = "reinforces your place in nature, lowering your equilibrium by 5"
      if self:knowTalent(self.T_RAZE) then
         resourceData = resourceData.." and tears its spirit, granting you 1 soul"
      end
      return ([[Savagely bite your target for %d%% weapon damage.  If you hit, this predatory act %s.

If the attack brings your target below %d%% life, you can try (#SLATE#Physical vs. Physical#LAST#)to swallow it whole, killing it automatically and regaining life depending on its level.
The chance to swallow depends on the relative size of the target.

This talent will also attack with your shield, if you have one equipped.
]]):
	 format(100 * t.getDamage(self, t), resourceData, t.maxSwallow(self, t, self))
   end,
         }


newTalent{
   name = "Wing Buffet", short_name = "REK_WYRMIC_COMBAT_BUFFET",
   type = {"wild-gift/draconic-combat", 2},
   require = gifts_req2,
   points = 5,
   equilibrium = 5,
   cooldown = 10,
   range = 0,
   speed = "weapon",
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.7) end,
   radius = function(self, t) return 3 end,
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
      local state = {}
      local shield, shield_combat = self:hasShield()
      local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
      self:project(tg, x, y, function(px, py, tg, self)
                      local target = game.level.map(px, py, Map.ACTOR)
                      if target and target ~= self and not state[target] then
                         state[target] = true
                         if not shield then
                            self:attackTarget(target, DamageType.PHYSKNOCKBACK, t.getDamage(self, t), true)
                         else
                            self:attackTargetWith(target, weapon, DamageType.PHYSKNOCKBACK, t.getDamage(self, t))
                            self:attackTargetWith(target, shield_combat, DamageType.PHYSKNOCKBACK, t.getDamage(self, t))
                         end
                         -- Slash armor if in physical aspect
                         if self:knowTalent(self.T_REK_WYRMIC_SAND) then
                            target:setEffect(target.EFF_SUNDER_ARMOUR, 3, {power=self:callTalent(self.T_REK_WYRMIC_SAND, "getPenetration"), apply_power=self:combatPhysicalpower()})
                         end
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
      return ([[You summon a powerful gust of wind, knocking back your foes within a radius of %d up to 3 tiles away and hitting them for %d%% weapon damage.
		This talent will also attack with your shield, if you have one equipped.]]):format(self:getTalentRadius(t),damage*100)
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
   radius = function(self, t) return 3 end,
   direct_hit = true,
   requires_target = true,
   tactical = { ATTACK = { weapon = 1 } },
   is_melee = true,
   speed = "weapon",
   damagemult = function(self, t) return self:combatTalentWeaponDamage(t, 1.6, 2.3) end,
   target = function(self, t)
      return {type="cone", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local damtype = DamageType.FIRE
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
                         local shield, shield_combat = self:hasShield()
                         local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
                         if not shield then
                            self:attackTarget(target, damtype, damage, true)
                         else
                            self:attackTargetWith(target, weapon, damtype, damage)
                            self:attackTargetWith(target, shield_combat, damtype, damage)
                         end

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
      local name = "Fire"
      local nameStatus = "unaffected otherwise (you don't have an aspect)"
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 --name = source.name
	 name = DamageType:get(source.damtype).text_color..DamageType:get(source.damtype).name.."#LAST#"
	 nameStatus = source.nameStatus
      end
      return ([[You call upon the mighty claws of the drake and rake the enemies in front of you, doing %d%% weapon damage as %s in a cone of %d, with a 25%% chance that the target will be %s.
This talent will also attack with your shield, if you have one equipped.]]):format(100 * t.damagemult(self, t), name, self:getTalentRadius(t), nameStatus)
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
   speed = "weapon",
   tactical = { ATTACK = { weapon = 2 } },
   requires_target = true,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.1, 0.60) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end

      local s = self.rek_wyrmic_dragon_damage or
	 {
	    name="Fire",
	    damtype=DamageType.FIRE,
	    nameStatus="N/A",
	    status=DamageType.FIRE
	 }
      local damtype = s.damtype
      local numAttacks = 4

      while numAttacks > 0 do
         local hit = false
         local damage = t.getDamage(self, t)
         local shield, shield_combat = self:hasShield()
         local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
         if not shield then
            hit = self:attackTarget(target, s.status, damage, true)
         else
            hit = self:attackTargetWith(target, weapon, s.status, damage)
            hit = self:attackTargetWith(target, shield_combat, s.status, damage) or hit
         end
	 -- Sand armor slash
	 if hit and self:knowTalent(self.T_REK_WYRMIC_SAND) then
	    target:setEffect(target.EFF_SUNDER_ARMOUR, 3, {power=self:callTalent(self.T_REK_WYRMIC_SAND, "getPenetration"), apply_power=self:combatPhysicalpower()})
	 end
	 numAttacks = numAttacks - 1
      end

      return true
   end,

   info = function(self, t)
      local name = "Fire"
      local nameStatus = "unaffected otherwise (you don't have an aspect)"
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 name = DamageType:get(source.damtype).text_color..DamageType:get(source.damtype).name.."#LAST#"
	 nameStatus = source.nameStatus
      end
      return ([[You strike the enemy with a rain of four fast blows each doing %d%% weapon damage as %s, with a chance that the enemy will be %s.  This will also attack with your shield, if you have one equipped.
		
]]):format(100 * t.getDamage(self, t), name, nameStatus)
   end,
}

