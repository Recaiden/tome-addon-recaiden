newTalent{
   name = "Champion's Focus", short_name = "REK_MTYR_CHIVALRY_CHAMPIONS_FOCUS",
   type = {"demented/chivalry", 1},
   require = martyr_mirror_req1,
   points = 5,
   cooldown = 15,
   mode = "sustained",
   no_energy = true,
   getChance = function(self,t) return math.min(100, self:combatTalentStatDamage(t, "dex", 10, 40)) end,
   getCost = function(self, t) return self:combatTalentScale(t, 5, 5) end,
   getThreshold = function(self, t) return self:combatTalentScale(t, 40, 40) end,
   on_pre_use = function(self, t, silent)
      if self:getInsanity() < 40 then
         if not silent then game.logPlayer(self, "You aren't insane enough to use this") end
         return false
      end
      return true
   end,
   deactivate_on = {no_combat=true, run=true, rest=true},
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
               self:forceUseTalent(self.T_REK_MTYR_CHIVALRY_CHAMPIONS_FOCUS, {ignore_energy=true})
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
      return ([[Each melee attack you land on your target has a %d%% chance to trigger another, similar strike at the cost of #INSANE_GREEN#%d insanity#LAST#.
This works for all blows, even those from other talents and from shield bashes, but this talent can grant at most one attack per weapon per turn.

Minimum Insanity: %d.
This talent will deactivate if it brings you to below its minimum insanity, or upon resting.

Dexterity: increases chance]]):format(t.getChance(self, t), t.getCost(self, t), t.getThreshold(self, t))
   end,
}

newTalent{
   name = "Lancer's Charge", short_name = "REK_MTYR_CHIVALRY_LANCERS_CHARGE",
   type = {"demented/chivalry", 2},
   require = martyr_mirror_req2,
   points = 5,
   range = function(self, t) return math.min(14, math.floor(self:combatTalentScale(t, 6, 10))) end,
   cooldown = 18,
   insanity = 15,
   requires_target = true,
   is_melee = true,
   speed = "combat",
   target = function(self, t) return {type="widebeam", radius=1, range=self:getTalentRange(t), selffire=false, talent=t} end,
   getHitDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 1.2) end,
   getSideDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.6, 1.0) end,
   getDazeDuration = function(self, t) return self:combatTalentScale(t, 2, 5) end,
   getStunDuration = function(self, t) return self:combatTalentScale(t, 2, 7) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local _ _, _, _, x, y = self:canProject(tg, x, y)
      if core.fov.distance(self.x, self.y, x, y) < 3 then
         game.logPlayer(self, "You are too close to build up momentum!")
         return nil
      end
      local target = game.level.map(x, y, Map.ACTOR)
      if not target then game.logPlayer(self, "You can only charge to a creature.") return nil end

      -- check movement to correct space
      local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
      local linestep = self:lineFOV(x, y, block_actor)
      local tx, ty, lx, ly, is_corner_blocked
      repeat  -- make sure each tile is passable
         tx, ty = lx, ly
         lx, ly, is_corner_blocked = linestep:step()
      until is_corner_blocked or not lx or not ly or game.level.map:checkAllEntities(lx, ly, "block_move", self)
      if not tx or not ty or core.fov.distance(x, y, tx, ty) > 1 then game.logPlayer(self, "Something is blocking your path.") return nil end 

      doMartyrWeaponSwap(self, "melee", true)

      local moment = false
      self:project(tg, x, y, function(px, py, tg, self)
                      local target = game.level.map(px, py, Map.ACTOR)
                      if target and self:reactionToward(target) < 0 then
                         local hit = false
                         local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
                         if (target.x == x and target.y == y) or moment then
                            -- full attack
                            local shield, shield_combat = self:hasShield()
                            if not shield then
                               hit = self:attackTarget(target, nil, t.getHitDamage(self, t), true)
                            else
                               _, hit = self:attackTargetWith(target, weapon, nil, t.getHitDamage(self, t))
                               self:attackTargetWith(target, shield_combat, nil, t.getHitDamage(self, t))
                            end
                            if hit then
                               self:incInsanity(15)
                               if target:canBe("stun") then
                                  target:setEffect(target.EFF_STUNNED, t.getStunDuration(self, t), {apply_power=self:combatPhysicalpower()})
                               end
                            end
                         else
                            -- daze attack
                            _, hit = self:attackTargetWith(target, weapon, nil, t.getSideDamage(self, t))
                            if hit and target:canBe("stun") then
                               target:setEffect(target.EFF_DAZED, t.getDazeDuration(self, t), {apply_power=self:combatPhysicalpower()})
                            end
                         end
                      end
                             end)

      local ox, oy = self.x, self.y
      self:move(tx, ty, true)
      if config.settings.tome.smooth_move > 0 then
         self:resetMoveAnim()
         self:setMoveAnim(ox, oy, 8, 5)
      end
      
      return true
   end,
   
   info = function(self, t)
      return ([[Hop astride your noble steed and run down a target at least 3 spaces away, striking with all weapons for %d%% damage. A hit will stun them for %d turns and grant you an additional #INSANE_GREEN#15 insanity#LAST#.  All other targets in or next to your path will be attacked with your mainhand weapon for %d%% damage and dazed for %d turns on a hit.]]):format(t.getSideDamage(self, t)*100, t.getDazeDuration(self, t), t.getHitDamage(self, t)*100, t.getStunDuration(self, t))
   end,
}
--If you are wielding the #MIDNIGHT#Moment#LAST# you will deal full damage to all targets.

newTalent{
   name = "Executioner's Onslaught", short_name = "REK_MTYR_CHIVALRY_EXECUTIONERS_ONSLAUGHT",
   type = {"demented/chivalry", 3},
   require = martyr_mirror_req3,
   points = 5,
   cooldown = 8,
   insanity = -10,
   range = 1,
   radius = 0,
   tactical = { ATTACK = { weapon = 2 }, CLOSEIN = 0.5 },
   requires_target = true,
   is_melee = true,
   speed = "combat",
   target = function(self, t) return {type="hitball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), simple_dir_request=true} end,
   getDamage = function(self, t, hate)
      return self:combatTalentIntervalDamage(t, "str", 0.25, 0.8, 0.4)
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local hit, x, y = self:canProject(tg, self:getTarget(tg))
      if not hit or not x or not y then return nil end
      doMartyrWeaponSwap(self, "melee", true)
      
      self:removeEffectsFilter({subtype={stun=true, daze=true, pin=true, pinned=true, pinning=true}}, 1)

      if self:canMove(x, y) then
         self:move(x, y, true)
      end

      local targets = {}
      self:project({type="ball", radius=1}, self.x, self.y,
                   function(px, py)
                      local target = game.level.map(px, py, Map.ACTOR)
                      if target and self:reactionToward(target) < 0 then
                         targets[#targets+1] = target
                      end
                   end)
      
      if #targets <= 0 then return true end
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
      return ([[Throw off a stun, daze, or pin that might stop you from moving and then lunge forward, striking a random adjacent enemy for %d%% damage.
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