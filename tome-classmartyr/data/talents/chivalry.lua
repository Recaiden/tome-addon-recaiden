newTalent{
   name = "Champion's Focus", short_name = "REK_MTYR_CHIVALRY_CHAMPIONS_FOCUS",
   type = {"demented/chivalry", 1},
   require = martyr_mirror_req1,
   points = 5,
   cooldown = 15,
   mode = "sustained",
   no_energy = true,
   getChance = function(self,t) return self:combatLimit(self:combatTalentStatDamage(t, "dex", 10, 90),100, 6.8, 6.8, 61, 61) end,
   getCost = function(self, t) return self:combatTalentScale(t, 5, 5) end,
   getThreshold = function(self, t) return self:combatTalentScale(t, 40, 40) end,
   on_pre_use = function(self, t, silent)
      if self:getInsanity() < 40 then
         if not silent then game.logPlayer(self, "You aren't insane enough to use this") end
         return false
      end
      return true
   end,
   callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam, hd)
      -- checks self.turn_procs._no_melee_recursion just in case
      if hitted and weapon and not (self.turn_procs._rek_mtyr_focus_active or self.turn_procs._no_melee_recursion or target.dead) then
         local rek_mtyr_focus = self.turn_procs._rek_mtyr_focus or {}
         self.turn_procs._rek_mtyr_focus = rek_mtyr_focus
         if not rek_mtyr_focus[weapon] and rng.percent(t.getChance(self, t)) then
            rek_mtyr_focus[weapon] = true

            self.turn_procs._rek_mtyr_focus_active = true
            self:attackTargetWith(target, weapon, damtype, mult)
            self.turn_procs._rek_mtyr_focus_active = nil

            self:incInsanity(-1*t.getCost(self, t))
            if self:getInsanity() < t.getThreshold(self, t) then
               self:forceUseTalent(self.T_MTYR_CHIVALRY_CHAMPIONS_FOCUS, {ignore_energy=true})
            end
            
         end
      end
   end,
   activate = function(self, t)
      doMartyrWeaponSwap(self, "melee", true)
      local ret = {}
      
      return ret
   end,
   deactivate = function(self, t, p)
      --self:removeParticles(p.particle)
      return true
   end,
   info = function(self, t)
      return ([[Each melee attack you land on your target has a %d%% chance to trigger another, similar strike at the cost of 5 insanity.
This works for all blows, even those from other talents and from shield bashes, but this talent can grant at most one attack per weapon per turn.

This talent will deactivate if it brings you to below %d insanity.

Dexterity: increases chance]]):format(t.getChance(self, t), t.getCost(self, t), t.getThreshold(self, t))
   end,
}

newTalent{
   name = "Lancer's Charge", short_name = "REK_MTYR_CHIVALRY_LANCERS_CHARGE",
   type = {"demented/chivalry", 2},
   require = martyr_mirror_req2,
   points = 5,
   range = 10,
   cooldown = 18,
   insanity = -10,
   target = function(self, t) return {type="widebeam", radius=1, range=self:getTalentRange(t), selffire=false, talent=t} end,
   getHitDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
   getSideDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
   getDazeDuration = function(self, t) return self:combatTalentScale(t, 2, 7) end,
   getStunDuration = function(self, t) return self:combatTalentScale(t, 2, 7) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      doMartyrWeaponSwap(self, "melee", true)
      local _ _, _, _, x, y = self:canProject(tg, x, y)
      if core.fov.distance(self.x, self.y, x, y) < 1 then return nil end
      
      local tgts = {}
      local dam = self:Crit(t.getDamage(self, t))
      local slow = t.getSlow(self, t)
      local proj = t.getProj(self, t)
      self:project(tg, x, y, function(px, py)
                      DamageType:get(DamageType.PHYSICAL).projector(self, px, py, DamageType.PHYSICAL, dam)
                      local target = game.level.map(px, py, Map.ACTOR)
                      if target then tgts[target] = true end
                             end)
      
      local sorted_tgts = {}
      for target, _ in pairs(tgts) do
         sorted_tgts[#sorted_tgts+1] = {target=target, dist=core.fov.distance(self.x, self.y, target.x, target.y)}
      end
      table.sort(sorted_tgts, "dist")
      
      -- Compute beam direction to knockback all targets in that direction even if they are on the sides of the beam
      local angle = math.atan2(y - self.y, x - self.x)
      
      for _, tgt in ripairs(sorted_tgts) do
         local target = tgt.target
         if target:canBe("slow") then
            target:setEffect(target.EFF_CONGEAL_TIME, 4, {slow=slow, proj=proj, apply_power=self:combatSpellpower()})
         end
         if self:getTalentLevel(t) >= 5 and target:canBe("knockback") then
            target:pull(target.x + math.cos(angle) * 10, target.y + math.sin(angle) * 10, 3)
         end
      end
      
      return true
   end,
   
   info = function(self, t)
      return ([[Hop astride your noble steed and run down a target at least 3 spaces away.  All other targets in or next to your path will be attacked with your mainhand weapon for %d%% damage and dazed for %d turns on a hit.  Your main target will be struck with all weapons for %d%% damage and stunned for %d turns.

If you are wielding the #MIDNIGHT#Moment#LAST# you will deal full damage to all targets.]]):format(t.getSideDamage(self, t)*100, t.getDazeDuration(self, t), t.getHitDamage(self, t)*100, t.getStunDuration(self, t))
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
      doMartyrWeaponSwap(self, "melee", true)
      
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
]]):format(t.getDamage(self, t)*100)
   end,
}

newTalent{
   name = "Hero's Resolve", short_name = "REK_MTYR_CHIVALRY_HEROS_RESOLVE",
   type = {"demented/chivalry", 4},
   require = martyr_mirror_req4,
   points = 5,
   mode = "passive",
   getImmunities = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.7) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "blind_immune", t.getImmunities(self, t))
      self:talentTemporaryValue(p, "disarm_immune", t.getImmunities(self, t))
      self:talentTemporaryValue(p, "cut_immune", t.getImmunities(self, t))
   end,
   info = function(self, t)
      return ([[You will not let minor wounds and difficulties stop you from fighting.
		You gain %d%% resistance to disarms, wounds and blindness.]]):
      format(100*t.getImmunities(self, t))
   end,
}