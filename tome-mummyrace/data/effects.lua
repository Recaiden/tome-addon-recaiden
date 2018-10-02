local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
   name = "ENTANGLE", image = "talents/thorn_grab.png",
   desc = "Mummy's Entangle",
   long_desc = function(self, eff) return ("The target is constricted in mummy bindings, reducing its speed by %d%%."):format(eff.dam, eff.speed*100) end,
   type = "physical",
   subtype = { slow=true },
   status = "detrimental",
   parameters = { speed=20 },
   activate = function(self, eff)
      eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.speed)
   end,
   on_timeout = function(self, eff)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("global_speed_add", eff.tmpid)
   end,
}

newEffect{
   name = "MUMMY_WEAKNESS", image = "talents/exploit_weakness.png",
   desc = "Weakened Defenses",
   long_desc = function(self, eff) return ("The target's damage resistance has been reduced by %d%%."):format(eff.cur_inc) end,
   type = "magical",
   subtype = { sunder=true },
   status = "detrimental",
   parameters = { inc=1, max=5 },
   on_merge = function(self, old_eff, new_eff)
      self:removeTemporaryValue("resists", old_eff.tmpid)
      old_eff.cur_inc = math.max(old_eff.cur_inc + new_eff.inc, new_eff.max)
      old_eff.tmpid = self:addTemporaryValue("resists", {all = old_eff.cur_inc})
      
      old_eff.dur = new_eff.dur
      return old_eff
   end,
   activate = function(self, eff)
      eff.cur_inc = eff.inc
      eff.tmpid = self:addTemporaryValue("resists", {all = eff.inc,})
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("resists", eff.tmpid)
   end,
}

newEffect{
   name = "MUMMY_STRENGTH", image = "talents/exploit_weakness.png",
   desc = "Strengthened Defenses",
   long_desc = function(self, eff) return ("The target's determination increases their damage resistance by %d%%."):format(eff.cur_inc) end,
   type = "magical",
   subtype = { sense=true },
   status = "beneficial",
   parameters = { inc=1, max=5 },
   on_merge = function(self, old_eff, new_eff)
      self:removeTemporaryValue("resists", old_eff.tmpid)
      old_eff.cur_inc = math.max(old_eff.cur_inc + new_eff.inc, new_eff.max)
      old_eff.tmpid = self:addTemporaryValue("resists", {all = old_eff.cur_inc})
      
      old_eff.dur = new_eff.dur
      return old_eff
   end,
   activate = function(self, eff)
      eff.cur_inc = eff.inc
      eff.tmpid = self:addTemporaryValue("resists", {all = eff.inc,})
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("resists", eff.tmpid)
   end,
}
