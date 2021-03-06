newTalent{
	name = "Drill Shot", short_name = "REK_GLR_SHOT_DRILL",
	type = {"technique/psychic-shots", 1},
	speed = "archery",
	points = 5,
	cooldown = 8,
	psi = 7,
	require = dex_req1,
	range = archery_range,
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.4) end,
	getShred = function(self, t) return self:combatTalentScale(t, 5, 25, 0.75) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	on_pre_use = function(self, t, silent) return archerPreUse(self, t, silent, "bow") end,
	archery_onhit = function(self, t, target, x, y, tg)
		if target and not target.dead then
			target:setEffect(target.EFF_REK_GLR_SUNDER_ARMOUR, t.getDuration(self, t), {power=t.getShred(self, t), apply_power=self:combatPhysicalpower(), src=self})
		end
	end,
	action = function(self, t)
		if not self:hasArcheryWeapon("bow") then game.logPlayer(self, "You must wield a bow!") return nil end

		local targets = self:archeryAcquireTargets({type="beam"}, {one_shot=true, no_energy=true})
		if not targets then return end
		self:archeryShoot(targets, t, {type="beam"}, {mult=t.getDamage(self, t), apr=500})
		return true
	end,
	info = function(self, t)
		return ([[You spin up an arrow that cuts right through anything, hitting multiple targets in a line for %d%% armor-piercing damage and reducing their armor (#SLATE#Physical Save#LAST#) by %d for %d turns.]]):format(t.getDamage(self, t)*100, t.getShred(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Crossfire", short_name = "REK_GLR_SHOT_CROSSFIRE",
	type = {"technique/psychic-shots", 2},
	require = dex_req2,
	getCount = function(self, t) return 3 + math.floor(self:combatTalentScale(t, 1, 12)) end,
	getStack = function(self, t) return math.floor(self:combatTalentLimit(t, 5, 1.1, 3.0)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.3, 0.75) end,
	on_pre_use = function(self, t, silent) return archerPreUse(self, t, silent, "bow") end,
	points = 5,
	speed = "archery",
	tactical = {ATTACKAREA = {weapon = 3}},
	range = 0,
	radius = archery_range,
	cooldown = 8,
	psi = 15,
	requires_target = true,
	target = function(self, t)
		return {
			type = "cone",
			range = self:getTalentRange(t),
			radius = self:getTalentRadius(t),
			selffire = false,
			talent = t,
			--cone_angle = 50, -- degrees
		}
	end,
	targetCross = function(self, t)
		return {type = "ball", range = 0, radius = math.ceil(self:getTalentRadius(t)/2), talent = t}
	end,
	action = function(self, t)
		if not self:hasArcheryWeapon("bow") then game.logPlayer(self, "You must wield a bow!") return nil end

		-- Collect targets in the cone
		local tg = self:getTalentTarget(t)
		local tgCross = t.targetCross(self, t)
		local x, y = self:getTarget(tg)
		if not x or not y then return end
		local targets = {}
		local spaces = {}
		--game.logPlayer(self, ("DEBUG - Crossfire player at %d %d!"):format(self.x, self.y))
		local add_target = function(x, y)
			local target = game.level.map(x, y, game.level.map.ACTOR)
			if target then
				--game.logPlayer(self, ("DEBUG - Crossfire target at %d %d!"):format(target.x, target.y))
				if self:reactionToward(target) < 0 and self:canSee(target) then
					tgCross.x = target.x
					tgCross.y = target.y
					self:project(
						tgCross, target.x, target.y,
						function(px, py)
							local source = game.level.map(px, py, game.level.map.ACTOR)
							local terrain = game.level.map(px, py, Map.TERRAIN)
							if not source and terrain and not terrain.does_block_move then
								--game.logPlayer(self, ("DEBUG - considering space %d %d!"):format(px, py))
								spaces[#spaces + 1] = {x=px, y=py}
							end
						end)
					for i = 1, t.getStack(self, t) do
						targets[#targets + 1] = target
					end
				end
			end
		end
		self:project(tg, x, y, add_target)
		if #targets == 0 then return end
		table.shuffle(targets)
		table.shuffle(spaces)

		-- Fire each shot.
		local old_target_forced = game.target.forced
		local fired = nil
		for i = 1, math.min(t.getCount(self, t), #targets) do
			local target = targets[i]
			game.target.forced = {target.x, target.y, target}
			--game.logPlayer(self, ("DEBUG - Aiming Crossfire at %d %d!"):format(target.x, target.y))
			local s = rng.table(spaces)
			local sx, sy = self.x, self.y
			if s then
				sx = s.x
				sy = s.y
			end
			--game.logPlayer(self, ("DEBUG - Aiming Crossfire from %d %d!"):format(sx, sy))
			local targets = self:archeryAcquireTargets({type = "hit"}, {one_shot=true, no_energy=true, no_sound=true})
			if targets then
				local target = targets.dual and targets.main[1] or targets[1]
				--self:archeryShoot(targets, t, {type="bolt", start_x=eff.x, start_y=eff.y}, {mult=t.getDamage(self, t)})
				self:archeryShoot(targets, t, {type = "bolt", start_x=sx, start_y=sy, speed=4}, {mult=t.getDamage(self, t)})
				fired = true
			else
				-- If no target that means we're out of ammo.
				break
			end
		end
		game.target.forced = old_target_forced
		if fired then game:playSoundNear(self, "talents/triple-arrow") end
		
		return fired
	end,
	info = function(self, t)
		return ([[Launch a volley of %d arrows on indirect paths.  Each arrow targets an enemy in a cone for %d%% damage and approaches from a random direction. No creature can be targeted by more than %d arrows.]]):format(t.getCount(self, t), t.getDamage(self, t)*100, t.getStack(self, t))
	end,
}

newTalent{
	name = "Boomerang Shot", short_name = "REK_GLR_SHOT_BOOMERANG",
	type = {"technique/psychic-shots", 3},
	points = 5,
	cooldown = 8,
	psi = 10,
	require = dex_req3,
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	range = archery_range,
	proj_speed = 10,
	speed = "archery",
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		if not weapon or not ammo then
			return {type="beam", range=self:getTalentRange(t), selffire=false, nolock=true, talent=t}
		end
		local speed = 10 + (ammo.travel_speed or 0) + (weapon.travel_speed or 0) + (self.combat and self.combat.travel_speed or 0)
		return {type="beam", speed=speed, range=self:getTalentRange(t), selffire=false, nolock=true, talent=t, display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 0.8) end,
	on_pre_use = function(self, t, silent) return archerPreUse(self, t, silent, "bow") end,
	action = function(self, t)
		if not self:hasArcheryWeapon("bow") then game.logPlayer(self, "You must wield a bow!") return nil end
		local weapon, ammo = self:hasArcheryWeapon()
		if not weapon or not ammo then return nil end
		
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		self.rek_boomerang_damage_bonus = 1
		
		self:projectile(
			tg, x, y,
			function(px, py, tg, self)
				self.rek_boomerang_damage_bonus = self.rek_boomerang_damage_bonus + 0.10
				local tmp_target = game.level.map(px, py, engine.Map.ACTOR)
				if tmp_target and tmp_target ~= self then
					local weapon, ammo = self:hasArcheryWeapon()
					local t = self:getTalentFromId(self.T_REK_GLR_SHOT_BOOMERANG)
					local targets = {{x=px, y=py, ammo=ammo.combat}}
					self:attr("instant_shot", 1)
					self:archeryShoot(targets, t, {start_x=px, start_y=py}, {mult=self.rek_boomerang_damage_bonus*t.getDamage(self, t)})
					self:attr("instant_shot", -1)
				end
				if x == px and y == py and self and self.x and self.y then
					local tgr = tg
					tgr.name = "Boomerang Shot"
					tgr.x, tgr.y = px, py
					game:playSoundNear(self, "talents/warp")
					self:projectile(
						tgr, self.x, self.y,
						function(px, py, tgr, self)
							self.rek_boomerang_damage_bonus = self.rek_boomerang_damage_bonus + 0.10
							local tmp_target = game.level.map(px, py, engine.Map.ACTOR)
							if tmp_target and tmp_target ~= self then
								local weapon, ammo = self:hasArcheryWeapon()
								local t = self:getTalentFromId(self.T_REK_GLR_SHOT_BOOMERANG)
								local targets = {{x=px, y=py, ammo=ammo.combat}}
								self:attr("instant_shot", 1)
								self:archeryShoot(targets, t, {start_x=px, start_y=py}, {mult=self.rek_boomerang_damage_bonus*t.getDamage(self, t)})
								self:attr("instant_shot", -1)
							end
						end)
				end
			end)
		game:playSoundNear(self, "actions/arrow")
		return true
	end,
	info = function(self, t)
		return ([[You loose an arrow that pierces through all targets for %d%% damage and then turns around and comes back, potentially damaging enemies again.  The damage increases by +10%% for each space the arrow crosses.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Hammer Shot", short_name = "REK_GLR_SHOT_HAMMER",
	type = {"technique/psychic-shots", 4},
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	psi = 15,
	require = dex_req4,
	range = archery_range,
	speed = "archery",
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { knockback = 2 }, ESCAPE = { knockback = 1 } },
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 1.0) end,
	getSlamDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.7, 1.4) end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 6, 2, 4)) end,
	on_pre_use = function(self, t, silent) return archerPreUse(self, t, silent, "bow") end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("knockback") then
			local shot = false
			game.level.map:particleEmitter(target.x, target.y, 4, "gravity_breath", {radius=4, tx=(x-self.x), ty=(y-self.y), allow=core.shader.allow("distort")})
			target:knockback(
				self.x, self.y, 4, nil,
				function(g, x, y)		
					if game.level.map:checkAllEntities(x, y, "block_move", target) and not target:hasProc("hammer_shot_knock") then
						target:setProc("hammer_shot_knock", true, 1)
						-- Reconstruct your approximate arrow damage and project it directly.
						local weapon, ammo = self:hasArcheryWeapon()
						local dam = self:combatDamage(ammo.combat)
						local damrange = self:combatDamageRange(ammo)
						dam = rng.range(dam, dam * damrange)
						dam = self:physicalCrit(dam, ammo, target, self:combatAttack(), target:combatDefense())
						dam = dam * t.getSlamDamage(self, t)
						self:project(target, target.x, target.y, DamageType.PHYSICAL, dam, nil)
						self:project({type="hit"}, x, y, DamageType.PHYSICAL, dam, nil)
						
						if target:canBe("stun") then
							target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
						end
						game:playSoundNear(self, "actions/melee_thud")
					end
				end)
		end
	end,
	action = function(self, t)
		if not self:hasArcheryWeapon("bow") then game.logPlayer(self, "You must wield a bow!") return nil end
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=t.getDamage(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Shoot an arrow encased in a shell of tremendous kinetic energy, doing %d%% damage and knocking the target back 4 spaces.  If the target collides with anything, it takes %d%% additional physical damage and is stunned (#SLATE#Physical Save#LAST#) for %d turns.  If it collided with a creature, that creature also takes the bonus damage (but is not stunned).]]):format(t.getDamage(self, t) * 100, t.getSlamDamage(self, t) * 100, t.getDuration(self, t))
	end,
}


newTalent{
	name = "Voyager Shot", short_name = "REK_GLR_SHOT_VOYAGE",
	type = {"technique/psychic-shots", 1},
	hide = true,
	speed = "archery",
	points = 5,
	cooldown = 10,
	psi = 10,
	require = dex_req1,
	range = archery_range,
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		if not weapon or not ammo then
			return {type="beam", range=self:getTalentRange(t), selffire=false, nolock=true, talent=t}
		end
		local speed = 10 + (ammo.travel_speed or 0) + (weapon.travel_speed or 0) + (self.combat and self.combat.travel_speed or 0)
		return {type="beam", speed=speed, range=self:getTalentRange(t), selffire=false, nolock=true, talent=t, display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	on_pre_use = function(self, t, silent) return archerPreUse(self, t, silent, "bow") end,
	action = function(self, t)
		if not self:hasArcheryWeapon("bow") then game.logPlayer(self, "You must wield a bow!") return nil end
		local weapon, ammo = self:hasArcheryWeapon()
		if not weapon or not ammo then return nil end
		
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		self:projectile(
			tg, x, y,
			function(px, py, tg, self)
				local tmp_target = game.level.map(px, py, engine.Map.ACTOR)
				if tmp_target and tmp_target ~= self then
					local weapon, ammo = self:hasArcheryWeapon()
					local t = self:getTalentFromId(self.T_REK_GLR_SHOT_VOYAGE)
					local targets = {{x=px, y=py, ammo=ammo.combat}}
					self:attr("instant_shot", 1)
					self:archeryShoot(targets, t, {start_x=px, start_y=py}, {mult=t.getDamage(self, t)})
					self:attr("instant_shot", -1)
				end
				if x == px and y == py and self and self.x and self.y then
					if not self:teleportRandom(x, y, 0) then game.logSeen(self, "There's no way through!") return end
				end
			end)
		game:playSoundNear(self, "actions/arrow")
		return true
	end,
	info = function(self, t)
		return ([[Launch an arrow with a telekinetic tether, hitting multiple targets in a line for %d%% armor-piercing damage and then teleporting yourself to where the arrow ended its flight.]]):format(t.getDamage(self, t)*100)
	end,
}
