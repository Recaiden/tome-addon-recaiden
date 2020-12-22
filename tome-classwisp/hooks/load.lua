local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

class:bindHook("ToME:load", function(self, data)
  Talents:loadDefinition('/data-classwisp/talents/talents.lua')
  ActorTemporaryEffects:loadDefinition('/data-classwisp/effects.lua')
  Birther:loadDefinition("/data-classwisp/birth/classes/psionic.lua")
  DamageType:loadDefinition("/data-classwisp/damage_types.lua")
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
	
	if type ~= DamageType.MIND and target and target.hasEffect then
		local eff = target:hasEffect(target.EFF_REK_GLR_COSMIC_AWARENESS)
		if eff then
			local damMind = dam * eff.power
			DamageType:get(DamageType.MIND).projector(src, target.x, target.y, DamageType.MIND, {src=src, damMind}, hd.state)
			--src:project(target, target.x, target.y, DamageType.MIND, {src=src, dam=damMind})
			hd.dam = dam * (1-eff.power)
		end
	end
	return hd
end)

class:bindHook("DamageProjector:base", function(self, hd)
	local src = hd.src
	local type = hd.type
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)

	if not src or not target then return end
	if src and src.knowTalent and src:knowTalent(src.T_REK_EVOLUTION_GLR_STORM) then
		local range = math.floor(core.fov.distance(src.x, src.y, target.x, target.y))
		local mult = math.max(0, 2.0 - range * 0.33)
		hd.dam = dam * mult
	end
	return hd
end)