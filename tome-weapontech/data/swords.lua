swordMHPreUse = function(self, t, silent)
	if self:attr("never_move") then
		if not silent then game.logPlayer(self, "You cannot move!") end
		return false
	end
	if not self:hasWeaponType("sword") then
		if not silent then game.logPlayer(self, "You require a mainhand sword to perform this technique!") end
		return false
	end
	return true
end

swordOHPreUse = function(self, t, silent)
	if self:attr("never_move") then
		if not silent then game.logPlayer(self, "You cannot move!") end
		return false
	end
	if not self:hasOffWeaponType("sword") then
		if not silent then game.logPlayer(self, "You require an offhand sword to perform this technique!") end
		return false
	end
	return true
end

newTalent{
	name = "Lunge", short_name = "REK_WTEK_SWORD_LUNGE",
	type = {"technique/weapon-techniques", 1}, require = str_req1, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 2 }, CLOSEIN = 2 },
	is_melee = true,
	range = 2,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = swordMHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.05, 1.05) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		if core.fov.distance(self.x, self.y, x, y) > 1 then
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
			local linestep = self:lineFOV(x, y, block_actor)
	
			local tx, ty, lx, ly, is_corner_blocked
			repeat  -- make sure each tile is passable
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = linestep:step()
			until is_corner_blocked or not lx or not ly or game.level.map:checkAllEntities(lx, ly, "block_move", self)
	
			if not tx or not ty or core.fov.distance(x, y, tx, ty) > 1 then return nil end
	
			local ox, oy = self.x, self.y
			self:move(tx, ty, true)
			if config.settings.tome.smooth_move > 0 then
				self:resetMoveAnim()
				self:setMoveAnim(ox, oy, 8, 5)
			end
		end
		
		-- Attack
		if not core.fov.distance(self.x, self.y, x, y) == 1 then return nil end
		self:attackTarget(target, nil, t.getDamage(self, t), true)
		
		return true
	end,
	info = function(self, t)
		return ([[Swiftly step up to your target and strike for %d%% weapon damage.]]):tformat(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Pommel Strike", short_name = "REK_WTEK_SWORD_POMMEL STRIKE",
	type = {"technique/weapon-techniques", 2}, require = str_req2, points = 1,
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

		local id_pen = self:addTemporaryValue("combat_apr", t.getAPR(self, t))
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead and target:canBe("stun") then target:setEffect(target.EFF_STUNNED, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end
		self:removeTemporaryValue("combat_apr", id_pen)
		
		return true
	end,
	info = function(self, t)
		return ([[Batter your enemy with the hilt of your sword, dealing %d%% damage with %d extra armor penetration and stunning them for 1 turn.]]):format(t.getDamage(self, t)*100, t.getAPR(self, t))
	end,
}

newTalent{
	name = "Breezeblade", short_name = "REK_WTEK_SWORD_BREEZEBLADE",
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
	on_pre_use = swordOHPreUse,
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
		return ([[Spin around and slash all adjacent targets for %d%% damage.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Overwhelm", short_name = "REK_WTEK_SWORD_OVERWHELM",
	type = {"technique/weapon-techniques", 4}, require = str_req4, points = 1,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 1 },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = swordOHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		self:attackTarget(target, nil, t.getDamage(self, t), true)
		if target then
			local hit = self:attackTarget(target, nil, t.getDamage(self, t), true, true)
			if hit and not target.dead and target:canBe("confusion") then target:setEffect(target.EFF_CONFUSED, 1, {power=33, src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end
		end
		return true
	end,
	info = function(self, t)
		return ([[Attack your enemy with all weapons, and then follow up with a kick for %d%% unarmed damage that confuses them for 1 turn.]]):format(t.getDamage(self, t)*100)
	end,
}
