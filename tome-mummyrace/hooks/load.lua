local class = require"engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local PartyLore = require "mod.class.interface.PartyLore"

local load = function(self, data)
  ActorTalents:loadDefinition('/data-mummyrace/talents.lua')
  ActorTemporaryEffects:loadDefinition('/data-mummyrace/effects.lua')
  Birther:loadDefinition("/data-mummyrace/birth.lua")
  PartyLore:loadDefinition("/data-mummyrace/lore/mummy-crypt-ruins.lua")
end
class:bindHook('ToME:load', load)

class:bindHook("MapGeneratorStatic:subgenRegister", function(self, data)
		  if data.mapfile ~= "wilderness/eyal" then return end
		  
		  data.list[#data.list+1] = {
		     x = 15, y = 49, w = 1, h = 1, overlay = true,
		     generator = "engine.generator.map.Static",
		     data = {
			map = "mummyrace+tomb-overlay",
		     },
		  }
end)

class:bindHook("Entity:loadList", function(self, data)
		  if data.file == "/data/zones/wilderness/grids.lua" then
		     self:loadList("/data-mummyrace/wilderness-overlay-grids.lua", data.no_default, data.res, data.mod, data.loaded)
		  end
end)
