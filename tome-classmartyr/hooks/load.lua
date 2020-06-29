local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"
local Colors = require "engine.colors"

if Game:isAddonActive("cults") then
   defineColor('MIDNIGHT', 25, 25, 112)
   class:bindHook("ToME:load", function(self, data)
                  Talents:loadDefinition('/data-classmartyr/talents/demented.lua')
                  ActorTemporaryEffects:loadDefinition('/data-classmartyr/effects.lua')
                  Birther:loadDefinition("/data-classmartyr/birth/classes/demented.lua")
                  DamageType:loadDefinition("/data-classmartyr/damage_types.lua")
                            end)

-- class:bindHook("Entity:loadList", function(self, data)
-- 		  if data.file == "/data/general/objects/world-artifacts.lua" then
-- 		     self:loadList("/data-classmartyr/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
-- 		  end
-- end)

   class:bindHook(
      "Actor:getSpeed",
      function(self, hd)
         local speed_type = hd.speed_type
         local speed = hd.speed
         if speed_type == "archery" then
            local eff = self:hasEffect(self.EFF_REK_MTYR_SEVENFOLD_SPEED)
            if eff then
               speed = speed / (1+eff.power)
            end
         end
         return hd
      end)
end