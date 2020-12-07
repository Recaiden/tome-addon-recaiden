
newTalent{
	name = "Mantra Initiate", short_name = "REK_SHINE_MANTRA_INITIATE",
	type = {"demented/shining-mantras", 1},
	require = mag_req1, points = 5,
	mode = "passive",
	getAffinity = function(self, t) return self:combatTalentScale(t, 10, 35, 0.75) end,
	on_learn = function(self, t) self.blood_color = colors.GOLD end,
	passives = function(self, t, p)
		self:talentTemporaryValue(
			p, "damage_affinity", {
				[DamageType.LIGHT] = t.getAffinity(self, t),
				[DamageType.FIRE] = t.getAffinity(self, t)
														})
		self:talentTemporaryValue(
			p, "resists", {
				[DamageType.LIGHT]=getMaxResistIncrease(self),
				[DamageType.FIRE]=getMaxResistIncrease(self)
										})
	end,
	info = function(self, t)
		return ([[You have learned to sing the truth of the Sun, in the form of three magical Mantras.

    Mantra of Precession: Increases your movement speed by %d%% and you move 2 spaces at a time if possible.

    Mantra of Helocentrism: Each round where you do not move, you gain +%d%% damage, stacking 5 times.

    Mantra of Entropy: When you cast a spell (that take a turn) enemies within range %d are knocked back.

    You may only have one Chant active at a time.
]]):tformat(t.getSpeed(self, t), t.getDamage(self, t), t.getRadius(self, t))
	end,
}

newTalent{
	name = "Mantra Adept", short_name = "REK_SHINE_MANTRA_ADEPT",
	type = {"demented/shining-mantras", 2},
	require = mag_req2, points = 5,
	mode = "passive",
	getChance = function(self, t) return math.floor(self:combatTalentScale(t, 4.4, 9)) end,
	getDuration = function(self, t) return 5 end,
	getBonusPower = function(self, t) return 5 end,
	-- insanity effect implemented in superload mod/class/Actor.lua:insanityEffect
	-- fireshield implemented in each mantra talent
	info = function(self, t)
		return ([[Your Mantras sear the air with unassailable truth, which does %0.1f fire damageto anyone who hits you in melee.  Additionally, whenever you would generate an insanity effect, you instead generate two and use the more extreme effect.

Spellpower: increases damage.]]):tformat(t.getDuration(self, t), t.getChance(self, t), t.getBonusPower(self, t), getResistBlurb(self))
	end,
}

newTalent{
	name = "Mantra Recitator", short_name = "REK_SHINE_MANTRA_RECITATOR",
	type = {"demented/shining-mantras", 3},
	require = mag_req3, points = 5,
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
	type = {"demented/shining-mantras", 4},	require = mag_req4,	points = 5,
	mode = "passive",
	getBoost = function(self, t) return self:combatTalentScale(t, 0.4, 1.2) end,
	getCapBoost = function(self, t) return 1.2 end,
	-- implemented in superload mod/class/Actor.lua:insanityEffect
	info = function(self, t)
		return ([[While repeating a mantra, your positive insanity effects are %d%% stronger, and the maximum power of positive insanity effects is increased from 50%% to %d%%.

The twists and turns of fate all lead to the inevitable end you have foretold.  Each setback is all part of the design. ]]):tformat(t.getBoost(self, t)*100, 50*t.getCapBoost(self, t))
	end,
}