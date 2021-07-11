local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "HAMMER_DEMONIC_WATERBREATHING",
	desc = _t"Shell of Living Air",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return (_t"Gives you a large but limited supply of air underwater.  Not useful when buried alive.") end,
	cancel_on_level_change = false,
	type = "other",
	subtype = { aura=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		eff.dur = 999
		self:effectTemporaryValue(eff, "can_breath", {water = 1})
	end,
	deactivate = function(self, eff) end,
}
