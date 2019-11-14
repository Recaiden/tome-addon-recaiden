local class = require"engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorResource = require "engine.interface.ActorResource"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local Map = require "engine.Map"
local Grid = require "engine.Grid"

require "engine.class"

class:bindHook(
   "ToME:load",
   function(self, data)
      DamageType:loadDefinition("/data-crit-shrug/damage_types.lua")
   end)

local function critReductionToIgnore(obj, amount)
   if not obj.wielder then
      obj.wielder = {}
   end
   if obj.wielder.combat_crit_reduction then
      obj.wielder.ignore_direct_crits = amount
      obj.wielder.combat_crit_reduction = nil
   end
end

local affectedFilenames = {
   ["/data/general/objects/boss-artifacts-maj-eyal.lua"] = true,
   ["/data/general/objects/world-artifacts-maj-eyal.lua"] = true,
}

local itemList = {
   ["Borfast's Cage"] = 20,
}

class:bindHook(
   "Entity:loadList",
   function(self, data)
      if affectedFilenames[data.file] then
         local p = game:getPlayer(true)
         for _,obj in pairs(data.res) do
            if type(obj) == "table" and itemList[obj.name] then
               critReductionToIgnore(obj, itemList[obj.name])
            end
            if type(obj) == "table" and obj.name == "Daneth's Neckguard" then
               obj.on_wear = function(self, who)
                  if who.descriptor and who.descriptor.race == "Halfling" then
                     local Talents = require "engine.interface.ActorStats"
                     
                     self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["technique/battle-tactics"] = 0.2 })
                     self:specialWearAdd({"wielder","combat_armor"}, 5)
                     self:specialWearAdd({"wielder","ignore_direct_crits"}, 10)
                     game.logPlayer(who, "#LIGHT_BLUE#You feel invincible!")
                  end
               end
            end
         end
      end
   end)
