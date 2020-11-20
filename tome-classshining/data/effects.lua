local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_SHINE_ENRICHMENT", image = "talents/rek_shine_nuclear_fuel_enrichment.png",
	desc = "Enrichment",
	long_desc = function(self, eff) return ("Increased critical chance by %d"):format(eff.power*eff.stacks) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	charges = function(self, eff) return eff.stacks end,
	parameters = { power = 2, stacks = 1, max_stacks = 5 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur		
		old_eff.stacks = math.min(old_eff.max_stacks, old_eff.stacks + 1)
		self:removeTemporaryValue("combat_spellcrit", old_eff.critid)
		old_eff.critid = self:addTemporaryValue("combat_spellcrit", old_eff.stacks*new_eff.power)
		return old_eff
	end,
	activate = function(self, eff)
		eff.stacks = 1
		eff.critid = self:addTemporaryValue("combat_spellcrit", eff.stacks*eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_spellcrit", eff.critid)
	end,
}

newEffect{
	name = "REK_SHINE_RADIANT_WEAKNESS", image = "talents/rek_shine_nuclear_criticality_excursion.png",
	desc = _t"Radiant Weakness",
	long_desc = function(self, eff)
		return ("Decreases strength and dexterity by %d."):tformat(eff.power)
	end,
	type = "other",
	subtype = { radiation=true },
	status = "detrimental",
	parameters = { power = 2 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur		
		old_eff.power = old_eff.power + new_eff.power
		self:removeTemporaryValue("inc_stats", old_eff.tmpid)
		local stats = old_eff.power
		old_eff.tmpid = self:addTemporaryValue("inc_stats",
																			 {
																				 [Stats.STAT_STR] = stats,
																				 [Stats.STAT_DEX] = stats,
																			 })
		return old_eff
	end,
	activate = function(self, eff)
		local stats = eff.power
		eff.tmpid = self:addTemporaryValue("inc_stats",
																			 {
																				 [Stats.STAT_STR] = stats,
																				 [Stats.STAT_DEX] = stats,
																			 })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "REK_SHINE_SOLAR_DISTORTION", image = "talents/rek_shine_sunlight_solar_flare.png",
	desc = _t"Solar Waning",
	long_desc = function(self, eff) return _t"Solar Flare has been used once recently." end,
	type = "other",
	subtype = { frenzy=true },
	status = "detrimental",
	parameters = { },
	activate = function(self, eff)		
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_SHINE_SOLAR_MINIMA", image = "talents/rek_shine_sunlight_solar_flare.png",
	desc = _t"Solar Minima",
	long_desc = function(self, eff) return _t"Solar Flare has been used twice recently." end,
	type = "other",
	subtype = { frenzy=true },
	status = "detrimental",
	parameters = { },
	activate = function(self, eff)		
	end,
	deactivate = function(self, eff)
	end,
}