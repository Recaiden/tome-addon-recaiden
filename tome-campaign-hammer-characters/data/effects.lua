local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_ONYX_IMPULSE", image = "talents/rek_onyx_impulse.png",
	desc = "Impulse",
	long_desc = function(self, eff) return ("The target is moving instantly for %d steps."):format(eff.steps) end,
	type = "physical",
	charges = function(self, eff) return eff.steps end,
	subtype = { haste=true },
	status = "beneficial",
	parameters = { steps=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "free_movement", 1)
		eff.ox = self.x
		eff.oy = self.y
	end,
	deactivate = function(self, eff)
	end,
	callbackOnMove = function(self, eff, moved, force, ox, oy, x, y)
		if not moved then return end
		if force then return end
		if ox == self.x and oy == self.y then return end
		
		if self.reload then
			local reloaded = self:reload()
			if not reloaded and self.reloadQS then
				self:reloadQS()
			end
		end
		
		eff.steps = eff.steps - 1
		if eff.steps <= 0 then
			self:removeEffect(self.EFF_REK_ONYX_IMPULSE)
		end
	end,
}

newEffect{
	name = "REK_ONYX_UNBREAKABLE", image = "talents/rek_onyx_unbreakable.png",
	desc = "Unbreakable",
	long_desc = function(self, eff) return ("The target is covered with hardened spines, gaining %d%% absolute resistance and triggering bursts of physical damage every round."):format(eff.power) end,
	type = "physical",
	subtype = { armor=true },
	status = "beneficial",
	parameters = { power=5, damage=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {absolute = eff.power})
		self.rek_onyx_spines_autoproc = eff.damage
	end,
	deactivate = function(self, eff)
		self.rek_onyx_spines_autoproc = nil
	end,
}
