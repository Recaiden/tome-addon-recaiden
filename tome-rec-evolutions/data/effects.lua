local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "HOLLOW_BLINDSIDE_BONUS", image = "talents/rek_hollow_shadow_blindside.png",
	desc = "Shadow of Speed",
	long_desc = function(self, eff) return ("The target has appeared out of nowhere! It takes %d less damage from each hit."):format(eff.power) end,
	type = "physical",
	subtype = { evade=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "flat_damage_armor", {all=eff.power})
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "HOLLOW_DOMINATED", image = "talents/rek_hollow_shadow_dominate.png",
	desc = "Dominated",
	long_desc = function(self, eff) return ("The target has been dominated.  It is unable to move and has lost %d armor, %d defense, %d mental save, and 10%% resistance."):format(-eff.armorChange, -eff.defenseChange,  -eff.defenseChange) end,
	type = "mental",
	subtype = { dominate=true },
	status = "detrimental",
	on_gain = function(self, err) return "#F53CBE##Target# has been dominated!", "+Dominated" end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer dominated.", "-Dominated" end,
	parameters = { armorChange = -3, defenseChange = -3 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_move", 1)
		self:effectTemporaryValue(eff, "combat_armor", eff.armorChange)
		self:effectTemporaryValue(eff, "combat_def", eff.armorChange)
		self:effectTemporaryValue(eff, "combat_mentalresist", eff.armorChange)
		self:effectTemporaryValue(eff, "resists", {all=-10})

		eff.particle = self:addParticles(Particles.new("dominated", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}