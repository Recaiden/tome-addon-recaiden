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
	type = {"technique/eyesight", 1}, require = mag_req_high1, points = 5,
	cooldown = 5,
	tactical = { ATTACKAREA = {MIND = 2}, DISABLE = 2 },
	range = 10,
	radius = function(self, t) return 6 end,
	requires_target = true,
	on_pre_use = function(self, t, silent)
		if countEyes(self) < 1 then
			if not silent then
				game.logPlayer(self, "You must have temporal hounds to use this talent.")
			end
			return false
		end
		return true
	end,
	getSlow = function(self, t) return 10 end,
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

			e.ai_state.stare_down = true
			e.ai_state.stare_down_target = {x=x, y=y}
			e.ai_state.stare_down_time = t.getDurationStare(self, t)
			
			a:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and target ~= a.summoner then
					DamageType:get(DamageType.MIND).projector(a, px, py, DamageType.MIND, dam)
					target:crossTierEffect(target.EFF_BRAINLOCKED, src:combatSpellpower())
				end
			end)
			
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "breath_time", {radius=tg.radius, tx=x-a.x, ty=y-a.y})
		end
		
		game:playSoundNear(self, "talents/breath")
		
		return true
	end,
	info = function(self, t)
		return ([[Direct one of your eyes to stare down a targeted area. Enemies in a cone extending from the eye are instantly brainlocked using your spellpower, and each turn take %0.1f mind damage and are slowed by %d%%.  The stare will last up to %d turns, ending early if there are no targets in the area, or if the eye needs to heal.
]]):tformat(damDesc(self, DamageType.MIND, damage), t.getSlow(self, t), t.getDurationStare(self, t))
	end,
}

newTalent{
	name = "Diffuse Anatomy", short_name = "REK_HEKA_EYESIGHT_ORGANS",
	type = {"technique/eyesight", 2},	require = mag_req_high2, points = 5,
	mode = "passive",
	critResist = function(self, t) return self:combatTalentScale(t, 15, 50, 0.75) end,
	immunities = function(self, t) return self:combatTalentLimit(t, 1, 0.20, 0.55) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "ignore_direct_crits", t.critResist(self, t))
	end,
	info = function(self, t)
		return ([[Now that your vital organs have no need to be connected in normal space, you can hide them away from harm.

You take %d%% less damage from direct critical hits.
Flow also increases your life regeneration by 2.5 per stack.]]):tformat(t.critResist(self, t), 100*t.immunities(self, t))
	end,
}

newTalent{
	name = "Divided Arms", short_name = "REK_HEKA_EYESIGHT_ARMS",
	type = {"technique/eyesight", 3}, require = mag_req_high3, points = 5,
	speed = "weapon",
	hands = 30,
	tactical = { ATTACK = { weapon = 1 }, },
	cooldown = 25,
	range = 6,
	radius = function (self, t) return 1 end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, nowarning=true} end,
	getDuration = function(self, t) return 12 end,
	getAttacks = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	getDamage = function(self, t)
		return math.max(1, self:combatScale(self:getTalentLevel(t), 1, 5, 1.5, 10))
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)

		self:setEffect(self.EFF_REK_HEKA_ARM_PORTAL, duration, {x=x, y=y, interval=math.ceil(duration / t.getAttacks(self, t)), mult=t.getDamage(self, t), src=self})
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		local timer = math.ceil(dur / t.getAttacks(self, t))
		return ([[Your body parts no longer need to stay together; send a few arms out to attack distant enemies.
Every %d turns for the next %d turns, all enemies in the targeted area will be attacked for %d%% damage.
Flow also increases your Defense by 5 per stack.]]):tformat(timer, dur, t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Disjoin", short_name = "REK_HEKA_EYESIGHT_ATTACK",
	type = {"technique/eyesight", 4}, require = mag_req_high4, points = 5,
	speed = "weapon",
	hands = 25,
	tactical = { ATTACK = { weapon = 2}, DISABLE = 1 },
	cooldown = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentScale(t, 1.0, 1.0) end,
	getDuration = function(self, t) return self:combatTalentScale(t, 3, 6) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local flow = 1
		local eff = self:hasEffect(self.EFF_REK_HEKA_ICHOR)
		if eff then flow = eff.stacks end
		
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit then
			target:setEffect(target.EFF_CRIPPLE, t.getDuration(self, t), {speed=0.1*flow, apply_power=self:combatAttack()})
		end

		game:onTickEnd(function()
										 if self:hasEffect(self.EFF_REK_HEKA_ICHOR) then
											 self:removeEffect(self.EFF_REK_HEKA_ICHOR)
										 end
									 end)

		return true
	end,
	info = function(self, t)
		return ([[Separate an enemy into many parts, just like you!
Of course, for them it is rather more dangerous.

Spend all of your Flow to make an attack that does %d%% damage and cripples (#SLATE#Accuracy vs Physical#LAST#) the target for %d turns.  The cripple is more intense for each stack of Flow.
Flow also increases your Accuracy by 5 per stack.]]):tformat(t.getDamage(self, t)*100, t.getDuration(self, t))
	end,
}

