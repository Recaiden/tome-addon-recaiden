
newTalent{
   name = "Share Pain", short_name = "REK_MTYR_CRUCIBLE_SHARE_PAIN",
   type = {"psionic/crucible", 1},
   points = 5, 
   require = wil_req_high1,
   feedback = 15,
   cooldown = 3,
   tactical = { ATTACKAREA = {MIND = 2}},
   requires_target = true,
   proj_speed = 10,
   range = 10,
   -- target = function(self, t)
   --    return {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, friendlyblock=false, display={particle="crucible_discharge", trail="lighttrail"}}
   -- end,
   requires_target = true,
   target = function(self, t)
      return {type="beam", range=self:getTalentRange(t), talent=t}
   end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 300) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local dam = self:mindCrit(t.getDamage(self, t))
      
      local baseradius = math.ceil(core.fov.distance(self.x, self.y, x, y) * 2.5)
      self:project(tg, x, y, function(px, py)
                      DamageType:get(DamageType.MIND).projector(self, px, py, DamageType.MIND, dam)
                      game.level.map:particleEmitter(px, py, 1, "mindsear", {baseradius=baseradius * 0.66})
                      baseradius = baseradius - 10
                             end)
      game:playSoundNear(self, "talents/spell_generic")
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[Force the pain you've felt out of your mind and into the world, doing %0.2f mind damage toa ll targets in a beam.
Mindpower: improves damage.]]):format(damDesc(self, DamageType.MIND, damage))
   end,
         }

newTalent{
   name = "Overflow", short_name = "REK_MTYR_CRUCIBLE_OVERFLOW",
   type = {"psionic/crucible", 2},
   points = 5, 
   require = wil_req_high2,
   mode = "passive",
   getEfficiency = function(self, t) return math.max(10, self:combatTalentScale(t, 30, 18)) end,
   action = function(self, t)
      local wrath = self:hasEffect(self.EFF_FOCUSED_WRATH)
      self:setEffect(self.EFF_FEEDBACK_LOOP, t.getDuration(self, t), {})
      game:playSoundNear(self, "talents/heal")
      return true
   end,
   info = function(self, t)
      local ret = ([[Feedback gains beyond your maximum allowed amount may reduce the cooldowns of Share Pain, Memento Mori, and Resonation (in that order), using %d feedback per turn of cooldown.]]):format(t.getEfficiency(self, t))
      if self:knowTalent(self.T_MIND_STORM) then
         ret = ret..[[
                        This effect occurs before Mind Storm.]]
      end
      return ret
   end,
         }

newTalent{
   name = "Memento Mori", short_name = "REK_MTYR_CRUCIBLE_MEMENTO",
   type = {"psionic/crucible", 3},
   points = 5, 
   require = wil_req_high3,
   cooldown = 12,
   feedback = 40,
   range = 7,
   direct_hit = true,
   radius = 7,
   requires_target = true,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
   getDam = function(self, t) return self:combatTalentScale(t, 25, 90) end,
   getMax = function(self, t) return self:combatTalentMindDamage(t, 50, 1000) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      
      self:project(tg, x, y, function(px, py)
                      local a = game.level.map(px, py, Map.ACTOR)
                      if a then
                         local lost_life = a.max_life - a.life
                         local dam = lost_life * t.getDam(self, t) / 100
                         dam = math.min(dam, t.getMax(self, t))
                         DamageType:get(DamageType.MIND).projector(self, px, py, DamageType.MIND, dam)
                         game.level.map:particleEmitter(px, py, 1, "image", {once=true, image="particles_images/butterfly_kick", life=25, av=-0.6/25, size=64})
                      end
                             end)
      
      game:playSoundNear(self, "actions/whip_hit")
      return true
   end,
   info = function(self, t)
      return ([[Meld together your painful feedback with a target's own suffering to form a lethal blade of mental turmoil. 
The target will take mind damage equal to %d%% of the life it already lost (up to %d).
Mindpower: raises the cap.]]):
      format(t.getDam(self, t), t.getMax(self, t))
   end,
}

newTalent{
   name = "Runaway Resonation", short_name = "REK_MTYR_CRUCIBLE_RESONATION",
   type = {"psionic/crucible", 4},
   points = 5, 
   require = wil_req_high4,
   feedback = 25,
   cooldown = 12,
   tactical = { BUFF = 2 },
   getCritBonus = function(self, t) return self:combatMindCrit() / 2  end,
   target = function(self, t)
      return {type="hit", range=self:getTalentRange(t)}
   end,
   getDuration = function(self, t) return self:combatTalentScale(t, 2, 5) end,
   action = function(self, t)
      self:setEffect(self.EFF_REK_MTYR_RESONATION, t.getDuration(self, t), {src=self, power=t.getCritBonus(self, t)})
      game.level.map:particleEmitter(self.x, self.y, 1, "generic_charge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
      return true
   end,
   info = function(self, t)
      local duration = t.getDuration(self, t)
      local crit_bonus = t.getCritBonus(self, t)
      return ([[Focus your feedback in on itself, setting your mind surging with unstoppable power.  For %d turns, your critical power is increased by half your mental critical rate (%d), and your mental critical rate becomes 100%%.]]):format(duration, crit_bonus)
   end,
}

