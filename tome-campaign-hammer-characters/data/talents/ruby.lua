newTalent{
	name = "Phase Step", short_name="REK_RUBY_PHASE_STEP",
	type = {"race/ruby", 1}, require = racial_req1, points = 5,
	range = 4,
	tactical = { ESCAPE = 2 },
	is_teleport = true,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 50, 22)) end,
	getDefense = function(self, t) return math.max(self:combatTalentStatDamage(t, "wil", 10, 25), self:combatTalentStatDamage(t, "mag", 10, 25)) end,
	getResist = function(self, t) return math.max(self:combatTalentStatDamage(t, "wil", 5, 15), self:combatTalentStatDamage(t, "mag", 5, 15)) end,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), nolock=true, talent=t} end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "defense_on_teleport", t.getDefense(self, t))
		self:talentTemporaryValue(p, "resist_all_on_teleport", t.getResist(self, t))
		self:talentTemporaryValue(p, "effect_reduction_on_teleport", t.getResist(self, t))
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_MAG or stat == self.STAT_WIL then self:updateTalentPassives(t) end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return end
		if not self:canProject(tg, x, y) then return end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return end

		if target or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self) then
			game.logPlayer(self, "You must have an empty space to teleport to.")
			return false
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(x, y, 0)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		game:playSoundNear(self, "talents/teleport")

		self:setEffect(self.EFF_OUT_OF_PHASE, 5, {})
		return true
	end,
	info = function(self, t)
		return ([[Instantly phase through space, teleporting you to a specific location up to %d spaces away.

Additionally you now go Out of Phase for five turns after any teleport, gaining %d defense, %d%% resist-all, and reducing incoming detrimental effect duration by %d%%.
The bonus will increase with the higher of your Magic and your Willpower]]):tformat(self:getTalentRange(t), t:_getDefense(self), t:_getResist(self), t:_getResist(self))
	end,
}

newTalent{
	name = "Legacy of Torment", short_name = "REK_RUBY_LEGACY_OF_TORMENT",
	type = {"race/ruby", 2}, require = racial_req2, points = 5,
	mode = "passive",
	getThreshold = function(self, t) return math.floor(math.max(10, (19 - self:getTalentLevel(t)*1.5))) / 100 end,
	getRemoveCount = function(self, t) return 1 end,
	getDuration = function(self, t) return 2 end,
	callbackOnHit = function(self, t, cb, src, death_note)
		local chance = 100 * cb.value / self.max_life * t.getThreshold(self, t)
		if cb.value >= self.max_life * t.getThreshold(self, t) or rng.percent(chance) then
			local effs = {}
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.status == "detrimental" and e.type ~= "other" then
					self.tempeffect_def[eff_id].dur = math.max(0, self.tempeffect_def[eff_id].dur-1)
				end
			end
		end
		return cb
	end,
	info = function(self, t)
		return ([[Whenever you are damaged, you have a chance to reduce the remaining duration of any phsyical, magical, or mental detrimental effects you are suffering.  The reduction is guaranteed if you would lose at least %d%% of your maximum life, 50%% if you take half that much, etc.

#{italic}#The pains you suffer only spur you harder to take your revenge.#{normal}#]]):tformat(t.getThreshold(self, t) * 100, t.getRemoveCount(self), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Cinder Power", short_name = "REK_RUBY_CINDER_POWER",
	type = {"race/ruby", 3}, require = racial_req3,	points = 5,
	mode = "passive",
	critPower = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
	spellCDR = function(self, t) return self:combatTalentScale(t, 5, 15, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_critical_power", t.critPower(self, t))
		self:talentTemporaryValue(p, "spell_cooldown_reduction", t.spellCDR(self, t)/100)
	end,
	info = function(self, t)
		return ([[Increases critical strike power by %d%% and spell cooldown reduction by %d%%.

#{italic}#More than any other demons, the children of ruby still feel the unstable magic of the Spellblaze.#{normal}#]]):tformat(t.critPower(self, t), t.spellCDR(self, t))
	end,
}

newTalent{
	name = "Daelach Hross", short_name = "REK_RUBY_SHADOWFLAME_SURGE",
	type = {"race/ruby", 4}, require = racial_req4, points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end,
	tactical = { DISABLE = 2, ATTACKAREA = 1 },
	range = 5,
	target = function(self, t) return {type="ball", range=0, friendlyfire=false, selffire=false, radius=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t)
		return math.max(self:combatStatScale("mag", 20, 60), self:combatStatScale("wil", 20, 80))
	end,
	getDuration = function(self, t) return 5 end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t, friendlyfire=false} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project({type="ball", range=0, radius=self:getTalentRange(t), talent=t, friendlyfire=false}, self.x, self.y, DamageType.BLIND_ALLPOWER, t.getDuration(self, t))
		self:project({type="ball", range=0, radius=self:getTalentRange(t), talent=t, friendlyfire=false}, self.x, self.y, DamageType.BLIND_ALLPOWER, t.getDuration(self, t))

		local ef = game.level.map:addEffect(
			self, self.x, self.y, t.getDuration(self, t),
			DamageType.SHADOWFLAME_FRIENDS, self:spellCrit(t.getDamage(self, t)),
			3,
			5, nil,
			{type="firestorm", only_one=true},
			function(e) e.x = e.src.x  e.y = e.src.y  return true end,
			0, 0
		)
		ef.name = _t"shadowflame surge"
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Conjure a storm of corrupted ash and blazing coals around you in a radius of %d, blinding enemies (#SLATE#Highest power vs Physical#LAST#) and dealing %0.1f fire and %0.1f darkness damage each turn for %d turns.  
Magic or Willpower: increases damage.

#{italic}#After tormenting them for countless years, the power of the dust mages has come into the demons' hands.#{normal}#]]):format(self:getTalentRange(t), damDesc(self, DamageType.FIRE, t.getDamage(self, t)/2), damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)/2), t:_getDuration(self))
	end,
}
