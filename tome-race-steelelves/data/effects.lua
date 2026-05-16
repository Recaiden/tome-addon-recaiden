local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_STEEL_WIELDING", image = "talents/rek_steel_wielding.png",
	desc = _t"Steel Wielding Speed",
	long_desc = function(self, eff) return ("Increasing weapon speed by %d%%"):tformat(eff.speed) end,
	type = "physical",
	subtype = { haste=true,},
	status = "beneficial",
	parameters = {speed=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physspeed", eff.speed/100)
	end,
}
