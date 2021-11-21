newTalent{
	name = "Overwhelm Awareness", short_name = "REK_HEKA_EYEBITE_TAUNT",
	type = {"spell/eyebite", 1}, require = eye_req_high1, points = 5,
	cooldown = function(self, t) return math.max(6, math.ceil(self:combatTalentScale(t, 18, 8))) end,
	hands = 15,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 2 },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nowarning=true} end,
	on_pre_use = on_pre_use_Eyes,
	action = function(self, t)
		local target = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(target)
		if not target then return nil end

		local eyes = {}
		for _, e in pairs(game.level.entities) do
			if isMyEye(self, e) then eyes[#eyes+1] = e end
		end
		local eye = rng.table(eyes)	
		eye.ai_target.x = nil
		eye.ai_target.y = nil
		eye.ai_target.actor = target
		eye.ai_target.focus_on_target = true
		eye.ai_target.blindside_chance = 100
		target:setTarget(eye)
		return true
	end,
	info = function(self, t)
		return ([[Command your eyes to distract the target. A random eye will bite the enemy and inflict taunt, forcing the enemy to target that eye.]]):tformat()
	end
}

newTalent{
	name = "Eyessimilation", short_name = "REK_HEKA_EYEBITE_SUMMON",
	type = {"spell/eyebite", 2},	require = eye_req_high2, points = 5,
	hands = 30,
	cooldown = 10,
	getDuration = function(self, t) return math.min(10, math.floor(self:combatTalentScale(t, 5, 10))) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 0, 250) end,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 2 },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nowarning=true} end,
	on_pre_use = on_pre_use_Eyes,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not target then return nil end

		if not target:canBe("blind") then return true end
		
		target:setEffect(target.EFF_BLINDED, t:_getDuration(self), {src=self, apply_power=self:combatSpellpower()})

		-- summon
		local eye = self:callTalent(self.T_REK_HEKA_HEADLESS_EYES, "summonEye", true)
		if eye then
			eye.summon_time = t:_getDuration(self)
			eye.temporary = true
			eye.ai_target.actor = target
			eye.ai_target.focus_on_target = true
		end

		-- damage
		self:project(tg, target.x, target.y, DamageType.PHYSICAL, self:spellCrit(t.getDamage(self, t)))
		
		-- invest cost
		game:onTickEnd(function() 
				self:setEffect(self.EFF_REK_HEKA_INVESTED, t:_getDuration(self),
											 {investitures={{power=util.getval(t.hands, self, t)}}, src=self})
		end)
		return true
	end,
	info = function(self, t)
		return ([[Choose an enemy and attempt (#SLATE#checks blindness immunity#LAST#) to make it a temporary anchor, dealing %d physical damage and granting you an axtra wandering eye for %d turns, during which the target may be blinded (#SLATE#Spellpower vs Physical#LAST#).

This talent invests hands; your maximum hands will be reduced by its cost until it expires.]]):tformat(damDesc(self, DamageType.PHYSICAL, t:_getDamage(self)), t:_getDuration(self))
	end,
}

newTalent{
	name = "Ocular Rift", short_name = "REK_HEKA_EYEBITE_RIFT",
	type = {"spell/eyebite", 3}, require = eye_req_high3, points = 5,
	hands = 20,
	cooldown = 12,
	radius = function(self, t) return 2 end,
	range = 8,
	getSlow = function(self, t) return self:combatTalentScale(t, 10, 40) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 0, 50) end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 5)) end,
	action = function(self, t)
		game.logPlayer(self, "Select an eye...")
		local tg_eye = {default_target=self, type="ball", friendlyblock = false, nowarning=true, range=self:getTalentRange(t), radius=self:getTalentRadius(t), first_target = "friend"}
		tx, ty = self:getTarget(tg_eye)
		if not tx or not ty then return nil end
		if tx then
			_, _, _, tx, ty = self:canProject(tg_eye, tx, ty)
			if not tx then return nil end
			target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return nil end
			if not isMyEye(self, target) then return nil end
		end
		target:die()
		game.level.map:addEffect(self,
														 tx, ty, t:_getDuration(self),
														 DamageType.REK_HEKA_ARCANE_SLOW, {dam=self:spellCrit(t:_getDamage(self)), power=t:_getSlow(self)/100},
														 self:getTalentRadius(t),
														 5, nil,
														 {type="star_zone"},
														 nil, false, false
		)
		
		return true
	end,
	info = function(self, t)
		return ([[Violently return an eye to the other place, 'killing' it and leaving a radius %d hole in reality for %d turns that slows enemies by %d%% and deals %0.1f arcane damage per turn.
]]):tformat(self:getTalentRadius(t), t:_getDuration(self), t:_getSlow(self), damDesc(self, DamageType.ARCANE, t:_getDamage(self)))
	end,
}


newTalent{
	name = "Eyes of the Basilisk", short_name = "REK_HEKA_EYEBITE_BASILISK",
	type = {"spell/eyebite", 4}, require = eye_req_high4, points = 5,
	hands = 30,
	tactical = { DISABLE = 4 },
	cooldown = 15,
	no_npc_use=true,
	range = 10,
	on_pre_use = function(self, t, silent)
		if countEyes(self) < 1 then
			if not silent then
				game.logPlayer(self, "You must have an eye to use this talent.")
			end
			return false
		end
		return true
	end,
	target = function(self, t)
		return {type="cone", range=0, radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3.6, 6.3)) end,
	requires_target = true,
	action = function(self, t)
		game.logPlayer(self, "Select an eye...")
		local tg_eye = {default_target=self, type="hit", friendlyblock = false, nowarning=true, range=self:getTalentRange(t), first_target = "friend"}
		local tx, ty = self:getTarget(tg_eye)
		if not tx or not ty then return nil end
		if tx then
			_, _, _, tx, ty = self:canProject(tg_eye, tx, ty)
			if not tx then return nil end
			target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return nil end
			if not target.is_wandering_eye then return nil end
			if not target.summoner or target.summoner ~= self then return nil end
		end
		
		local eye = target
		if not eye then return false end
		
		game.logPlayer(self, "Target the beam...")

		local tgEnd = {type="beam", start_x=tx, start_y=ty, nolock=true, range=5, no_start_scan=true}
		dx, dy = self:getTarget(tgEnd)
		if not dx or not dy then
			game.logPlayer(self, "Invalid end point")
			return
		end
		eye:project(
			tgEnd, dx, dy,
			function(px, py, tgEnd, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				
				if target:canBe("stun") and target:canBe("stone") and target:canBe("instakill") then
					target:setEffect(target.EFF_STONED, t.getDuration(self, t), {apply_power=self:combatSpellpower()})
					game.level.map:particleEmitter(px, py, 1, "archery")
				end
			end
		)
		-- todo visible beam
		game:playSoundNear(self, "talents/earth")
		
		return true
	end,
	info = function(self, t)
		return ([[Choose a wandering eye, and fire from it a beam that turns enemies to stone (#SLATE#Spell save#LAST#) for %d turns.  Stoned creatures are unable to act or regenerate life, and if they are hit by an attack that deals more than 30%% of their life they will shatter and be destroyed. Stoned creatures are highly resistant to fire and lightning, and somewhat resistant to physical attacks.]]):tformat(t.getDuration(self, t))
	end,
}
