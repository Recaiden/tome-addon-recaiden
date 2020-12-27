local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"


newEffect{
	name = "REK_HEKA_SUNDERED_RESISTANCES", image = "talents/rek_heka_titanic_sunder.png",
	desc = _t"Sundered",
	long_desc = function(self, eff) return ("The target's resistances have been reduced by %d%%."):tformat(eff.power) end,
	type = "physical",
	subtype = { wound=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {
			all = -eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "REK_HEKA_TOWERING_WRATH", image = "talents/rek_heka_shambler_towering_wrath.png",
	desc = _t"Towering Wrath",
	long_desc = function(self, eff) return ("This creature is winding up a massive attack that does %0.2fx damage."):tformat(1+eff.power*eff.stacks) end,
	charges = function(self, eff) return eff.stacks end,
	type = "physical",
	subtype = { might=true },
	status = "beneficial",
	parameters = { power=0.5, stacks=1, max_stacks=3 },
	on_merge = function(self, old_eff, new_eff, e)
		self:removeTemporaryValue("size_category", old_eff.sizeid)
		new_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
		new_eff.sizeid = self:addTemporaryValue("size_category", 1)
		return new_eff
	end,
	activate = function(self, eff)
		eff.sizeid = self:addTemporaryValue("size_category", 1)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()
										 self:removeTemporaryValue("size_category", eff.sizeid)
									 end)
	end,
}

newEffect{
	name = "REK_HEKA_IMMERSED", image = "talents/rek_heka_titanic_immersion.png",
	desc = _t"Immersed",
	long_desc = function(self, eff) return ("Projected into the warped realm of a hekatonkheire, reducing damge taken by %d%%, reducing damage dealt by %d%%, and being continually beaten for %d%% damage."):tformat(eff.resist, eff.numb, eff.dam) end,
	type = "magical",
	subtype = { warp=true },
	status = "detrimental",
	parameters = { power=0.5, stacks=1, max_stacks=3 },
	on_gain = function(self, err) return _t"#Target# is drawn towards the other place!", _t"+Immersed" end,
	on_lose = function(self, err) return _t"#Target# returns to normal space.", _t"-Immersed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("numbed", eff.numb)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("numbed", eff.tmpid)
	end,
	callbackOnHit = function(self, eff, cb, src)
		cb.value = cb.value - (cb.value * (1 - eff.resist/100))
		return cb.value
	end,
	on_timeout = function(self, eff)
		self:removeTemporaryValue("numbed", eff.tmpid)

		if eff.src and not eff.src.dead then
			eff.src:attackTarget(self, nil, eff.dam, true, true)
		end

		eff.tmpid = self:addTemporaryValue("numbed", eff.numb)
	end,
}

newEffect{
	name = "REK_SHINE_ENRICHMENT", image = "talents/rek_shine_nuclear_fuel_enrichment.png",
	desc = "Enrichment",
	long_desc = function(self, eff) return ("Increased critical chance by %d and power by %d%%"):format(eff.chance, eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	charges = function(self, eff) return eff.stacks end,
	parameters = { power = 5, chance=10 },
	activate = function(self, eff)
		self:effectTemporaryValue("combat_physcrit", eff.chance)
		self:effectTemporaryValue("combat_spellcrit", eff.chance)
		self:effectTemporaryValue(eff, "combat_critical_power", eff.power)
	end,
	deactivate = function(self, eff)
	end,
}