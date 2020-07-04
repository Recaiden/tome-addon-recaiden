local Object = require "mod.class.Object"

function useFinalMoment(self)
   local combat = {
      talented = "sword",
      sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2},

      wil_attack = true,
      damrange = 1.5,
      physspeed = 1,
      dam = 16,
      apr = 0,
      atk = 0,
      physcrit = 0,
      dammod = {cun=1.3},
      melee_project = {},
   }
   if self:knowTalent(self.T_REK_MTYR_MOMENT_CUT) then
      local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_CUT)
      combat.dam = 16 + t.getBaseDamage(self, t)
      combat.apr = 0 + t.getBaseApr(self, t)
      combat.physcrit = 0 + t.getBaseCrit(self, t)
      combat.atk = 0 + t.getBaseAtk(self, t)
   end
   if self:knowTalent(self.T_REK_MTYR_MOMENT_DASH) then
      local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_DASH)
      combat.atk = t.getAttackTotal(self, t)
   end
   if self:knowTalent(self.T_REK_MTYR_MOMENT_STOP) then
      local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_STOP)
      combat.melee_project = { [engine.DamageType.ITEM_TEMPORAL_ENERGIZE] = t.getChance(self, t) }
   end
   if self:knowTalent(self.T_REK_MTYR_MOMENT_BLOCK) then
      local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_STOP)
      combat.talent_on_hit = { T_REK_MTYR_MOMENT_CUT = {level=self:getTalentLevel(self.T_REK_MTYR_MOMENT_BLOCK), chance=20} }
   end
   return combat
end

-- tactical value (between 1 and 3) for a Moment attack, accounting for various talent enhancements
function moment_tactical(self, t)
   return "PHYSICAL", 1 + util.bound(self:getTalentLevelRaw(self.T_REK_MTYR_MOMENT_CUT) + self:getTalentLevelRaw(self.T_REK_MTYR_MOMENT_DASH)/2 + self:getTalentLevelRaw(self.T_REK_MTYR_MOMENT_BLOCK)/2, 0, 10)/5
end

newTalent{
   name = "Cut Time", short_name = "REK_MTYR_MOMENT_CUT",
   type = {"demented/moment", 1},
   points = 5,
   require = str_req_high1,
   cooldown = 6,
   insanity = -10,
   range = 0,
   no_energy = true,
   requires_target = true,
   radius = function(self, t) return 1 end,
   tactical = { ATTACK = { [moment_tactical] = 1 } },
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.4, 2.1) end,
   getBaseDamage = function(self, t) return self:combatTalentMindDamage(t, 0, 60) end,
   getBaseAtk = function(self, t) return self:combatTalentMindDamage(t, 0, 20) end,
   getBaseApr = function(self, t) return self:combatTalentMindDamage(t, 0, 20) end,
   getBaseCrit = function(self, t) return self:combatTalentMindDamage(t, 0, 20) end,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)

      game.level.map:particleEmitter(self.x, self.y, 1, "dreamhammer", {tile="shockbolt/object/dream_hammer", tx=self.x, ty=self.y, sx=self.x, sy=self.y})

      self:project(tg, self.x, self.y, function(px, py, tg, self)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target ~= self then
                         --self:attackTarget(target, nil, t.getDamage(self, t), true)

			 self:attackTargetWith(target, useFinalMoment(self), nil, t.getDamage(self, t))
		      end
                                       end)
      game:playSoundNear(self, "talents/rek_triple_tick")


      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      local weapon_stats = Object:descCombat(self, {combat=useFinalMoment(self)}, {}, "combat")
      return ([[
You think of the sword.  
					The world stands still. 
You are holding a sword.
					The sword slices through everyone around you (%d%%). 
You are not holding the sword.
					The world is in motion.


The base power, Accuracy, Armour penetration, and critical strike chance of the Final Moment will scale with your Mindpower.
		Current Final Moment Stats:
		%s]]):format(damage * 100, tostring(weapon_stats))
   end,
         }

