newTalent{
   name = "Shadow of Flame", short_name = "REK_HOLLOW_SHADOW_FLAME",
   type = {"spell/shadow-destruction",1},
   require = undeads_req1,
   points = 5,
   hate = 2,
   cooldown = 3,
   tactical = { ATTACK = { FIRE = 2 } },
   range = 10,
   proj_speed = 20,
   requires_target = true,
   target = function(self, t)
      local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"}}
      if self:getTalentLevel(t) >= 5 then tg.type = "beam" end
      return tg
   end,
   allow_for_arcane_combat = true,
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 290) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local grids = nil
      self:projectile(tg, x, y, DamageType.FIREBURN, self:spellCrit(t.getDamage(self, t)), function(self, tg, x, y, grids)
                         game.level.map:particleEmitter(x, y, 1, "flame")
                         if self:attr("burning_wake") then
                            game.level.map:addEffect(self, x, y, 4, engine.DamageType.INFERNO, self:attr("burning_wake"), 0, 5, nil, {type="inferno"}, nil, self:spellFriendlyFire())
                         end
                                                                                           end)
      
      
      game:playSoundNear(self, "talents/fire")
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[Conjures up a beam of flames, setting the targets ablaze and doing %0.2f fire damage over 3 turns.
Spellpower: increases damage]]):
      format(damDesc(self, DamageType.FIRE, damage))
   end,
         }

newTalent{
   name = "Shadow of Storm", short_name = "REK_HOLLOW_SHADOW_LIGHTNING",
   type = {"spell/shadow-destruction",2},
   require = undeads_req2,
   points = 5,
   hate = 3,
   cooldown = 3,
   tactical = { ATTACK = { LIGHTNING = 2 } },
   range = 1,
   direct_hit = true,
   requires_target = true,
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 350) end,
   action = function(self, t)
      local tg = {type="hit", range=self:getTalentRange(t), talent=t}
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local dam = self:spellCrit(t.getDamage(self, t))
      self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
      local _ _, x, y = self:canProject(tg, x, y)
      game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
      game:playSoundNear(self, "talents/lightning")
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[Strikes the target with a pulse of lightning doing %0.2f to %0.2f damage (%0.2f average).
Spellpower: increases damage]]):
      format(damDesc(self, DamageType.LIGHTNING, damage / 3),
             damDesc(self, DamageType.LIGHTNING, damage),
             damDesc(self, DamageType.LIGHTNING, (damage + damage / 3) / 2))
   end,
         }

newTalent{
   name = "Shadow of Violence", short_name = "REK_HOLLOW_SHADOW_DOMINATE",
   type = {"spell/shadow-destruction",3},
   require = undeads_req3,
   points = 5,
   cooldown = function(self, t) return 8 end,
   hate = 4,
   tactical = { ATTACK = function(self, t, aitarget)
                   return self.fov.actors[aitarget] and self.fov.actors[aitarget].sqdist <= 1 and 2 or nil
                         end,
		DISABLE = {pin = 2}},
   requires_target = true,
   range = 2.5,
   getDuration = function(self, t)
      return math.min(6, math.floor(2 + self:getTalentLevel(t)))
   end,
   getArmorChange = function(self, t)
      return -self:combatTalentStatDamage(t, "wil", 4, 30)
   end,
   getDefenseChange = function(self, t)
      return -self:combatTalentStatDamage(t, "wil", 6, 45)
   end,
   getResistPenetration = function(self, t) return self:combatLimit(self:combatTalentStatDamage(t, "wil", 30, 80), 100, 0, 0, 55, 55) end, -- Limit < 100%
   is_melee = true,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      
      -- attempt domination
      local duration = t.getDuration(self, t)
      local armorChange = t.getArmorChange(self, t)
      local defenseChange = t.getDefenseChange(self, t)
      local resistPenetration = t.getResistPenetration(self, t)
      target:setEffect(target.EFF_DOMINATED, duration, {src = self, armorChange = armorChange, defenseChange = defenseChange, resistPenetration = resistPenetration, apply_power=self:combatMindpower() })
      
      -- attack if adjacent
      if core.fov.distance(self.x, self.y, x, y) <= 1 then
         -- We need to alter behavior slightly to accomodate shields since they aren't used in attackTarget
         local shield, shield_combat = self:hasShield()
         local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat --can do unarmed attack
         local hit = false
         if not shield then
            hit = self:attackTarget(target, nil, 1, true)
         else
            hit = self:attackTargetWith(target, weapon, nil, 1)
            if self:attackTargetWith(target, shield_combat, nil, 1) or hit then hit = true end
         end
      end
      
      return true
   end,
   info = function(self, t)
      local duration = t.getDuration(self, t)
      local armorChange = t.getArmorChange(self, t)
      local defenseChange = t.getDefenseChange(self, t)
      local resistPenetration = t.getResistPenetration(self, t)
      return ([[Turn your attention to a nearby foe, and dominate them with your overwhelming presence. If the target fails to save versus your Mindpower, it will be unable to move for %d turns and vulnerable to attacks. They will lose %d Armour, %d Defense and your attacks will gain %d%% resistance penetration. If the target is adjacent to you, your domination will include a melee attack.
		Effects will improve with your Willpower.
                
		This talent will also attack with your shield, if you have one equipped.]]):format(duration, -armorChange, -defenseChange, resistPenetration)
   end,
}

newTalent{
   name = "Shadow of Speed", short_name = "REK_HOLLOW_SHADOW_BLINDSIDE",
   type = {"spell/shadow-destruction",4},
   require = undeads_req4,
   points = 5,
   cooldown = function(self, t) return math.max(6, 13 - math.floor(self:getTalentLevel(t))) end,
   range = 10,
   requires_target = true,
   tactical = { CLOSEIN = 2 },
   is_melee = true,
   is_teleport = true,
   target = function(self, t) return {type="hit", pass_terrain = true, range=self:getTalentRange(t)} end,
   getDefenseChange = function(self, t) return self:combatTalentStatDamage(t, "dex", 20, 50) end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.7, 1.9) * getHateMultiplier(self, 0.3, 1.0, false) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end

      game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
      if not self:teleportRandom(x, y, 0) then game.logSeen(self, "The teleport fizzles!") return true end
      game:playSoundNear(self, "talents/teleport")
      game.level.map:particleEmitter(x, y, 1, "teleport_in")
      
      -- Attack ?
      if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
         local multiplier = t.getDamage(self, t)         
         self:attackTarget(target, nil, multiplier, true)
         self:setEffect(target.EFF_BLINDSIDE_BONUS, 1, { defenseChange=t.getDefenseChange(self, t) })
      end
      return true
   end,info = function(self, t)
      local multiplier = self:combatTalentWeaponDamage(t, 0.9, 1.9)
      return ([[With blinding speed you suddenly appear next to a target up to %d spaces away and attack for up to %d%% damage (based on hate).
Your sudden appearance catches everyone off-guard, giving you %d extra Defense for 1 turn.

Dexterity: improves Defense bonus]]):format(self:getTalentRange(t), multiplier * 100)
   end,
}