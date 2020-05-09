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
   -- todo pre use can't be poinned, dazed, etc.
   getMinSteps = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
   getMaxSteps = function(self, t) return 8 end,
   info = function(self, t)
      return ([[Step into the time between seconds and move at infinite speed.  This will last for a random number of steps between %d and %d, or for one turn, whichever comes sooner.

#{italic}#Perfection is not 'going faster'.  Perfection is 'already being there'.#{normal}#]]):format(t.getMinSteps(self, t), t.getMaxSteps(self, t))
   end,
}

newTalent{
   name = "Dement", short_name = "REK_MTYR_POLARITY_DEMENT",
   type = {"demented/polarity", 3},
   require = martyr_req3,
   points = 5,
   cooldown = 8,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 3.2) end,
   getExtension = function(self, t) return self:combatTalentScale(t, 3, 5) end,
   range = 0,
   radius = 10,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
   end,
   info = function(self, t)
      return ([[...
]]):format()
   end,
}

newTalent{
   name = "Mad Inspiration", short_name = "REK_MTYR_POLARITY_REBOUND",
   type = {"demented/polarity", 4},
   require = martyr_req4,
   points = 5,
   mode = "sustained",
   cooldown = function(self, t) return math.max(25, self:combatTalentScale(t, 60, 35)) end,
   callbackOnHit = function(self, eff, cb, src)
      if cb.value >= (self.life - self.die_at) then
         cb.value = 0

         self:forceUseTalent(self.T_REK_MTYR_POLARITY_JOLT, {ignore_energy=true})
         game.logSeen(self, "#YELLOW#%s awakens from a terrible dream!#LAST#", self.name:capitalize())
         self:incInsanity(-1 * self:getInsanity())
         self:setEffect(self.EFF_REK_MTYR_JOLT_SHIELD, 1, {src=self})
      end
      return cb.value
   end,
   activate = function(self, t)
      game:playSoundNear(self, "talents/dispel")
      local ret = {}
      
      return ret
   end,
   deactivate = function(self, t, p)
      --self:removeParticles(p.particle)
      return true
   end,
   info = function(self, t)
      return ([[If you suffer damage that would kill you, you instead awake from a dream of dying, setting your insanity to zero and becoming immune to damage until the end of your next action.
]]):format()
   end,
}