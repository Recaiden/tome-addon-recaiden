newTalent{
	name = "Cave-in Ambush", short_name = "REK_OCLT_TROOPER_AMBUSH",
	type = {"technique/trooper", 1}, require = str_req1, points = 5,
	cooldown = 10,
	range = 6,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t, 1, 2))
	end,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, self.x, self.y, function(px, py)
									 local target = game.level.map(px, py, Map.ACTOR)
									 if not target then return end
									 local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
									 if tx and ty and target:canBe("teleport") then
										 target:move(tx, ty, true)
										 game.logSeen(target, "%s is called to battle!", target:getName():capitalize())
									 end
		end)
		return true
	end,
	info = function(self, t)
		return ([[Lure all foes in a radius %d ball towards you, getting them into melee range in an instant.]]):tformat(t.radius(self, t))
	end,
}

newTalent{
	name = "Earthquake Stance", short_name = "REK_OCLT_TROOPER_STANCE",
	type = {"technique/trooper", 2}, require = str_req2, points = 5,
	mode = "sustained",
	cooldown = 20,
	tactical = { BUFF = 1 },
	getPenalty = function(self, t) return 30 end,
	getCritBoost = function(self, t)
		local dex = self:combatStatScale("dex", 10/25, 100/25, 0.75)
		return (self:combatTalentScale(t, dex, dex*5, 0.5, 4))
	end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "combat_dam", -1 * t:_getPenalty(self))
		self:talentTemporaryValue(ret, "combat_physcrit", t:_getCritBoost(self))
		return ret
	end,
	deactivate = function(self, t, r)
		return true
	end,
	info = function(self, t)
		return ([[Fight with wild strikes that land less heavily, but are more likely to strike a weak point.  While sustained you lose %d physical power but gain +%d%% physical critical rate.  The benefit will increase with your Dexterity.]]):format(t_:getPenalty(self), t:_getCritBoost(self))
	end,
}

newTalent{
	name = "Rockslide Targeting", short_name = "REK_OCLT_TROOPER_TARGETING",
	type = {"technique/trooper", 3}, points = 5, require = str_req3,
	mode = "passive",
	getMult = function(self, t) return self:combatTalentLimit(t, 1.75, 0.5, 1.4) end,
	getConThreshold = function(self, t) return math.max(15, 35 - 5*self:getTalentLevel(t)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_atk", t:getStat("con") * t:_getMult(self))
		if t:getStat("con") > t:_getConThreshold(self) then
			self:talentTemporaryValue(p, "blind_fight", 1)
		end
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_CON then self:updateTalentPassives(t) end
	end,
	info = function(self, t)
		return ([[Once you've chosen a target, nothing can deter you from striking it.
You gain raw Accuracy equal to %d%% of your Constitution.
With at least %d Constitution, you can fight while blinded or against invisible targets without penalty.]]):format(t.getMult(self, t)*100, t.getConThreshold(self, t))
	end,
}

newTalent{
	name = "Crushing Might", short_name = "REK_OCLT_TROOPER_POWER",
	type = {"technique/trooper", 4}, points = 5, require = str_req4,
	cooldown = 30,
	no_energy = true,
	getDamageAmp = function(self, t)
		local weapon = nil
		if self:getInven("MAINHAND") then
			weapon = self:getInven("MAINHAND")[1]
		end

		local val = 30
		if weapon then
			val = val + self:combatDamage(weapon) * self:combatTalentScale(t, 0.3, 0.9)
		end
		return val
	end,
	getDuration = function(self, t) return 6 end,
	tactical = { BUFF = 2 },
	on_pre_use_ai = function(self, t) -- don't use out of combat
		local target = self.ai_target.actor
		if target and core.fov.distance(self.x, self.y, target.x, target.y) <= 10 and self:hasLOS(target.x, target.y, "block_move") then return true end
		return false
	end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_OCLT_MIGHT, t:_getDuration(self), {power=t.getDamageAmp(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Summon up reserves of strength to fight harder; for %d turns, your physical power is increased by %d.  This will increase with the damage of your mainhand weapon.]]):format(t.getDuration(self, t), t.getDamageAmp(self, t))
	end,
}
