
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
   requires_target = true,
   radius = 2,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire=false, talent=t, trail="lighttrail"}
   end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 300) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local a = game.level.map(x, y, Map.ACTOR)
      if not a then return nil end
      local dam = self:mindCrit(t.getDamage(self, t))
      
      local tgts = {}
      self:project(
         tg, x, y,
         function(px, py)
            local a = game.level.map(px, py, Map.ACTOR)
            if a and self:reactionToward(a) < 0 then
               tgts[#tgts+1] = a
            end
         end)
      
      dam = dam * (0.9 + 0.1 * #tgts)

      local tg = {type="hit", range=self:getTalentRange(t), talent=t, friendlyfire=false}
      game.level.map:particleEmitter(self.x, self.y,
                                              math.max(
                                                 math.abs(x-self.x),
                                                 math.abs(y-self.y)),
                                              "rek_mind_beam", {tx=x-self.x, ty=y-self.y})
      for i, a in ipairs(tgts) do
         self:project(tg, a.x, a.y, DamageType.MIND, dam)

         for j, b in ipairs(tgts) do
            if b ~= a then
               game.level.map:particleEmitter(a.x, a.y,
                                              math.max(
                                                 math.abs(b.x-a.x),
                                                 math.abs(b.y-a.y)),
                                              "rek_mind_beam", {tx=b.x-a.x, ty=b.y-a.y})

               --game.level.map:particleEmitter(a.x, a.y, math.max(math.abs(a.x-b.x), math.abs(a.y-b.y)), "lighttrail", {tx=b.x, ty=b.y})
               --game.level.map:particleEmitter(px, py, 1, "mindsear", {baseradius=baseradius * 0.66})
            end
         end
      end
      game:playSoundNear(self, "talents/spell_generic")
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[Force the pain you've felt out of your mind and into the world, doing %0.2f mind damage to target enemy and all enemies with radius 2 of them.  Each affected target after the first increases damage done to all targets by 10%%.
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
   info = function(self, t)
      local ret = ([[Feedback gains beyond your maximum allowed amount will reduce the cooldowns of your feedback talents, using %d excess feedback per turn of cooldown.  You cannot gain more overflow at once than your maximum feedback.
Talents are recharged in this order:
 - Share Pain
 - Memento Mori
 - Runaway Resonation
 - Resonance Field
 - Conversion]]):format(t.getEfficiency(self, t))
      if self:knowTalentType("psionic/discharge") or self:knowTalentType("psionic/discharge") == false then
         ret = ret..[[
 - Focused Wrath]]
      end
      if self:knowTalentType("psionic/charge") or self:knowTalentType("psionic/charge") == false then
         ret = ret..[[
 - Charged Shot
 - Domination Shot
 - Resonance Link]]
      end
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
      local a = game.level.map(x, y, Map.ACTOR)
      if not a then return nil end
      
      self:project(tg, x, y, function(px, py)
                      local a = game.level.map(px, py, Map.ACTOR)
                      if a then
                         local lost_life = a.max_life - a.life
                         --game.logSeen(self, "#ORANGE#DEBUG: Missing life: %d!#LAST#", lost_life)

                         local dam = lost_life * t.getDam(self, t) / 100
                         --game.logSeen(self, "#ORANGE#DEBUG: execute: %d!#LAST#", dam)
                         dam = math.min(dam, t.getMax(self, t))
                         --game.logSeen(self, "#ORANGE#DEBUG: capped execute: %d!#LAST#", dam)
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
   getCritBonus = function(self, t) return math.floor(self:combatMindCrit() / 2)  end,
   target = function(self, t)
      return {type="hit", range=self:getTalentRange(t)}
   end,
   getDuration = function(self, t) return self:combatTalentScale(t, 2, 5) end,
   action = function(self, t)
      if self:hasEffect(self.EFF_REK_MTYR_RESONATION) then
         self:removeEffect(self.EFF_REK_MTYR_RESONATION)
      end
      self:setEffect(self.EFF_REK_MTYR_RESONATION, t.getDuration(self, t), {src=self, power=t.getCritBonus(self, t)})
      game.level.map:particleEmitter(self.x, self.y, 1, "generic_charge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
      return true
   end,
   info = function(self, t)
      local duration = t.getDuration(self, t)
      local crit_bonus = t.getCritBonus(self, t)
      return ([[Focus your feedback in on itself, setting your mind surging with unstoppable power.  For %d turns, your critical power is increased by half your mental critical rate (%d%% => %d), and your mental critical rate becomes 100%%.]]):format(duration, self:combatMindCrit(), crit_bonus)
   end,
}

