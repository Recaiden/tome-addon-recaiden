local class = require"engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local PartyLore = require "mod.class.interface.PartyLore"

local load = function(self, data)
   ActorTalents:loadDefinition('/data-rec-evolutions/talents/talents.lua')
   ActorTemporaryEffects:loadDefinition('/data-rec-evolutions/effects.lua')
   DamageType:loadDefinition("/data-rec-evolutions/damage_types.lua")
end
class:bindHook('ToME:load', load)

-- class:bindHook("ToME:birthDone", function()
-- 	dofile("/data-rec-evolutions/talents/dlc.lua")
-- end)
