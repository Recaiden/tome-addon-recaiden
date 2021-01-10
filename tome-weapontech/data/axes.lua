axeMHPreUse = function(self, t, silent)
	if not self:hasWeaponType("axe") then
		if not silent then game.logPlayer(self, "You require a mainhand axe to perform this technique!") end
		return false
	end
	return true
end

axeOHPreUse = function(self, t, silent)
	if not self:hasOffWeaponType("axe") then
		if not silent then game.logPlayer(self, "You require an offhand axe to perform this technique!") end
		return false
	end
	return true
end

newTalent{
	name = "Arterial Cut", short_name = "REK_WTEK_AXE_ARTERIAL_CUT",
	type = {"technique/weapon-techniques", 1}, require = str_req1, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1, PHYSICAL = 1 } },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = axeMHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.7, 0.7) end,
	getBleedDamage = function(self, t)
		local sw = self:getInven("MAINHAND")
		if sw then
			sw = sw[1] and sw[1].combat
		end
		sw = sw or self.combat
		local dam = self:combatDamage(sw)
		local damrange = self:combatDamageRange(sw)
		dam = rng.range(dam, dam * damrange)
		dam = dam * self:combatTalentWeaponDamage(t, 0.8, 0.8)
		return dam
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and target:canBe("cut") then
			local sw = self:getInven("MAINHAND")
			if sw then
				sw = sw[1] and sw[1].combat
			end
			sw = sw or self.combat
			local dam = self:combatDamage(sw)
			local damrange = self:combatDamageRange(sw)
			dam = rng.range(dam, dam * damrange)
			dam = dam * t.getBleedDamage(self, t)
			target:setEffect(target.EFF_CUT, 3, {src=self, power=dam / 3, apply_power=self:combatAttack(), no_ct_effect=true})
		end
		return true
	end,
	info = function(self, t)
		return ([[Carve through the target for %d%% weapon damage and bleeding them based on %d%% of your weapon damage over 3 turns.]]):tformat(t.getDamage(self, t)*100, t.getBleedDamage(self, t)*100)
	end,
}

newTalent{
	name = "Shieldshatter", short_name = "REK_WTEK_AXE_SHIELDSHATTER",
	type = {"technique/weapon-techniques", 2}, require = str_req2, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 1 },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = axeMHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.05, 1.05) end,
	getAPR = function(self, t) return 10+math.floor(self.level / 5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		local id_pen = self:addTemporaryValue("combat_apr", t.getAPR(self, t))
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		self:removeTemporaryValue("combat_apr", id_pen)
		
		return true
	end,
	info = function(self, t)
		return ([[Hack into your enemy with a brutal strike, dealing %d%% damage with %d extra armor penetration]]):format(t.getDamage(self, t)*100, t.getAPR(self, t))
	end,
}

newTalent{
	name = "Breezeblade", short_name = "REK_WTEK_AXE_BREEZEBLADE",
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
	on_pre_use = axeOHPreUse,
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
		return ([[Spin around and hack all adjacent targets for %d%% damage.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Rending Blade", short_name = "REK_WTEK_AXE_RENDING",
	type = {"technique/weapon-techniques", 4}, require = str_req4, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 2 } },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = axeOHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		self:attackTarget(target, nil, t.getDamage(self, t), true)
		if target then
			local weapon, offweapon = self:hasDualWeapon()
			if not offweapon then return nil end
			self:attackTargetWith(target, offweapon.combat, nil, self:getOffHandMult(offweapon.combat, t.getDamage(self, t)))	
		end
		return true
	end,
	info = function(self, t)
		return ([[Attack your enemy with all weapons, and then follow up with a second chop from your offhand axe, dealing %d%% damage.]]):format(t.getDamage(self, t)*100)
	end,
}
