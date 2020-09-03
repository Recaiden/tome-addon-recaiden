local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
   name = "REK_WIGHT_FURY", image = "talents/rek_wight_fury.png",
   desc = "Fury of the Wild",
   type = "magical",
   subtype = { darkness=true },
   status = "beneficial",
   parameters = { power = 100 },
   long_desc = function(self, eff) return ("The target is wreathed in elemental energy, dealing %d damage on-hit."):format(eff.power) end,
   callbackOnDealDamage = function(self, eff, val, target, dead, death_note)
      if dead then return end
      if target == self then return end
      if self.turn_procs.rek_wight_fury_damage then
         for i = 1, #self.turn_procs.rek_wight_fury_damage do
            if self.turn_procs.rek_wight_fury_damage[i] == target.uid then return end
         end
      end
      self.turn_procs.rek_wight_fury_damage = self.turn_procs.rek_wight_fury_damage or {}
      self.turn_procs.rek_wight_fury_damage[#self.turn_procs.rek_wight_fury_damage+1] = target.uid

      -- hit them with the damage
      local tg = {type="ball", range = 10, radius=1, selffire = false, friendlyfire = false}

      local particle = "ball_physical"
      local damtype = self.rek_wight_damage or DamageType.FIRE
      if damtype == DamageType.LIGHTNING then particle = "ball_lightning_beam"
      elseif damtype == DamageType.COLD then particle = "ball_ice"
      elseif damtype == DamageType.FIRE then particle = "fireflash"
      end
      game.level.map:particleEmitter(target.x, target.y, 1, particle, {radius=1, grids=grids, tx=x, ty=y})      
      self:project(tg, target.x, target.y, damtype, eff.power)
   end,
   activate = function(self, eff)
   end,
   deactivate = function(self, eff)
   end,
         }

newEffect{
   name = "REK_WIGHT_GHOSTLY", image = "talents/rek_wight_ghost_vision.png",
   desc = "Haunting Form",
   long_desc = function(self, eff) return ("The target is able to walk through walls and see enemies in range %d."):format(eff.power) end,
   type = "magical",
   subtype = { undead=true },
   status = "beneficial",
   parameters = { power = 10 },
   activate = function(self, eff)
      eff.pass = self:addTemporaryValue("can_pass", {pass_wall=70})
      eff.rid = self:addTemporaryValue("detect_range", eff.power)
      eff.aid = self:addTemporaryValue("detect_actor", 1)
      game.level.map.changed = true
      if not self.shader then
	 eff.set_shader = true
         self.shader = "moving_transparency"
	 self.shader_args = { a_min=0.3, a_max=0.8, time_factor = 3000 }
	 self:removeAllMOs()
	 game.level.map:updateMap(self.x, self.y)
      end
      self:effectTemporaryValue(eff, "no_breath", 1)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("can_pass", eff.pass)
      self:removeTemporaryValue("detect_range", eff.rid)
      self:removeTemporaryValue("detect_actor", eff.aid)
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
   name = "REK_WIGHT_DESPAIR", image = "talents/rek_wight_drain.png",
   desc = "Despair",
   long_desc = function(self, eff) return ("The target is in despair, reducing their armour, defence, and saves resist by %d."):format(-eff.statChange) end,
   charges = function(self, eff) return math.floor(-eff.statChange) end,	
   type = "mental",
   subtype = { fear=true }, -- but bypasses fear resistance
   status = "detrimental",
   parameters = {statChange = -10},
   on_gain = function(self, err) return "#F53CBE##Target# is in despair!", "+Despair" end,
   on_lose = function(self, err) return "#Target# is no longer in despair", "-Despair" end,
   activate = function(self, eff)
      eff.despairSaveM = self:addTemporaryValue("combat_mentalresist", eff.statChange)
      eff.despairSaveS = self:addTemporaryValue("combat_spellresist", eff.statChange)
      eff.despairSaveP = self:addTemporaryValue("combat_physresist", eff.statChange)
      eff.despairArmor = self:addTemporaryValue("combat_armor", eff.statChange)
      eff.despairDef = self:addTemporaryValue("combat_def", eff.statChange)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("combat_mentalresist", eff.despairSaveM)
      self:removeTemporaryValue("combat_spellresist", eff.despairSaveS)
      self:removeTemporaryValue("combat_physresist", eff.despairSaveP)
      self:removeTemporaryValue("combat_armor", eff.despairArmor)
      self:removeTemporaryValue("combat_def", eff.despairDef)
   end,
}

newEffect{
   name = "REK_WIGHT_FEARLESS", image = "talents/rek_wight_drain_fearless.png",
   desc = "Immune to Draining Presence",
   long_desc = function(self, eff) return "You refused to give in to fear and can ignore the draining presence of wights...for now." end,
   type = "mental",
   subtype = { fear=true },
   status = "beneficial",
   parameters = {},
   on_gain = function(self, err) return nil, true end,
   on_lose = function(self, err) return nil, true end,
   activate = function(self, eff)
      game:onTickEnd(function() self:removeEffect(self.EFF_REK_WIGHT_DESPAIR) end)
   end,
}