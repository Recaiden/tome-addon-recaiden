greatmaulPreUse = function(self, t, silent)
	if not self:hasTwoHandedWeapon() or not self:hasWeaponType("mace") then
		if not silent then
			game.logPlayer(self, "You require a two handed mace to use this talent.")
		end
		return false
	end
			return true
end

newTalent{
	name = "Crushing Blow", short_name = "REK_WTEK_GREATMAUL_CRUSH",
	type = {"technique/weapon-techniques", 1}, require = str_req1, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 2 } },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = greatmaulPreUse,
	getAPR = function(self, t) return 10+math.floor(self.level / 5) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.00, 1.00) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		
		local id_pen = self:addTemporaryValue("combat_apr", t.getAPR(self, t))
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead and target:canBe("stun") then target:setEffect(target.EFF_STUNNED, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end
		self:removeTemporaryValue("combat_apr", id_pen)

		return true
	end,
	info = function(self, t)
		return ([[Smash your hammer straight down on an enemy, dealing %d%% damage with %d extra armor-penetration and stunning them for 1 turn.]]):tformat(t.getDamage(self, t)*100, t.getAPR(self, t))
	end,
}

newTalent{
	name = "Earthbreaker", short_name = "REK_WTEK_GREATMAUL_EARTHSHAKER",
	type = {"technique/weapon-techniques", 2}, require = str_req2, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACKAREA = { weapon = 1 }, DISABLE = 1 },
	is_melee = true,
	range = 2,
	target = function(self, t)
		return {type="cone", range=0, radius=self:getTalentRange(t), selffire=false}
	end,
	on_pre_use = greatmaulPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.1) end,
	getAPR = function(self, t) return 10+math.floor(self.level / 5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "mudflow", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		self:project(tg, x, y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTarget(target, nil, t.getDamage(self, t), true)
				if target and not target.dead and target:canBe("pin") then target:setEffect(target.EFF_PINNED, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Smash your hammer against the ground, sending out a shockwave that does %d%% damage in a cone and knocks enemies down, pinning them for 1 turn.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Gusthammer", short_name = "REK_WTEK_GREATMAUL_GUSTBLADE",
	type = {"technique/weapon-techniques", 3}, require = str_req3, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACKAREA = { weapon = 1 } },
	is_melee = true,
	range = 0,
	radius = 1,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	on_pre_use = greatmaulPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.05, 1.05) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
				if hit and not target.dead then target:setEffect(target.EFF_OFFGUARD, 2, {src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end
			end
		end)
		self:addParticles(Particles.new("meleestorm", 1, {radius=1, img="spinningwinds_blue"}))

		return true
	end,
	info = function(self, t)
		return ([[Spin around to crush all adjacent targets, dealing %d%% damage and trying to knock them off-guard, increasing critical-hit chance against them.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Guarded Slam", short_name = "REK_WTEK_GREATMAUL_GUARD",
	type = {"technique/weapon-techniques", 4}, require = str_req4, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	on_pre_use = greatmaulPreUse,
	tactical = { ATTACKARE = { weapon = 1 } },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead then target:setEffect(target.EFF_OFFBALANCE, 2, {src=self, apply_power=self:combatAttack()}) end
		
		return true
	end,
	info = function(self, t)
		return ([[Strike with a measured blow that deals %d%% damage and leaves the target off-balance for 2 turns.]]):format(t.getDamage(self, t)*100, 10)
	end,
}
