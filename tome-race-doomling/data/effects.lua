local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_DOOMLING_LUCK", image = "talents/rek_doomling_luck.png",
	desc = _t"Curse of the Little Folk",
	long_desc = function(self, eff) return ("The target is cursed, reducing defence and all saves by %d and damage by %d%%"):tformat(eff.curse, eff.numb) end,
	type = "magical",
	subtype = { curse=true,},
	status = "detrimental",
	parameters = {curse=5, numb=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "numbed", eff.numb)
		self:effectTemporaryValue(eff, "combat_def", -eff.curse)
		self:effectTemporaryValue(eff, "combat_mentalresist", -eff.curse)
		self:effectTemporaryValue(eff, "combat_spellresist", -eff.curse)
		self:effectTemporaryValue(eff, "combat_physresist", -eff.curse)
	end,
}

newEffect{
	name = "REK_DOOMLING_VICTIM", image = "talents/rek_doomling_doom_hunt.png",
	desc = _t"Prey of the Doomed",
	long_desc = function(self, eff) return ("The target is being hunted by a doomling, reducing their immunities by half."):tformat(eff.curse, eff.numb) end,
	type = "magical",
	subtype = { curse=true,},
	status = "detrimental",
	parameters = {},
	activate = function(self, eff)
		if self:attr("stun_immune") then self:effectTemporaryValue(eff, "stun_immune", -self:attr("stun_immune") / 2)	end
		if self:attr("poison_immune") then self:effectTemporaryValue(eff, "poison_immune", -self:attr("poison_immune") / 2)	end
		if self:attr("disease_immune") then self:effectTemporaryValue(eff, "disease_immune", -self:attr("disease_immune") / 2)	end
		if self:attr("cut_immune") then self:effectTemporaryValue(eff, "cut_immune", -self:attr("cut_immune") / 2)	end
		if self:attr("confusion_immune") then self:effectTemporaryValue(eff, "confusion_immune", -self:attr("confusion_immune") / 2)	end
		if self:attr("blind_immune") then self:effectTemporaryValue(eff, "blind_immune", -self:attr("blind_immune") / 2)	end
		if self:attr("fear_immune") then self:effectTemporaryValue(eff, "fear_immune", -self:attr("fear_immune") / 2)	end
		if self:attr("knockback_immune") then self:effectTemporaryValue(eff, "knockback_immune", -self:attr("knockback_immune") / 2)	end

		if self:attr("silence_immune") then self:effectTemporaryValue(eff, "silence_immune", -self:attr("silence_immune") / 2)	end
		if self:attr("disarm_immune") then self:effectTemporaryValue(eff, "disarm_immune", -self:attr("disarm_immune") / 2)	end
		if self:attr("pin_immune") then self:effectTemporaryValue(eff, "pin_immune", -self:attr("pin_immune") / 2)	end
		if self:attr("sleep_immune") then self:effectTemporaryValue(eff, "sleep_immune", -self:attr("sleep_immune") / 2)	end
		if self:attr("teleport_immune") then self:effectTemporaryValue(eff, "teleport_immune", -self:attr("teleport_immune") / 2)	end
	end,
}

newEffect{
	name = "REK_DOOMLING_HUNTER", image = "talents/rek_doomling_doom_hunt.png",
	desc = _t"Doom Hunt",
	long_desc = function(self, eff) return ("You are focusing all your fury on %s"):tformat(eff.name) end,
	type = "other",
	subtype = { curse=true,},
	status = "beneficial",
	parameters = {target=0, name="no one"},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "see_invisible", 500)
		self:effectTemporaryValue(eff, "see_stealth", 500)
		self:resetCanSeeCache()
		if self == game.player then
			for uid, e in pairs(game.level.entities) do
				if e.x then
					game.level.map:updateMap(e.x, e.y)
				end
			end game.level.map.changed = true
		end
	end,
	deactivate = function(self, eff)
		self:resetCanSeeCache()
		if self == game.player then
			for uid, e in pairs(game.level.entities) do
				if e.x then
					game.level.map:updateMap(e.x, e.y)
				end
			end game.level.map.changed = true
		end
	end,
}
