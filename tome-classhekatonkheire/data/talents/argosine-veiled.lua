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
	name = "Thorough Lashing", short_name = "REK_HEKA_VEILED_LASHING",
	type = {"spell/veiled-shepherd", 1}, require = mag_req1, points = 5,
	cooldown = 3,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 2 },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nowarning=true} end,
	on_pre_use = function(self, t, silent)
		if not self:isTalentActive(self.T_REK_HEKA_HEADLESS_EYES) then
			if not silent then game.logPlayer(self, "You have no eyes to see!") end
			return false
		end
		if self:callTalent(self.T_REK_HEKA_HEADLESS_EYES, "nbEyesUp") == 0 then
			if not silent then game.logPlayer(self, "You have no eyes to see!") end
			return false
		end
		return true
	end,
	getCritChance = function(self, t) return math.floor(math.sqrt(self:getTalentLevel(t)) * 10) end,
	getCritDamage = function(self, t) return self:combatTalentScale(t, 25, 50) end,
	action = function(self, t)
		local target = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(target)
		if not target then return nil end

		local chance = t:_getCritChance(self)
		local power = t:_getCritDamage(self)
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.is_wandering_eye then
				e:setEffect(e.EFF_REK_HEKA_LASHING_POWER, 1, {src=self, chance=chance, power=power})
				e:forceUseTalent(e.T_REK_HEKA_EYE_EYE_LASH, {ignore_cd=true, ignore_energy=true, force_target=target, ignore_ressources=true, silent=true})
				if e then
					if e:hasEffect(e.EFF_REK_HEKA_LASHING_POWER) then e:removeEffect(e.EFF_REK_HEKA_LASHING_POWER) end
				end
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Command each eye use its lash talent on a chosen target, with +%d%% critical hit chance and +%d%% critical power.]]):tformat(t.getCritChance(self, t), t.getCritDamage(self, t))
	end
}

newTalent{
	name = "Oversight", short_name = "REK_HEKA_VEILED_OVERWATCH",
	type = {"spell/veiled-shepherd", 2},	require = mag_req2, points = 5,
	mode = "passive",
	getOverwatch = function(self, t) return self:combatTalentScale(t, 1, 5) end,
	--used in an effect applied in the eye's stare down talent via the STARE damage type
	info = function(self, t)
		return ([[Rest easy knowing that someone is watching your back, even if that someone is you.  When you are in the area of an Evil Eye, your health regeneration is increased by %d and your saves by %d.]]):tformat(t.getOverwatch(self, t), t.getOverwatch(self, t)*8)
	end,
}

newTalent{
	name = "Inescapable Gaze", short_name = "REK_HEKA_VEILED_INESCAPABLE",
	type = {"spell/veiled-shepherd", 3}, require = mag_req3, points = 5,
	mode = "passive",
	getMultiplier = function(self, t) return math.max(1, self:combatTalentLimit(t, 5, 1.5, 2.25)) end,
	-- handled in the STARE damage type
	info = function(self, t)
		return ([[If an enemy is affected by multiple Evil Eyes in one turn, the damage will be increased by %d%% and the slow by %d%%.]]):tformat(t.getMultiplier(self, t)*200-100, t.getMultiplier(self, t)*100)
	end,
}


newTalent{
	name = "Panopticon", short_name = "REK_HEKA_VEILED_PANOPTICON",
	type = {"spell/veiled-shepherd", 4}, require = mag_req4, points = 5,
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
