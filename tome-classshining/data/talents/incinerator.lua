newTalent{
	name = "Sunburn", short_name = "REK_SHINE_INCINERATOR_SUNBURN",
	type = {"celestial/incinerator", 1}, require = mag_req_high1, points = 5,
	mode = "passive",
	getStacks = function(self, t)
		local count = 12
		if self:isTalentActive(self.T_REK_SHINE_INCINERATOR_INCINERATOR) then
			count = count + self:callTalent("T_REK_SHINE_INCINERATOR_INCINERATOR", "getExtraBurn")
		end
		return count
	end,
	getTurns = function(self, t) return self:combatTalentLimit(t, 1, 10, 3) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 12, 25) end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if dead then return end
		if target == self or target == self.summoner or (target.summoner and target.summoner == self) then return end
		if not death_note or (death_note.damtype == DamageType.FIRE) then return end
		if self:attr("sunburning") then return end
		local procs = self.turn_procs.sunburn or 0
		if self.summoner and self.summoner.turn_procs.sunburn then
			procs = self.summoner.turn_procs.sunburn
		end
		if procs >= t.getStacks(self, t) then return end
		
		self:attr("sunburning",1)
		local dam = self:spellCrit(t.getDamage(self, t))
		DamageType:get(DamageType.FIRE).projector(self, target.x, target.y, DamageType.FIRE, dam)
		self:attr("sunburning",-1)
		if self.summoner then
			self.summoner.turn_procs.sunburn = procs + 1
		else
			self.turn_procs.sunburn = procs + 1
		end
	end,

	info = function(self, t)
		return ([[Whenever you inflict non-fire damage to a target, they take an additional %0.2f fire damage.  This will not apply to you or your reflections.
This can only hit a given target %d times per turn, and the cap is shared with your reflections.
The damage increases with your Spellpower.
		]]):tformat(damDesc(self, DamageType.FIRE, t.getDamage(self, t)), t.getStacks(self, t))
	end,
}

newTalent{
	name = "Scorched Earth", short_name = "REK_SHINE_INCINERATOR_WORLD_CUTTER",
	type = {"celestial/incinerator", 2},	require = mag_req_high2,	points = 5,
	mode = "sustained",
	sustain_positive = 10,
	cooldown = 20,
	tactical = { BUFF=2, ATTACKAREA = { LIGHT = 1 } },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 55) end,
	callbackOnTalentPost = function(self, t, ab)
		if ab.short_name == "SUN_FLARE" then
			local se_duration = 4
			if self:isTalentActive(self.T_REK_SHINE_INCINERATOR_INCINERATOR) then
				se_duration = se_duration + self:callTalent("T_REK_SHINE_INCINERATOR_INCINERATOR", "getExtraDuration")
			end
			local tg = self:getTalentTarget(ab)
			local grids = self:project(tg, self.x, self.y, function() end)
			game.level.map:addEffect(self, self.x, self.y, se_duration, DamageType.LIGHT, self:callTalent("T_REK_SHINE_INCINERATOR_WORLD_CUTTER", "getDamage"), 0, 5, grids, {type="inferno"}, nil, self:spellFriendlyFire())
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		self:addShaderAura("burning_wake", "awesomeaura", {time_factor=3500, alpha=0.6, flame_scale=0.6}, "particles_images/wings.png")
		return {}
	end,
	deactivate = function(self, t, p)
		self:removeShaderAura("burning_wake")
		return true
	end,
	info = function(self, t)
		return ([[Your Sun Flare, Solar Flare, Coronal Shield, and Nova Blast irradiate the ground they strike, searing all within for %0.2f light damage each turn for 4 turns.
		The damage will increase with your Spellpower.]]):tformat(damDesc(self, DamageType.LIGHT, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Soletta", short_name = "REK_SHINE_INCINERATOR_SUCCESSION",
	type = {"celestial/incinerator", 3}, require = mag_req_high3, points = 5,
	mode= "passive",
	getEnergy = function(self, t)	return self:combatTalentLimit(t, 50, 15, 30) end,
	callbackOnTalentPost = function(self, t, ab)
		if not self.in_combat then return end
		if not ab.is_spell then return end
		if ab.mode == "sustained" then return end
		if util.getval(ab.no_energy, self, ab) == true then return end
		self:setEffect(self.EFF_REK_SHINE_SOLETTA, 2, {power=t.getEnergy(self, t), stacks=1, src=self})
	end,
	info = function(self, t)
		return ([[The sun shines on all, both heroes and monsters, but it shines especially bright for you.  Every %d spells you cast (that take a turn) in quick succession, you receive a burst of energy and gain %d%% of a turn. This is more effective the more it triggers, but never gives more than 1 whole turn.]]):tformat(3, t.getEnergy(self, t))
	end,
}

newTalent{
	name = "Incinerator", short_name = "REK_SHINE_INCINERATOR_INCINERATOR",
	type = {"celestial/incinerator", 4},	require = mag_req_high4, points = 5,
	mode = "sustained",
	sustain_positive = 10,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getExtraBurn = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
	getExtraDuration = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	getResistPenalty = function(self, t) return self:combatTalentLimit(t, 60, 20, 50) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		local particle
		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			particle = self:addParticles(Particles.new("shader_wings", 1, {infinite=1, x=bx, y=by}))
		else
			particle = self:addParticles(Particles.new("wildfire", 1))
		end
		return {
			dam = self:addTemporaryValue("resists_pen",
																	 {[DamageType.LIGHT] = t.getDamageIncrease(self, t),
																		[DamageType.FIRE] = t.getDamageIncrease(self, t)}),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		return ([[Dedicate yourself to destruction by fire, increasing your fire and light resistance penetration by %d%%, allowing your Sunburn to trigger %d additional times per turn, and increasing the duration of Scorched Earth effects by %d.]])
		:tformat(t.getResistPenalty(self, t), t.getExtraBurn(self, t), t.getExtraDuration(self, t))
	end,
}