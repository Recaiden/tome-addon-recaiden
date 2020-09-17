local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_DEML_SAVE_BOOST", image = "talents/rek_deml_drone_medic.png",
	desc = "Perfect Health",
	long_desc = function(self, eff) return ("The target's saves are boosted by %d."):format(eff.power) end,
	type = "physical",
	subtype = { steam=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physresist", eff.power)
		self:effectTemporaryValue(eff, "combat_spellresist", eff.power)
		self:effectTemporaryValue(eff, "combat_mentalresist", eff.power)
	end,
}