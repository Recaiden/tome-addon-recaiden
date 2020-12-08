newTalent{
	name = "Mantra of Precession", short_name="REK_SHINE_MANTRA_PRECESSION",
	type = {"celestial/shining-mantra-mantras", 1}, require = mag_req1, points = 5,
	mode = "sustained",
	sustain_slots = 'shining_mantra',
	cooldown = 12,
	hide = true,
	no_energy = true,
	tactical = { ESCAPE = 1, CLOSEIN = 1 },
	getMovementSpeed = function(self, t) return self:combatTalentLimit(t, 5, 0.3, 1.0) end,
	callbackOnMove = function(self, t, moved, force, ox, oy, x, y)
		if not moved or force or (ox == self.x and oy == self.y) then return end
		if self.moving == true then return end
		if self.running then return end
		if not self.shining_precession_jump then 
			self.moving = true
			self:knockback(ox, oy, 1)
			self.moving = false
		end
		self.shining_precession_jump = nil
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {}
		self:talentTemporaryValue(ret, "movement_speed", t.getMovementSpeed(self, t))
		ret.particle = self:addParticles(Particles.new("mantra_shield", 1))
		mantraFireshield(self, t, ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		mantraRecitation(self)
		return true
	end,
	info = function(self, t)
		return ([[In singsong voice you repeat the secrets of motion, which increases your movement speed by %d%% and causes you to move 2 spaces at a time if possible.
You may only have one Mantra active at once.]]):format(t.getMovementSpeed(self, t)*100)
	end,
}

newTalent{
	name = "Mantra of Heliocentrism", short_name="REK_SHINE_MANTRA_HELIOCENTRISM",
	type = {"celestial/shining-mantra-mantras", 1}, require = mag_req1, points = 5,
	mode = "sustained",
	sustain_slots = 'shining_mantra',
	cooldown = 12,
	hide = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDamage = function(self, t) return self:combatTalentLimit(t, 100, 5, 10) end,
	callbackOnAct = function(self, t)
		if not self.old_x then self.old_x, self.old_y = self.x, self.y return end
		if self.old_x == self.x and self.old_y == self.y then
			self:setEffect(self.EFF_REK_SHINE_HELIOCENTRISM, 1, {power=t.getDamage(self, t)})
		end
		self.old_x, self.old_y = self.x, self.y
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {}
		ret.particle = self:addParticles(Particles.new("mantra_shield", 1))
		mantraFireshield(self, t, ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		mantraRecitation(self)
		return true
	end,
	info = function(self, t)
		return ([[In singsong voice you affirm the sun as the center.  Every turn you do not move, your gain a bonus of +%d%% damage, stacking up to 10 times.
You may only have one Mantra active at once.]]):format(t.getDamage(self, t))
	end,
}

newTalent{
	name = "Mantra of Entropy",  short_name="REK_SHINE_MANTRA_ENTROPY",
	type = {"celestial/shining-mantra-mantras", 1}, require = mag_req1, points = 5,
	mode = "sustained",
	sustain_slots = 'shining_mantra',
	cooldown = 12,
	hide = true,
	no_energy = true,
	tactical = { DEFEND = 1 },
	range = function(self, t) return self:combatTalentLimit(t, 10, 2, 5) end,
	callbackOnTalentPost = function(self, t, ab)
		if not self.in_combat then return end
		if not ab.is_spell then return end
		if ab.mode == "sustained" then return end
		if util.getval(ab.no_energy, self, ab) == true then return end

		local tg = {type="ball", range=0, friendlyfire=false, radius=self:getTalentRange(t), talent=t}
		local tgts = {}
		local grids = self:project(
			tg, self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target  then
					-- If we've already moved this target don't move it again
					for _, v in pairs(tgts) do
						if v == target then
							return
						end
					end
					
					local hit = target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95) and target:canBe("knockback")
					if hit then
						local dist = 1
						target:knockback(self.x, self.y, dist, false)
						tgts[#tgts+1] = target
						game.logSeen(target, "%s is knocked back!", target.name:capitalize())
					else
						game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
					end		
				end
			end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "gravity_spike", {radius=math.ceil(self:getTalentRange(t)), allow=core.shader.allow("distort")})
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {}
		ret.particle = self:addParticles(Particles.new("mantra_shield", 1))
		mantraFireshield(self, t, ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		mantraRecitation(self)
		return true
	end,
	info = function(self, t)
		return ([[In singsong voice you repeat the futility of action.  Every time you cast a spell (that takes a turn), enemies within range %d are knocked back (#SLATE#Spellpwoer vs. Physical#LAST#)
You may only have one Mantra active at once.]]):format(t.getMovementSpeed(self, t)*100)
	end,
}

----------- learnable talents
newTalent{
	name = "Mantra Initiate", short_name = "REK_SHINE_MANTRA_INITIATE",
	type = {"celestial/shining-mantras", 1}, require = mag_req1, points = 5,
	mode = "passive",
	no_unlearn_last = true,
	on_learn = function(self, t)
		self:learnTalent(self.T_REK_SHINE_MANTRA_PRECESSION, true, nil, {no_unlearn=true})
		self:learnTalent(self.T_REK_SHINE_MANTRA_HELIOCENTRISM, true, nil, {no_unlearn=true})
		self:learnTalent(self.T_REK_SHINE_MANTRA_ENTROPY, true, nil, {no_unlearn=true})
	end,
	on_unlearn = function(self, t)
		self:unlearnTalent(self.T_REK_SHINE_MANTRA_PRECESSION)
		self:unlearnTalent(self.T_REK_SHINE_MANTRA_HELIOCENTRISM)
		self:unlearnTalent(self.T_REK_SHINE_MANTRA_ENTROPY)
	end,
	info = function(self, t)
		local ret = ""
		local old1 = self.talents[self.T_REK_SHINE_MANTRA_PRECESSION]
		local old2 = self.talents[self.T_REK_SHINE_MANTRA_HELIOCENTRISM]
		local old3 = self.talents[self.T_REK_SHINE_MANTRA_ENTROPY]
		self.talents[self.T_REK_SHINE_MANTRA_PRECESSION] = (self.talents[t.id] or 0)
		self.talents[self.T_REK_SHINE_MANTRA_HELIOCENTRISM] = (self.talents[t.id] or 0)
		self.talents[self.T_REK_SHINE_MANTRA_ENTROPY] = (self.talents[t.id] or 0)
		pcall(function()
						local t1 = self:getTalentFromId(self.T_REK_SHINE_MANTRA_PRECESSION)
						local t2 = self:getTalentFromId(self.T_REK_SHINE_MANTRA_HELIOCENTRISM)
						local t3 = self:getTalentFromId(self.T_REK_SHINE_MANTRA_ENTROPY)
						ret = ([[[You have learned to sing the truth of the Sun, in the form of three magical Mantras.
			Mantra of Precession: Increases your movement speed by %d%% and you move 2 spaces at a time if possible.
			Mantra of Helocentrism: Each round where you do not move, you gain +%d%% damage, stacking 5 times.
			Mantra of Entropy: When you cast a spell (that takes a turn) enemies within range %d are knocked back.
    You may only have one Mantra active at a time.]]):
						tformat(t1.getSpeed(self, t1), t2.getDamage(self, t), self:getTalentRadius(t3))
					end)
		self.talents[self.T_REK_SHINE_MANTRA_PRECESSION] = old1
		self.talents[self.T_REK_SHINE_MANTRA_HELIOCENTRISM] = old2
		self.talents[self.T_REK_SHINE_MANTRA_ENTROPY] = old3
		return ret
	end,
}

mantraFireshield = function(self, t, ret)
	--Fire shield
	if self:knowTalent(self.T_REK_SHINE_MANTRA_ADEPT) then
		local t2 = self:getTalentFromId(self.T_REK_SHINE_MANTRA_ADEPT)
		self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.FIRE]=t2.getDamageOnMeleeHit(self, t2)})
	end
end

newTalent{
	name = "Mantra Adept", short_name = "REK_SHINE_MANTRA_ADEPT",
	type = {"celestial/shining-mantras", 2}, require = mag_req2, points = 5,
	mode = "passive",
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 50) end,
	-- insanity effect implemented in superload mod/class/Actor.lua:insanityEffect
	-- fireshield implemented in each mantra talent
	info = function(self, t)
		return ([[Your Mantras sear the air with unassailable truth, which does %0.1f fire damageto anyone who hits you in melee.  Additionally, whenever you would generate an insanity effect, you instead generate two and use the more extreme effect.

Spellpower: increases damage.]]):tformat(t.getDuration(self, t), t.getChance(self, t), t.getBonusPower(self, t), getResistBlurb(self))
	end,
}

newTalent{
	name = "Mantra Recitator", short_name = "REK_SHINE_MANTRA_RECITATOR",
	type = {"celestial/shining-mantras", 3}, require = mag_req3, points = 5,
	mode = "passive",
	range = function(self, t) 10 end,
	getMaxStacks = function(self, t) return 10 end,
	getHeal = function(self,t) return self:combatTalentScale(t, 10, 440) end,
	getDamage = function(self,t) return self:combatTalentScale(t, 10, 330) end,
	-- implemented in deactivate of mantras
	info = function(self, t)
		return ([[Conclude your mantras with a word of purifying flame.  While in combat, your Mantras generate stacks of Repetition each round, up to %d stacks.  When you deactivate a mantra, you are healed for up to %0.1f life and up to %d enemies in sight suffer up to %0.1f fire damage, based on your stacks of Repetition.
The healing is increased based on your increased fire damage.
Spellpower: increases healing and damage.]]):tformat(t.getMaxStacks(self, t), damDesc(self, DamageType.FIRE, t.getHeal(self, t)), damDesc(self, DamageType.FIRE, t.getDamage(self, t)), t.getMaxStacks(self, t))
	end,
}

newTalent{
	name = "Mantra Prophet", short_name = "REK_SHINE_MANTRA_PROPHET",
	type = {"celestial/shining-mantras", 4},	require = mag_req4,	points = 5,
	mode = "passive",
	getBoost = function(self, t) return self:combatTalentScale(t, 0.4, 1.2) end,
	getCapBoost = function(self, t) return 1.2 end,
	-- implemented in superload mod/class/Actor.lua:insanityEffect
	info = function(self, t)
		return ([[While repeating a mantra, your positive insanity effects are %d%% stronger, and the maximum power of positive insanity effects is increased from 50%% to %d%%.

The twists and turns of fate all lead to the inevitable end you have foretold.  Each setback is all part of the design. ]]):tformat(t.getBoost(self, t)*100, 50*t.getCapBoost(self, t))
	end,
}