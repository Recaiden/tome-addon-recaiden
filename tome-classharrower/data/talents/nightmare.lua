newTalent{
	name = "Cosmic Awareness", short_name = "REK_GLR_NIGHTMARE_AWARENESS",
	type = {"psionic/unleash-nightmare", 1},
	require = wil_req_high1,
	points = 5,
	cooldown = 20,
	no_energy = true,
	psi = 20,
	getDuration = function(self, t) return self:combatTalentWeaponDamage(t, 5, 10) end,
	getConversion = function(self, t) return math.min(2/3, self:combatTalentMindDamage(t, 0.33, 0.6)) end,
	getResist = function(self, t) return self:combatTalentScale(t, 4, 9) end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_GLR_COSMIC_AWARENESS, t.getDuration(self, t) {power=t.getConversion(self, t), resist=t.getResist(self, t), src=self})
		return true
	end,
	info = function(self, t)
		return ([[Awaken the mind within your mind and let it bear witness to the false world around you. For the next %d turns, you can act while asleep, %d%% of incoming damage is converted to mind damage, and your mind resistance and maximum mind resistance are increased by +%d%%.
Mindpower: improves	conversion to mind damage.

#{italic}#I am awake.  I am aware.#{normal}#

#YELLOW#You can only learn 1 Unleash tree.#LAST#]]):
		format(t.getDuration(self, t), t.getConversion(self, t)*100, t.getResist(self, t))
	end,
}

newTalent{
	name = "Narcolepsy", short_name = "REK_GLR_NIGHTMARE_NARCOLESPY",
	type = {"psionic/unleash-nightmare", 2},
	require = wil_req_high2,
	points = 5,
	cooldown = 9,
	range = 10,
	psi = 7,
	tactical = { DISABLE = {SLEEP = 2 } },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDuration = function(self, t) return 4 end,
	getInsomniaPower = function(self, t)
		if not self:knowTalent(self.T_SANDMAN) then return 20 end
		local t = self:getTalentFromId(self.T_SANDMAN)
		local reduction = t.getInsomniaPower(self, t)
		return 20 - reduction
	end,
	getSleepPower = function(self, t)
		local power = self:combatTalentMindDamage(t, 15, 80)
		if self:knowTalent(self.T_SANDMAN) then
			local t = self:getTalentFromId(self.T_SANDMAN)
			power = power * t.getSleepPowerBonus(self, t)
		end
		return math.ceil(power)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		local is_waking =0
		if self:knowTalent(self.T_RESTLESS_NIGHT) then
			local t = self:getTalentFromId(self.T_RESTLESS_NIGHT)
			is_waking = t.getDamage(self, t)
		end

		local power = self:mindCrit(t.getSleepPower(self, t))
		if target:canBe("sleep") then
			target:setEffect(target.EFF_SLUMBER, t.getDuration(self, t), {src=self, power=power, waking=is_waking, insomnia=t.getInsomniaPower(self, t), no_ct_effect=true, apply_power=self:combatMindpower()})
			game.level.map:particleEmitter(target.x, target.y, 1, "generic_charge", {rm=180, rM=200, gm=100, gM=120, bm=30, bM=50, am=70, aM=180})
		else
			game.logSeen(self, "%s resists the sleep!", target.name:capitalize())
		end
		game:playSoundNear(self, "talents/dispel")
		return true
	end,
	info = function(self, t)
		return([[Puts the target into a sudden sleep for %d turns, rendering it mostly unable to act.  Every %d points of damage the target suffers will reduce the effect duration by one turn.
Mindpower: increases damage threshold 
When they wake, the target will benefit from Insomnia for a number of turns equal to the amount of time it was asleep (up to ten turns max), granting it %d%% sleep immunity.]]):format(t.getDuration(self, t), t.getSleepPower(self, t), t.getInsomniaPower(self, t))
	end,
}

newTalent{
	name = "Nightmare Overlay", short_name = "REK_GLR_NIGHTMARE_OVERLAY",
	type = {"psionic/unleash-nightmare", 3},
	require = wil_req_high3,
	points = 5,
	cooldown = 24,
	psi = 16,
	range = 6
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4.5)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.6) end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 4, 7)) end,
	getHallucination = function(self, t) return math.min(0.5, self:combatTalentMindDamage(t, 0.20, 0.33)) end,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Merge dreams and reality within a radius %d area for %d turns. Within this area, stun, daze, and sleep effects do not expire, and nightguants and hallucinations continually spawn.
Nightguants are weak attackers that do not interrupt sleep or daze.
Hallucinations do no harm but reduce damage dealt to non-hallucination targets by %d%%.
Mindpower: improves summon powers]]):format(self:getTalentRadius(t), t.getDuration(self, t), t.getHallucination(self, t))
	end,
}

newTalent{
	name = "Dream Shift", short_name = "REK_GLR_NIGHTMARE_SHIFT",
	type = {"psionic/unleash-nightmare", 4},
	require = wil_req_high4,
	points = 5,
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	psi = 15,
	range = 10,
	requires_target = true,
	tactical = { DISABLE = { stun = 1 } },
	getStat = function(self, t) return self:combatTalentMindDamage(t, 15, 85) end,
	getDuration = function(self, t) return self:combatTalentScale(t, 3, 6) end,
	target = function(self, t) return {type = "hit", range = self:getTalentRange(t), talent = t } end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return end
		local target = game.level.map(x, y, game.level.map.ACTOR)
		if not target then return nil end
		if not target:attr("sleep") then return end

		target:setEffect(target.EFF_REK_GLR_DREAM_SHIFT, 5, {power=t.getStat(self, t), lockin=t.getDuration(self, t), save=self:combatMindpower(), src=self})
		return true
		end,
	info = function(self, t)
		return ([[Transform a sleeping target into a harmless animal.  In this state all their stats are reduced by %d.
They spend at least %d turns in animal form (and turns while sleeping do not count).  After this they make a mental save each round to return to normal.]]):format(t.getDamage(self, t) * 100, t.getEffDamage(self, t) * 100)
	end,
}