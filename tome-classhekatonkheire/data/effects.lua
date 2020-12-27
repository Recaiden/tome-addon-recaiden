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
	name = "REK_HEKA_SUDDEN_INSIGHT", image = "talents/rek_heka_otherness_sudden_insight.png",
	desc = "Sudden Insight",
	long_desc = function(self, eff) return ("Increased critical chance by %d and power by %d%%"):format(eff.chance, eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power = 5, chance=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physcrit", eff.chance)
		self:effectTemporaryValue(eff, "combat_spellcrit", eff.chance)
		self:effectTemporaryValue(eff, "combat_critical_power", eff.power)
	end,
	deactivate = function(self, eff)
	end,
}


newEffect{
	name = "REK_HEKA_INVESTED", image = "talents/rek_heka_otherness_sudden_insight.png",
	desc = "Invested Hands",
	long_desc = function(self, eff) return ("%d of your hands are busy elsewhere"):format(eff.cost) end,
	type = "other",
	subtype = { hands=true },
	status = "neutral",
	decrease = 0,
	charges = function(self, eff) return eff.cost end,
	parameters = { cost = 0 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		self:removeTemporaryValue("max_hands", old_eff.costid)
		old_eff.cost = math.min(self.max_hands, old_eff.cost + new_eff.cost)
		old_eff.costid = self:addTemporaryValue("max_hands", -old_eff.cost)
		return old_eff
	end,
	activate = function(self, eff)
		eff.costid = self:addTemporaryValue("max_hands", -eff.cost)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_HEKA_GRASPED", image = "talents/rek_heka_harming_titans_grasp.png",
	desc = "Titan's Grasp",
	long_desc = function(self, eff) return ("Pinned by disembodied hands, taking %d damage per turn.  Can break free by dealing %d damage to other targets."):format(eff.power, eff.health*10) end,
	type = "physical",
	subtype = { grapple=true, pin=true, silence=true },
	status = "detrimental",
	parameters = { power = 5, health=10, silence=0 },
	activate = function(self, eff)
		if self:canBe("pin") then
			self:effectTemporaryValue(eff, "never_move", 1)
		end
		if (eff.silence > 0) and self:canBe("silence") then
			self:effectTemporaryValue(eff, "silence", 1)
		end
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}
class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	local dam = hd.dam

	if src.hasEffect then
		local eff = src:hasEffect(src.EFF_REK_HEKA_GRASPED)
		if eff then
			local absorbed = dam * 0.1
			game:delayedLogDamage(src, hd.target, 0, ("#c68642#(%d to grapsing hands)#LAST#"):format(absorbed), false)
			eff.health = eff.health - absorbed
			hd.dam = dam - absorbed
		end
	end
	return hd
end)


newEffect{
	name = "REK_HEKA_CHOKE_READY", image = "talents/rek_heka_harming_chokehold.png",
	desc = "Chokehold Prepared",
	long_desc = function(self, eff) return ("Next use of Titan's Grasp will also silence the target"):format() end,
	type = "physical",
	subtype = { hands=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physcrit", eff.chance)
		self:effectTemporaryValue(eff, "combat_spellcrit", eff.chance)
		self:effectTemporaryValue(eff, "combat_critical_power", eff.power)
	end,
	deactivate = function(self, eff)
	end,
}