local class = require"engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local PartyLore = require "mod.class.interface.PartyLore"

local load = function(self, data)
   ActorTalents:loadDefinition('/data-race-banshee/talents.lua')
   ActorTemporaryEffects:loadDefinition('/data-race-banshee/effects.lua')
   Birther:loadDefinition("/data-race-banshee/birth.lua")
   PartyLore:loadDefinition("/data-race-banshee/lore/kidnapper-hideout.lua")
   DamageType:loadDefinition("/data-race-banshee/damage_types.lua")
end
class:bindHook('ToME:load', load)

class:bindHook("MapGeneratorStatic:subgenRegister", function(self, data)
		  if data.mapfile ~= "wilderness/eyal" then return end
		  
		  data.list[#data.list+1] = {
		     x = 23, y = 19, w = 1, h = 1, overlay = true,
		     generator = "engine.generator.map.Static",
		     data = {
			map = "race-banshee+tomb-overlay",
		     },
		  }
end)
