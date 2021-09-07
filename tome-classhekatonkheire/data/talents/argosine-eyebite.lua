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
		return ([[Command your eyes to distract the target. A random eye will bite the enemy and taunt them, forcing the enemy to target them.]]):tformat()
	end
}

newTalent{
	name = "Eyessimilation", short_name = "REK_HEKA_EYEBITE_OVERWATCH",
	type = {"spell/eyebite", 2},	require = eye_req_high2, points = 5,
	mode = "passive",
	getOverwatch = function(self, t) return self:combatTalentScale(t, 1, 5) end,
	--used in an effect applied in the eye's stare down talent via the STARE damage type
	info = function(self, t)
		return ([[Rest easy knowing that someone is watching your back, even if that someone is you.  When you are in the area of an Evil Eye, your health regeneration is increased by %d and your saves by %d.]]):tformat(t.getOverwatch(self, t), t.getOverwatch(self, t)*8)
	end,
}

newTalent{
	name = "Ocular Rift", short_name = "REK_HEKA_EYEBITE_RIFT",
	type = {"spell/eyebite", 3}, require = eye_req_high3, points = 5,
	mode = "passive",
	getMultiplier = function(self, t) return math.max(1, self:combatTalentLimit(t, 5, 1.5, 2.25)) end,
	-- handled in the STARE damage type
	info = function(self, t)
		return ([[If an enemy is affected by multiple Evil Eyes in one turn, the damage will be increased by %d%% and the slow by %d%%.]]):tformat(t.getMultiplier(self, t)*200-100, t.getMultiplier(self, t)*100)
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
		tx, ty = self:getTarget(tg_eye)
		if not tx or not ty then return nil end
		if tx then
			_, _, _, tx, ty = self:canProject(tg_eye, tx, ty)
			if not tx then return nil end
			target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return nil end
			if not target.is_wandering_eye then return nil end
			if not target.summoner or target.summoner ~= self then return nil end
		end
		
		local tg = {multiple=true}
		local eye = target
		if not eye then return false end
		
		tg[#tg+1] = {type="beam", range=5, start_x=target.x, start_y=target.y, selffire=false, nolock=true, talent=t}
		-- Pick a target
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		-- Switch our targeting type back
		local tg = self:getTalentTarget(t)
		
		tg.start_x, tg.start_y = eye.x, eye.y
		
		eye:project(
			tg, x, y,
			function(px, py)
				local target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return end
				
				if target:canBe("stun") and target:canBe("stone") and target:canBe("instakill") then
					target:setEffect(target.EFF_STONED, t.getDuration(self, t), {apply_power=self:combatSpellpower()})
					game.level.map:particleEmitter(tx, ty, 1, "archery")
				end
				)	
	end
		game:playSoundNear(self, "talents/earth")
		
		return true
	end,
	info = function(self, t)
		return ([[Choose a wandering eye, and fire from it a beam that turns enemies to stone (#SLATE#Spell save#LAST#) for %d turns.  Stoned creatures are unable to act or regenerate life, and if they are hit by an attack that deals more than 30% of their life they will shatter and be destroyed. Stoned creatures are highly resistant to fire and lightning, and somewhat resistant to physical attacks.]]):tformat(t.getDuration(self, t), t.getSightBonus(self, t))
	end,
}
