getMindPrisonKills = function(self)
	return math.min(1000, self.rek_glr_mindprison_kills or 0)
end


newTalent{
	name = "Dream Chorus", short_name = "REK_GLR_MINDPRISON_CHORUS",
	type = {"psionic/mindprison", 1},
	require = wil_req1,
	points = 5,
	mode = "passive",
	getScaling = function(self, t)
		local critTL = self:combatTalentScale(t, 1, 8)
		local critKill = self:combatTalentScale(t, 0.003, 0.012) * getMindPrisonKills(self)
		return critTL + critKill
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_mindcrit", t.getScaling(self, t))
	end,
	callbackOnKill = function(self, t, src, death_note)
		if src.summoner then return end
		if src:reactionToward(self) > 0 then return end
		self.rek_glr_mindprison_kills = (self.rek_glr_mindprison_kills or 0) + 1
		self:updateTalentPassives(t)
	end,
	info = function(self, t)
		return ([[When you kill an enemy, you absorb their psyche into your dreams.
Their psychic energy grants you %d%% additional mental critical strike chance.
Absorbed Psyches: %d / 1000]]):
		format(t.getScaling(self, t), getMindPrisonKills(self))
	end,
}

newTalent{
	name = "Reverie", short_name = "REK_GLR_MINDPRISON_REVERIE",
	type = {"psionic/mindprison", 2},
	require = wil_req2,
	points = 5,
	cooldown = function(self, t) return 44 - math.floor(getMindPrisonKills(self) / 50) end,
	fixed_cooldown = true,
	no_energy = true,
	psi = 15,
	getCount = function(self,t) return math.max(1,math.floor(self:combatTalentScale(t, 1.01, 2.9, "log"))) end,
	action = function(self, t)
		local state = {remaining = t.getCount(self,t)}
		local Chat = require("engine.Chat")
		local chat = Chat.new("rek-glr-reverie", {name="Reverie"}, self, {version=self, state=state, co=coroutine.running()})
		local d = chat:invoke()
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		return ([[Retreat into your mindscape and spend a while planning, resting, and conversing, all in an instant.  Select %d of your cooling-down class talents with non-fixed cooldowns, and they become available to use again.
Absorbed Psyches: improves cooldown]]):format(t.getCount(self, t))
	end,
}

newTalent{
	name = "Sacrificial Identity", short_name = "REK_GLR_MINDPRISON_CLEANSE",
	type = {"psionic/mindprison", 3},
	require = wil_req3,
	points = 5,
	psi = 5,
	innate = true,
	cooldown = function(self, t) return self:combatTalentLimit(t, 9, 30, 12) end, 
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Shift a mental effect onto a psyche in your mindscape, removing it from you.

#{italic}#An affliction shared is an affliction halved!#{normal}#]]):
		format()
	end,
}

newTalent{
	name = "Overflowing Thoughts", short_name = "REK_GLR_MINDPRISON_OVERFLOW",
	type = {"psionic/mindprison", 4},
	require = wil_req4,
	points = 5,
	sustain_psi = 5,
	cooldown = 30,
	fixed_cooldown = true,
	no_energy=true,
	tactical = { BUFF = 2 },
	points = 5,
	getGain = function(self, t) return self:combatTalentMindDamage(t, 0.5, 1.5) + getMindPrisonKills(self) / 1000 end,
	action = function(self, t)
		self.energy.value = self.energy.value + t.getGain(self, t) * game.energy_to_act
		self:setEffect(self.EFF_REK_GLR_OVERFLOW, 1, {src=self})
		return true
	end,
	info = function(self, t)
		return ([[Instantly gain %0.2f%% of a turn.  One round later, lose 100%% of a turn.
Mindpower: improves turn gain
Absorbed Psyches: improves turn gain

#{italic}#Your mind spills over with a dozen voices, driving you in multiple directions at once. #{normal}#]]):format(t.getGain(self, t)*100)
	end,
}