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
	hands = 10,
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
	name = "Blade-breaking Lens", short_name = "REK_HEKA_VEILED_DISARM",
	type = {"spell/veiled-shepherd", 2},	require = mag_req2, points = 5,
	range = 9,
	cooldown = 12,
	hands = 25,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 250) end,
	getDuration = function(self, t) return meth.ceil(self:combatTalentScale(t, 1, 5)) end,
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

		local tg_hit = {type="ball", range=0, radius=1, no_restrict=true, friendlyfire=false, x=target.x, y=target.y}

		target:project(tg_hit, target.x, target.y, DamageType.REK_HEKA_LENS, {dam=self:spellCrit(t.getDamage(self, t)), dur=t.getDuration(self, t)})
		
		return true
	end,
	info = function(self, t)
		return ([[Direct one of your eyes to whirl around in a frenzy, snapping and smashing.  All adjacent enemies will be hit for %0.1f physical damage and may be disarmed (#SLATE# Eye's spellpower vs Physical#LAST#) for %d turns.]]):tformat(damDesc(self, DamageType.PHYSICAL, t:_getDamage(self)), t:_getDuration(self))
	end,
}

newTalent{
	name = "Eyes Open", short_name = "REK_HEKA_VEILED_FRENZY",
	type = {"spell/veiled-shepherd", 3}, require = mag_req3, points = 5,
	mode = "passive",
	getHands = function(self, t) return 15 end,
	getHeal = function(self, t) return self:combatTalentScale(t, 10, 100) end,
	recover = function(self, t)
		local healed = self:spellCrit(t:_getHeal(self))
		self:incHands(t:_getHands(self))
		for _, e in pairs(game.level.entities) do
			if (e == self) or (e.summoner and e.summoner == self and e.is_wandering_eye) then
				e:attr("allow_on_heal", 1)
				e:heal(healed, self)
				e:attr("allow_on_heal", -1)
			end
		end
	end,
	callbackOnKill = function(self, t) t.recover(self, t)	end,
	callbackOnSummonKill = function(self, t) t.recover(self, t)	end,
	callbackOnSummonDeath = function(self, t) t.recover(self, t) end,
	info = function(self, t)
		return ([[Whenever you or your summons kill an enemy, or when one of your summons dies, you receive a burst of life and power, regaining %d hands and providing %d healing to you and your eyes.

#{italic}#Most victims are just more flesh for you to use.#{normal}#]]):tformat(t:_getHands(self), t:_getHeal(self))
	end,
}

newTalent{
	name = "Eyelight", short_name="REK_HEKA_VEILED_HIGHLIGHT",
	type = {"spell/veiled-shepherd", 4}, require = mag_req4, points = 5,
	cooldown = 8,
	hands = 30,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 2, DISABLE = 1 },
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
	getNumb = function(self, t) return self:combatTalentLimit(t, 50, 12, 25) end,
	getDuration = function(self, t) return 3 end,
	action = function(self, t)
		local target = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(target)
		if not target then return nil end

		target:setEffect(target.EFF_REK_HEKA_EYELIGHT, t:_getDuration(self), {src=self, power=t:_getNumb(self), apply_power=self:combatSpellpower()})
		
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.is_wandering_eye then
				-- reset target and set to focus
				e.ai_target.x = nil
				e.ai_target.y = nil
				e.ai_target.actor = target
				e.ai_target.focus_on_target = true
				e.energy.value = e.energy.value + game.energy_to_act
			end
		end

		-- invest cost
		game:onTickEnd(function() 
				self:setEffect(self.EFF_REK_HEKA_INVESTED, t:_getDuration(self),
											 {investitures={{power=util.getval(t.hands, self, t)}}, src=self})
		end)
		return true
	end,
	info = function(self, t)
		return ([[Focus your entire gaze on an enemy, crushing them beneath the weight of your attention.  All of your eyes will gain an exra turn and prioritize attacking the target, while the target will be numbed (#SLATE#Spell save#LAST#), reducing all damage they deal by %d%% for %d turns.
This talent invests hands; your maximum hands will be reduced by its cost until it expires.]]):tformat(t.getNumb(self, t), t.getDuration(self, t))
	end
}
