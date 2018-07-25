local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"
newEffect{
   name = "REK_LIGHTNING_SPEED", image = "talents/lightning_speed.png",
   desc = "Lightning Speed",
   long_desc = function(self, eff) return ("Turn into pure lightning, moving %d%% faster. It also increases your lightning resistance by 100%% and your physical resistance by 30%%."):format(eff.power) end,
   type = "physical",
   subtype = { lightning=true, speed=true },
   status = "beneficial",
   parameters = {},
   on_gain = function(self, err) return "#Target# turns into lightning!.", "+Lightning Speed" end,
   on_lose = function(self, err) return "#Target# is back to normal.", "-Lightning Speed" end,
   get_fractional_percent = function(self, eff)
      local d = game.turn - eff.start_turn
      return util.bound(360 - d / eff.possible_end_turns * 360, 0, 360)
   end,
   activate = function(self, eff)
      eff.start_turn = game.turn
      eff.possible_end_turns = 10 * (eff.dur+1)
      eff.tmpid = self:addTemporaryValue("lightning_speed", 1)
      eff.moveid = self:addTemporaryValue("movement_speed", eff.power/100)
      eff.resistsid = self:addTemporaryValue("resists", {
						[DamageType.PHYSICAL]=30,
						[DamageType.LIGHTNING]=100,
      })
      eff.capresistsid = self:addTemporaryValue("resists_cap", {
						   [DamageType.LIGHTNING]=100,
      })
      if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
      eff.particle = self:addParticles(Particles.new("bolt_lightning", 1))
   end,
   deactivate = function(self, eff)
      self:removeParticles(eff.particle)
      self:removeTemporaryValue("lightning_speed", eff.tmpid)
      self:removeTemporaryValue("resists", eff.resistsid)
      self:removeTemporaryValue("resists_cap", eff.capresistsid)
      if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
      self:removeTemporaryValue("movement_speed", eff.moveid)
   end,
}
