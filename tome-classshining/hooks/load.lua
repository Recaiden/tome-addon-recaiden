local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

class:bindHook("ToME:load", function(self, data)
                  Talents:loadDefinition('/data-classshining/talents/demented.lua')
                  ActorTemporaryEffects:loadDefinition('/data-classshining/effects.lua')
                  Birther:loadDefinition("/data-classshining/birth/classes/demented.lua")
                  DamageType:loadDefinition("/data-classshining/damage_types.lua")
                            end)

-- class:bindHook("Entity:loadList", function(self, data)
-- 		  if data.file == "/data/general/objects/world-artifacts.lua" then
-- 		     self:loadList("/data-classshining/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
-- 		  end
-- end)

class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)

	local seff = game.level.map:hasEffectType(src.x, src.y, DamageType.REK_SHINE_MIRROR)
	local deff = game.level.map:hasEffectType(target.x, target.y, DamageType.REK_SHINE_MIRROR)
	if deff and deff ~= seff and not hd.state.no_reflect then
		local state = hd.state
		local type = hd.type
		local reflected = math.min(dam, deff.dam.dam)
		deff.dam.dam = deff.dam.dam - reflected
		if deff.dam.dam <= 0 then game.level.map:removeEffect(deff) end
		game:delayedLogMessage(src, target, "reflect_damage"..(target.uid or ""), "#CRIMSON##Target# reflects damage back to #Source#!")
		
		game:delayedLogDamage(src, target, 0, ("#GOLD#(%d to mirror barrier)#LAST#"):format(reflected), false)
		hd.dam = dam - reflected
		state.no_reflect = true
		reflected = reflected * 100 / (target:attr("reflection_damage_amp") or 100)
		DamageType.defaultProjector(target, src.x, src.y, type, reflected, state)
		state.no_reflect = nil
	end
	return hd
end)