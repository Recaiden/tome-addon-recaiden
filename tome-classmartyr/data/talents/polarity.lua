newTalent{
   name = "Deeper Shadows", short_name = "REK_MTYR_POLARITY_DEEPER_SHADOWS",
   type = {"demented/polarity", 1},
   require = martyr_req1,
   points = 5,
   mode = "passive",

   passives = function(self, t, p)

   end,

   info = function(self, t)
      return ([[...
]]):format()
   end,
}

newTalent{
   name = "Manic Speed", short_name = "REK_MTYR_POLARITY_MANIC_SPEED",
   type = {"demented/polarity", 2},
   require = martyr_req2,
   points = 5,
   insanity = 15,
   no_energy = true,
   cooldown = 12,
   on_pre_use = function(self, t, silent)
      if self:attr("never_move") then
         if not silent then game.logPlayer(self, "You can't use this if you can't move") end
         return false
      end
      return true
   end,
   getMinSteps = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
   getMaxSteps = function(self, t) return 8 end,
   info = function(self, t)
      return ([[Step into the time between seconds and move at infinite speed.  This will last for a random number of steps between %d and %d, or for one turn, whichever comes sooner.

#{italic}#Perfection is not 'going faster'.  Perfection is 'already being there'.#{normal}#]]):format(t.getMinSteps(self, t), t.getMaxSteps(self, t))
   end,
}

newTalent{
   name = "Mad Inspiration", short_name = "REK_MTYR_POLARITY_REBOUND",
   type = {"demented/polarity", 3},
   require = martyr_req3,
   points = 5,
   mode = "passive",
   getPower = function(self, t) return self:combatTalentScale(t, 5, 10) end,
   getDuration = function(self, t) return 10 end,
   getMaxStacks = function(self, t) return 5 end,
   callbackOnChaosEffect = function(self, t, effectname, ief, v)
      if self.turn_procs.rek_mtyr_inspired then return end
      local trig = t.getTrigger(self, t)
      if ief < 0 then
         self.turn_procs.rek_mtyr_inspired = true
         self:setEffect(self.EFF_REK_MTYR_INSPIRED, 10, {stacks = 1, max_stacks=t.getMax(self, t)})
      end
   end,
   info = function(self, t)
      return ([[When you suffer a negative insanity effect, the mad visions grant you Inspiration, increasing your Mindpower by %d for %d turns.  This stacks up to %d times.
]]):format(t.getPower(self, t), t.getDuration(self, t) t.getMaxStacks(self, t))
   end,
}

newTalent{
   name = "Dement", short_name = "REK_MTYR_POLARITY_DEMENT",
   type = {"demented/polarity", 4},
   require = martyr_req4,
   points = 5,
   cooldown = 8,
   getDamage = function(self, t) return math.min(50, self:combatTalentMindDamage(t, 15, 40)) end,
   getDuration = function(self, t) return self:combatTalentScale(t, 3, 5) end,
   range = 10,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
   on_pre_use = function(self, t, silent)
      if not self:hasEffect(self.EFF_REK_MTYR_INSPIRED) then
         if not silent then game.logPlayer(self, "You must be Inspired to use this talent.") end
         return false
      end
      return true
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local _ _, x, y = self:canProject(tg, x, y)
      local target = game.level.map(x, y, Map.ACTOR)
      if not target then return end
      
      target:setEffect(target.EFF_REK_MTYR_DEMENTED, t.getDuration(self, t), {power=t.getPower(self, t) or 15, src=self})
      self:removeEffect(self.EFF_REK_MTYR_INSPIRED)
      return true
   end,
   info = function(self, t)
      return ([[Consume your Inspiration to drag a target into the depths of insanity, reducing their damage dealt by %d%% and increasing the cooldowns of any talents they use by %d%% for the next %d turns.
]]):format(t.getPower(self, t), t.getPower(self, t), t.getDuration(self, t))
   end,
}
