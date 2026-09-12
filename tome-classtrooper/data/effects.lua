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
		--todo visual effect
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
		--todo visual effect
	end,
	deactivate = function(self, eff)
	end,
}


newEffect{
	name = "REK_OCLT_TOOL_FRENZY", image = "talents/rek_oclt_tool_frenzy.png",
	desc = "Close-Quarters Combat Mode",
	long_desc = function(self, eff) return ("The target has additional strength, speed, and accuracy."):format() end,
	type = "physical",
	subtype = { strength=true },
	status = "beneficial",
	parameters = { acc=5, speed=0.1, power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_atk", eff.acc)
		self:effectTemporaryValue(eff, "global_speed_add", eff.speed)
		self:effectTemporaryValue(eff, "inc_stats", { [Stats.STAT_STR] = eff.power })

		--todo visual effect
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_OCLT_STONE_RAIN", image = "talents/rek_oclt_stoneshaping_rain.png",
	desc = "Stone Rain",
	long_desc = function(self, eff) return ("The target deals bonus damage equal to %d%% of their armor."):format(100*eff.power) end,
	type = "physical",
	subtype = { earth=true },
	status = "beneficial",
	parameters = { power=0.1 },
	activate = function(self, eff)
		--todo visual effect
	end,
	deactivate = function(self, eff)
	end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if dead then return end
		self.turn_procs = self.turn_procs or {}
		if self.self.turn_procs.rek_stone_rain then return end
		self.turn_procs.rek_stone_rain = true

		local dam = self:occultCrit(eff.power * self:combatArmor())
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, dam)
	end,
}
