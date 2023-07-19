local class = require"engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local Map = require "engine.Map"
local DamageType = require "engine.DamageType"

local load = function(self, data)
   ActorTalents:loadDefinition('/data-campaign-hammer-characters/talents/talents.lua')
   ActorTemporaryEffects:loadDefinition('/data-campaign-hammer-characters/effects.lua')
   Birther:loadDefinition("/data-campaign-hammer-characters/birth/demon-races.lua")
	 Birther:loadDefinition("/data-campaign-hammer-characters/birth/eyal-races.lua")
	 Birther:loadDefinition("/data-campaign-hammer-characters/birth/classes.lua")
	 DamageType:loadDefinition("/data-campaign-hammer-characters/damage_types.lua")
end
class:bindHook('ToME:load', load)

class:bindHook("Combat:getDammod:subs", function(self, hd) 
	if hd.dammod and hd.dammod.cun and hd.dammod.cun == 0.4 and hd.dammod.dex and hd.dammod.dex == 0.4 and self:knowTalent(self.T_REK_IMP_ETERNAL_FLAME) then
	   local old_mod = table.clone(hd.dammod)
	   hd.dammod = {dex = old_mod.dex and old_mod.dex + 0.2 or 0.6, mag = old_mod.mag and old_mod.mag + 0.6 or 0.6, cun = old_mod.cun and old_mod.cun - 0.4 or 0, str = old_mod.str and old_mod.str - 0.4 or 0, con = old_mod.con and old_mod.con + 0 or 0, wil = old_mod.wil and old_mod.wil + 0 or 0}
	   if hd.dammod.dex == 0 then
		hd.dammod.dex = nil
	   end
	   if hd.dammod.str == 0 then
		hd.dammod.str = nil
	   end
	   if hd.dammod.cun == 0 then
		hd.dammod.cun = nil
	   end
	   if hd.dammod.wil == 0 then
		hd.dammod.wil = nil
	   end
	   if hd.dammod.mag == 0 then
		hd.dammod.mag = nil
	   end
	   if hd.dammod.con == 0 then
		hd.dammod.con = nil
	   end
	   return hd
   else
		return hd
   end   
end)
