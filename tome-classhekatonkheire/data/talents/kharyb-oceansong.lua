newTalent{
	name = "Lamenting Echo", short_name = "REK_HEKA_OCEANSONG_SONG",
	type = {"spell/oceansong", 1}, require = mag_req1, points = 5,
	mode= "passive",
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2.6)) end,
	targetCenters = function(self, t) return {type="ball", range=0, radius=10, selffire=false, friendlyfire=false} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 120) end,
	callbackOnTalentPost = function(self, t, ab)
		if not ab.hands then return end
		local tgMain = t.targetCenters(self, t)

		local targets = {}
		self:project(
			tgMain,
			self.x, self.y,
			function(px, py)
				local a = game.level.map(px, py, engine.Map.ACTOR)
				if a and a:reactionToward(self) < 0 then
					targets[#targets+1] = a
				end
		end)
		if #targets <= 0 then return end
		local target = rng.table(targets)
		local x, y, dist = target.x, target.y, core.fov.distance(self.x, self.y, target.x, target.y)

		local rad = self:getTalentRadius(t)
		while rad + dist > 10 do rad = rad - 1 end
		
		local tg = {type="ball", radius=rad, range=10, selffire=false, friendlyfire=false, talent=t}

		local t2 = self:getTalentFromId(self.T_REK_HEKA_OCEANSONG_HARMONY)
		if self:knowTalent(self.T_REK_HEKA_OCEANSONG_HARMONY) and not self:isTalentCoolingDown(t2) then
			self:project(tg, x, y, DamageType.REK_HEKA_MIND_HARMONY, self:spellCrit(t.getDamage(self, t))*self:callTalent(self.T_REK_HEKA_OCEANSONG_HARMONY, "getMultiplier"))
			self:startTalentCooldown(self.T_REK_HEKA_OCEANSONG_HARMONY)
			game:playSoundNear(self, "talents/chant_one")
		else
			self:project(tg, x, y, DamageType.REK_HEKA_MIND_CRIPPLE, self:spellCrit(t.getDamage(self, t)))
		end
	end,
	info = function(self, t)
		return ([[When you spend Hands, your voices spill into the world, creating a radius %d burst of sound centered on a random enemy within range 10 that deals %0.1f mind damage.
The radius is reduced if the target is more than %d spaces away.]]):tformat(self:getTalentRadius(t), damDesc(self, DamageType.MIND, t.getDamage(self, t)), 10-self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Pounding Harmony", short_name = "REK_HEKA_OCEANSONG_HARMONY",
	type = {"spell/oceansong", 2},	require = mag_req2, points = 5,
	mode = "passive",
	cooldown = 4,
	getMultiplier = function(self, t) return self:combatTalentScale(t, 1.5, 3.0) end,
	info = function(self, t)
		return ([[Every %d turns, Lamenting Echo will do %d%% of its normal damage and confuse enemies (33%% power) for %d turns.]]):tformat(self:getTalentCooldown(t), t:_getMultiplier(self)*100, 3)
	end,
}

newTalent{
	name = "Drowned Lullaby", short_name = "REK_HEKA_OCEANSONG_FAIL",
	type = {"spell/oceansong", 3}, require = mag_req3, points = 5,
	mode = "passive",
	getFail = function(self, t) return self:combatTalentLimit(t, 50, 8, 20) end,
	info = function(self, t)
		return ([[Enhance your Lamenting Echo with melodies of peaceful demise that confound enemies (#SLATE#Spell save, no spellshock#LAST#) for 1 turn. Confounded enemies have a %d%% chance upon using a talent to fail and lose a turn.]]):tformat(t:_getFail(self))
	end,
}

newTalent{
	name = "Siren Song", short_name = "REK_HEKA_OCEANSONG_SIREN",
	type = {"spell/oceansong", 4}, require = mag_req4, points = 5,
	cooldown = 10,
	hands = 20,
	requires_target = true,
	range = 10,
	tactical = { DISABLE = 2 },
	getDuration = function(self, t) return math.min(10, math.floor(self:combatTalentScale(t,5,10))) end,
	getChance = function(self, t) return math.min(55, math.floor(25 + (math.sqrt(self:getTalentLevel(t)) - 1) * 20)) end,
	getPowerChange = function(self, t) return -self:combatTalentStatDamage(t, "mag", 8, 33) end,
	action = function(self, t)
		local range = self:getTalentRange(t)

		local tg = {type="hit", pass_terrain=true, range=range}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > range then return nil end

		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		target:setEffect(target.EFF_BECKONED, duration, {src=self, range=range, chance=chance, spellpowerChange=0, mindpowerChange=0})
		game:playSoundNear(self, "talents/chant_two")

		return true
	end,
	info = function(self, t)
		return ([[Sing a particularly entrancing song that lures a victim towards you. For %d turns, they will try to come to you, even pushing others aside to do so. They will move towards you instead of acting %d%% of the time (less often if they succeed at a mind save).  For every %% of their life they lose, they have the same %% chance to escape the lure.]]):tformat(t.getDuration(self, t), t.getChance(self, t), -t.getPowerChange(self, t))
	end,
}
