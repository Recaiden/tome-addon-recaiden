local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

class:bindHook("ToME:load", function(self, data)
  Talents:loadDefinition('/data-classharrower/talents/talents.lua')
  ActorTemporaryEffects:loadDefinition('/data-classharrower/effects.lua')
  Birther:loadDefinition("/data-classharrower/birth/classes/psionic.lua")
  DamageType:loadDefinition("/data-classharrower/damage_types.lua")
end)
