local class = require"engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local Map = require "engine.Map"

local load = function(self, data)
   ActorTalents:loadDefinition('/data-race-steelelves/talents.lua')
   ActorTemporaryEffects:loadDefinition('/data-race-steelelves/effects.lua')
   Birther:loadDefinition("/data-race-steelelves/birth.lua")
end
class:bindHook('ToME:load', load)
