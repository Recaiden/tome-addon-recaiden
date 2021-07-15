local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "HAMMER_DEMONIC_WATERBREATHING", image = "effects/hammer_demonic_waterbreathing.png",
	desc = _t"Shell of Living Air",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return (_t"Gives you a large but limited supply of air underwater.  Not useful when buried alive.") end,
	cancel_on_level_change = false,
	type = "other",
	subtype = { aura=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		eff.dur = 666
		self:effectTemporaryValue(eff, "can_breath", {water = 1})
	end,
	deactivate = function(self, eff) end,
}

newEffect{
	name = "HAMMER_CULTIST_REVIVE", image = "effects/hammer_demonic_waterbreathing.png",
	desc = _t"Cult of the Demon Seed",
	long_desc = function(self, eff) return (_t"Helps you not die, somehow") end,
	cancel_on_level_change = false,
	type = "other",
	subtype = { aura=true },
	status = "beneficial",
	parameters = {},
	no_decrease = true,
	activate = function(self, eff)	end,
	deactivate = function(self, eff) end,
}
