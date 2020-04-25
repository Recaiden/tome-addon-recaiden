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
local masteryList = {
   ["Bindings of Eternal Night"] = {["undead/mummy"]=0.3},
}
local cooldownsList = {
   ["Crown of Eternal Night"] = {
      value = 4,
      talents = {
         "T_JAR_LUNG",
         "T_JAR_LIVER",
         "T_JAR_INTESTINE",
         "T_JAR_STOMACH"
      }
   }
}
local talentEquivalents = {
   T_KINETIC_SHIELD = "T_CRYSTALIST_KINETIC_SHIELD",
   T_THERMAL_SHIELD = "T_CRYSTALIST_THERMAL_SHIELD",
   T_CHARGED_SHIELD = "T_CRYSTALIST_CHARGED_SHIELD",
}

class:bindHook("Entity:loadList",
               function(self, data)
                  -- Load the starting zone
                  if data.file == "/data/zones/wilderness/grids.lua" then
		     self:loadList("/data-mummyrace/wilderness-overlay-grids.lua", data.no_default, data.res, data.mod, data.loaded)
		  end

                  -- Buff the mummy items
                  for _,obj in pairs(data.res) do
                     if type(obj) == "table" then
			if masteryList[obj.name] then
                           insertMastery(obj, masteryList[obj.name])
			end
                        if cooldownsList[obj.name] then
                           if obj.wielder then
                              local reductions = obj.wielder.talent_cd_reduction or {}
                              for _, tal in pairs(cooldownsList[obj.name]["talents"]) do
                                 reductions[tal] = cooldownsList[obj.name].value
                              end
                              obj.wielder.talent_cd_reduction = reductions
                           end
			end
                     end
                  end

               end
              )
