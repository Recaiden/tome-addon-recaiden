local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

class:bindHook("ToME:load", function(self, data)
  Talents:loadDefinition('/data-classgravwyrm/talents/talents.lua')
  ActorTemporaryEffects:loadDefinition('/data-classgravwyrm/effects.lua')
  Birther:loadDefinition("/data-classgravwyrm/birth/classes/wilder.lua")
  DamageType:loadDefinition("/data-classgravwyrm/damage_types.lua")
end)

-- class:bindHook("Entity:loadList", function(self, data)
-- 		  if data.file == "/data/general/objects/world-artifacts.lua" then
-- 		     self:loadList("/data-classgravwyrm/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
-- 		  end
-- 			if data.file == "/data/general/objects/egos/bow.lua" then
-- 		     self:loadList("/data-classgravwyrm/egos-bow.lua", data.no_default, data.res, data.mod, data.loaded)
-- 		  end
-- end)
