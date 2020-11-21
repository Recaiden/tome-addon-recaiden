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

newEffect{
	name = "REK_SHINE_SOLETTA", image = "talents/rek_shine_incinerator_succession.png",
	desc = _t"Soletta",
	long_desc = function(self, eff)
		return ("Casting enough spells grants %d%% of a turn."):tformat(eff.power * (0.9 + eff.stacks/30))
	end,
	type = "magical",
	subtype = { radiation=true, haste=true },
	status = "beneficial",
	parameters = { power = 10, stacks = 1 },
	charges = function(self, eff) return eff.stacks end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.stacks = old_eff.stacks + 1
		if old_eff.stacks % 3 == 0 then
			local energy = math.min(game.energy_to_act, 0.01 * game.energy_to_act * old_eff.power * (0.9 + old_eff.stacks/30))
			self.energy.value = self.energy.value + energy
			local particles = {type="light"}
			if core.shader.allow("adv") then
				particles = {type="volumetric", args={kind="conic_cylinder", life=14, base_rotation=rng.range(160, 200), radius=4, y=1.8, density=30, shininess=20, growSpeed=0.006, img="sunray"}}
			end
			self:project(self, self.x, self.y, DamageType.COSMETIC, 0, particles)
		end
		return old_eff
	end,
	activate = function(self, eff)	eff.stacks = 1 end,
	deactivate = function(self, eff) end,
}


newEffect{
	name = "REK_SHINE_REFLECTION_LINK", image = "talents/rek_shine_prism_reflections.png",
	desc = _t"Reflection Link",
	long_desc = function(self, eff) return _t"This target is splitting all damage with its reflections." end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	decrease = 0,
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, state)
		if src ~= self and src.hasEffect and src:hasEffect(src.EFF_REK_SHINE_REFLECTION_LINK) then
			-- Find our clones
			for i = 1, #eff.targets do
				local target = eff.targets[i]
				if target == self then dam = 0 end
			end
		end
		return {dam=dam}
	end,
	callbackOnHit = function(self, eff, cb, src)
		if cb.value <= 0 then return cb.value end

		local clones = {}
		-- Find our clones
		for i = 1, #eff.targets do
			local target = eff.targets[i]
			if not target.dead and game.level:hasEntity(target) then
				clones[#clones+1] = target
			end
		end

		-- Split the damage
		if #clones > 0 and not self.turn_procs.prism_reflection_damage_self and not self.turn_procs.prism_reflection_damage_target then
			self.turn_procs.prism_reflection_damage_self = true
			cb.value = cb.value/#clones
			game:delayedLogMessage(self, nil, "fugue_damage", "#STEEL_BLUE##Source# shares damage with %s reflections!", string.his_her(self))
			for i = 1, #clones do
				local target = clones[i]
				if target ~= self then
					target.turn_procs.prism_reflection_damage_target = true
					target:takeHit(cb.value, src)
					game:delayedLogDamage(src or self, self, 0, ("#STEEL_BLUE#(%d shared)#LAST#"):tformat(cb.value), nil)
					target.turn_procs.prism_reflection_damage_target = nil
				end
			end

			self.turn_procs.prism_reflection_damage_self = nil
		end

		-- If we're the last clone remove the effect
		if #clones <= 0 then
			self:removeEffect(self.EFF_REK_SHINE_REFLECTION_LINK)
		end

		return cb.value
	end,
	on_timeout = function(self, eff)
		-- Temporal Fugue does not cooldown while active
		if self.talents_cd[self.T_REK_SHINE_REFLECTION_LINK] then
			self.talents_cd[self.T_TEMPORAL_FUGUE] = self.talents_cd[self.T_TEMPORAL_FUGUE] + 1
		end

		local alive = false
		for i = 1, #eff.targets do
			local target = eff.targets[i]
			if target ~=self and not target.dead then
				alive = true
				break
			end
		end
		if not alive then
			self:removeEffect(self.EFF_REK_SHINE_REFLECTION_LINK)
		end
	end,
	activate = function(self, eff)
	end,
}