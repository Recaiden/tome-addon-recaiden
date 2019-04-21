local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorInventory = require "engine.interface.ActorInventory"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

class:bindHook("ToME:load", function(self, data)
  ActorInventory:defineInventory("REK_WYRMIC_GEM", "Socketed Gems", true, "Gems worn in/on the body, providing their worn bonuses without granting their latent damage type", nil, {equipdoll_back="ui/equipdoll/gem_inv.png", stack_limit = 1})
  Talents:loadDefinition('/data-revamped-wyrmic/talents/gifts/wild-gift.lua')
  ActorTemporaryEffects:loadDefinition('/data-revamped-wyrmic/effects.lua')
  Birther:loadDefinition("/data-revamped-wyrmic/birth/classes/wilder.lua")
  DamageType:loadDefinition("/data-revamped-wyrmic/damage_types.lua")
end)

--class:bindHook("Entity:loadList", function(self, data)
--		  if data.file == "/data/general/objects/world-artifacts.lua" then
--		     self:loadList("/data-revamped-wyrmic/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
--		  end
--end)

class:bindHook("Entity:loadList",
	       function(self, data)
		  for _,obj in pairs(data.res) do
		     if type(obj) == "table" then
			if obj.type == "gem" then
			   obj.offslot = "REK_WYRMIC_GEM"
			end
		     end
		  end
end)
