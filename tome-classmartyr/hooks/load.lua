local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"
local Colors = require "engine.colors"

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
