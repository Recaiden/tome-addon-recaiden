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
	name = "Evil Eye", short_name = "REK_HEKA_EYESIGHT_STARE",
	type = {"spell/eyesight", 1}, require = mag_req_high1, points = 5,
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
		if tx then
			_, _, _, tx, ty = self:canProject(tg_eye, tx, ty)
			if tx then
				target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return nil end
				if not target.is_wandering_eye then return nil end
				if not target.summoner or target.summoner ~= self then return nil end
			end
		end
		
		local tg = {multiple=true}
		local eyes = {target}
		tg[#tg+1] = {type="cone", range=0, radius=self:getTalentRadius(t), start_x=target.x, start_y=target.y, selffire=false, talent=t}
			
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
			
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "breath_time", {radius=tg.radius, tx=x-a.x, ty=y-a.y})
		end
		
		game:playSoundNear(self, "talents/breath")
		
		return true
	end,
	info = function(self, t)
		return ([[Direct one of your eyes to stare down a targeted area. Enemies in a cone extending from the eye are instantly brainlocked using your spellpower, and each turn take %0.1f mind damage and are slowed by %d%%.  The stare will last up to %d turns, ending early if there are no targets in the area, or if the eye needs to heal.
]]):tformat(damDesc(self, DamageType.MIND, t.getDamage(self, t)), t.getSlow(self, t), t.getDurationStare(self, t))
	end,
}

newTalent{
	name = "Oversight", short_name = "REK_HEKA_EYESIGHT_OVERWATCH",
	type = {"spell/eyesight", 2},	require = mag_req_high2, points = 5,
	mode = "passive",
	getOverwatch = function(self, t) return self:combatTalentScale(t, 1, 5) end,
	--used in an effect applied in the eye's stare down talent via the STARE damage type
	info = function(self, t)
		return ([[Rest easy knowing that someone is watching your back, even if that someone is you.  When you are in the area of an Evil Eye, your health regeneration is increased by %d and your saves by %d.]]):tformat(t.getOverwatch(self, t), t.getOverwatch(self, t)*8)
	end,
}

newTalent{
	name = "Inescapable Gaze", short_name = "REK_HEKA_EYESIGHT_INESCAPABLE",
	type = {"spell/eyesight", 3}, require = mag_req_high3, points = 5,
	mode = "passive",
	getMultiplier = function(self, t) return math.max(1, self:combatTalentLimit(t, 5, 1.5, 2.25)) end,
	-- handled in the STARE damage type
	info = function(self, t)
		return ([[If an enemy is affected by multiple Evil Eyes in one turn, the damage will be increased by %d%% and the slow by %d%%.]]):tformat(t.getMultiplier(self, t)*200-100, t.getMultiplier(self, t)*100)
	end,
}


newTalent{
	name = "Panopticon", short_name = "REK_HEKA_EYESIGHT_PANOPTICON",
	type = {"spell/eyesight", 4}, require = mag_req_high4, points = 5,
	hands = 40,
	tactical = { DISABLE = 5 },
	cooldown = 50,
	no_npc_use=true,
	range = 5,
	getSightBonus = function(self, t) return math.floor(self:combatTalentLimit(t, 4, 1, 3)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "sight", t.getSightBonus(self, t))
	end,
	getDuration = function(self, t) return self:combatTalentScale(t, 2, 4.5)	end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(target.x, target.y, x, y) > 5 then return nil end
		if not target:hasProc("heka_panopticon_ready") then return nil end
		target:setEffect(target.EFF_REK_HEKA_PANOPTICON, t.getDuration(self, t), {})
		game.level.map:particleEmitter(self.x, self.y, 1, "circle", {oversize=1.7, a=170, limit_life=12, shader=true, appear=12, speed=0, base_rot=180, img="oculatus", radius=0})
		return true
	end,
	info = function(self, t)
		return ([[Paralyze a target wth the weight of your gaze.  A target who has been seen by at least two Evil Eyes is rendered unable to act for %d turns (#SLATE#No save or immunity#LAST#).

Passively increases the sight range of your eyes by %d.]]):tformat(t.getDuration(self, t), t.getSightBonus(self, t))
	end,
}