newTalent{
	name = "Blazing Trail", short_name = "REK_DEML_ENGINE_BLAZING_TRAIL",
	type = {"steamtech/engine", 1},
	require = steam_req1,
	points = 5,
	drain_steam = 5,
	cooldown = 5,
	mode = "sustained",
	no_energy = true,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 50) end,
	getMovement = function(self, t) return self:combatTalentScale(t, 0.18, 0.5, 0.75) end,
	callbackOnMove = function(self, t, moved, force, ox, oy, x, y)
		if moved and not force and self:getSteam() > 0 then
			game.level.map:addEffect(self, ox, oy, 4, engine.DamageType.FIRE, t.getDamage(self, t), 0, 5, nil, {type="inferno"}, nil, true)
		end
	end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	deactivate = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Fire up rocket engines to scorch the ground you pass over.  Each movement will leave a trail of flames doing %d fire damage for 4 turns.  This will only take effect if you have steam remaining.

Passively improve your vehicle's engine output.  While riding, you gain %d%% movement speed.]]):format(damDesc(self, DamageType.FIRE, t.getDamage(self, t)), t.getMovement(self, t)*100)
	end,
}

newTalent{
	name = "Drift Nozzles", short_name = "REK_DEML_ENGINE_DRIFT_NOZZLES",
	type = {"steamtech/engine", 2},
	require = steam_req2,
	points = 5,
	cooldown = 0,
	mode = "sustained",
	no_energy = true,
	getDefense = function(self, t) return self:combatTalentScale(t, 5, 50, 1) end,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	callbackOnMove = function(self, t, moved, force, ox, oy, x, y)
		if not ox or not oy then return end
		if not x or not y then return end
		if not moved or force then return end
		local dx, dy = (self.x - ox), (self.y - oy)
		if dx ~= 0 then dx = dx / math.abs(dx) end
		if dy ~= 0 then dy = dy / math.abs(dy) end
		local dir = util.coordToDir(dx, dy, 0)
		self:setEffect(self.EFF_REK_DEML_DRIFTING, 2, {dir=dir, src=self})
	end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	deactivate = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Attach additional jet nozzles to your vehicle that amplify its movements.  Each round for 2 rounds after moving, you move 1 space in the same direction for free.

Passively improve your vehicle's evasive movements. While riding, you have %d extra defense.]]):format(t.getDefense(self, t))
	end,
}

newTalent{
	name = "Ramming Speed", short_name = "REK_DEML_ENGINE_RAMMING_SPEED",
	type = {"steamtech/engine", 3},
	require = steam_req3,
	points = 5,
	steam = 30,
	cooldown = 12,
	tactical = { ATTACKAREA = { PHYSICAL = 1,	FIRE = 1 }, CLOSEIN = 3 },
	requires_target = true,
	getCrashDamage = function (self, t)
		local dam = self:combatTalentSteamDamage(t, 30, 190)
		if self:knowTalent(self:getTalentFromId(self.T_REK_DEML_BATTLEWAGON_HEAVY)) then
			local t2 = self:getTalentFromId(self.T_REK_DEML_BATTLEWAGON_HEAVY)
			dam = dam * (1 + t2.getRamBoost(self, t2))
		end
		return dam
	end,
	getWaveDamage = function(self, t) return self:combatTalentSteamDamage(t, 30, 190) end,
	range = function(self, t) return  math.ceil(self:combatTalentScale(t, 4, 8.5)) end,
	fireRadius = function(self, t) return math.ceil(self:combatTalentScale(t, 1, 4)) end,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "You can't ram if you can't move.") return end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local l = self:lineFOV(x, y, block_actor)
		local lx, ly, is_corner_blocked = l:step()
		if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
			game.logPlayer(self, "You are too close to build up momentum!")
			return
		end
		local tx, ty = lx, ly
		lx, ly, is_corner_blocked = l:step()
		while lx and ly do
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
		end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end
		
		local did_crit=self:steamCrit(1)

		if core.fov.distance(self.x, self.y, x, y) == 1 then
			DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, did_crit * t.getCrashDamage(self, t))
			if self:isTalentActive(self.T_REK_DEML_ENGINE_BLAZING_TRAIL) then
				local damageFlame = self:callTalent(self.T_REK_DEML_ENGINE_BLAZING_TRAIL, "getDamage")
				game.level.map:addEffect(self, target.x, target.y, 4, engine.DamageType.FIRE, damageFlame, 0, 5, nil, {type="inferno"}, nil, true)
			end
			target:attr("knockback_immune", 1)
			local blast = {type="ball", range=0, radius=3, friendlyfire=false}
			local grids = self:project(blast, self.x, self.y, DamageType.FIREKNOCKBACK, {dist=t.fireRadius(self,t), dam=did_crit * (t.getWaveDamage(self, t))})
			game.level.map:particleEmitter(self.x, self.y, blast.radius, "ball_fire", {radius=blast.radius})
			game:playSoundNear(self, "talents/fire")
			target:attr("knockback_immune", -1)
		end

		return true
	end,
	info = function(self, t)
		return ([[Launch your ride towards a target. If the target is reached you crash into them for %0.2f physical damage and release a massive burst of fire in radius %d, knocking away all other enemies and dealing %0.2f fire damage.
You must launch from at least 2 tiles away.]]):format(damDesc(self, DamageType.PHYSICAL, t.getCrashDamage(self, t)), t.fireRadius(self,t), damDesc(self, DamageType.PHYSICAL, t.getWaveDamage(self, t)))
	end,
}

newTalent{
	name = "Full Throttle", short_name = "REK_DEML_ENGINE_FULL_THROTTLE",
	type = {"steamtech/engine", 4},
	require = steam_req4,
	points = 5,
	drain_steam = 10,
	cooldown = 5,
	mode = "sustained",
	no_energy = true,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	getDamage = function(self, t)
		local dam = self:combatTalentSteamDamage(t, 5, 50)
		if self:knowTalent(self:getTalentFromId(self.T_REK_DEML_BATTLEWAGON_HEAVY)) then
			local t2 = self:getTalentFromId(self.T_REK_DEML_BATTLEWAGON_HEAVY)
			dam = dam * (1 + t2.getRamBoost(self, t2))
		end
		return dam
	end,
	getMovement = function(self, t) return self:combatTalentScale(t, 2.0, 4.0) end,
	callbackOnAct = function(self, t)
		if self:getSteam() < 0.1 then
			self:forceUseTalent(t.id, {ignore_energy=true})
		end
	end,
	callbackBreakOnTalent = function(self, t, bt)
		if t.id == bt.id then return end
		self:forceUseTalent(t.id, {ignore_energy=true})
	end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "movement_speed", t.getMovement(self, t))
		return ret
	end,
	deactivate = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Push your vehicle's engines to the maximum, increasing your movement speed by %d%%. When you would move into an enemy, instead you ram past them, dealing %0.2f physical damage and trying to move to the opposite side of them.
This ends when you take an action other than moving or ramming, or if you run out of steam.]]):format(t.getMovement(self, t)*100, damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}