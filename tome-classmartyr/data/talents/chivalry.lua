newTalent{
   name = "Duelist's Challenge", short_name = "REK_MTYR_CHIVALRY_DUELIST_CHALLENGE",
   type = {"demented/chivalry", 1},
   require = martyr_mirror_req1,
   points = 5,
   cooldown = 6,
   range = 1,
   is_melee = true,
   requires_target = true,
   tactical = { ATTACK = 1 },
   target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
   getHitDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
   getDotDamage = function(self, t) return self:combatTalentMindDamage(t, 4, 25) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      if not target then return end

      local dam = self:mindCrit(t.getDotDamage(self, t))
      local ramp = 1
      local fail = 0
      local lifesteal = 0
      --DoT
      if self:knowTalent(self.T_REK_MTYR_CHIVALRY_SPROUTING) then
         local t2 = self:getTalentFromId(self.T_REK_MTYR_CHIVALRY_SPROUTING)
         ramp = ramp + t2.getRamp(self, t2)
         if amInsane(self) then
            fail = t2.getFail(self, t2)
         end
      end
      if self:knowTalent(self.T_REK_MTYR_CHIVALRY_SHARED_FEAST) then
         local t4 = self:getTalentFromId(self.T_REK_MTYR_CHIVALRY_SHARED_FEAST)
         lifesteal = lifesteal + t4.getDrain(self, t4)
      end

      local hit = self:attackTarget(target, nil, 1, true)
      if hit and not target.dead then
         target:setEffect(target.EFF_REK_MTYR_SCORN, 5, {damage=dam, ramp=ramp, fail=fail, lifesteal=lifesteal, src=self, apply_power=self:combatMindpower()})
         -- insanityBonus
         if amInsane(self) then
            if target:canBe("stun") then
               target:setEffect(target.EFF_STUN, t.getDuration(self, t), {apply_power=self:combatMindpower()})
            end
         end
      end
      
      return true
   end,
   
   info = function(self, t)
      return ([[Strike an enemy in melee, and, if you hit, afflict the target with Scorn, which does %d mind damage per turn for %d turns (#SLATE#No save#LAST#).  Scorn ignores immunity but is otherwise treated as a disease.
Mindpower: increases damage.

#GREEN#Our Gift:#LAST# The target will be stunned (#SLATE#Mindpower vs. Physical#LAST#) for %d turns.
]]):format(t.getDotDamage(self, t), 5, t.getDuration(self, t))
   end,
}

newTalent{
   name = "Lancer's Charge", short_name = "REK_MTYR_CHIVALRY_LANCERS_CHARGE",
   type = {"demented/chivalry", 2},
   require = martyr_mirror_req2,
   points = 5,
   mode = "passive",
   getRamp = function(self, t) return self:combatTalentScale(t, 0.08, 0.3) end,
   getFail = function(self, t) return math.min(33, self:combatTalentScale(t, 10, 20)) end,
   info = function(self, t)
      return ([[Hop astride your noble steed and run down a target at least 3 spaces away.  All other targets in or next to your path will be attacked with your mainhand weapon for %d%% damage and dazed for %d turns on a hit.  Your main target will be struck with all weapnos for %d%% damage and stunned for %d turns.

If you are wielding the #MIDNIGHT#Moment#LAST# you will deal full damage to all targets.]]):format(t.getRamp(self, t)*100, t.getFail(self, t))
   end,
}

newTalent{
   name = "Executioner's Onslaught", short_name = "REK_MTYR_CHIVALRY_EXECUTIONERS_ONSLAUGHT",
   type = {"demented/chivalry", 3},
   require = martyr_mirror_req3,
   points = 5,
   cooldown = 1,
   insantity = 15,
   range = 1,
   radius = 0,
   tactical = { ATTACK = { weapon = 2 }, CLOSEIN = 0.5 },
   requires_target = true,
   is_melee = true,
   target = function(self, t) return {type="hitball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), simple_dir_request=true} end,
   getDamage = function(self, t, hate)
      return self:combatTalentIntervalDamage(t, "str", 0.25, 0.8, 0.4)
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local hit, x, y = self:canProject(tg, self:getTarget(tg))
      if not hit or not x or not y then return nil end
      
      self:removeEffectsFilter({subtype={stun=true, daze=true, pin=true, pinned=true, pinning=true}}, 50)

      if self:canMove(x, y) then
         self:move(x, y, true)
      end

      local subtargeter = {type="ball", range=0, selffire=false, radius=1}
      x, y = self:getTarget(subtargeter)
      if not x then return nil end
      _, _, _, x, y = self:canProject(subtargeter, x, y)
      local targets = {}
      self:project(subtargeter, self.x, self.y,
                   function(px, py, tg, self)
                      local target = game.level.map(px, py, Map.ACTOR)
                      if target and self:reactionToward(target) < 0 then
                         targets[#targets+1] = target
                      end
                   end)
      
      if #targets <= 0 then return nil end
      local damageMultiplier = t.getDamage(self, t)
      target = rng.table(targets)
      local shield, shield_combat = self:hasShield()
      local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
      local hit = false
      if not shield then
         hit = self:attackTarget(target, nil, damageMultiplier, true)
      else
         hit = self:attackTargetWith(target, weapon, nil, damageMultiplier)
         if self:attackTargetWith(target, shield_combat, nil, damageMultiplier) or hit then hit = true end
      end
      
      self:addParticles(Particles.new("meleestorm", 1, {radius=1}))
      
      return true
   end,
   info = function(self, t)
      return ([[Throw off any stun, daze, or pin that would stop you from moving and then lunge forward, striking a random adjacent enemy for %d%% damage.
This will also attack with your shield if you have one equipped.
]]):format(self:getDamage(t))
   end,
}

newTalent{
   name = "Hero's Resolve", short_name = "REK_MTYR_CHIVALRY_HEROS_RESOLVE",
   type = {"demented/chivalry", 4},
   require = martyr_mirror_req4,
   points = 5,
   mode = "passive",
   immunities = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.7) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "blind_immune", t.immunities(self, t))
      self:talentTemporaryValue(p, "disarm_immune", t.immunities(self, t))
      self:talentTemporaryValue(p, "cut_immune", t.immunities(self, t))
   end,
   info = function(self, t)
      return ([[You will not let minor wounds and difficulties stop you from fighting.
		You gain %d%% resistance to disarms, wounds and blindness.]]):
      format(t.critResist(self, t), 100*t.immunities(self, t))
   end,
}