local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
   name = "FLN_SHADOW_FADE_SHIELD", image = "talents/flash_of_the_blade.png",
   desc = "Protected by the Sun",
   long_desc = function(self, eff) return "The Sun has granted brief invulnerability." end,
   type = "other",
   subtype = {},
   status = "beneficial",
   on_gain = function(self, err) return "#Target# is surrounded by a radiant shield!", "+Divine Shield" end,
   parameters = {},
   activate = function(self, eff)
      eff.iid = self:addTemporaryValue("invulnerable", 1)
      eff.imid = self:addTemporaryValue("status_effect_immune", 1)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("invulnerable", eff.iid)
      self:removeTemporaryValue("status_effect_immune", eff.imid)
   end,
   on_timeout = function(self, eff)
      -- always remove
      return true
   end,
}

newEffect{
   name = "FLN_SHADOW_REFT", image = "effects/fln_shadow_shadow_reave.png",
   desc = _t"Shadowless",
   long_desc = function(self, eff) return ("Target has lost their shadow, lowering light/dark resistance by %d%%."):tformat(-eff.resists) end,
   type = "mental",
   subtype = { shadow=true, psionic=true },
   status = "detrimental",
   parameters = { resists = 5 },
   on_gain = function(self, err) return _t"#F53CBE##Target#'s shadow is torn away!", _t"+Reft" end,
   on_lose = function(self, err) return _t"#Target#'s shadow returns to them.", _t"-Reft" end,
   activate = function(self, eff)
      eff.resistChangeId = self:addTemporaryValue("resists", { [DamageType.LIGHT]=-1*eff.resists, [DamageType.DARKNESS]=-1*eff.resists })
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("resists", eff.resistChangeId)
   end,
}

-- type other because the original was and this is a resource mechanic.
newEffect{
   name = "FLN_ABSORPTION_STRIKE", image = "talents/absorption_strike.png",
   desc = _t"Shadow Absorption",
   long_desc = function(self, eff) return ("The target's light has been drained, reducing light resistance by %d%%."):tformat(eff.power) end,
   type = "other",
   subtype = { sun=true, },
   status = "detrimental",
   parameters = { power = 10 },
   on_gain = function(self, err) return _t"#Target# is drained from light!", _t"+Shadow Absorption" end,
   on_lose = function(self, err) return _t"#Target#'s light is back.", _t"-Shadow Absorption" end,
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHT]=-eff.power})
   end,
   callbackOnMeleeHit = function(self, eff, attacker, dam)
      attacker:incHate(1)
   end,
         }

-- type other because it's just a delayed talent.  Defend by not getting melee hit.
newEffect{
   name = "FLN_LIGHT_VICTIM", image = "talents/fln_shadow_mages.png",
   desc = _t"Searing Mark",
   long_desc = function(self, eff) return ("The target is marked by a shadow anorithil, and will take %d light damage if hit by the shadow's summoner."):tformat(eff.power) end,
   type = "other",
   subtype = { sun=true, },
   status = "detrimental",
   parameters = { power = 10 },
   on_gain = function(self, err) return _t"#Target# is marked by the light!", _t"+Searing Mark" end,
   on_lose = function(self, err) return _t"#Target#'s is free from the mark.", _t"-Searing Mark" end,
   activate = function(self, eff)
      eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=1, oversize=1.0, a=200, appear=8, speed=0, img="fln_marked", radius=0}))
   end,
   deactivate = function(self, eff)
      self:removeParticles(eff.particle)
   end,
   callbackOnMeleeHit = function(self, eff, attacker, dam)
      if attacker == eff.fallen then
         --trigger the spell
         local x = self.x
         local y = self.y
         local target = self
         if not x or not y then return nil end

         local projector = eff.shadow or eff.fallen
         if target then
            projector:project({type="hit", talent=t}, x, y, DamageType.LIGHT, eff.power, {type="light"})
            self:removeEffect(self.EFF_FLN_LIGHT_VICTIM)
         end
         
         -- Add a lasting map effect
         game.level.map:addEffect(projector,
                                  x, y, 4,
                                  DamageType.LIGHT, eff.power / 2,
                                  1,
                                  5, nil,
                                  {type="light_zone"},
                                  nil, false, false
                                 )
         
         game:playSoundNear(self, "talents/flame")
      end
   end,
}