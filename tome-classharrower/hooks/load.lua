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

class:bindHook(
	"Combat:getDammod:subs",
	function(self, hd) 
		if hd.combat and hd.combat.talented == "bow"  and self:knowTalent(self.T_REK_GLR_MARKSMAN_ACCELERATE) then
			hd.dammod.wil = (hd.dammod.wil or 0) + (hd.dammod.str or 0)
			hd.dammod.str = nil
	--if hd.combat.talented and hd.combat.talented == "unarmed" and self:knowTalent(self.T_K_FROZEN_FIST) then
		end
		return hd   
	end)

class:bindHook("DamageProjector:base", function(self, hd)
	local src = hd.src
	local type = hd.type
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)
	
	if type ~= DamageType.MIND and target.hasEffect then
		local eff = target:hasEffect(target.EFF_REK_GLR_COSMIC_AWARENESS)
		if eff then
			local damMind = dam * eff.power
			src:project(target, target.x, target.y, DamageType.MIND, {src=src, dam=damMind})
			hd.dam = dam * (1-eff.power)
		end
	end
	return hd
end)