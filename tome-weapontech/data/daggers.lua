daggerMHPreUse = function(self, t, silent)
	if self:attr("never_move") then
		if not silent then game.logPlayer(self, "You cannot move!") end
		return false
	end
	if not self:hasWeaponType("knife") then
		if not silent then game.logPlayer(self, "You require a mainhand dagger to perform this technique!") end
		return false
	end
	return true
end

daggerOHPreUse = function(self, t, silent)
	if self:attr("never_move") then
		if not silent then game.logPlayer(self, "You cannot move!") end
		return false
	end
	if not self:hasOffWeaponType("knife") then
		if not silent then game.logPlayer(self, "You require an offhand dagger to perform this technique!") end
		return false
	end
	return true
end

newTalent{
	name = "Thousand Cuts", short_name = "REK_WTEK_DAGGER_THOUSAND_CUTS",
	type = {"technique/weapon-techniques", 1}, require = dex_req1, points = 1,
	speed = "weapon",
	cooldown = 1,
	tactical = { ATTACK = { weapon = 2 } },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = daggerMHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		local stacks = target:hasProc("rek_thousand_cuts")
		if stacks then stacks = stacks.val else stacks = 0 end
		target:setProc("rek_thousand_cuts", stacks + 1, 5)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		local proc = target:hasProc("rek_thousand_cuts")
		if not proc or proc.val < 4 then
			game.logPlayer(self, "You haven't hit that target enough to use Thousand Cuts!")
			return nil
		end

		self:attackTarget(target, nil, t.getDamage(self, t), true)
		if target then self:attackTarget(target, nil, t.getDamage(self, t), true) end
		if target and target.turn_procs and target.turn_procs.multi then
			target.turn_procs.multi["rek_thousand_cuts"] = nil
		end
		return true
	end,
	info = function(self, t)
		return ([[Strike twice with each weapon, for %d%% damage.
This can only be used on a target that you have hit four or more times recently, and resets that counter.]]):tformat(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Rolling Stab", short_name = "REK_WTEK_DAGGER_ROLLING_STAB",
	type = {"technique/weapon-techniques", 2}, require = dex_req2, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 2 } },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = daggerMHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		--if not self:isNear(target.x, target.y, self:getTalentRange(t)) then return nil end
		
		local ox, oy = self.x, self.y
		local tx = (target.x - self.x) + target.x
		local ty = (target.y - self.y) + target.y
		if not game.level.map:checkAllEntities(tx, ty, "block_move", self) then
			self:move(tx, ty, true)
			if config.settings.tome.smooth_move > 0 then
				self:resetMoveAnim()
				self:setMoveAnim(ox, oy, 8, 5)
			end
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		else return nil end
		return true
	end,
	info = function(self, t)
		return ([[You sweep past the target, attacking for %d%% weapon damage and moving to the opposite side of them.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Throat Slitter", short_name = "REK_WTEK_DAGGER_THROAT_SLITTER",
	type = {"technique/weapon-techniques", 3}, require = dex_req3, points = 1,
	speed = "weapon",
	cooldown = 5,
	tactical = { ATTACK = { weapon = 2 } },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = daggerOHPreUse,
	getPower = function(self, t) return self:combatTalentScale(t, 1.0, 1.5, "log") end, 
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 0.8) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		local perc = 1 - (target.life / target.max_life)
		local mult = t.getDamage(self, t) + t.getPower(self, t) * perc
		self:attackTarget(target, nil, mult, true)
		if target.dead then
			game:onTickEnd(function() self:alterTalentCoolingdown(t.id, -9999) end)
		end
		return true
	end,
	info = function(self, t)
		return ([[Take advantage of an enemy's wounds to finish them off, dealing %d%% damage, increased by %0.1f%% for each %% of life the target is below maximum.  If an enemy dies from this attack then this talent's cooldown is reset.]]):format(t.getDamage(self, t)*100, t.getPower(self, t))
	end,
}

newTalent{
	name = "Blade Rush", short_name = "REK_WTEK_DAGGER_BLADE_RUSH",
	type = {"technique/weapon-techniques", 4}, require = dex_req4, points = 1,
	speed = function(self, t) return self:getSpeed("weapon") * 0.5 end,
	display_speed = function(self, t)
		return ("Double Weapon (#LIGHT_GREEN#%d%%#LAST# of a turn)"):tformat(self:getSpeed("weapon") * 50)
	end,
	cooldown = 3,
	tactical = { ATTACK = { weapon = 2 } },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = daggerOHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		self:attackTarget(target, nil, t.getDamage(self, t), true)
		return true
	end,
	info = function(self, t)
		return ([[Strike your enemy for %d%% damage with extreme speed.]]):format(t.getDamage(self, t)*100)
	end,
}
