shieldPreUse = function(self, t, silent)
	if not self:hasShield() then if not silent then game.logPlayer(self, "You require a shield to use this talent.") end return false end return true
end

newTalent{
	name = "Shield Bash", short_name = "REK_WTEK_SHIELD_BASH",
	type = {"technique/weapon-techniques", 3}, require = str_req3, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1 } },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = shieldPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 2.0, 2.0) end,
	action = function(self, t)
		local shield, shield_combat = self:hasShield()
		if not shield then return nil end
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		self:attackTargetWith(target, shield_combat, nil, t.getDamage(self, t))

		self:alterTalentCoolingdown(self.T_BLOCK, -2)
		return true
	end,
	info = function(self, t)
		return ([[Bash an enemy with your shield for %d%% shield damage and then take a defensive stance, reducing the cooldown of Block by 2.]]):tformat(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Shield Toss", short_name = "REK_WTEK_SHIELD_TOSS",
	type = {"technique/weapon-techniques", 4}, require = str_req4, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1 }, },
	is_melee = true,
	range = 5,
	--target = function(self, t) return {type="hit", range=self:getTalentRange(t), nolock=true, talent = t} end,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = shieldPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.25, 1.25) end,
	getAPR = function(self, t) return 5+math.floor(self.level / 10) end,
	action = function(self, t)
		local shield, shield_combat = self:hasShield()
		if not shield then return nil end
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		
		local hit = self:attackTargetWith(target, shield_combat, nil, t.getDamage(self, t))

		return true
	end,
	info = function(self, t)
		return ([[Throw your shield such that it strikes an enemy for %d%% shield damage and then returns to your hand.]]):format(t.getDamage(self, t)*100)
	end,
}