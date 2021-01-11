battleaxePreUse = function(self, t, silent)
	if not self:hasTwoHandedWeapon() or not self:hasWeaponType("axe") then
		if not silent then
			game.logPlayer(self, "You require a two handed axe to use this talent.")
		end
		return false
	end
	return true
end

newTalent{
	name = "Hewing Blades", short_name = "REK_WTEK_BATTLEAXE_HEWING_BLADES",
	type = {"technique/weapon-techniques", 1}, require = str_req1, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 2 } },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = battleaxePreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.6, 0.60) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		for i = 1, 2 do
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		end
		return true
	end,
	info = function(self, t)
		return ([[Swing your battleaxe through and back, making two attacks for %d%% damage each.]]):tformat(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Wild Swing", short_name = "REK_WTEK_BATTLEAXE_WILD_SWING",
	type = {"technique/weapon-techniques", 2}, require = str_req2, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 1 },
	is_melee = true,
	range = 1,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = battleaxePreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	getAcc = function(self, t) return self:combatScale(self.level, 1, 1, 40, 50) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		local weapon = self:hasTwoHandedWeapon()
		
		local id_acc = self:addTemporaryValue("combat_atk", t.getAcc(self, t))
		local id_hit = self:addTemporaryValue("combat_physcrit", self:combatCrit(weapon)*0.5)
		local id_power = self:addTemporaryValue("combat_critical_power", 25)
		self:attackTarget(target, nil, t.getDamage(self, t), true)
		self:removeTemporaryValue("combat_critical_power", id_power)
		self:removeTemporaryValue("combat_physcrit", id_hit)
		self:removeTemporaryValue("combat_atk", id_acc)
		return true
	end,
	info = function(self, t)
		return ([[Swing your axe madly, attacking with %d reduced accuracy but one half more critical hit chance and +50%% critical power.]]):format(t.getDamage(self, t)*100, t.getAcc(self, t))
	end,
}

newTalent{
	name = "Gustblade", short_name = "REK_WTEK_BATTLEAXE_GUSTBLADE",
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
	on_pre_use = battleaxePreUse,
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
		return ([[Spin around to slash all adjacent targets, dealing %d%% damage and trying to knock them off-guard, increasing critical-hit chance against them.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Whirlwind Axe", short_name = "REK_WTEK_BATTLEAXE_WHIRLWIND",
	type = {"technique/weapon-techniques", 4}, require = str_req4, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACKAREA = { weapon = 1 }, CLOSEIN = 1.5 },
	range = 2,
	radius = 1,
	requires_target = true,
	target = function(self, t)
		return  {type="beam", nolock=true, default_target=self, range=self:getTalentRange(t), talent=t }
	end,
	getDamage = function (self, t) return self:combatTalentWeaponDamage(t, 0.8, 0.8) end,
	proj_speed = 20,
	on_pre_use = function(self, t, silent)
		if self:attr("never_move") then return false end
		return battleaxePreUse(self, t, silent)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not (x and y) then return nil end
		if core.fov.distance(self.x, self.y, x, y) > tg.range or not self:hasLOS(x, y) then
			game.logPlayer(self, "The target location must be within range and within view.")
			return nil 
		end
		local _ _, x, y = self:canProject(tg, x, y)
		if not (x and y) or not self:hasLOS(x, y) then return nil end
		-- make sure the grid location is valid
		local mx, my, grids = util.findFreeGrid(x, y, 1, true, {[Map.ACTOR]=true})
		if mx and my then
			if core.fov.distance(self.x, self.y, mx, my) > tg.range or not self:hasLOS(mx, my) then -- not valid,  check other free grids
				mx, my = nil, nil
				for i, grid in ipairs(grids) do
					if core.fov.distance(self.x, self.y, grid[1], grid[2]) <= tg.range and self:hasLOS(grid[1], grid[2]) then
						mx, my = grid[1], grid[2]
						break
					end
				end
			end
		end
		if not (mx and my) then 
			game.logPlayer(self, "There is no open space in which to land near there.")
			return nil 
		end

		local seen_targets = {}
		for px, py in core.fov.lineIterator(self.x, self.y, mx, my, "block_NOTHINGLOL") do
			local aoe = {type="ball", radius=1, friendlyfire=false, selffire=false, talent=t, display={ } }
			game.level.map:particleEmitter(px, py, 1, "meleestorm", {img="spinningwinds_red"})
			self:project(aoe, px, py, function(tx, ty)
				local target = game.level.map(tx, ty, engine.Map.ACTOR)
				if not target or seen_targets[target] or self.dead then return end
				local dam = 0
				seen_targets[target] = true
				self:attackTarget(target, nil, t.getDamage(self, t), true)
			end)
		end
		
		self:move(mx, my, true)

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local range = self:getTalentRange(t)
		return ([[You quickly spin up to %d tiles to arrive adjacent to a target location you can see, leaping around or over anyone in your way.  During your movement, you attack all foes within one grid of your path for %d%% weapon damage]]):
		tformat(range, damage*100)
	end,
}
