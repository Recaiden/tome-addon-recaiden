newTalent{
	name = "Breaking of Ways", short_name = "REK_HEKA_TENTACLE_WAVE",
	type = {"spell/oubliette", 1}, require = mag_req1, points = 5,
	cooldown = 10,
	tactical = { ESCAPE = { knockback = 2 }, ATTACKAREA = { COLD = 0.5, PHYSICAL = 0.5 }, DISABLE = { knockback = 1 } },
	direct_hit = true,
	range = 0,
	requires_target = true,
	radius = function(self, t)
		return 1 + 0.5 * t.getDuration(self, t)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire = false}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 60) end,
	getDuration = function(self, t) return 3 + self:combatTalentSpellDamage(t, 5, 5) end,
	callbackOnSummonDeath = function(self, t, summon, src, death_note)
		t.well(self, t, summon.x, summon.y)
	end,
	well = function(self, t, x, y)
		-- Add a lasting map effect
		game.logSeen(self, "A #DARK_BLUE#wave of emptiness#LAST# erupts from the ground!")
		self:callTalent(self.T_ENERGY_ALTERATION, "forceActivate", DamageType.COLD)
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.VOID, {dam=t.getDamage(self, t), x=self.x, y=self.y, apply_wet=5},
			1,
			5, nil,
			MapEffect.new{color_br=30, color_bg=60, color_bb=200, effect_shader="shader_images/water_effect1.png"},
--			MapEffect.new{color_br=30, color_bg=60, color_bb=200, effect_shader={"shader_images/water_effect1.png","shader_images/water_effect2.png", max=6}},
			function(e, update_shape_only)
				if not update_shape_only then e.radius = e.radius + 0.5 end
				return true
			end,
			false -- no selffire
		)
		game:playSoundNear(self, "talents/tidalwave")
	end,
	action = function(self, t)
		t.well(self, t, self.x, self.y)
		return true
	end,
	info = function(self, t)
		return ([[A well of draining emptiness seeps out from the caster with an initial radius of 1, increasing by 1 per turn to a maximum radius of %d, doing %0.2f darkness damage and %0.2f arcane damage to all inside.
The well lasts for %d turns.
Spellpower: increases damage and duration.

Whenever one of your minions dies, the same well is cast from their position automatically.]]):tformat(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)/2), damDesc(self, DamageType.ARCANE, t.getDamage(self, t)/2), t.getDuration(self, t))
	end,
}

newTalent{
	name = "???", short_name = "REK_HEKA_TENTACLE_UNCERTAIN",
	type = {"spell/oubliette", 2},	require = mag_req2, points = 5,
	mode = "passive",
	range = 1,
	getDamage = function(self, t) return self:combatTalentScale(t, 10, 45) end,
	-- implemented in Earthdrum
	info = function(self, t)
		return ([[When a pillar rises, it does so with great force, dealing %0.1f physical damage and knocking enemies 2 spaces towards you.]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Spite's Sake", short_name = "REK_HEKA_TENTACLE_DEBUFF",
	type = {"spell/oubliette", 3}, require = mag_req3, points = 5,
	hands = 20,
	tactical = { DISABLE = 3 },
	cooldown = 16,
	range = 5,
	getEffectCount = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
	getDurationMult = function(self, t) return self:combatTalentLimit(t, 2.0, 1.1, 1.35) end,
	getNumb = function(self, t) return self:combatTalentLimit(t, 0.5, 0.05, 0.13) end,
	target = function(self, t) return {type="ball", range=0, radius=self:getTalentRange(t), nolock=true, nowarning=true, talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, _ = self:getTarget(tg)
		if not self:canProject(tg, x, y) then return nil end
		local target = game.level.map(x, y, Map.TERRAIN)
		if not target.is_pillar then return nil end

		target.temporary = 0
		target:act()

		return true
	end,
	info = function(self, t)
		return ([[Up to %d detrimental effects will be copied to nearby enemies, with their durations increased by %d%% (rounded up). Each enemy affected also deals %d%% less damage for as long as the longest effect copied to them. You still suffer from the effects.]]):tformat(t.getEffectCount(self, t), (t.getDurationMult(self, t)-1)*100, t.getNumb(self,t)*100)
	end,
}

newTalent{
	name = "Void of Meaning", short_name = "REK_HEKA_TENTACLE_EXECUTE",
	type = {"spell/oubliette", 4}, require = mag_req4, points = 5,
	mode = "passive"
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getPowerBonus = function(self, t) return self:combatTalentScale(t, 5, 30) end,
	kill = function(self, t, target)
		if target.turn_procs and target.turn_procs.rek_heka_tentacle then return end
		if target.life > target.max_life * 0.1 then return end
		if not target:checkHit(src:combatSpellpower(1, t.getPowerBonus(self, t)), target:combatMentalResist()) then return end
		target:setProc("rek_heka_tentacle", 3)
		if target:canBe("instakill") then
			target:die()
		else
			DamageType:get(DamageType.MIND).projector(self, target.x, target.y, DamageType.MIND, t.getDamage(self, t))
			target:crossTierEffect(target.EFF_BRAINLOCKED, self:combatSpellpower(1, t.getPowerBonus(self, t)))
		end
	end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if val <= 0 then return end
		if self.summoner and self:reactionToward(target) < 0 then
			if rng.percent(self.summoner:callTalent("T_TERROR_FRENZY", "getChance")) then
				self.summoner:callTalent("T_TERROR_FRENZY", "doReset")
			end
		end
	end,
	info = function(self, t)
		return ([[When you or your summons reduce a creature to less than 10%% life, it may die instantly (#SLATE#mental save vs spellpower + %d#LAST#).  Creatures immune to instant death instead take %0.1f mind damage and may be brainlocked.  This can only affect a given creature once every 3 turns.
Spellpower: increases damage.]]):tformat(t.getPowerBonus(self, t), damDesc(self, DamageType.MIND, t.getDamage(self, t)))
	end,
}
