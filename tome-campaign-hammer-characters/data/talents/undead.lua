newTalent{
	name = "Impulse", short_name="REK_ONYX_IMPULSE",
	type = {"race/onyx", 1}, require = racial_req1, points = 5,
	tactical = { CURE = 1 },
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 12)) end,
	getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6, "log")) end,
	getSteps = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	action = function(self, t)
		local effs = {}
		-- remove movement-restricting effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.stun or e.subtype.pin then -- Daze is stun subtype
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
			end
		end

		-- move fast
		self:setEffect(self.EFF_REK_ONYX_IMPULSE, 1, {steps=t.getSteps(self, t), src=self})

		-- check talent 3
		if self:knowTalent(self.T_REK_ONYX_TACTICAL) then
			self.energy.value = self.energy.value + game.energy_to_act * self:callTalent(self.T_REK_ONYX_TACTICAL, "getEnergy")
		end
		return true
	end,
	info = function(self, t)
		return ([[Instantly generate motion and energy within yourself, removing up to %d stun, daze, or pin effects and allowing you to move %d times without taking a turn.]]):tformat(t:_getRemoveCount(self), t:_getSteps(self))
	end,
}

newTalent{
	name = "Devil Spines", short_name = "REK_ONYX_SPINES",
	type = {"race/onyx", 2}, require = racial_req2, points = 5,
	mode = "passive",
	range = 3,
	getHardiness = function(self, t) return self:combatTalentScale(t, 10, 25) end,
	getDamage = function(self, t)
		return 5 + self:combatArmor() / 2
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_armor_hardiness", t.getHardiness(self, t))
	end,
	callbackOnHit = function(self, t, cb, src, death_note)
		self.rek_onyx_spines_proc = true
		return cb
	end,
	callbackOnActBase = function(self, t)
		if not self.rek_onyx_spines_proc and not self.rek_onyx_spines_autoproc then return end
		self.rek_onyx_spines_proc = nil
		local tg = {type="ball", range=0, radius=self:getTalentRange(t), friendlyfire=false, talent=t}
		self:project(tg, self.x, self.y, DamageType.PHYSICAL, t.getDamage(self, t) + (self.rek_onyx_spines_autoproc or 0))
	end,
	info = function(self, t)
		return ([[At the start of every round, if you were hit in the last round, lash out with your spines, dealing %0.1f physical daamge (based on your armor) to enemies within range %d. 

You also gain %d%% armor hardiness.

#{italic}#....#{normal}#]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), self:getTalentRange(t), t.getHardiness(self, t))
	end,
}

newTalent{
	name = "Principle of Motion", short_name = "REK_ONYX_TACTICAL",
	type = {"race/onyx", 3}, require = racial_req3,	points = 5,
	mode = "passive",
	getEnergy = function(self, t) return self:combatTalentScale(t, 0.2, 0.5) end,
	info = function(self, t)
		return ([[Making efficient use of every movement, you are capable of sudden bursts of speed.  Whenever you use Impulse or Unbreakable, you gain %d%% of a turn.

#{italic}#More than any other demons, the children of onyx are warriors at heart.#{normal}#]]):tformat(t.getEnergy(self, t)*100)
	end,
}

newTalent{
	name = "Unbreakable", short_name = "REK_ONYX_UNBREAKABLE",
	type = {"race/onyx", 4}, require = racial_req4, points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end, -- Limit > 5
	getDuration = function(self, t) return 5 end,
	getPower = function(self, t) return self:combatStatScale("cun", 11, 25) end,
	getDamage = function(self, t) return self:getCun() * self:combatTalentScale(t, 0.5, 1.25) end,
	tactical = { ATTACK = 1, DEFEND = 1 },
	action = function(self, t)
		self:setEffect(self.EFF_REK_ONYX_UNBREAKABLE, 5, {power=t.getPower(self, t), damage=getDamage(self,t), src=self})
		
		-- check talent 3
		if self:knowTalent(self.T_REK_ONYX_TACTICAL) then
			self.energy.value = self.energy.value + game.energy_to_act * self:callTalent(self.T_REK_ONYX_TACTICAL, "getEnergy")
		end
		return true
	end,
	info = function(self, t)
		return ([[Harden your skin and sprout additional spines.  For the next %d turns, you gain %d%% absolute resistance, and Devil Spines always triggers (with %0.1f additional damage).
Cunning: increases resistance and damage.

#{italic}#...#{normal}#]]):format(t.getDuration(self, t), t.getPower(self, t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}
