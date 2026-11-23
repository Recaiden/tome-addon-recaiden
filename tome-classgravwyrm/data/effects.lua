-- local Stats = require "engine.interface.ActorStats"
-- local Particles = require "engine.Particles"
-- local Shader = require "engine.Shader"
-- local Entity = require "engine.Entity"
-- local Chat = require "engine.Chat"
-- local Map = require "engine.Map"
-- local Level = require "engine.Level"

newEffect{
	name = "GRAVITY_SURGE", image = "talents/rek_grv_pull.png",
	desc = _t"Gravity Surge",
	long_desc = function(self, eff) local str = ("Increases attack speed by +%d%%.  Removed after attacking."):tformat(eff.speed*100)
	end,
	type = "magical",
	subtype = { haste=true },
	status = "beneficial",
	parameters = { speed=0 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physspeed", eff.speed)
	end,
	deactivate = function(self, eff)
	end,
	callbackOnMeleeAttack = function(self, eff, target, hitted)
		game:onTickEnd(function() self:removeEffect(eff.effect_id) end)
	end,
}
