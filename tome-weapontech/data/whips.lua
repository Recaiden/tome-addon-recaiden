whipMHPreUse = function(self, t, silent)
	if not self:hasWeaponType("whip") then
		if not silent then game.logPlayer(self, "You require a mainhand whip to perform this technique!") end
		return false
	end
	return true
end

whipOHPreUse = function(self, t, silent)
	if not self:hasOffWeaponType("whip") then
		if not silent then game.logPlayer(self, "You require an offhand whip to perform this technique!") end
		return false
	end
	return true
end

newTalent{
	name = "Whipcrack", short_name = "REK_WTEK_WHIP_WHIPCRACK",
	type = {"technique/weapon-techniques", 1}, require = dex_req1, points = 1, innate = true,
	speed = "weapon",
	cooldown = 0,
	tactical = { ATTACK = { weapon = 1 } },
	is_melee = true,
	range = 3,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = whipMHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		self:attackTarget(target, nil, t.getDamage(self, t), true)

		return true
	end,
	info = function(self, t)
		return ([[Lash out with your whip to hit a target up to %d spaces away for %d%% damage.]]):tformat(self:getTalentRange(t), t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Wrest", short_name = "REK_WTEK_WHIP_WREST",
	type = {"technique/weapon-techniques", 2}, require = dex_req2, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = { DISARM = 0.5 } },
	is_melee = true,
	range = 3,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 0.8) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead and target:canBe("disarm") then target:setEffect(target.EFF_DISARM, 1, {src=self, apply_power=self:combatAttack(), no_ct_effect=true}) end

		return true
	end,
	info = function(self, t)
		return ([[Snap your whip to wrap around a targets weapon, dealing %d%% damage and disarming them for 1 turn.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Encoil", short_name = "REK_WTEK_WHIP_ENCOIL",
	type = {"technique/weapon-techniques", 3}, require = dex_req3, points = 1, innate = true,
	speed = "weapon",
	cooldown = 5,
	tactical = { ATTACK = { weapon = 2 } },
	is_melee = true,
	range = 3,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t, nolock=true} end,
	on_pre_use = whipOHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 0.5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local dist = core.fov.distance(self.x, self.y, x, y)
		if dist > tg.range then return end
		local ok = true
		self:project(
			tg, x, y,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				
				if target then -- hook actor
					local tx, ty
					local size = target.size_category - self.size_category
					if size >= 1 or not target:canBe("knockback") then
						if self:attr("never_move") then game.logPlayer(self, "You cannot move!") ok = false return end
						local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
						local linestep = self:lineFOV(x, y, block_actor)
						local lx, ly, is_corner_blocked
						repeat  -- make sure each tile is passable
							tx, ty = lx, ly
							lx, ly, is_corner_blocked = linestep:step()
						until is_corner_blocked or not lx or not ly or game.level.map:checkAllEntities(lx, ly, "block_move", self)
						if not tx or not ty or core.fov.distance(x, y, tx, ty) > 1 then ok = false return end
					end
					
					local dam, dam2 = 0, 0
					local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
					if not hit then return end

					if size >= 1 or not target:canBe("knockback") then
						self:logCombat(target, "#Source# is dragged towards #target#!")
						local ox, oy = self.x, self.y
						self:move(tx, ty, true)
						if config.settings.tome.smooth_move > 0 then
							self:resetMoveAnim()
							self:setMoveAnim(ox, oy, 8, 5)
						end
				else
					self:logCombat(target, "#Target# is dragged towards #source#!")
					target:pull(self.x, self.y, tg.range)
				end
			
			else -- anchor to terrain
				if game.level.map:checkAllEntities(x, y, "block_move", target) then
					if self:attr("never_move") then game.logPlayer(self, "You cannot move!") ok = false return end
					local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move") end
					local linestep = self:lineFOV(x, y, block_actor)
			
					local tx, ty, lx, ly, is_corner_blocked
					repeat  -- make sure each tile is passable
						tx, ty = lx, ly
						lx, ly, is_corner_blocked = linestep:step()
					until is_corner_blocked or not lx or not ly or game.level.map:checkAllEntities(lx, ly, "block_move")
					if not tx or core.fov.distance(self.x, self.y, tx, ty) <= 1 then
						game.logPlayer(self, "You need more room to swing your whip effectively.")
						ok = false return
					end
			
					game.logSeen(self, "%s uses a whip to pull %s %s!", self:getName():capitalize(), self:his_her_self(), game.level.map:compassDirection(tx - self.x, ty - self.y))
					local ox, oy = self.x, self.y
					self:move(tx, ty, true)
					if config.settings.tome.smooth_move > 0 then
						self:resetMoveAnim()
						self:setMoveAnim(ox, oy, 8, 5)
					end
				else
					ok = false
					game.logPlayer(self, "You must anchor the whip to something solid.")
				end
			end
		end)

		return ok
	end,
	info = function(self, t)
		return ([[Wrap your whip around a creature or bit of terrain within range %d. If this strikes either a wall or a creature that is immovable or larger than you, you will swing yourself towards it, otherwise, you will drag the target towards you.  Creatures struck by the whip will take %d%% damage.]]):format(self:getTalentRange(t), t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Lashing Pain", short_name = "REK_WTEK_WHIP_LASH",
	type = {"technique/weapon-techniques", 4}, require = dex_req4, points = 1, innate = true,
	speed = "weapon",
	cooldown = 3,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 0.5 },
	is_melee = true,
	range = 3,
	target = function(self, t)	return {type="hit", range=self:getTalentRange(t), talent=t}	end,
	on_pre_use = whipOHPreUse,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.9, 0.9) end,
	getNumb = function(self, t) return self:combatTalentWeaponDamage(t, 30, 30) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit and not target.dead then target:setEffect(target.EFF_MAIM, 1, {src=self, power=0, reduce=t.getNumb(self, t), apply_power=self:combatAttack(), no_ct_effect=true}) end

		return true
	end,
	info = function(self, t)
		return ([[Strike your enemy for %d%% damage and maim them with the pain of the whip, reducing their damage by %d%% for one turn.]]):format(t.getDamage(self, t)*100, t.getNumb(self, t))
	end,
}
