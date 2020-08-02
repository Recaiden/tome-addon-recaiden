local class = require"engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local PartyLore = require "mod.class.interface.PartyLore"

local load = function(self, data)
   ActorTalents:loadDefinition('/data-race-undeadpack/talents/talents.lua')
   ActorTemporaryEffects:loadDefinition('/data-race-undeadpack/effects.lua')
   Birther:loadDefinition("/data-race-undeadpack/birth/banshee.lua")
   Birther:loadDefinition("/data-race-undeadpack/birth/wight.lua")
   Birther:loadDefinition("/data-race-undeadpack/birth/mummy.lua")
   PartyLore:loadDefinition("/data-race-undeadpack/lore/kidnapper-hideout.lua")
   PartyLore:loadDefinition("/data-race-undeadpack/lore/mummy-crypt-ruins.lua") 
   DamageType:loadDefinition("/data-race-undeadpack/damage_types.lua")
end
class:bindHook('ToME:load', load)

class:bindHook("MapGeneratorStatic:subgenRegister", function(self, data)
		  if data.mapfile ~= "wilderness/eyal" then return end

                  -- defines where player appears after starter dungeon
		  data.list[#data.list+1] = {
		     x = 23, y = 19, w = 1, h = 1, overlay = true,
		     generator = "engine.generator.map.Static",
		     data = {
			map = "race-undeadpack+banshee-tomb-overlay",
		     },
		  }

                  -- persistent dungeon zone, where the mummy can return to their spawn point
                  data.list[#data.list+1] = {
		     x = 15, y = 49, w = 1, h = 1, overlay = true,
		     generator = "engine.generator.map.Static",
		     data = {
			map = "race-undeadpack+mummy-tomb-overlay",
		     },
		  }

                  -- defines where player appears after starter dungeon
                  data.list[#data.list+1] = {
		     x = 24, y = 23, w = 1, h = 1, overlay = true,
		     generator = "engine.generator.map.Static",
		     data = {
			map = "race-undeadpack+battleground-overlay",
		     },
		  }
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
class:bindHook("Entity:loadList",
               function(self, data)
                  -- Load the starting zone
                  if data.file == "/data/zones/wilderness/grids.lua" then
		     self:loadList("/data-race-undeadpack/wilderness-overlay-grids.lua", data.no_default, data.res, data.mod, data.loaded)
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
