newTalent{
	name = "Pulse Shield", short_name = "REK_HEKA_BLOODTIDE_SHIELD",
	type = {"spell/bloodtide", 1}, require = mag_req1, points = 5,
	mode= "passive",
	no_unlearn_last = true,
	getPercentage = function(self, t) return self:combatTalentLimit(t, 100, 30, 90) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp, no_martyr)
		local false_speed = 1
		if self.global_speed_add >= 0 then false_speed = self.global_speed_base + self.global_speed_add
		else false_speed = self.global_speed_base / (1 + math.abs(self.global_speed_add))
		end
		false_speed = math.max(false_speed, 0.1)

		if false_speed == 1.0 then return {dam=dam} end

		local percentage = t:_getPercentage(self)
		local delta = false_speed - 1
		local delta_eff = false_speed >= 1.0 and delta * (percentage / 100) or delta * (50/(50+percentage))
		local effective_speed =  1 + delta_eff

		local amped = dam / effective_speed
		if amped < dam then game:delayedLogDamage(src, self, 0, ("#WHITE#(%d to pulse shield)#LAST#"):format(dam-amped), false)
		else
			game:delayedLogDamage(src, self, 0, ("#WHITE#(%d extra from pulse shield)#LAST#"):format(amped-dam), false)
		end
		return {dam=amped}
	end,
	info = function(self, t)
		return ([[You are always perfectly balanced, acting as if your global speed was exactly 100%%.  
If you would be hasted, you reduce incoming damage by %d%% of your bonus speed.
If you would be slowed, you increase incoming damage by %d%% of your missing speed.]]):tformat(t:_getPercentage(self), 5000/(50+t:_getPercentage(self)))
	end,
}

newTalent{
	name = "Tidal Tempo", short_name = "REK_HEKA_BLOODTIDE_BUFF",
	type = {"spell/bloodtide", 2},	require = mag_req_slow2, points = 5,
	mode = "passive",
	getMultiplier = function(self, t) return self:combatTalentScale(t, 1.3, 1.75) end,
	doUnHighlight = function(self, t, tid)
		if not self:playerControlled() then return end
		
		game.uiset.bloodtide_particles = game.uiset.bloodtide_particles or {}
		if game.uiset.bloodtide_particles[tid] then
			local p = game.uiset.bloodtide_particles[tid].p
			game.uiset.particles[p] = nil
			game.uiset.bloodtide_particles[tid] = nil
		end
	end,
	doHighlight = function(self, t, tid)
		if not self:playerControlled() then return end
		
		game.uiset.bloodtide_particles = game.uiset.bloodtide_particles or {}
		
		local hk
		-- find the hotkey
		for n, info in pairs(self.hotkey) do
			local kind, hk_tid = info[1], info[2]
			if kind == 'talent' then
				if hk_tid == tid then
					hk = n
				end
			end
		end
		
		local x, y
		local zone
		
		if hk and config.settings.tome.visual_hotkeys and game.uiset.hotkeys_display and game.uiset.hotkeys_display.clics and game.uiset.hotkeys_display.clics[hk] and self.hotkey[hk] then
			zone = game.uiset.hotkeys_display.clics[hk]
			x = game.uiset.hotkeys_display.display_x + zone[1] + zone[3] / 2
			y = game.uiset.hotkeys_display.display_y + zone[2] + zone[4] / 2
		end
		
		--if there's already a particle and its not in the right place, delet
		if game.uiset.bloodtide_particles[tid] and (game.uiset.bloodtide_particles[tid].x ~= x or game.uiset.bloodtide_particles[tid].y ~= y) then
			local p = game.uiset.bloodtide_particles[tid].p
			game.uiset.particles[p] = nil
			game.uiset.bloodtide_particles[tid] = nil
		end
		
		--if we have a valid position and there isn't already a particle in that position, add
		if zone and
			not game.uiset.bloodtide_particles[tid] or
			not (game.uiset.bloodtide_particles[tid] and game.uiset.bloodtide_particles[tid].x == x and game.uiset.bloodtide_particles[tid].y == y) then
			local p = Particles.new("hotkey_highlight_bloodtide", 1, {icon_w=game.uiset.hotkeys_display.icon_w})
			game.uiset.particles[p] = {x=x or 0, y=y or 0}
			game.uiset.bloodtide_particles[tid] = {p=p, x=x or 0, y=y or 0}
		end
	end,
	info = function(self, t)
		return ([[If you use your Kharybdian talents the same turn they come off cooldown, their damage will be multiplied by %0.1fx.]]):tformat(t:_getMultiplier(self))
	end,
}

