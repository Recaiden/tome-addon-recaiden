local Map = require "engine.Map"

newTalent{
	name = "Arrowstorm", short_name = "REK_GLR_ARROWSTORM_KALMANKA",
	type = {"technique/arrowstorm", 1},
	require = dex_req_high1,
	points = 5,
	range = 2,
	cooldown = 20,
	mode = "sustained",
	target = function(self, t) return {type="ball", range=0, radius=self:getTalentRange(t), selffire=false, talent=t} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.3, 0.65) end,
	doStorm = function(self, t)
		if not self:hasArcheryWeapon("bow") then return end
		local tg = self:getTalentTarget(t)
		local targets = self:projectCollect(tg, self.x, self.y, Map.ACTOR, "hostile")

		local old_target_forced = game.target.forced
		self:attr("instant_shot", 1)
		for i, target in pairs(targets) do
			game.target.forced = {target.x, target.y, target}
			local subtargets = self:archeryAcquireTargets({type = "hit", speed=200}, {one_shot=true, no_energy=true, no_sound=true, infinite=true})
			if subtargets then
				self:archeryShoot(subtargets, t, {type = "bolt", start_x=target.x, start_y=target.y}, {mult=t.getDamage(self, t)})
			else
				break
			end
		end
		self:attr("instant_shot", -1)
		game.target.forced = old_target_forced
	end,
	callbackOnActBase = function(self, t)
		t.doStorm(self, t)
	end,
	activate = function(self, t)
		local ret  = {}
		ret.p1 = self:addParticles(Particles.new("circle", 1, {toback=true, oversize=1.5, a=220, appear=4, speed=-4.0, img="arrowstorm_1", radius=self:getTalentRange(t)}))
		ret.p2 = self:addParticles(Particles.new("circle", 1, {toback=true, oversize=1.4, a=220, appear=4, speed=-6.0, img="arrowstorm_2", radius=self:getTalentRange(t)}))
		ret.p3 = self:addParticles(Particles.new("circle", 1, {toback=true, oversize=1.3, a=220, appear=4, speed=-8.0, img="arrowstorm_3", radius=self:getTalentRange(t)}))
		ret.p4 = self:addParticles(Particles.new("circle", 1, {toback=true, oversize=1.2, a=220, appear=4, speed=-11.0, img="arrowstorm_4", radius=self:getTalentRange(t)}))
			
		self:talentTemporaryValue(ret, 'ammo_mastery_reload', -1)
		return ret
	end,
	deactivate = function(self, t, p)
		local p = self:isTalentActive(self.T_REK_GLR_ARROWSTORM_KALMANKA)
		if not p then return end
		self:removeParticles(p.p1)
		self:removeParticles(p.p2)
		self:removeParticles(p.p3)
		self:removeParticles(p.p4)
		return true
	end,
	info = function(self, t)
		return ([[Use your telekinesis to set countless arrows, arrowheads, and bits of scrap whirling around you at high speeds.  Each round, enemies within range will be struck for %d%% weapon damage.

Reduces your reload rate by 1 while active.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Brilliant Exploits", short_name = "REK_GLR_ARROWSTORM_VITARIS",
	type = {"technique/arrowstorm", 2},
	require = dex_req_high2,
	points = 5,
	cooldown = 12,
	range = archery_range,
	psi = 10,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = { blind = 2 } },
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 2.0, 3.6) end,
	getPbDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 0.72) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	on_pre_use = function(self, t, silent) return archerPreUse(self, t, silent, "bow") end,
	archery_onhit = function(self, t, target, x, y)
		local dist = math.max(0, core.fov.distance(self.x, self.y, target.x, target.y) - 2)
		if dist < 5 then
			local tg = {type="ball", range=0, friendlyfire=false, radius=4-dist, talent=t}
			self:project(tg, target.x, target.y, DamageType.BLINDPHYSICAL, t.getDuration(self, t))
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=target.x, ty=target.y, max_alpha=80})
		end
	end,
	action = function(self, t)
		local tg = {type = "hit"}
		local targets = self:archeryAcquireTargets(tg, table.clone(t.archery_target_parameters))
		if not targets then return end
		
		local target = game.level.map(targets[1].x, targets[1].y, engine.Map.ACTOR)
		if not target then return end
		
		local dist = math.max(0, core.fov.distance(self.x, self.y, target.x, target.y) - 2)
		local damage, distPenalty = t.getDamage(self, t), t.getPbDamage(self, t) * dist
		
		if distPenalty > 0  then
			game:delayedLogMessage(self, target, "brilliant_exploit", "#DARK_ORCHID##Source# shoots #Target# (%-d%%%%%%%% penalty for range)!#LAST#", math.min(90, distPenalty/damage*100))
		end

		local params = {mult = math.max(0.1, damage - distPenalty)}
		self:archeryShoot(targets, t, {type = "hit"}, params)

		return true
	end,
	info = function(self, t)
		return ([[Snap off a shot that shines with a gloriously incandescent light.  It does %d%% damage and releases a blinding (#SLATE#Accuracy vs Physical#LAST#, lasts %d turns) flash in radius 4.  The arrow loses light and momentum quickly; each space it travels after the second reduces the damage by -%d%% and the blind radius by 1 (to a minimum of 10%% damage and no blind).

#{italic}#A true marksman's arrows can race the sunlight ... and win#{normal}#]]):format(t.getDamage(self, t)*100, t.getDuration(self, t), t.getPbDamage(self, t)*100)
	end,
}

newTalent{
	name = "Grinding Duality", short_name = "REK_GLR_ARROWSTORM_PELLEGRINA",
	type = {"technique/arrowstorm", 3},
	require = dex_req_high3,
	points = 5,
	mode = "passive",
	getDefense = function(self, t) return math.floor(self:combatTalentScale(t, 1, 4)) end,
	getPower = function(self, t) return math.floor(self:combatTalentScale(t, 1.5, 6)) end,
	getAccuracy = function(self, t) return math.floor(self:combatTalentScale(t, 2, 8)) end,
	callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam, talent)
		if talent.id ~= self.T_REK_GLR_ARROWSTORM_KALMANKA then return end
		if not target or not hitted then return end
		target:setEffect(target.EFF_REK_GLR_GRINDING, 1, {def=t.getDefense(self, t), pow=t.getPower(self, t), atk=t.getAccuracy(self, t), src=self})
	end,
	info = function(self, t)
		return ([[The constant rain of projectiles wears away enemy defenses.  Enemies hit by Arrowstorm suffer a penalty of %d defense, %d power, and %d accuracy.  This stacks up to 5 times and lasts only 1 turn if not reapplied.

#{italic}#One day you'll learn that there's so much more to destroy than these fragile things.#{normal}#]]):format(t.getDefense(self, t), t.getPower(self, t), t.getAccuracy(self, t))
	end,
}

newTalent{
	name = "Inversion Wave", short_name = "REK_GLR_ARROWSTORM_KAMILLA",
	type = {"technique/arrowstorm", 4},
	require = dex_req_high4,
	points = 5,
	cooldown = 12,
	psi = 12,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, nowarning=true, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		if x == self.x and y == self.y then
			-- Do pull
			local tgts = {}
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
			game.level.map:particleEmitter(x, y, tg.radius, "gravity_spike", {radius=math.ceil(self:getTalentRadius(t)/2), allow=core.shader.allow("distort")})
			return true
		else
			-- Do knockback
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
		end
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[Project a wave of motive force, knocking back all targets in a range %d cone to the edge of the cone.
If you target yourself, you will instead pull in targets in a circle of radius %d.
Either way, affected targets are dazed for 1 turn.
(#SLATE#Mindpower vs Physical, one save for both knockback and daze#LAST#)

#{italic}#It's too late for them, but it's not too late, you know, in the end.#{normal}#]]):format(self:getTalentRadius(t), math.ceil(self:getTalentRadius(t)/2))
	end,
}