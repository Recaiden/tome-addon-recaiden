require "engine.Game"

local _M = loadPrevious(...)

local k, mod = debug.getlocal(6, 2) 	
if k == "mod" and mod.addons and mod.addons.orcs then
   Talents.talents_def.T_RAZE.getResists = function(self, t) return self:combatTalentScale(t, 2, 25) end

   Talents.talents_def.T_RAZE.on_learn = function(self, t)
      self:learnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY)
   end

   Talents.talents_def.T_RAZE.on_unlearn = function(self, t)
      self:unlearnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY)
   end
   Talents.talents_def.T_RAZE.soulBonus = function(self, t) return 1 end
   Talents.talents_def.T_RAZE.info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[You revel in death and can take on the power of the Eternal Wyrm using Prismatic Blood, granting you %d%% darkness resistance and the ability to Doom enemies using your other draconic talents.

Whenever you inflict damage to a target, you deal an additional %0.2f darkness damage (up to 15 times per turn).
The damage will scale with the higher of your spell or mind power.

You will gain a soul whenever you score a kill or hit with Devour.

Doom is darkness damage that can reduce enemy healing by up to 75%%.
]]):
      format(t.getResists(self, t), damDesc(self, DamageType.DARKNESS, damage), t.soulBonus(self,t))
   end

   Talents.talents_def.T_NECROTIC_BREATH.name = "Ureslak's Curse"
   Talents.talents_def.T_NECROTIC_BREATH.radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.7)) end
   Talents.talents_def.T_NECROTIC_BREATH.range = function(self, t) return 7 end
   Talents.talents_def.T_NECROTIC_BREATH.direct_hit = false
   Talents.talents_def.T_NECROTIC_BREATH.target = function(self, t)
      return {type="ball", nolock=true, pass_terrain=false, friendly_fire=false, nowarning=true, range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
   end,
   Talents.talents_def.T_NECROTIC_BREATH.getDamage = function(self, t)
      self:combatTalentStatDamage(t, "mag", 30, 550)
   end
   Talents.talents_def.T_NECROTIC_BREATH.getDuration = function(self, t)
      self:combatTalentScale(t, 3, 5)
   end
   Talents.talents_def.T_NECROTIC_BREATH.action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      self:project(tg, x, y, DamageType.CIRCLE_DEATH, {dam=self:spellCrit(t.getDamage(self, t))/4,dur=t.getDuration(self, t)})
      game.level.map:particleEmitter(x, y, tg.radius, "circle", {zdepth=6, oversize=1, a=130, appear=8, limit_life=12, speed=5, img="necromantic_circle", radius=tg.radius})
      
      if core.shader.active(4) then
         local bx, by = self:attachementSpot("back", true)
         self:addParticles(Particles.new("shader_wings", 1, {img="darkwings", life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
      end
      game:playSoundNear(self, "talents/fire")
      return true
   end
   Talents.talents_def.T_NECROTIC_BREATH.info  = function(self, t)
      return ([[You conjure a wave of deathly miasma in a circle of radius %d. Any target caught in the area will take %0.2f darkness damage over %d turns and receive either a bane of confusion or a bane of blindness for the duration.
Magic: Increases damage]]):format(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)), t.getDuration(self, t))
   end
end

return _M