newTalent{
	name = "Relentless Waters", short_name = "REK_HEKA_BLOODTIDE_WATERS",
	type = {"spell/bloodtide", 3}, require = mag_req3, points = 5,
	mode = "passive",
	cooldown = function(self, t) return math.floor(20 / math.sqrt(self:getTalentLevel(t))) end,
	getSpeedup = function(self, t) return self:combatTalentScale(t, 10, 20) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			if self.player then
				if self == game:getPlayer(true) then
					position = self:findQuickHotkey("Player: Specific", "talent", t.id)
					if not position then
						local global_hotkeys = engine.interface.PlayerHotkeys.quickhotkeys["Player: Global"]
						if global_hotkeys and global_hotkeys["talent"] then position = global_hotkeys["talent"][t.id] end
					end
				else
					position = self:findQuickHotkey(self.name, "talent", t.id)
				end
			end

			if position and not self.hotkey[position] then
				self.hotkey[position] = {"talent", t.id}
			else
				for i = 1, 12 * (self.nb_hotkey_pages or 5) do
					if not self.hotkey[i] then
						self.hotkey[i] = {"talent", t.id}
						break
					end
				end
			end
		end
	end,
	callbackOnTemporaryEffectAdd = function(self, t, eff_id, e, p)
		if e.subtype and e.subtype.stun and not self:isTalentCoolingDown(t) then
			self:removeEffect(eff_id)
			self:startTalentCooldown(t, math.ceil(self:getTalentCooldown(t) * (1 - (self.stun_immune or 0))))
			if (self.stun_immune or 0) >= 1 then
				self:setEffect(self.EFF_REK_HEKA_RELENTLESS, 1, {power=t:_getSpeedup(self), src=self})
			end
		end
	end,
	info = function(self, t)
		return ([[If you are stunned while this talent is ready, the stun is removed and this talent goes on cooldown.  Your stun immunity reduces the effective cooldown of this talent instead of having its normal effect. If your stun immunity was already 100%%, you get %d%% faster for one turn upon avoiding a stun this way.]]):tformat(t:_getSpeedup(self))
	end,
}

newTalent{
	name = "Tide Stands Still", short_name = "REK_HEKA_BLOODTIDE_WAIT",
	type = {"spell/bloodtide", 4}, require = mag_req4, points = 1,
	cooldown = 35,
	tactical = { ATTACK = {PHYSICAL = 2}, DISABLE = 1 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	callbackOnWait = function(self, t)
		local eff = self:hasEffect(self.EFF_REK_HEKA_TEMPO)
		if not eff then return end
		for tid, _ in pairs(eff.talents) do
			eff.talents[tid] = eff.talents[tid] + 1
		end
		eff.dur = eff.dur + 1
	end,
	on_pre_use = function(self, t, silent)
		if self:hasEffect(self.EFF_REK_HEKA_TEMPO) then return true end
		if not silent then game.logPlayer(self, "You require a ready talent to hold") end
		return false
	end,
	
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		local eff = self:hasEffect(self.EFF_REK_HEKA_TEMPO)
		if not eff then return end
		for tid, _ in pairs(eff.talents) do
			self:forceUseTalent(tid, {ignore_energy=true, force_target=target})
		end
		self:removeEffect(self.EFF_REK_HEKA_TEMPO)
		return true
	end,
	info = function(self, t)
		return ([[If you wait on the turn a Kharybdian talent comes off cooldown, it is paused, and will count as having just become ready next turn as well.  Use this talent to cast all readied talents at once, at the same target.]]):tformat()
	end,
}
