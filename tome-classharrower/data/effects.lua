local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_GLR_DAZE", image = "talents/rek_psi_idol_fascinating.png",
	desc = "Fascinated",
	long_desc = function(self, eff) return ("The target is dazed with fascination."):format() end,
	type = "mental",
	subtype = { psionic=true, stun=true },
	status = "detrimental",
	parameters = { power=1, immunity=15 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "dazed", 1)
		self:effectTemporaryValue(eff, "never_move", 1)
	end,
	deactivate = function(self, eff)
		self:setEffect(self.EFF_REK_GLR_NO_FASCINATE, eff.immunity, {src = eff.src})
	end,
}

newEffect{
	name = "REK_GLR_NO_FASCINATE", image = "talents/rek_psi_idol_fascinating.png",
	desc = "Bored",
	long_desc = function(self, eff) return ("The target is immune to further fascination."):format() end,
	type = "mental",
	subtype = { psionic=true, emotion=true },
	status = "beneficial",
	parameters = { power=1 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_GLR_QUENCHED_SPEED", image = "talents/rek_psi_idol_thought_drinker.png",
	desc = "Mind-Quenched",
	long_desc = function(self, eff) return ("Movement speed increased by %d%%."):format(eff.speed) end,
	type = "mental",
	subtype = { haste = true },
	status = "beneficial",
	parameters = { speed = 1, steps = 1 },
	callbackOnMove = function(self, eff, moved, force, ox, oy, x, y)
		if not moved then return end
		if force then return end
		if ox == self.x and oy == self.y then return end
		eff.steps = eff.steps - 1
		if eff.steps <= 0 then
			self:removeEffect(self.EFF_REK_GLR_QUENCHED_SPEED)	
		end
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "movement_speed", eff.speed)
	end,
}


newEffect{
	name = "REK_GLR_INTIMIDATED", image = "talents/rek_psi_idol_terrific.png",
	desc = "Awed",
	long_desc = function(self, eff) return ("The target is in awe, losing %d mental save."):format(eff.power) end,
	type = "mental",
	subtype = { psionic=true, emotion=true },
	status = "detrimental",
	parameters = { power=1 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_mentalresist", -eff.power)
	end,
	deactivate = function(self, eff)
	end,
}
