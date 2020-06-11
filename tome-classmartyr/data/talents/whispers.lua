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
Reduce incoming damage by a flat amount as you approach sanity, up to %d per hit (currently %d).
Both values will improve with your level.

You benefit from #ORANGE#Sanity Bonus#LAST# while you have up to 40 Insanity.
You benefit from #GREEN#Our Gift#LAST# while you have at least 60 Insanity.

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
   getChance = function(self, t) return 20 end,
   getDuration = function(self, t) return 3 end,
   callbackOnActBase = function (self, t)
      if not rng.percent(t.getChance(self, t)) then return end
      local _, _, gs = util.findFreeGrid(self.x, self.y, 10, true, {})
      if gs and #gs > 0 then
         local dur = t.getDuration(self, t)
         
         local DamageType = require "engine.DamageType"
         local MapEffect = require "engine.MapEffect"
         local x, y = gs[#gs][1], gs[#gs][2]
         local options = {
            {
               dam=DamageType.REK_MTYR_GUIDE_HEAL,
               r=60, g=255, b=60
            },
            {
               dam=DamageType.REK_MTYR_GUIDE_BUFF,
               r=20, g=100, b=255
            },
            {
               dam=DamageType.REK_MTYR_GUIDE_FLASH,
               r=255, g=210, b=60
            }
         }
         local type = options[rng.range(1, #options)]
         local ground_effect = game.level.map:addEffect(game.player, x, y, dur, type.dam, 5, rng.range(1, 2), 5, nil, MapEffect.new{color_br=type.r, color_bg=type.g, color_bb=type.b, alpha=100, effect_shader="shader_images/sun_effect.png"}, nil, true)
         self:setEffect(self.EFF_REK_MTYR_GUIDANCE_AVAILABLE, 3, {src=self, ground_effect=ground_effect})
         game.logSeen(self, "#YELLOW#A guiding light appears!#LAST#", self.name:capitalize())
      end
   end,
   info = function(self, t)
      return ([[While in combat, zones of guiding light will appear nearby, lasting %d turns.
Entering a green light will cause you to regenerate for %d health per turn for 5 turns.
Entering a blue light will refresh you, reducing the duration of outstanding cooldowns by %d turns.
Entering a orange light will grant you vision sevenfold, allowing you to see stealthed and invisible targets with power %d. and fight while blinded.]]):format(3, 1, 2, 3)
   end,
}

-- green light is aura of mind damage , light will imbue you with a destructive psychic aura, dealing %d mind damage per turn to enemies in range 2
-- orange blinds light will release a brilliant flash, blinding and reducing the sight radius of enemies in range 10.
newTalent{
   name = "Warning Lights", short_name = "REK_MTYR_WHISPERS_WARNING",
   type = {"demented/whispers", 3},
   require = martyr_req3,
   points = 5,
   mode = "passive",
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 4, 32) end,
   getDuration = function(self, t) return 5 end,
   radius = 2,
   info = function(self, t)
      return ([[Entering any light will imbue you with a destructive aura, dealing %d mind damage to enemies within range 2 each turn for %d turns.

#{italic}#The light whispers secrets to bring about the destruction of your enemies.#{normal}#]]):format(damDesc(self, DamageType.MIND, t.getDamage(self, t)), t.getDuration(self, t))
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