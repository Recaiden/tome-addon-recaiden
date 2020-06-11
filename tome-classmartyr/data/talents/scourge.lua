newTalent{
   name = "Scorn", short_name = "REK_MTYR_SCOURGE_INFEST",
   type = {"demented/scourge", 1},
   require = martyr_req1,
   points = 5,
   cooldown = 6,
   range = 1,
   insanity = -5,
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
      if self:knowTalent(self.T_REK_MTYR_SCOURGE_SPROUTING) then
         local t2 = self:getTalentFromId(self.T_REK_MTYR_SCOURGE_SPROUTING)
         ramp = ramp + t2.getRamp(self, t2)
         if amInsane(self) then
            fail = t2.getFail(self, t2)
         end
      end
      if self:knowTalent(self.T_REK_MTYR_SCOURGE_SHARED_FEAST) then
         local t4 = self:getTalentFromId(self.T_REK_MTYR_SCOURGE_SHARED_FEAST)
         lifesteal = lifesteal + t4.getDrain(self, t4)
      end

      local hit = self:attackTarget(target, nil, 1, true)
      if hit and not target.dead then
         target:setEffect(target.EFF_REK_MTYR_SCORN, 5, {damage=dam, ramp=ramp, fail=fail, lifesteal=lifesteal, src=self, apply_power=self:combatMindpower()})
         -- insanityBonus
         if amInsane(self) then
            if target:canBe("stun") then
               target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatMindpower()})
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
   name = "Mental Collapse", short_name = "REK_MTYR_SCOURGE_SPROUTING",
   type = {"demented/scourge", 2},
   require = martyr_req2,
   points = 5,
   mode = "passive",
   getRamp = function(self, t) return self:combatTalentScale(t, 0.08, 0.3) end,
   getFail = function(self, t) return math.min(33, self:combatTalentScale(t, 10, 20)) end,
   info = function(self, t)
      return ([[The knowledge of their failure compounds over time, increasing the mind damage by %d%% each turn.

#GREEN#Our Gift:#LAST# Scorn also gives the victim a %d%% chance to fail to use talents.]]):format(t.getRamp(self, t)*100, t.getFail(self, t))
   end,
}

newTalent{
   name = "Mass Hysteria", short_name = "REK_MTYR_SCOURGE_GRASPING_TENDRILS",
   type = {"demented/scourge", 3},
   require = martyr_req3,
   points = 5,
   cooldown = 8,
   insanity = 10,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 180) end,
   range = 10,
   radius = 3,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
   action = function(self, t)
       local tg = self:getTalentTarget(t)
       local x, y = self:getTarget(tg)
       if not x or not y then return nil end
       local _ _, x, y = self:canProject(tg, x, y)
       local target = game.level.map(x, y, Map.ACTOR)
       if not target then return nil end
       if not target:hasEffect(target.EFF_REK_MTYR_SCORN) then return nil end

       local DT = require("engine.DamageType")
       local dam = self:mindCrit(t.getDamage(self, t))
       local tgts = {}
       local gift = amInsane(self) and self:knowTalent(self.T_REK_MTYR_SCOURGE_INFEST)
       local t1 = self:getTalentFromId(self.T_REK_MTYR_SCOURGE_INFEST)
       local ramp = 1
       local fail = 0
       local lifesteal = 0
       if self:knowTalent(self.T_REK_MTYR_SCOURGE_SPROUTING) then
          local t2 = self:getTalentFromId(self.T_REK_MTYR_SCOURGE_SPROUTING)
          ramp = ramp + t2.getRamp(self, t)
          if amInsane(self) then
            fail = t2.getFail(self, t2)
         end
       end
       if self:knowTalent(self.T_REK_MTYR_SCOURGE_SHARED_FEAST) then
          local t4 = self:getTalentFromId(self.T_REK_MTYR_SHARED_FEAST)
          lifesteal = lifesteal + t4.getDrain(self, t4)
       end
       self:project({type="ball", radius=self:getTalentRadius(t), x=target.x, y=target.y}, target.x, target.y,
                    function(px, py)
                       local tgt = game.level.map(px, py, engine.Map.ACTOR)
                       if (px ~= target.x or py ~= target.y) and tgt and self:reactionToward(tgt) < 0 then tgts[#tgts+1] = {tgt=tgt, dist=core.fov.distance(target.x, target.y, px, py)} end
                    end)
       if #tgts > 0 then
          table.sort(tgts, "dist")
          for i, d in ipairs(tgts) do
             if d.tgt:canBe("knockback") then
                d.tgt:pull(target.x, target.y, self:getTalentRadius(t)+1,
                           function(a)
                              game.logSeen(d.tgt, "%s is pulled into %s!", d.tgt.name, target.name)
                              DT:get(DT.PHYSICAL).projector(self, d.tgt.x, d.tgt.y, DT.PHYSICAL, dam)
                              DT:get(DT.PHYSICAL).projector(self, target.x, target.y, DT.PHYSICAL, dam)
                              if gift then
                                 d.tgt:setEffect(target.EFF_REK_MTYR_SCORN, t1.getDuration(self, t1), {damage=t1.getDotDamage(self, t1), ramp=ramp, fail=fail, lifesteal=lifesteal, src=self})
                                 
                              end
                           end
                          )
             end
          end
       end
      return true
   end,
   info = function(self, t)
      return ([[A scorned target gathers its fellows from within range %d#SLATE#(Checks knockback resistance)#LAST# creating a dangerous feedback effect that deals %d physical damage to both.

#GREEN#Our Gift:#LAST# all targets pulled in also have Scorn applied to them.
]]):format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
   end,
}

newTalent{
   name = "Triumphant Vitality", short_name = "REK_MTYR_SCOURGE_SHARED_FEAST",
   type = {"demented/scourge", 4},
   require = martyr_req4,
   points = 5,
   mode = "passive",
   getDrain = function(self, t) return math.min(1.0, self:combatTalentScale(t, 0.2, 0.45)) end,
   info = function(self, t)
      return ([[Whenever your Scorn effect deals damage, you heal for %d%% of the damage done.  
]]):format(100*t.getDrain(self, t))
   end,
}