getMindPrisonKills = function(self)
	return math.min(20, self.rek_glr_mindprison_kills or 0)
end


newTalent{
	name = "Dream Chorus", short_name = "REK_GLR_MINDPRISON_CHORUS",
	type = {"psionic/mindprison", 1},
	require = wil_req1,
	points = 5,
	no_unlearn_last = true,
	points = 5,
	cooldown = 30,
	psi = 10,
	range = 10,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getScaling = function(self, t)
		local critTL = self:combatTalentScale(t, 1, 8)
		local critKill = self:combatTalentScale(t, 0.15, 0.60) * getMindPrisonKills(self)
		return critTL + critKill
	end,
	getDamage = function(self, t) return 10 + self:combatMindpower() / 3 end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 5, 10)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_mindcrit", t.getScaling(self, t))
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target or target == self then return nil end

		if target.dead then game.logPlayer(self, "Your target is dead!") return nil end

		target:setEffect(target.EFF_REK_GLR_MIND_NET, t.getDuration(self, t), {apply_power=self:combatMindpower(), src=self, power=t.getDamage(self, t)})
		game:playSoundNear(self, "talents/chant_three")
		return true
	end,
	captureMind = function(self, t, src, death_note)
		if src.summoner then return nil end
		if src:reactionToward(self) > 0 then return nil end
		self.rek_glr_mindprison_kills = (self.rek_glr_mindprison_kills or 0) + 1
		self:updateTalentPassives(t)
		return true
	end,
	info = function(self, t)
		return ([[You project a psionic net around a target (#SLATE#Mindpower vs Mental#LAST#) that lasts for %d turns and deals %0.2f mind damage each turn.
If a rare or stronger target dies with the net in place you will capture its mind and absorb it into your dreams.
Mindpower: increases damage.
Their psychic energy grants you additional mental critical chance, currently: %d%%.
Absorbed Psyches: %d / 20]]):
		format(t.getDuration(self, t), t.getDamage(self, t), t.getScaling(self, t), getMindPrisonKills(self))
	end,
}

newTalent{
	name = "Reverie", short_name = "REK_GLR_MINDPRISON_REVERIE",
	type = {"psionic/mindprison", 2},
	require = wil_req2,
	points = 5,
	cooldown = function(self, t) return 44 - math.floor(getMindPrisonKills(self)) end,
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
		game:playSoundNear(self, "talents/chant_two")
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
	innate = true,
	no_energy = true,
	on_pre_use = function(self, t)
		if getMindPrisonKills(self) < 1 then return false end
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type == "mental" then
				return true
			end
		end
		return false
	end,
	cooldown = function(self, t) return self:combatTalentLimit(t, 9, 30, 12) end, 
	action = function(self, t)
		self:removeEffectsFilter(self, {status="detrimental", type="mental"}, 1)
		self.rek_glr_mindprison_kills = math.max(0, getMindPrisonKills(self) -1)
		if self:knowTalent(self.T_REK_GLR_MINDPRISON_CHORUS) then
			local t = self:getTalentFromId(self.T_REK_GLR_MINDPRISON_CHORUS)
			self:updateTalentPassives(t)
		end
	
		return true
	end,
	info = function(self, t)
		return ([[Shift a negative mental effect onto a captured mind and release it, removing the effect from you at the cost of 1 absorbed psyche.

#{italic}#An affliction shared is an affliction halved!#{normal}#]]):
		format()
	end,
}

newTalent{
	name = "Overflowing Thoughts", short_name = "REK_GLR_MINDPRISON_OVERFLOW",
	type = {"psionic/mindprison", 4},
	require = wil_req4,
	points = 5,
	psi = 12,
	cooldown = 30,
	fixed_cooldown = true,
	no_energy=true,
	tactical = { BUFF = 2 },
	points = 5,
	getGain = function(self, t) return 0.25 + self:combatTalentMindDamage(t, 0.25, 1.25) + getMindPrisonKills(self) / 20 end,
	action = function(self, t)
		self.energy.value = self.energy.value + t.getGain(self, t) * game.energy_to_act
		self:setEffect(self.EFF_REK_GLR_OVERFLOW, 1, {src=self})
		game:playSoundNear(self, "talents/shimmerpower")
		return true
	end,
	info = function(self, t)
		return ([[Instantly gain %0.2f%% of a turn.  One round later, lose 100%% of a turn.
Mindpower: improves turn gain
Absorbed Psyches: improves turn gain

#{italic}#Your mind spills over with a dozen voices, driving you in multiple directions at once. #{normal}#]]):format(t.getGain(self, t)*100)
	end,
}