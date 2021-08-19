countEyes = function(self)
	local eyes = 0
	if not game.level then return 0 end
	for _, e in pairs(game.level.entities) do
		if e and e.summoner and e.summoner == self and e.is_wandering_eye then 
			eyes = eyes + 1 
		end
	end
	return eyes
end

newTalent{
	name = "Evil Eye", short_name = "REK_HEKA_EYEBITE_STARE",
	type = {"spell/eyebite", 1}, require = eye_req_high1, points = 5,
	cooldown = 5,
	tactical = { ATTACKAREA = {MIND = 2}, DISABLE = 2 },
	range = 10,
	radius = function(self, t) return 6 end,
	requires_target = true,
	on_pre_use = function(self, t, silent)
		if countEyes(self) < 1 then
			if not silent then
				game.logPlayer(self, "You must have an eye to use this talent.")
			end
			return false
		end
		return true
	end,
	getSlow = function(self, t) return self:combatTalentScale(t, 0.1, 0.2) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 0, 30) end,
	getDurationBrainlock = function(self, t) return 3 end,
	getDurationStare = function(self, t) return 15 end,
	target = function(self, t)
		return {type="cone", range=0, radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
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
		local eyes = {target}
		tg[#tg+1] = {type="cone", range=0, radius=self:getTalentRadius(t), start_x=target.x, start_y=target.y, selffire=false, nolock=true, talent=t}
			
		-- Pick a target
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		-- Switch our targeting type back
		local tg = self:getTalentTarget(t)
		
		for i = 1, #eyes do
			if #eyes <= 0 then break end
			local a, id = rng.table(eyes)
			table.remove(eyes, id)
			
			tg.start_x, tg.start_y = a.x, a.y
			local dam = a:spellCrit(t.getDamage(self, t))

			a.ai_state.stare_down = true
			a.ai_state.stare_down_target = {x=x, y=y}
			a.ai_state.stare_down_time = t.getDurationStare(self, t)
			
			a:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and target ~= a.summoner and a.summoner ~= target.summoner then
					DamageType:get(DamageType.MIND).projector(a, px, py, DamageType.MIND, dam)
					target:crossTierEffect(target.EFF_BRAINLOCKED, self:combatSpellpower())
				end
			end)

			game.level.map:addEffect(a,
															 a.x, a.y, t.getDurationStare(self, t)+1,
															 DamageType.COSMETIC, 1,
															 tg.radius,
															 {delta_x=x-a.x, delta_y=y-a.y}, 55,
															 engine.MapEffect.new{color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/pale_paradox_effect.png"},
															 nil, true
			)
			
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "breath_time", {radius=tg.radius, tx=x-a.x, ty=y-a.y})
		end
		
		game:playSoundNear(self, "talents/breath")
		
		return true
	end,
	info = function(self, t)
		return ([[Direct one of your eyes to stare down a targeted area. Enemies in a cone extending from the eye are instantly brainlocked using your spellpower, and each turn take %0.1f mind damage and are slowed by %d%%.  The stare will last up to %d turns, ending early if there are no targets in the area, or if the eye needs to heal.
]]):tformat(damDesc(self, DamageType.MIND, t.getDamage(self, t)), t.getSlow(self, t)*100, t.getDurationStare(self, t))
	end,
}

newTalent{
	name = "Oversight", short_name = "REK_HEKA_EYEBITE_OVERWATCH",
	type = {"spell/eyebite", 2},	require = eye_req_high2, points = 5,
	mode = "passive",
	getOverwatch = function(self, t) return self:combatTalentScale(t, 1, 5) end,
	--used in an effect applied in the eye's stare down talent via the STARE damage type
	info = function(self, t)
		return ([[Rest easy knowing that someone is watching your back, even if that someone is you.  When you are in the area of an Evil Eye, your health regeneration is increased by %d and your saves by %d.]]):tformat(t.getOverwatch(self, t), t.getOverwatch(self, t)*8)
	end,
}

newTalent{
	name = "Inescapable Gaze", short_name = "REK_HEKA_EYEBITE_INESCAPABLE",
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
