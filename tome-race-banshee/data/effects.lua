local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
   name = "REK_BANSHEE_GHOSTLY", image = "talents/rek_banshee_ghost.png",
   desc = "Ghostly Form",
   long_desc = function(self, eff) return ("The target is able to walk through walls, and and gains %d%% movement speed"):format(eff.power) end,
   type = "magical",
   subtype = { darkness=true },
   status = "beneficial",
   parameters = { power = 100, steps = 3 },
   activate = function(self, eff)
      eff.pass = self:addTemporaryValue("can_pass", {pass_wall=70})
      eff.moveid = self:addTemporaryValue("movement_speed", eff.power / 100)
      if not self.shader then
	 eff.set_shader = true
	 self.shader = "moving_transparency"
	 self.shader_args = { a_min=0.3, a_max=0.8, time_factor = 3000 }
	 self:removeAllMOs()
	 game.level.map:updateMap(self.x, self.y)
      end
      self:effectTemporaryValue(eff, "no_breath", 1)
   end,
   callbackOnMove = function(self, eff, moved, force, ox, oy, x, y)
      if not moved then return end
      if ox == x and oy == y then return end
      eff.steps = eff.steps - 1
      if eff.steps <= 0 and eff.moveid then
	 self:removeTemporaryValue("movement_speed", eff.moveid)
	 eff.moveid = nil
	 eff.power = 0
      end
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("can_pass", eff.pass)
      if eff.moveid then
	 self:removeTemporaryValue("movement_speed", eff.moveid)
      end
      if eff.set_shader then
	 self.shader = nil
	 self:removeAllMOs()
	 game.level.map:updateMap(self.x, self.y)
      end
      if not self:canMove(self.x, self.y, true) then
	 local free = false
	 local dist = 1
	 while not free and dist < 50 do
	    local x, y = util.findFreeGrid(self.x, self.y, dist, false, {[Map.ACTOR]=true})
	    free = self:teleportRandom(x, y, 0)
	    dist = dist + 1
	 end
      end
   end,
}

newEffect{
   name = "REK_BANSHEE_CURSE", image = "talents/rek_banshee_curse.png",
   desc = "Banshee's Doom",
   long_desc = function(self, eff) return ("The target is doomed to die, reducing their healing factor by %d%%."):format(10 * eff.stacks) end,
   type = "magical",
   subtype = { arcane=true },
   status = "detrimental",
   parameters = { stacks=1, max_stacks=1 },
   on_merge = function(self, old_eff, new_eff)
      self:removeTemporaryValue("healing_factor", old_eff.healid)
      old_eff.dur = new_eff.dur
      old_eff.stacks = old_eff.stacks + 1
      old_eff.max_stacks = new_eff.max_stacks
      old_eff.stacks = math.min(old_eff.max_stacks, old_eff.stacks)
      old_eff.healid = self:addTemporaryValue("healing_factor", -0.1*old_eff.stacks)
      return old_eff
   end,
   activate = function(self, eff)
      eff.stacks = 1
      eff.healid = self:addTemporaryValue("healing_factor", -0.1*eff.stacks)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("healing_factor", eff.healid)
   end,
}
