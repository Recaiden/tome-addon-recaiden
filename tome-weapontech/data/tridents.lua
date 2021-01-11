tridentPreUse = function(self, t, silent)
	if not self:hasTwoHandedWeapon() or not self:hasWeaponType("trident") then
		if not silent then
			game.logPlayer(self, "You require a two handed trident to use this talent.")
		end
		return false
	end
			return true
end

newTalent{
	name = "Piercing Points", short_name = "REK_WTEK_TRIDENT_PIERCE",
	type = {"technique/weapon-techniques", 1}, require = str_req1, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACKAREA = { weapon = 1 } },
	is_melee = true,
	range = 3,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local targets = {}
		self:project(
			tg, x, y,
			function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and target ~= self then
					targets[#targets+1] = target
				end
			end)
		for i, target in ipairs(targets) do
			self:attackTarget(target, nil, t.getDamage(self, t)*(1+#targets*0.1), true)
		end

		return true
	end,
	info = function(self, t)
		return ([[Spear through all targets in a short line, dealing %d%% damage, increased by %d%% per target.]]):format(t.getDamage(self, t)*100, 10)
	end,
}

newTalent{
	name = "Impaler", short_name = "REK_WTEK_TRIDENT_IMPALER",
	type = {"technique/weapon-techniques", 2}, require = str_req2, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 1 },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = tridentPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.95, 0.95) end,
	getAPR = function(self, t) return 10+math.floor(self.level / 5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead and target:canBe("slow") then target:setEffect(target.EFF_CRIPPLE, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end
		
		return true
	end,
	info = function(self, t)
		return ([[Tear your trident across an enemy's weak points, dealing %d%% damage and crippling the target for 1 turn.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Typhoon Trident", short_name = "REK_WTEK_TRIDENT_GUSTBLADE",
	type = {"technique/weapon-techniques", 3}, require = str_req3, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACKAREA = { weapon = 1 } },
	is_melee = true,
	range = 0,
	radius = 2,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	on_pre_use = tridentPreUse,
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
		return ([[Spin around to slash all targets within radius 2, dealing %d%% damage and trying to knock them off-guard, increasing critical-hit chance against them.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Vault", short_name = "REK_WTEK_TRIDENT_VAULT",
	type = {"technique/weapon-techniques", 4}, require = str_req4, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	on_pre_use = tridentPreUse,
	tactical = { ATTACKARE = { weapon = 1 } },
	is_melee = true,
	range = 2,
	target = function(self, t) return {type="cone", x=self.x, y=self.y, stop_before_target=true, radius=1, range=self:getTalentRange(t), nolock=true} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		self:setTarget(nil) -- stop_before_target requires that to force a scan
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local ox, oy = self.x, self.y

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local l = self:lineFOV(x, y, block_actor)
		local lx, ly, is_corner_blocked = l:step()
		local tx, ty, _ = lx, ly
		while lx and ly do
			if is_corner_blocked or block_actor(_, lx, ly) then break end
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
		end

		-- Find space
		if block_actor(_, tx, ty) then return nil end
		local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not fx then return end


		--collect targets before moving to keep cone orientation
		local targets = self:projectCollect(tg, fx, fy, Map.ACTOR)

		-- move in case the attack would block the space somehow  
		self:move(fx, fy, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 9, 5)
		end

		-- attack
		for target, pos in pairs(targets) do
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Plant the end of your trident on the ground to assist a leap into the air, then bring the points down on enemeis in a small cone, dealing %d%% damage.]]):format(t.getDamage(self, t)*100)
	end,
}
