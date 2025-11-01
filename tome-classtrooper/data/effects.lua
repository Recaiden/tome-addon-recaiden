local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_OCLT_BURNT", image = "talents/rek_oclt_carbine_empty.png",
	desc = "Laserburnt",
	long_desc = function(self, eff) return ("The target takes %d%% more non-light damage."):format(eff.power) end,
	type = "physical",
	subtype = { light=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(
			eff, "resists", {
				all = -eff.power,
				[DamageType.LIGHT] = eff.power
		})
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_OCLT_MIGHT", image = "talents/rek_oclt_trooper_power.png",
	desc = "Crushing Might",
	long_desc = function(self, eff) return ("The target has %d additional physical power."):format(eff.power) end,
	type = "physical",
	subtype = { strength=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_dam", eff.power)
	end,
	deactivate = function(self, eff)
	end,
}
