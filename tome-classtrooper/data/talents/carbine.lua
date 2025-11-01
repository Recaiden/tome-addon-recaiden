carbine_hit = function(self, tx, ty)
	
end

newTalent{
	name = "Pulsed Coherent Light Emitter", short_name = "REK_OCLT_CARBINE",
	type = {"occultech/carbine", 1}, require = cun_req1, points = 5,
	cooldown = 0,
	battery = 1,
	tactical = { ATTACK = {LIGHT = 2} },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), force_max_range=true, talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 150) end,
	action = function(self, t)
		-- Check for dig ability to allow targetting to pass into walls
		local digs = self:isTalentActive(self.T_REK_OCLT_CARBINE_DIG) and 1 or 0
		local tg = self:getTalentTarget(t)
		-- Just for targeting change to pass terrain
		if digs then tg.pass_terrain = true end
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		-- dig out walls
		self.turn_procs.has_dug = nil
		if digs then self:project(tg, x, y, DamageType.DIG, 1) end
		if self.turn_procs.has_dug and self.turn_procs.has_dug > 0 then
			if digs then self.turn_procs.rek_oclt_dig = self:callTalent(self.T_REK_OCLT_CARBINE_DIG, "getDamage") end
		end
		
		self:project(tg, x, y, DamageType.REK_CARBINE_LIGHT, {dam=self:spellCrit(t.getDamage(self, t))})
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "shadow_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Project a focused beam of light from your carbine, dealing %0.1f light damage and applying ranged on-hit effects to all targets in a line.]]):tformat(damDesc(self, DamageType.LIGHT, t.getDamage(self, t)))
	end,	
}

newTalent{
	name = "Mineral Decomposition Beam", short_name = "REK_OCLT_CARBINE_DIG",
	type = {"occultech/carbine", 2},
	require = cun_req2,
	points = 5,
	mode = "sustained",
	innate = true,
	no_energy = true,
	cooldown = 0,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 10) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "ranged_project", {[DamageType.PHYSICAL] = t.getDamage(self, t)})
	end,
	info = function(self, t)
		return ([[Adjust your carbine's settings for increased collateral damage.  While active, your carbine attaks dig out walls (up to 1 space deep), adding an explosion of %0.1f physical damage to their normal light damage if they successfully dig out a wall.]]):format(t.getDamage(self, t), t.getAccBonus(self, t))
	end,
}

newTalent{
	name = "Wide-Angle Dispersal Lens", short_name = "REK_OCLT_CARBINE_CONE",
	type = {"occultech/carbine", 3}, points = 5, require = cun_req3,
	cooldown = 10,
	battery = 2,
	tactical = { ATTACKAREA = { LIGHT = 2 } },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="cone", cone_angle=t.getAngle(self, t), range=self:getTalentRange(t), force_max_range=true, talent=t} end,
	getMult = function(self, t) return self:ombatTalentLimit(t, 3, 1.2, 1.9) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
	getAngle = function(self, t) return self:combatTalentLimit(t, 120, 15, 45) end,
	action = function(self, t)
		-- Check for dig ability to allow targetting to pass into walls
		local digs = self:isTalentActive(self.T_REK_OCLT_CARBINE_DIG) and 1 or 0
		local tg = self:getTalentTarget(t)
		-- Just for targeting change to pass terrain
		if digs then tg.pass_terrain = true end
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		-- dig out walls
		self.turn_procs.has_dug = nil
		if digs then self:project(tg, x, y, DamageType.DIG, 1) end
		if self.turn_procs.has_dug and self.turn_procs.has_dug > 0 then
			if digs then self.turn_procs.rek_oclt_dig = self:callTalent(self.T_REK_OCLT_CARBINE_DIG, "getDamage") end
		end
		local dam = t.getMult(self, t) * self:spellCrit(self:callTalent(self.T_REK_OCLT_CARBINE, "getDamage"))
		self:project(tg, x, y, DamageType.REK_CARBINE_LIGHT, {dam=dam, blind=t.getDuration(self, t)})
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "shadow_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Focus your carbine's light through a special lens, dealing %d%% of normal damage in a %d degree cone and blinding (#SLATE#Physical#LAST#) those hit for %d turns.]]):format(t.getMult(self, t)*100, t.getAngle(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Overcharge Capacitor", short_name = "REK_OCLT_CARBINE_EMPTY",
	type = {"occultech/carbine", 4}, points = 5, require = cun_req4,
	cooldown = 12,
	battery = function(self, t) return math.max(2, self:getBattery()) end,
	target = function(self, t) return {type="widebeam", radius=1, range=self:getTalentRange(t), force_max_range=true, talent=t} end,
	getMult = function(self, t) return self:ombatTalentLimit(t, 5, 1.5, 3.2) end,
	getDamageAmp = function(self, t) return self:combatTalentLimit(t, 100, 15, 45) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
	action = function(self, t)
		-- Check for dig ability to allow targetting to pass into walls
		local digs = self:isTalentActive(self.T_REK_OCLT_CARBINE_DIG) and 1 or 0
		local tg = self:getTalentTarget(t)
		-- Just for targeting change to pass terrain
		if digs then tg.pass_terrain = true end
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		-- dig out walls
		self.turn_procs.has_dug = nil
		if digs then self:project(tg, x, y, DamageType.DIG, 1) end
		if self.turn_procs.has_dug and self.turn_procs.has_dug > 0 then
			if digs then self.turn_procs.rek_oclt_dig = self:callTalent(self.T_REK_OCLT_CARBINE_DIG, "getDamage") end
		end
		local dam = t.getMult(self, t) * self:spellCrit(self:callTalent(self.T_REK_OCLT_CARBINE, "getDamage"))
		self:project(tg, x, y, DamageType.REK_CARBINE_LIGHT, {dam=dam, vuln={dur=t.getDuration(self, t), power=t.getDamageAmp(self,t)}})
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "shadow_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Empty your carbine's entire battery in one blast of light, dealing %d%% of normal carbine damage in a wide beam.  Those hit will also be left vulnerable, taking %d%% more non-light damage for %d turns.

This requires at least 2 charges in the battery.]]):format(t.getMult(self, t), t.getDamageAmp(self, t), t.getDuration(self, t))
	end,
}
