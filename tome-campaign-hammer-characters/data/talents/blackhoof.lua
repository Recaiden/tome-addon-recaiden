newTalent{
	name = "Blackhooves", short_name="REK_BLACKHOOF_MOVEMENT",
	type = {"race/blackhoof", 1}, require = racial_req1, points = 5,
	tactical = { CLOSEIN = 1, ESCAPE = 1 },
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 12)) end,
	getSteps = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6, "log")) end,
	action = function(self, t)
		-- move fast
		self:setEffect(self.EFF_REK_BLACKHOOF_MOVEMENT, 2, {steps=t.getSteps(self, t), src=self})
		
		return true
	end,
	info = function(self, t)
		return ([[Begin charging as fast as possible, increasing your movement speed by +900%% for the next %d moves you make within 2 turns. with ech of these moves you will attempt to Daze adjacent enemies using your highest power.]]):tformat(t:_getSteps(self))
	end,
}

newTalent{
	name = "Wreck", short_name = "REK_BLACKHOOF_WRECK",
	type = {"race/blackhoof", 2}, require = racial_req2, points = 5,
	mode = "passive",
	range = 3,
	getMaxStacks = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	getPower = function(self, t) return self:combatScale(self.level, 1, 8, 2, 50) * 10 end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if dead then return end
		if self.turn_procs.rek_blackhoof then
			for i = 1, #self.turn_procs.rek_blackhoof_wreck do
	      if self.turn_procs.rek_blackhoof_wreck[i] == target.uid then return end
			end
		end
		self.turn_procs.rek_blackhoof_wreck = self.turn_procs.rek_blackhoof_wreck or {}
		self.turn_procs.rek_blackhoof_wreck[#self.turn_procs.rek_blackhoof_wreck+1] = target.uid
		target:setEffect(target.EFF_REK_BLACKHOOF_WRECK, 5, {max_stacks = t.maxStacks(self,t)}, true)
	end,
	info = function(self, t)
		return ([[Each time you damage an opponent (once per turn per target), you reduce their defense and saves by %d for 5 turns.
This stacks up to %d times.

#{italic}#....#{normal}]]):tformat(t:_getPower(self), t:-maxStacks(self))
	end,
}

newTalent{
	name = "Bewildering Roar", short_name = "REK_BLACKHOOF_CONFUSE",
	type = {"race/blackhoof", 3}, require = racial_req3,	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 9, 46, 30)) end,
	tactical = { ATTACKAREA = {PHYSICAL=2}, DISABLE = {confusion=2} },
	getDamage = function(self, t) return self:combatStatScale("con", 50, 300) end,
	getDur = function(self, t) return self:combatTalentLimit(t, 8, 3, 5) end,
	radius = function(self, t) return self:gatTalentRange(t) end,
	range = 5,
	target = function(self, t) return {type="cone", radius=self:getTalentRadius(t), range=self:getTalentRange(t), friendlyfire=false} end,
	requires_target = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.PHYSICAL, self:physicalCrit(t.getDamage(self, t)))
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, t.getDur(self, t), {power=35, apply_power=self:combatBestpower()})
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "gravity_spike", {radius=tg.radius, allow=core.shader.allow("distort")})
		return true
	end,
	info = function(self, t)
		return ([[Let out a deafening roar that covers a cone of radius %d.  Anyone caught in the area will suffer %0.2f physical damage and be confused (#SLATE#35%% confusion, best power vs mental save#LAST#) for %d turns.  
The damage will increase with your Constitution.]]):tformat(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), t.getDur(self, t))
	end,


	
	info = function(self, t)
		return ([[Making efficient use of every movement, you are capable of sudden bursts of speed.  Whenever you use Impulse or Unbreakable, you gain %d%% of a turn.

#{italic}#More than any other demons, the children of blackhoof are warriors at heart.#{normal}#]]):tformat(t.getEnergy(self, t)*100)
	end,
}

newTalent{
	name = "Essence Surge", short_name = "REK_BLACKHOOF_POWERUP",
	type = {"race/blackhoof", 4}, require = racial_req4, points = 5,
	mode = "passive",
	getDamage = function(self, t) return self:combatScale(self.level, 1, 24, 2, 50) * (10 + self:combatTalentScale(t, 0, 15)) end, -- up to 50% at 5/5 and level 50
	callbackOnMove = function(self, eff, moved, force, ox, oy, x, y)
		if not moved then return end
		if force then return end
		if ox == self.x and oy == self.y then return end
		
		if not self:hasEffect(self.EFF_REK_BLACKHOOF_MOVEMENT) and self:isTalentCoolingDown(self.T_REK_BLACKHOOF_MOVEMENT) then
			self:alterTalentCoolingDown(self.T_REK_BLACKHOOF_MOVEMENT, -1)
		end
		self:setEffect(self.EFF_BLACKHOOF_POWERUP, 2, {power=t:_getDamage(self), src=self})
	end,
	info = function(self, t)
		return ([[Each time you move in combat, you build up destructive magical energies, giving you +d%% damage for 2 turns and reducing the cooldown of Blackhooves by 1 if it is not already active.

#{italic}#...#{normal}#]]):format(t.getDamage(self, t))
	end,
}
