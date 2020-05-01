local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
   name = "REK_WIGHT_FURY", iamge = "talents/rek_wight_fury.png",
   desc = "Fury of the Wild",
   type = "magical",
   subtype = { darkness=true },
   status = "beneficial",
   parameters = { power = 100 },
   long_desc = function(self, eff) return ("The target is wreathed in elemental energy, dealing %d damage on-hit."):format(eff.power) end,
   callbackOnDealDamage = function(self, eff, val, target, dead, death_note)
      if dead then return end
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
   name = "REK_WIGHT_VISION", image = "talents/rek_wight_ghost_vision.png",
   desc = "Sensing",
   long_desc = function(self, eff) return "Improves senses, allowing vision without sight." end,
   type = "other",
   subtype = { sense=true },
   status = "beneficial",
   parameters = { range=10, actor=1 },
   activate = function(self, eff)
      eff.rid = self:addTemporaryValue("detect_range", eff.range)
      eff.aid = self:addTemporaryValue("detect_actor", eff.actor)
      self.detect_function = eff.on_detect
      game.level.map.changed = true

      if self.hotkey and self.isHotkeyBound then
	 local pos = self:isHotkeyBound("talent", self.T_REK_WIGHT_GHOST_VISION)
	 if pos then
	    self.hotkey[pos] = {"talent", self.T_REK_WIGHT_GHOST_VISION_JUMP}
	 end
      end
      
      local ohk = self.hotkey
      self.hotkey = nil -- Prevent assigning hotkey, we do that
      self:learnTalent(self.T_REK_WIGHT_GHOST_VISION_JUMP, true, eff.level, {no_unlearn=true})
      self.hotkey = ohk
      
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("detect_range", eff.rid)
      self:removeTemporaryValue("detect_actor", eff.aid)
      self.detect_function = nil

      if self.hotkey and self.isHotkeyBound then
	 local pos = self:isHotkeyBound("talent", self.T_REK_WIGHT_GHOST_VISION_JUMP)
	 if pos then
	    self.hotkey[pos] = {"talent", self.T_REK_WIGHT_GHOST_VISION}
	 end
      end
      
      self:unlearnTalent(self.T_REK_WIGHT_GHOST_VISION_JUMP, eff.level, nil, {no_unlearn=true})      
   end,
         }

newEffect{
	name = "REK_WIGHT_DESPAIR", image = "effects/despair.png",
	desc = "Despair",
	long_desc = function(self, eff) return ("The target is in despair, reducing their armour, defence, and saves resist by %d."):tformat(-eff.statChange) end,
	charges = function(self, eff) return math.floor(-eff.statChange) end,	
	type = "mental",
	subtype = { fear=true },
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