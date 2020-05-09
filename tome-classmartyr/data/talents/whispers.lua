newTalent{
   name = "Slipping Psyche", short_name = "REK_MTYR_WHISPERS_SLIPPING_PSYCHE",
   type = {"demented/whispers", 1},
   require = martyr_req1,
   points = 5,
   mode = "passive",
   getPower = function(self, t)
      input = self:getInsanity() * self.level * self:getTalentLevel(t)
      return self:combatScale(input, 3, 100, 25, 25000)
   end,
   getMaxPower = function(self, t)
      input = 100 * self.level * self:getTalentLevel(t)
      return self:combatScale(input, 3, 100, 25, 25000)
   end,
   getReduction = function(self, t)
      input = (100-self:getInsanity()) * self.level * self:getTalentLevel(t)
      return self:combatScale(input, 6, 100, 60, 25000)
   end,
   getMaxReduction = function(self, t)
      input = 100 * self.level * self:getTalentLevel(t)
      return self:combatScale(input, 6, 100, 60, 25000)
   end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "flat_damage_armor", {all=t.getReduction(self, t)})
      self:talentTemporaryValue(p, "combat_dam", t.getPower(self, t))
   end,
   callbackOnAct = function (self, t)
      self:updateTalentPassives(t.id)
   end,
   callbackOnTalentPost = function(self, t, ab, ret, silent)
      self:updateTalentPassives(t.id)
   end,
   info = function(self, t)
      return ([[Gain physical power as you gain insanity, up to %d (currently %d).
Reduce incoming damage as you approach sanity, up to %d (currently %d).
Both values will improve with your level.

You benefit from #ORANGE#Sanity Bonus#LAST# when you have up to 40 Insanity.
You benefit from #GREEN#Our Gift#LAST# when you have at least 60 Insanity.

#{italic}#As long as I don't start thinking like #GREEN#us#LAST#, I'll be safe.#{normal}#
]]):format(t.getMaxPower(self, t), t.getPower(self, t), t.getMaxReduction(self, t), t.getReduction(self, t))
   end,
}

newTalent{
   name = "Guiding Light", short_name = "REK_MTYR_WHISPERS_GUIDING_LIGHT",
   type = {"demented/whispers", 2},
   require = martyr_req2,
   points = 5,
   mode = "passive",
   info = function(self, t)
      return ([[While in combat, zones of guiding light will appear nearby.  Entering one will ...]]):format()
   end,
}

newTalent{
   name = "???", short_name = "REK_MTYR_WHISPERS_UNVEIL",
   type = {"demented/whispers", 3},
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
   name = "Jolt Awake", short_name = "REK_MTYR_WHISPERS_JOLT",
   type = {"demented/whispers", 4},
   require = martyr_req4,
   points = 5,
   mode = "sustained",
   cooldown = function(self, t) return math.max(25, self:combatTalentScale(t, 60, 35)) end,
   callbackOnHit = function(self, eff, cb, src)
      if cb.value >= (self.life - self.die_at) then
         cb.value = 0

         self:forceUseTalent(self.T_REK_MTYR_WHISPERS_JOLT, {ignore_energy=true})
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