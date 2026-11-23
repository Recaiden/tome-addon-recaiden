newTalent{
	name = "Chronogravitational Core", short_name = "REK_GRV_CORE",
	type = {"chronomancy/geosynchrony", 1},	require = wil_req1,	points = 5,
	mode = "passive",
	no_unlearn_last = true,
	getDamage = function(self, t) return (1 + math.sqrt(self.level)/7) * (self:combatTalentScale(t, 0, 30))+10 end,
	callbackOnLevelup = function(self, t)
		self:updateTalentPassives(t)
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "paradox_from_eq", 1.0)
		self:talentTemporaryValue(p, "melee_project", {[DamageType.GRAVITY] = t.getDamage(self, t)})
	end,
	info = function(self, t)
		return ([[Increasing or decreasing your paradox also changes your equilibrium by half as much.  When you fail to use a talent because of high equilibrium, you also trigger a paradox anomaly.

In addition, you do %0.1f physical gravity damage with every attack, based on your level.]]):format(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Gravity Surge", short_name = "REK_GRV_PULL",
	type = {"chronomancy/geosynchrony", 2}, require = wil_req2,	points = 5,
	cooldown = 10,
	paradox = 10,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 12))end,
	requires_target = true,
	tactical = { CLOSEIN = 1 },
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	message = _t"@Source@ increases local gravity.",
	getSpeed = function(self, t) return 7 end,
	callbackOnTalentPost = function(self, t, ab)
		if not ab.is_spell then return end
		if ab.mode == "sustained" then return end
		if util.getval(ab.no_energy, self, ab) == true then return end
		self:setEffect(self.T_GRAVITY_SURGE, 3, {src=self, power=t:_getSpeed(self)})
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if not x or not y then
			if cancellable then return nil else x, y = self.x, self.y end
		end
		
		self:project(tg, x, y, function(px, py)
									 local target = game.level.map(px, py, Map.ACTOR)
									 if not target then return end
			local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
			
			if tx and ty and target:canBe("knockback") and not target:isTalentActive(target.T_GRAVITY_LOCUS) then
				target:move(tx, ty, true)
				game.logSeen(target, "%s is drawn in by gravity!", target:getName():capitalize())
			end
		end)
		
		game.level.map:particleEmitter(x, y, tg.radius, "gravity_spike", {radius=self:getTalentRadius(t), grids=grids, tx=x, ty=y, allow=core.shader.allow("distort")})
		game:playSoundNear(self, "talents/earth")
		
		return true
	end,
	info = function(self, t)
		return ([[Increases localized gravity, pulling in targets in a radius of %d.

Passively, after casting a spell (that uses a turn), you gain %d%% attack speed for one attack.]]):tformat(self:getTalentRadius(t), 100*t:_getSpeed(self))
	end,
}

newTalent{
	name = "Gravitatinal Anchor", short_name = "REK_GRV_ANCHOR",
	type = {"chronomancy/geosynchrony", 3},	require = wil_req3,	points = 5,
	mode = "passive",
	getStunImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.5) end,
	getMoveImmune = function(self, t) return self:combatTalentLimit(t, 2, 0.2, 1.0) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "stun_immune", t:_getStunImmune(self))
		self:talentTemporaryValue(p, "knockback_immune", t:_getMoveImmune(self))
		self:talentTemporaryValue(p, "pin_immune", t:_getMoveImmune(self))
	end,
	info = function(self, t)
		return ([[Maintain your position by adjusting the force of gravity on you.  Increases your resistance to stunning by %d%% and to knockback and pinning by %d%%.]]):format(100*t.getStunImmune(self, t), 100*t.getMoveImmune(self, t))
	end,
}

newTalent{
	name = "Gravity Ripples", short_name = "REK_GRV_RIPPLE",
	type = {"chronomancy/geosynchrony", 4},	require = wil_req4,	points = 5,
	cooldown = 12,
	mode = "sustained",
	sustain_equilibrium = 8,
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.05, 0.11) end,
	range = 4,
	callbackOnAct = function(self, t)
		local p = self:isTalentActive(t.id)
		if not p then return end

		if p.asdpid then self:removeTemporaryValue("combat_physspeed", p.resid) end
		if p.mspdid then self:removeTemporaryValue("combat_mindspeed", p.cresid) end
		if p.sspdid then self:removeTemporaryValue("combat_spellspeed", p.cresid) end

		local foes = table.listify(self:projectCollect({type="ball", radius=self:getTalentRange(t)}, self.x, self.y, Map.ACTOR, "hostile"))

		if #foes > 0 then
			local bonus = t.getSpeed(self, t) * #foes
			p.asdpid = self:addTemporaryValue("combat_physspeed", bonus)
			p.mspdid = self:addTemporaryValue("combat_mindspeed", bonus)
			p.sspdid = self:addTemporaryValue("combat_spellspeed", bonus)
		end
	end,		
	activate = function(self, t)
		local r ={}
		local foes = table.listify(self:projectCollect({type="ball", radius=self:getTalentRange(t)}, self.x, self.y, Map.ACTOR, "hostile"))

		if #foes > 0 then
			local bonus = t.getSpeed(self, t) * #foes
			r.asdpid = self:addTemporaryValue("combat_physspeed", bonus)
			r.mspdid = self:addTemporaryValue("combat_mindspeed", bonus)
			r.sspdid = self:addTemporaryValue("combat_spellspeed", bonus)
		end
		return r
	end,
	deactivate = function(self, t, p)
		if p.asdpid then self:removeTemporaryValue("combat_physspeed", p.resid) end
		if p.mspdid then self:removeTemporaryValue("combat_mindspeed", p.cresid) end
		if p.sspdid then self:removeTemporaryValue("combat_spellspeed", p.cresid) end
		return true
	end,
	info = function(self, t)
		return ([[Receiving subtle feedback from the mass of animate things, you gain +%d%% spell, mind, and attack speed for every enemy within radius %d.]]):format(100*t.getSpeed(self, t), self:getTalentRange(t))
	end,
}
