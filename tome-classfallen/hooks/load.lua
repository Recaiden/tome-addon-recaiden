local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

class:bindHook("ToME:load", function(self, data)
  Talents:loadDefinition('/data-classfallen/talents/cursed/cursed.lua')
  ActorTemporaryEffects:loadDefinition('/data-classfallen/effects.lua')
  Birther:loadDefinition("/data-classfallen/birth/classes/afflicted.lua")
end)

local function insertMastery(obj,mastery)
   if not obj.wielder then
      obj.wielder = {}
   end
   if obj.wielder.talents_types_mastery then
      for typ,amt in pairs(mastery) do
         obj.wielder.talents_types_mastery[typ] = amt
      end
   else
      obj.wielder.talents_types_mastery = mastery
   end
end

-- Give Solar Shadows mastery to anything with Shadows mastery
local masteryEquivalents = {
   ["cursed/shadows"] = "cursed/solar-shadows"
}
class:bindHook(
	"Entity:loadList",
	function(self, data)
		for _,obj in pairs(data.res) do
			if type(obj) == "table" then
				if obj.wielder then
					if obj.wielder.talents_types_mastery then
						for t,m in pairs(obj.wielder.talents_types_mastery) do
							if masteryEquivalents[t] then
								obj.wielder.talents_types_mastery[masteryEquivalents[t]] = m
							end
						end
					end
				end
			end
		end
	end
)
