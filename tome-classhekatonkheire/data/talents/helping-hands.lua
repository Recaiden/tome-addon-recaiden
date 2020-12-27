newTalent{
	name = "Forfend", short_name = "REK_HEKA_HELPING_FORFEND",
	type = {"technique/helping-hands", 1}, require = str_req_slow, points = 5,
	tactical = { DEFEND = 2 },
	speed= "weapon",
	cooldown = 8,
	hands = 20,
	getDuration = function (self, t) return 1 end,
	getBlock = function(self, t) return self:combatTalentScale(t, 30, 200) * (1 + self.level/50) end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_HEKA_FORFEND, t.getDuration(self, t), {power=t.getgetBlock(self, t), src=self})
		return true
	end,
	info = function(self, t)
		return ([[Throw out handfuls of hands, palms open, to block incoming threats, reducing all non-Mind damage by %d. If you block all of an attack's damage, the attacker will be vulnerable to a deadly counterstrike (the next weapon attack will deal double damage) for one turn.
The blocking value will increse with your level]]):tformat(t.getBlock(self, t))
	end,
}

newTalent{
	name = "Magpie Hook", short_name = "REK_HEKA_HELPING_MAGPIE",
	type = {"technique/helping-hands", 2}, require = str_req2, points = 5,
	speed = "weapon",
	mode = "sustained",
	--hands = 10,
	tactical = { ATTACK = { weapon = 2}, DISABLE = 1 },
	cooldown = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentScale(t, 1.0, 1.8) end,
	getDuration = function(self, t) return 2 end,
	getCD = function(self, t) return 10 end,
	-- TODO
	-- target:setEffect(target.EFF_DISARMED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower(), src=self})
	-- if target:hasEffect(target.EFF_DISARMED) then
	-- self:setEffect(self.EFF_REK_HEKA_MAGPIE_WEAPONS, t.getDuration(self, t), {weapon=weapon, src=self})
	-- end
	info = function(self, t)
		return ([[When an enemy hits you in melee, your hand swoop in to steal their weapon, disarming (#SLATE#Physical vs Physical#LAST#) them for %d turns.  Your next attack armed attack will also attack using the stolen weapon for %d%% damage.  A given enemy can only have their weapon stolen every %d turns.]]):tformat(t.getDuration(self, t), t.getDamage(self, t)*100, t.getCD(self, t))
	end,
}

newTalent{
	name = "Lay on Hands", short_name = "REK_HEKA_HELPING_HEALING",
	type = {"technique/helping-hands", 3}, require = str_req3, points = 5,
	mode = "passive",
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 0, 14) end,
	--TODO implement
	info = function(self, t)
		return ([[When your hands reunite with you after ending a talent that drains hands, invests hands, or has a sustained hand cost, you are healed by %d per hand.]]):tformat(t.getHeal(self, t))
	end,
}

newTalent{
	name = "???", short_name = "REK_HEKA_HELPING_XXXXXXXXXXXX",
	type = {"technique/helping-hands", 4},	require = str_req4, points = 5,
	cooldown = function(self, t) return 15 end,
	range = 1,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 3 },
	--no_npc_use = true,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 1.2) end,
	getDamageImmersion = function(self, t) return self:combatTalentWeaponDamage(t, 0.1, 0.6) end,
	getRes = function(self, t) return 80 - math.floor(self:combatTalentLimit(t, 40, 5, 20)) end,
	getNumb = function(self, t) return 40 + math.floor(self:combatTalentLimit(t, 40, 5, 20)) end,
	getDuration = function(self, t) return 5 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead then
			target:setEffect(target.EFF_REK_HEKA_IMMERSED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower(), dam=t.getDamageImmersion(self, t), resist=t.getRes(self, t), numb=t.getNumb(self, t), src=self})
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Hit an enemy for %d%% damage and knock them partway into the Other Place (#SLATE#Physical vs Spell#LAST#) for %d turns. Each turn while there, they suffer an unarmed attack for %d%% damage, all other damage they take is reduced by %d%%, and all damage they deal is reduced by %d%%.]]):tformat(t.getDamage(self, t)*100, t.getDuration(self, t), t.getDamageImmersion(self, t)*100, t.getRes(self, t), t.getNumb(self, t))
	end,
}