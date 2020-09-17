local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

class:bindHook("ToME:load", function(self, data)
                  Talents:loadDefinition('/data-classdemolisher/talents/steam.lua')
                  ActorTemporaryEffects:loadDefinition('/data-classdemolisher/effects.lua')
                  Birther:loadDefinition("/data-classdemolisher/birth/classes/tinker.lua")
                  DamageType:loadDefinition("/data-classdemolisher/damage_types.lua")
                            end)

-- class:bindHook("Entity:loadList", function(self, data)
-- 		  if data.file == "/data/general/objects/world-artifacts.lua" then
-- 		     self:loadList("/data-classdemolisher/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
-- 		  end
-- end)