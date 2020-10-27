newTalent{
	name = "Accelerate", short_name = "REK_GLR_MARKSMAN_ACCELERATE",
	type = {"technique/psychic-marksman", 1},
	require = mastery_dex_req,
	points = 5,
	mode = "passive",
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.8 end,
	getReload = function(self, t)	return math.floor(self:combatTalentScale(t, 0, 2.7, "log"))	end,
	getSpeed = function(self, t) return self:combatTalentScale(t, 10, 45) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, 'ammo_mastery_reload', t.getReload(self, t))
		self:talentTemporaryValue(p, "slow_projectiles_outgoing", -1*t.getSpeed(self, t))
	end,
	info = function(self, t)
		return ([[Enhance the strength of the bow with the strength of your mind. Increases Physical Power by %d and weapon damage by %d%% when using a bow & arrow and increases your reload rate by %d.  You substitute Willpower for Strength when dealing damage with arrows.

In addition, outgoing projectiles have their speed increased by %d%%.]]):format(t.getDamage(self, t), 100*t.getPercentInc(self, t), t.getReload(self, t), t.getSpeed(self, t))
	end,
}


newTalent{
	name = "Pinpoint Targeting", short_name = "REK_GLR_MARKSMAN_PINPOINT",
	type = {"technique/psychic-marksman", 2},
	require = dex_req2,
	points = 5,
	mode = "passive",
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 6, 60) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "ranged_project", {[DamageType.PHYSICAL] = t.getDamage(self, t)})
	end,
	info = function(self, t)
		return ([[You use telekinetic power to impart additional force to your arrows after firing, causing them to do an additional %0.2f physical damage on-hit.

Your arrow attacks benefit from an additional accuracy bonus: 2.5%% increased on-hit damage per excess accuracy.  Your on-hit damage can get mental critical hits.]]):format(t.getDamage(self, t))
	end,
}


newTalent{
	name = "Trace", short_name = "REK_GLR_MARKSMAN_TRACE",
	type = {"technique/psychic-marksman", 3},
	points = 5,
	cooldown = 25,
	psi = 30,
	require = dex_req3,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 7, 2, 5)) end,
	getRevealPower = function(self, t) return 15 + self:combatTalentMindDamage(t, 1, 100) end,
	getAtk = function(self, t) return self:combatTalentScale(t, 40, 100, 0.75) end,
	callbackOnArcheryAttack = function(self, t, target, hitted)
		if hitted and target and not target.dead then
			target:setEffect(target.EFF_REK_GLR_TRACED, 5, {power=t.getRevealPower(self, t), src=self})
		end
	end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_GLR_TRACE, t.getDuration(self, t), {power = t.getAtk(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Form a psychic map of your foes' defenses, increasing your accuracy by %d for the next %d turns.

Whenever you hit someone with an arrow, your tracing focuses on them, reducing their stealth and invisiblity power by %d and allowing you to fight them without vision.]]):format(t.getAtk(self, t), t.getDuration(self, t), t.getRevealPower(self, t))
	end,
}

newTalent{
	name = "Soundshock", short_name = "REK_GLR_MARKSMAN_SOUNDSHOCK",
	type = {"technique/psychic-marksman", 4},
	points = 5,
	require = dex_req4,
	mode = "passive",
	getMinConfuse = function(self, t) return math.max(0, self:combatTalentScale(t, 0, 10)) end,
	getAccConfuse = function(self, t) return 10 end,
	callbackOnArcheryAttack = function(self, t, target, hitted)
		local weapon, ammo = self:hasArcheryWeapon()
		if not weapon then return end
		local bonus = util.bound((self:combatAttack() - target:combatDefense())/2, 0, t.getAccConfuse(self, t))
		if hitted and target and not target.dead then
			if target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, 1, {power=t.getMinConfuse(self, t)+bonus, apply_power=self:combatMindpower(), no_ct_effect=true, src=self})
			end
		end
	end,
	info = function(self, t)
		return ([[The impact of your arrows creates a disorienting sonic vortex, confusing the targets you strike for 1 turn.  The confusion power (%d%% to %d%%) is based on your accuracy compared to their defense and can never inflict brainlock.]]):format(t.getMinConfuse(self, t), t.getMinConfuse(self, t) + t.getAccConfuse(self, t))
	end,
}