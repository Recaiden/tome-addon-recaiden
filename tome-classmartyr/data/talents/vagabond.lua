newTalent{
   name = "Sling Practice", short_name = "REK_MTYR_VAGABOND_SLING_PRACTICE",
   type = {"demented/vagabond", 1},
   require = martyr_req1,
   points = 5,
   mode = "passive",
   getDamage = function(self, t) return 30 end,
   getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.8 end,
   getReload = function(self, t) return self:getTalentLevel(t) >= 2 and 1 or 0 end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, 'ammo_mastery_reload', t.getReload(self, t))
   end,
   callbackOnArcheryAttack = function(self, t, target, hitted)
      if hitted then
         self:incInsanity(5)
      end
   end,
   info = function(self, t)
      return ([[You can't really call it 'mastery', but you've used a sling before, along with a variety of other weapons.
This increases Physical Power by %d and weapon damage by %d%% when using a sling and increases your reload rate by %d.

Whenever you hit with a ranged weapon, you will gain 5 insanity.]]):format(t.getDamage(self, t), 100*t.getPercentInc(self, t), t.getReload(self, t))
   end,
}

newTalent{
   name = "Stagger Shot", short_name = "REK_MTYR_VAGABOND_STAGGER_SHOT",
   type = {"demented/vagabond", 2},
   require = martyr_req2,
   points = 5,
   insanity = 5,
   cooldown = 10,
   range = archery_range,
   tactical = { ATTACK = { weapon = 1 } },
   requires_target = true,
   on_pre_use = function(self, t, silent) return archerPreUse(self, t, silent, "sling") end,
   getDist = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 4, 8)) end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.8) end,
   archery_onhit = function(self, t, target, x, y)
      if not target or not target:canBe("knockback") then return end
      target:knockback(self.x, self.y, t.getDist(self, t))
   end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, 'quick_weapon_swap', 1)
   end,
   action = function(self, t)
      local targets = self:archeryAcquireTargets(nil, {one_shot=true, add_speed=self.combat_physspeed})
      if not targets then return end
      self:archeryShoot(targets, t, nil, {mult=t.getDamage(self, t)})
      return true
   end,
   info = function(self, t)
      return ([[You ready a sling shot with all your strength.
This shot does %d%% weapon damage and knocks back your target by %d.

Learning this talent allows you to swap to your alternate weapon set instantly.]]):
      format(t.getDamage(self, t) * 100, t.getDist(self, t))
   end,
}

newTalent{
   name = "Tainted Bullets", short_name = "REK_MTYR_VAGABOND_TAINTED_BULLETS",
   type = {"demented/vagabond", 3},
   require = martyr_req3,
   points = 5,
   mode = "sustained",
   cooldown = 10,
   tactical = { BUFF = 2 },
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 5, 40) end,
   callbackOnArcheryAttack = function(self, t, target, hitted)
      if not hitted then return end
      if not game.player or self:getTalentLevel(t) < 5 then return end
      if self:hasEffect(self.EFF_REK_MTYR_OVERSEER) then
         self:removeEffect(self.EFF_REK_MTYR_OVERSEER)
      end
      self:setEffect(self.EFF_REK_MTYR_OVERSEER, 5, {type=tostring(target.type), subtype=tostring(target.subtype)})
   end,
   activate = function(self, t)
      game:playSoundNear(self, "talents/fire")
      local ret = {
         particle = particle,
         dam = self:addTemporaryValue("ranged_project", {[DamageType.MIND] = t.getDamage(self, t)}),
      }
      if core.shader.active(4) then
         local slow = rng.percent(50)
         local h1x, h1y = self:attachementSpot("hand1", true) if h1x then ret.particle1 = self:addParticles(Particles.new("shader_shield", 1, {img="fireball", a=0.7, size_factor=0.4, x=h1x, y=h1y-0.1}, {type="flamehands", time_factor=slow and 700 or 1000})) end
      end
      return ret
   end,
   deactivate = function(self, t, p)
      if p.particle1 then self:removeParticles(p.particle1) end
      self:removeTemporaryValue("ranged_project", p.dam)
      return true
   end,
   info = function(self, t)
      return ([[You make unusual modifications to your sling bullets, causing them to deal %0.2f mind damage on hit and grant you telepathy to all similar creatures (radius 15) for 5 turns.

Mindpower: increases damage.]]):format(damDesc(self, DamageType.MIND, t.getDamage(self, t)))
   end,
}

newTalent{
   name = "Hollow Shell", short_name = "REK_MTYR_VAGABOND_HOLLOW_SHELL",
   type = {"demented/vagabond", 4},
   require = martyr_req4,
   points = 5,
   mode = "passive",
   getCritResist = function(self, t) return self:combatTalentScale(t, 15, 50, 0.75) end,
   immunities = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.7) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "ignore_direct_crits", t.getCritResist(self, t))
   end,
   info = function(self, t)
      return ([[Your body's vital organs are indistinct or perhaps missing.
You take %d%% less damage from critical hits.

#{italic}#Nothing's ever going to hurt me worse than #GREEN#we#LAST# already have.#{normal}#]]):format(t.getCritResist(self, t))
   end,
}