newTalent{
   name = "Cut Space", short_name = "REK_MTYR_MOMENT_DASH",
   type = {"demented/moment", 2},
   points = 5,
   require = str_req_high2,
   cooldown = 18,
   insanity = 15,
   tactical = { ATTACKAREA = { [moment_tactical] = 1 } },
   range = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
   requires_target = true,
   proj_speed = 10,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
   getChance = function(self, t) return self:combatTalentLimit(t, 50, 10, 30) end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
   getAttack = function(self, t) return self:getTalentLevel(t) * 10 end,
   getAttackTotal = function(self, t)
      local base_atk = 0
      if self:knowTalent(self.T_REK_MTYR_MOMENT_CUT) then
         local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_CUT)
         base_atk = 0 + t.getBaseAtk(self, t)
      end
      return base_atk + t.getAttack(self, t)
   end,
   getFinalMoment = function(self, t) return useFinalMoment(self) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local tx, ty, target = self:getTargetLimited(tg)
      if not tx or not ty then return nil end
      if not self:canProject(tg, tx, ty) then return nil end
      
      local ox, oy = self.x, self.y
      self:move(tx, ty, true)
      if ox == self.x and oy == self.y then return end
      
      self:project(
         {type="beam", range=100}, ox, oy,
         function(px, py)
             local tmp_target = game.level.map(px, py, engine.Map.ACTOR)
             local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_DASH)
             if tmp_target and tmp_target ~= self then
                self:attackTargetWith(tmp_target, t.getFinalMoment(self, t), nil, t.getDamage(self, t))
             end
         end)
      game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(ox-self.x), math.abs(oy-self.y)), "psionicbeam", {tx=ox-self.x, ty=oy-self.y})

      -- TODO leave a lingering marker that will come to you 2 turns later, repeating the damage
      game:playSoundNear(self, "talents/frog_speedup")
      --game:playSoundNear(self, "talents/warp")
      return true
   end,
   info = function(self, t)
      return ([[
The sword goes out before you, %d paces.
					The sword cuts all in its path (%d%% damage).
					You come to the blade.
The sword is behind you.
					It waits.
					It waits.
The sword comes to you.
					The sword cuts all in its path once more.
					You are together.
You are not holding a sword.                                        


Learning this talent increases the Accuracy of the Final Moment by %d.]]):format(self:getTalentRange(t), t.getDamage(self, t) * 100, t.getAttack(self, t))
   end,
         }

newTalent{
   name = "Knight of Hours", short_name = "REK_MTYR_MOMENT_STOP",
   type = {"demented/moment", 3},
   points = 5,
   require = str_req_high3,
   cooldown = 18,
   fixed_cooldown = true,
   mode = "passive",
   getFinalMoment = function(self, t) return useFinalMoment(self) end,
   getChance = function(self, t) return self:combatTalentLimit(t, 50, 10, 30) end,
   getGain = function(self, t) return math.min(5, self:combatTalentMindDamage(t, 1.0, 2.2)) end,
   doStop = function(self, t)
      if self:isTalentCoolingDown(t) then return end
      game:playSoundNear(self, "talents/roat_luna_dial")
      self.energy.value = self.energy.value + game.energy_to_act * t.getGain(self, t)
      self:startTalentCooldown(t)
      self:setEffect(self.EFF_REK_MTYR_MOMENT_WIELD, 1, {src=self})
   end,
   callbackOnHit = function(self, eff, cb, src)
      if cb.value >= (self.life) then
         t.doStop(self, t)
      end
      return cb.value
   end,
   info = function(self, t)
      return ([[
Your mind or body breaks.
					The world stands still.
You are holding a sword.
					The world remains still.
You have %d hundredths of a breath.

This effect has a cooldown.
Mindpower: improves turn gain.

Learning this talent grants attacks with the Final Moment a %d%% chance of giving you %d%% of a turn.]]):format(t.getGain(self, t)*100, t.getChance(self, t), 10)
   end,
         }

newTalent{
   name = "Implacable Blade", short_name = "REK_MTYR_MOMENT_BLOCK",
   type = {"demented/moment", 4},
   points = 5,
   require = str_req_high4,
   cooldown = 24,
   insanity = -15,
   tactical = { ATTACK = {[moment_tactical] = 1}, ATTACKAREA = { TEMPORAL = 1} },
   getFinalMoment = function(self, t) return useFinalMoment(self) end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
   getBlock = function(self, t) return self:combatTalentMindDamage(t, 20, 120) end,
   getProject = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
   action = function(self, t)
      self:setEffect(self.EFF_REK_MTYR_MOMENT_COUNTER, 1, {src=self, power=self:mindCrit(t.getBlock(self, t)), dam=t.getDamage(self, t)})
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      local project = t.getProject(self, t)
      return ([[
Danger approaches.
					Your sword is your shield.
The danger strikes you, weakened by %d.
					Your sword strikes back (%d%%).

Strikes with the sword may strike again, with levels for every level here.]]):format(t.getBlock(self, t), damage * 100, damDesc(self, DamageType.MIND, project))
   end,
         }