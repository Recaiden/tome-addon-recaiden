local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

class:bindHook("ToME:load", function(self, data)
  Talents:loadDefinition('/data-classfallen/talents/cursed/cursed.lua')
  Talents:loadDefinition('/data-classfallen/talents/celestial/celestial.lua')
  ActorTemporaryEffects:loadDefinition('/data-classfallen/effects.lua')
  Birther:loadDefinition("/data-classfallen/birth/classes/afflicted.lua")
  DamageType:loadDefinition("/data-classfallen/damage_types.lua")
end)

-- class:bindHook("Entity:loadList", function(self, data)
-- 		  if data.file == "/data/general/objects/world-artifacts.lua" then
-- 		     self:loadList("/data-classfallen/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
-- 		  end
-- end)

-- Give Solar Shadows mastery to anything with Shadows mastery
local masteryEquivalents = {
   ["cursed/shadows"] = "cursed/solar-shadows",
}
class:bindHook("Entity:loadList",
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
