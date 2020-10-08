newTalent{
	name = "Telekinetic Supremacy", short_name = "REK_GLR_ABOMINATION_SUPREMACY",
	type = {"psionic/unleash-abomination", 1},
	require = wil_req_high1,
	points = 5,
	range = function(self, t) return math.min(14, math.floor(self:combatTalentScale(t, 6, 10))) end,
	cooldown = 18,
	no_energy = true,
	mode = "suistained"
	target = function(self, t) return {type="widebeam", radius=1, nolock=true, range=self:getTalentRange(t), selffire=false, talent=t} end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 250) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty, target = self:getTargetLimited(tg)
		if not tx or not ty then return nil end
		if not self:canProject(tg, tx, ty) then return nil end
		if game.level.map(tx, ty, engine.Map.ACTOR) then return nil end
		if game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move") then return nil end


		local hit = false
		local dam = self:mindCrit(t.getDamage(self, t))

		-- look for enemies near the landing zone
		self:project(
			{type="ball", range=0, radius=4, start_x=tx, start_y=ty, selffire=false, friendlyfire=false}, tx, ty,
			function(tx, ty)
				local act = game.level.map(tx, ty, engine.Map.ACTOR)
				if act and self:canSee(act) then
					hit = true
				end
			end)
		
		--move us
		self:move(tx, ty, true)
		
		--send out damage along the path
		self:project(tg, tx, ty, function(px, py)
									 DamageType:get(DamageType.PHYSICALBLEED).projector(self, px, py, DamageType.PHYSICALBLEED, dam)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then hit = true end
		end)

		--local ox, oy = self.x, self.y
		
		if hit then
			game:onTickEnd(function() self:alterTalentCoolingdown(t.id, -math.floor((self.talents_cd[t.id] or 0) * 0.67)) end)
		end
				
		return true
	end,
	info = function(self, t)
		return ([[Surround yourself with a powerful nimbus of telekinetic energy.  Your movement speed is increased by %d%%, you gain %d%% pinning immunity, you can't trigger pressure traps, and whenever you shoot an arrow you shoot another arrow for %d%% damage.
Mindpower: improves	movement speed

This talent is difficult to maintain, draining 5%% of your maximum psi per turn (+100%% per turn). For example, on turn 2 it will drain 10%%, on turn 3, 15%%.

#{italic}#Your psionic core constantly roils with suppressed energy.  If you undid some mental precautions, you could draw more power...#{normal}#]]):
		format(self:getTalentRange(t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)*1.5))
	end,
}

newTalent{
	name = "Shard Shot", short_name = "REK_GLR_ABOMINATION_SHARD_SHOT",
	type = {"psionic/unleash-abomination", 2},
	require = wil_req_high2,
	points = 5,
	cooldown = 10,
	range = 1,
	psi = 15,
	getReduction = function(self, t) return self:combatTalentMindDamage(t, 10, 50) + self.level end,
	callbackOnHit = function(self, t, cb, src, death_note)
		if not self:hasLightArmor() then
			--game.logPlayer(self, ("DEBUG - Not in light armor"):format(sx, sy))
			return end
		if self:getPsi() < (self:getMaxPsi() / 2) then
			--game.logPlayer(self, ("DEBUG - Not enough psi!"):format(sx, sy))
			return end
		local dam = cb.value
		local cost = t.getCost(self, t)
		if dam < t.getReduction(self, t) then cost = cost * dam / t.getReduction(self, t) end
		if self:getPsi() < cost then return end -- in case max psi is really tiny?
		
		if dam > 0 and not self:attr("invulnerable") then					
			local reduce = math.min(t.getReduction(self, t), dam)
			dam = dam - reduce
			local d_color = "#4080ff#"
			game:delayedLogDamage(src, self, 0, ("%s(%d to silken armor)"):format(d_color, reduce, stam_txt, d_color), false)
			cb.value = dam
			self:incPsi(-1 * cost)
		end
		return cb
	end,
	activate = function(self, t)
		--TODO particle
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Transmute part of an adjacent target's body into arrows and launch them with psionic force.  The target is hit %d times for %d%% damage, and arrows are launched at random targets in a cone behind them, doing %d%% damage each.]]):format(t.getCount(self, t), t.getConversionDamage(self, t), t.getHitDamage(self, t))
	end,
}

newTalent{
	name = "Telepathic Aim", short_name = "REK_GLR_ABOMINATION_AIM",
	type = {"psionic/unleash-abomination", 3},
	require = wil_req_high3,
	points = 5,
	mode = "passive",
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.6) end,
	getChance = function(self, t) return math.floor(self:combatTalentLimit(t, 40, 10, 30)) end,
	getReduction = function(self, t) return math.min(0.75, self:combatTalentMindDamage(t, 0.20, 0.50)) end,
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, tmp)
		if not src.__is_actor then return end
		if src.turn_procs and src.turn_procs.rek_glr_telepathic_aim then return end
		if not rng.percent(t.getChance(self, t)) then return end
		
		-- shoot them
		game.target.forced = {src.x, src.y, src}
		local targets = self:archeryAcquireTargets({type = "hit", speed = 200}, {one_shot=true, no_energy = true})
		if not targets then return end --no ammo

		game.logSeen(src, "%s is interrupted by a telepathically aimed shot!", src.name:capitalize())

		src.turn_procs = src.turn_procs or {}
		src.turn_procs.rek_glr_telepathic_aim = true
		dam = dam * (100 - t.getReduction(self, t))
		local shot_params_base = {mult = t.getDamage(self, t), phasing = true}
		local params = table.clone(shot_params_base)
		local target = targets.dual and targets.main[1] or targets[1]
		params.phase_target = game.level.map(target.x, target.y, game.level.map.ACTOR)
		self:archeryShoot(targets, t, {type = "hit", speed = 200}, params)

		return {dam=dam}
	end,

	info = function(self, t)
		return ([[Reading an enemy's subtle impulses, you know when they're going to strike before  they do, and can interrupt the attack with a well-timed arrow.  When you would be damaged by an enemy, there is a %d%% chance that they are instantly struck by an arrow that you already fired, doing %d%% damage and reducing their damage to you by %d%%.
This can only happen once per enemy per turn. 
Mindpower: damage reduction]]):format(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Inversion Wave", short_name = "REK_GLR_ABOMINATION_WAVE",
	type = {"psionic/unleash-abomination", 4},
	require = wil_req_high4,
	points = 5,
	cooldown = 12,
	psi = 12,
	getVulnerability = function(self, t) return math.floor(self:combatTalentMindDamage(t, 10, 40)) end,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4.5, 6.5)) end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		if x == self.x and y == self.y then
			--TODO pull
			tg = {type="ball", range=0, friendlyfire=false, radius=math.ceil(self:getTalentRadius(t)/2), talent=t}
			self:project(
				tg, self.x, self.y,
				function(px, py)
					local target = game.level.map(px, py, Map.ACTOR)
					if not target then return end
					if self:reactionToward(target) < 0 and not tgts[target] then
						tgts[target] = true
						local ox, oy = target.x, target.y
						local hit = target:checkHit(self:combatMindpower(), target:combatPhysicalResist(), 0, 95) and target:canBe("knockback")
						if hit then
							target:pull(self.x, self.y, math.ceil(self:getTalentRadius(t)/2) - 1)
							if target.x ~= ox or target.y ~= oy then game.logSeen(target, "%s is pulled in!", target.name:capitalize()) end
							target:setEffect(target.EFF_DAZED, 1, {src=self})
						end
					end
				end)
			return true
		end

		
		-- Do our knockback
		local tgts = {}
		local grids = self:project(
			tg, x, y,
			function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target  then
					-- If we've already moved this target don't move it again
					for _, v in pairs(tgts) do
						if v == target then
							return
						end
					end
					
					local hit = target:checkHit(self:combatMindpower(), target:combatPhysicalResist(), 0, 95) and target:canBe("knockback")
					
					if hit then
						local dist = self:getTalentRadius(t) + 1 - core.fov.distance(self.x, self.y, px, py)
						target:knockback(self.x, self.y, dist, false)
						target:setEffect(target.EFF_DAZED, 1, {src=self})
						tgts[#tgts+1] = target
						game.logSeen(target, "%s is knocked back!", target.name:capitalize())
					else
						game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
					end		
				end
			end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "gravity_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y, allow=core.shader.allow("distort")})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Project a wave of motive force, knocking back all targets in a range %d cone to the edge of the cone and dazing them for 1 turn.

If you target yourself, you will instead pull in targets in a circle of radius %d.]]):format(self:getTalentRadius(t), math.ceil(self:getTalentRadius(t)/2))
	end,
}