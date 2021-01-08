maceMHPreUse = function(self, t, silent)
	if not self:hasWeaponType("mace") then
		if not silent then game.logPlayer(self, "You require a mainhand mace to perform this technique!") end
		return false
	end
	return true
end

maceOHPreUse = function(self, t, silent)
	if not self:hasOffWeaponType("mace") then
		if not silent then game.logPlayer(self, "You require an offhand mace to perform this technique!") end
		return false
	end
	return true
end

newTalent{
	name = "Dazing Blow", short_name = "REK_WTEK_MACE_DAZING_BLOW",
	type = {"technique/weapon-techniques", 1}, require = str_req1, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 1 },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = swordMHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.9, 0.9) end,
	getAPR = function(self, t) return 5+math.floor(self.level / 10) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead then game:onTickEnd(function() target:setEffect(target.EFF_DAZED, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end) end
		
		return true
	end,
	info = function(self, t)
		return ([[Batter your enemy with your mace, dealing %d%% damage and dazing them for 1 turn after the attack]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Earthshaker", short_name = "REK_WTEK_MACE_EARTHSHAKER",
	type = {"technique/weapon-techniques", 2}, require = str_req2, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACKAREA = { weapon = 1 }, DISABLE = 1 },
	is_melee = true,
	range = 2,
	target = function(self, t)
		return {type="line", range=self:getTalentRange(t), selffire=false}
	end,
	on_pre_use = maceMHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTarget(target, nil, t.getDamage(self, t), true)
				if target and not target.dead and target:canBe("pin") then target:setEffect(target.EFF_PINNED, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end
			end
		end)
		self:addParticles(Particles.new("meleestorm", 1, {radius=1, img="spinningwinds_blue"}))

		return true
	end,
	info = function(self, t)
		return ([[Smash your mace against the ground, sending out a shockwave that does %d%% damage and knocks enemies down, pinning them for 1 turn.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Breezehammer", short_name = "REK_WTEK_MACE_BREEZEHAMMER",
	type = {"technique/weapon-techniques", 3}, require = str_req3, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACKAREA = { weapon = 1 } },
	is_melee = true,
	range = 0,
	radius = 1,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	on_pre_use = maceOHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 0.8) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTarget(target, nil, t.getDamage(self, t), true)
			end
		end)
		self:addParticles(Particles.new("meleestorm", 1, {radius=1, img="spinningwinds_blue"}))

		return true
	end,
	info = function(self, t)
		return ([[Spin around and crush all adjacent targets for %d%% damage.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Bonegrinder", short_name = "REK_WTEK_MACE_BONEGRINDER",
	type = {"technique/weapon-techniques", 4}, require = str_req4, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1, offhand = 1 }, DISABLE = 2 },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = maceOHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local hit = self:attackTargetWith(target, weapon.combat, nil, t.getDamge(self, t))
		if hit then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLIND, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true})
			end
		end
		
		local speed, hit = self:attackTargetWith(target, offweapon.combat, nil, self:getOffHandMult(offweapon.combat, t.getDamge(self, t)))
		if hit then
			if target:canBe("slow") then
				target:setEffect(target.EFF_CRIPPLE, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true})
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Attack your enemy with a pair of torminting blows doing %d%% damage.  Your mainhand strike inflcits blindness, and your offhand strike inflicts cripple, each for 1 turn.]]):format(t.getDamage(self, t)*100)
	end,
}
