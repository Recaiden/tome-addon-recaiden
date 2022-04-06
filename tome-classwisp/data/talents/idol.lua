local Object = require "mod.class.Object"

numIdolAurasKnown = function(self)
	local num = 0
	local auras = {
		self.T_REK_GLR_IDOL_FASCINATING,
		self.T_REK_GLR_IDOL_TERRIFIC,
		self.T_REK_GLR_IDOL_THOUGHT_DRINKER
	}
	for k, talent in pairs(auras) do
		if self:knowTalent(talent) then
			num = num + 1
		end
	end
	return num
end

local idol_on_pre_use_ai = function(self, t, silent, fake)
	if self.ai_state._advanced_ai then return true end -- let the AI decide when to use
	local aitarget = self.ai_target.actor
	if not aitarget or self:reactionToward(aitarget) >= 0 then -- no hostile target, keep activated
		return not self:isTalentActive(t.id)
	end
	return true -- requires_target controls if active
end

local idol_tactical = function(self, t, aitarget)
	local log_detail = 2--config.settings.log_detail_ai or 0
	local is_active = self:isTalentActive(t.id)
	local psi_val, aura_cost = self:getPsi(), t.getAuraCost(self, t) or 0
	
	local tacs = {
		self = {
			BUFF =  1,
			PSI = -1*aura_cost
		},
	}
	if is_active and psi_val >= t.getSpikeCost(self, t) then --add spike tactics
		table.merge(tacs, t.tactical_spike)
	end
	if log_detail > 1 then print(" == PROJECTION TACTICS == final tactics:", t.id) table.print(tacs, "\t_ft_") end
	return tacs
end

newTalent{
	name = "Star Power", short_name = "REK_GLR_IDOL_STARPOWER",
	type = {"psionic/other", 1},
	points = 1,
	mode = "passive",
	getMindpower = function(self, t) return self:getTalentLevel(t) * 2 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, 'combat_mindpower', t.getMindpower(self, t))
	end,
	info = function(self, t)
		return ([[Increases your mindpower by %d]]):format(t.getMindpower(self, t))
	end,
}

newTalent{
	name = "Fascinating", short_name = "REK_GLR_IDOL_FASCINATING",
	type = {"psionic/idol", 1},
	require = {
		stat = { wil=function(level) return 12 + (level-1) * 4 end },
		level = function(level) return 0 + (level-1) end,
		special =
			{
			desc="You can learn 1 Idol Aura every 4 levels",
			fct=function(self)
				return self:knowTalent(self.T_REK_GLR_IDOL_FASCINATING) or self.level >= numIdolAurasKnown(self)*4
	    end
			},
	},
	points = 5,
	cooldown = 12,
	no_energy = function(self, t) return not self:isTalentActive(t.id) end,
	mode = "sustained",
	no_sustain_autoreset = true,
	sustain_psi = 10,
	range = 7,
	on_pre_use_ai = idol_on_pre_use_ai,
	tactical = idol_tactical,
	tactical_spike = {
		DISABLE = function(self, t, target)
			return math.floor(((target.max_life - target.life) / target.max_life) * 5 ) - 1
		end},
	on_learn = function(self, t) self:learnTalent(self.T_REK_GLR_IDOL_STARPOWER, true) end,
	on_unlearn = function(self, t) self:unlearnTalent(self.T_REK_GLR_IDOL_STARPOWER) end,
	getSpikeCost = function(self, t) return 20 end,
	spikeTarget = function(self, t) return {type="hit", nolock=true, nowarning=true, range=self:getTalentRange(t)} end,
	getAuraCost = function(self, t) return 2.0 end,
	auraRange = function(self, t) return 0 end,
	auraRadius = function(self, t) return 10 end,
	auraTarget = function(self, t)
		return {type="ball", range=t.auraRange(self, t), radius=t.auraRadius(self, t), selffire=false, friendlyfire=false}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 1, 4.8)) end,
	getImmunityDuration = function(self, t) return 15 end,
	getMaxOppression = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	callbackOnAct = function(self, t)
		local tg = t.auraTarget(self, t)
		local dur = math.max(1, t.getDuration(self, t)-1)
		local durImm = t.getImmunityDuration(self, t)
		local paid = false
		self:project(
			tg, self.x, self.y,
			function(tx, ty)
				local act = game.level.map(tx, ty, engine.Map.ACTOR)
				if act and not act:hasEffect(act.EFF_REK_GLR_NO_FASCINATE) and not act:hasEffect(act.EFF_REK_GLRDAZE) then
					if not paid then
						incPsi2(self, -t.getAuraCost(self, t))
						paid = true
					end
					act:setEffect(act.EFF_REK_GLR_DAZE, dur, {immunity=durImm, src=self, apply_power=self:combatMindpower(), no_ct_effect=true})
				end
			end)
	end,
	deactivate = function(self, t, p)
		if self:attr("save_cleanup") then return true end
		--self:removeParticles(p.particle)

		local cost = t.getSpikeCost(self, t)
		if self:getPsi() <= cost and not self:attr("force_talent_ignore_ressources") then
			game.logPlayer(self, "The aura dissipates without producing a spike.")
			return true
		end

		local tg = t.spikeTarget(self, t)
		local x, y = self:getTarget(tg)
		if x == self.x and y == self.y then return true end
		-- if no target, turn the ability off without spending resource or going on CD
		-- in 1.7 make this handle dispelling better
		if not x or not y then
			game:onTickEnd(function()
											 if self:isTalentCoolingDown(self.T_REK_GLR_IDOL_FASCINATING) then
												 self:alterTalentCoolingdown(self.T_REK_GLR_IDOL_FASCINATING, -1000)
											 end
										 end)
			
			return nil
		end
		local actor = game.level.map(x, y, Map.ACTOR)
		if core.fov.distance(self.x, self.y, x, y) == 0 then return true end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if not actor then return end		
		local missing = (actor.max_life - actor.life) / actor.max_life
		actor.energy.value = actor.energy.value - game.energy_to_act * (missing / 0.2)
		game:playSoundNear(self, "talents/distortion")
		incPsi2(self, -cost)
		return true
	end,
	info = function(self, t)
		return ([[

While Active: Each turn, nearby non-fascinated enemies will be fascinated, dazing them (#SLATE#Mental Save#LAST#) for %d turns.  This can never inflict Brainlock. Once they recover from fascination, they are immune for %d turns.
Costs #4080ff#2 Psi#LAST# when triggered
Range: 10

Deactivate: Focus your fascination to overwhelm a single creature, causing it to lose 1 turn for every 20%% of its life it was missing (up to %d turns).
Costs #4080ff#%d Psi#LAST#
Uses Mind Speed

#{italic}#All who look upon you lose the will to fight.#{normal}#

Each point in Idol talents increases your mindpower by 2.]]):
		format(t.getDuration(self, t), t.getImmunityDuration(self, t), t.getMaxOppression(self, t), t.getSpikeCost(self, t))
	end,
}

newTalent{
	name = "Awesome", short_name = "REK_GLR_IDOL_TERRIFIC",
	type = {"psionic/idol", 1},
	require = {
		stat = { wil=function(level) return 12 + (level-1) * 4 end },
		level = function(level) return 0 + (level-1) end,
		special =
			{
			desc="You can learn 1 Idol Aura every 4 levels",
			fct=function(self)
				return self:knowTalent(self.T_REK_GLR_IDOL_TERRIFIC) or self.level >= numIdolAurasKnown(self)*4
	    end
			},
	},
	points = 5,
	cooldown = 20,
	no_energy = function(self, t) return not self:isTalentActive(t.id) end,
	on_pre_use_ai = idol_on_pre_use_ai,
	tactical = idol_tactical,
	tactical_spike = { DISABLE = 3 },
	mode = "sustained",
	no_sustain_autoreset = true,
	sustain_psi = 10,
	range = 4,
	on_learn = function(self, t) self:learnTalent(self.T_REK_GLR_IDOL_STARPOWER, true) end,
	on_unlearn = function(self, t) self:unlearnTalent(self.T_REK_GLR_IDOL_STARPOWER) end,
	getSpikeCost = function(self, t) return 12 end,
	getAuraCost = function(self, t) return 1.0 end,
	spikeTarget = function(self, t) return {type="hit", nolock=true, nowarning=true, range=self:getTalentRange(t)} end,
	auraRange = function(self, t) return 0 end,
	auraRadius = function(self, t) return self.getTalentRange and self:getTalentRange(t) or 4 end,
	auraTarget = function(self, t)
		return {type="ball", range=t.auraRange(self, t), radius=t.auraRadius(self, t), selffire=false, friendlyfire=false}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getPower = function(self,t) return self:getTalentLevel(t) * 7.5 end,
	activate = function(self, t)
		local ret = {}
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=0.2+self:getTalentRange(t)*1.78, blend=true, img="glr_awesome_aura"}, {type="shield", shieldIntensity=0.02, ellipsoidalFactor=1, color={1,1,1}}))
		end
		return ret
	end,
	callbackOnAct = function(self, t)
		local tg = t.auraTarget(self, t)
		local dur = 1
		self:project(
			tg, self.x, self.y,
			function(tx, ty)
				local act = game.level.map(tx, ty, engine.Map.ACTOR)
				if act then
					act:setEffect(act.EFF_REK_GLR_INTIMIDATED, dur, {power=t.getPower(self, t)})
				end
			end)
	end,
	deactivate = function(self, t, p)
		if p.particle then self:removeParticles(p.particle) end
		if self:attr("save_cleanup") then return true end
		
		local cost = t.getSpikeCost(self, t)
		if self:getPsi() <= cost and not self:attr("force_talent_ignore_ressources") then
			game.logPlayer(self, "The aura dissipates without producing a spike.")
			return true
		end

		local tg = t.spikeTarget(self, t)
		local x, y = self:getTarget(tg)
		if not x or not y then
			game:onTickEnd(function()
											 if self:isTalentCoolingDown(self.T_REK_GLR_IDOL_TERRIFIC) then
												 self:alterTalentCoolingdown(self.T_REK_GLR_IDOL_TERRIFIC, -1000)
											 end
										 end)
			
			return nil
		end
		if x == self.x and y == self.y then return true end

		local actor = game.level.map(x, y, Map.ACTOR)
		if core.fov.distance(self.x, self.y, x, y) == 0 then return true end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if not actor then return end
		actor:setEffect(actor.EFF_REK_GLR_DELIRIOUS, t.getDuration(self, t), {apply_power=self:combatMindpower()})
		game:playSoundNear(self, "talents/arcane")
		incPsi2(self, -cost)
		return true
	end,
	info = function(self, t)
		return ([[

While Active: Enemies within %d have their mental save reduced by %d. (#SLATE#No Save#LAST#)

Deactivate: Focus your awesomeness to dazzle a single creature, giving them a 1/3 chance to fail to use talents for %d turns.
Costs #4080ff#%d Psi#LAST#
Uses Mind Speed

#{italic}#All who approach you realize how unimportant they are.#{normal}#

Each point in Idol talents increases your mindpower by 2.]]):format(t.auraRadius(t), t.getPower(self, t), t.getDuration(self, t), t.getSpikeCost(self, t))
	end,
}

newTalent{
	name = "Thought Drinker", short_name = "REK_GLR_IDOL_THOUGHT_DRINKER",
	type = {"psionic/idol", 1},
	require = {
		stat = { wil=function(level) return 12 + (level-1) * 4 end },
		level = function(level) return 0 + (level-1) end,
		special =
			{
			desc="You can learn 1 Idol Aura every 4 levels",
			fct=function(self)
				return self:knowTalent(self.T_REK_GLR_IDOL_THOUGHT_DRINKER) or self.level >= numIdolAurasKnown(self)*4
	    end
			},
	},
	points = 5,
	no_energy = true,
	mode = "sustained",
	on_pre_use_ai = idol_on_pre_use_ai,
	tactical = idol_tactical,
	tactical_spike = { ESCAPE = 2, CLOSEIN = 1 },
	no_sustain_autoreset = true,
	cooldown = 15,
	range = 4,
	on_learn = function(self, t) self:learnTalent(self.T_REK_GLR_IDOL_STARPOWER, true) end,
	on_unlearn = function(self, t) self:unlearnTalent(self.T_REK_GLR_IDOL_STARPOWER) end,
	auraRange = function(self, t) return 0 end,
	auraRadius = function(self, t) return self.getTalentRange and self:getTalentRange(t) or 4 end,
	auraTarget = function(self, t)
		return {type="ball", range=t.auraRange(self, t), radius=t.auraRadius(self, t), selffire=false, friendlyfire=false}
	end,
	getAuraCost = function(self, t) return -1 end,
	getSpikeCost = function(self, t) return -25 end,
	getSpeedBoost = function(self, t) return 1 + self:getTalentLevel(t) end,
	getPsiRefund = function(self, t) return self:combatTalentScale(t, 0.1, 0.8) end,
	getKillMultiplier = function(self, t) return 25 end,
	callbackOnActBase = function(self, t)
		local gain = 0
		local tg = t.auraTarget(self, t)
		self:project(
			tg, self.x, self.y,
			function(tx, ty)
				local act = game.level.map(tx, ty, engine.Map.ACTOR)
				if act and self:canSee(act) then
					gain = gain + 1
				end
			end)
		if not self:attr("zero_resource_cost") then
			self:incPsi(gain * t.getPsiRefund(self, t))
		end
	end,
	callbackOnKill = function(self, t, src, death_note)
		if not self:attr("zero_resource_cost") then
			self:incPsi(t.getKillMultiplier(self, t) * t.getPsiRefund(self, t))
		end
		self:setEffect(self.EFF_REK_GLR_QUENCHED_SPEED, 2, {speed=t.getSpeedBoost(self, t), steps=math.ceil(t.getSpeedBoost(self, t)), src=self})
		game.level.map:particleEmitter(self.x, self.y, 1, "wide_stream", { dx = src.x - self.x, dy = src.y - self.y, dir_c=2, color_b=200, color_g=50, color_r=50})
		game:playSoundNear(self, "talents/drink")
	end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		if self:attr("save_cleanup") then return true end
		--self:removeParticles(p.particle)
		t.callbackOnKill(self, t, self, "deactivation")
		return true
	end,
	info = function(self, t)
		return ([[

While Active: Each round, you gain %0.2f #4080ff#Psi #LAST#for each visible enemy within range %d.

Deactivate: You gain %0.2f #4080ff#Psi #LAST#and %d%% movement speed (which lasts 2 turns or %d steps, whichever comes first).

When you kill an enemy, gain the deactivation effect of this talent (but it stays active).

#{italic}#Fighting is challenging.  Challenge is fun.  Winning is better.#{normal}#

Each point in Idol talents increases your mindpower by 2.]]):
		format(t.getPsiRefund(self, t), t.auraRadius(self, t), t.getKillMultiplier(self, t) * t.getPsiRefund(self, t), t.getSpeedBoost(self, t)*100, math.ceil(t.getSpeedBoost(self, t)))
	end,
}

newTalent{
	name = "Beloved", short_name = "REK_GLR_IDOL_BELOVED",
	type = {"psionic/idol", 1},
	require = wil_req4,
	points = 5,
	mode = "sustained",
	sustain_psi = 5,
	cooldown = 0,
	tactical = { DEFENSE = 2 },
	points = 5,
	on_learn = function(self, t) self:learnTalent(self.T_REK_GLR_IDOL_STARPOWER, true) end,
	on_unlearn = function(self, t) self:unlearnTalent(self.T_REK_GLR_IDOL_STARPOWER) end,
	getPrice = function(self, t) return math.floor(self:combatTalentLimit(t, 2, 6, 2.8)) end,
	getThresh = function(self, t) return self:combatTalentLimit(t, 0.10, 0.33, 0.16) end,
	callbackPriorities = {callbackOnTakeDamage = -100},
	callbackOnTakeDamage = function (self, t, src, x, y, type, dam, tmp, no_martyr)
		local thresh = t.getThresh(self, t) * self.max_life
		local threshShock = 0.25 * self.max_life
		if dam >= thresh then
			local dmg_src = self
			if src.__is_actor then dmg_src = src end

			if dam >= threshShock then
				-- ignore special immunities too
				local immun_phys = self:attr("physical_negative_status_effect_immune")
				local immun_all = self:attr("negative_status_effect_immune")
				if immun_phys then
					self:attr("physical_negative_status_effect_immune", -1*immun_phys)
				end
				if immun_phys then
					self:attr("negative_status_effect_immune", -1*immun_all)
				end

				local eff_count = 0
				local prevented = dam
				while prevented >= threshShock do
					eff_count = eff_count + 1
					prevented = prevented - threshShock
				end
				while eff_count > 0 do 
					-- give effects
					if not self:hasEffect(self.EFF_SLOW_MOVE) then
						self:setEffect(self.EFF_SLOW_MOVE, 5, {power=0.50, src=dmg_src})
						eff_count = eff_count-1
					elseif not self:hasEffect(self.EFF_REK_GLR_MULTI_STUNNED) and not self:hasEffect(self.EFF_STUNNED) then
						self:setEffect(self.EFF_REK_GLR_MULTI_STUNNED, 3, {src=dmg_src, layers=eff_count})
						eff_count = 0
					else
						self:setEffect(self.EFF_REK_GLR_MULTI_STUNNED, 3, {src=dmg_src, layers=eff_count+1})
						eff_count = 0
					end
				end
				
				-- restore special immunities
				if immun_phys then
					self:attr("physical_negative_status_effect_immune", immun_phys)
				end
				if immun_phys then
					self:attr("negative_status_effect_immune", immun_all)
				end
			end

			-- ignore damage
			game:playSoundNear(self, "talents/heal")
			incPsi2(self, -t.getPrice(self,t))

			local d_color = "#F9E58B#"
			game:delayedLogDamage(src, self, 0, ("%s(%d to love)#LAST#"):format(d_color, dam-0.05*self.max_life), false)
			
			return {dam=0.05*self.max_life}
		end
		
		return {dam=dam}
	end,
	callbackOnDeath = function(self, t, src, death_note)
		if not death_note then
			death_note = {special_death_msg = ("was taken captive by %s and never seen again"):format(src and src.name or "someone")}
			return
		end
		death_note.special_death_msg = ("was taken captive by %s and never seen again"):format(src and src.name or "someone")
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local particle = Particles.new("ultrashield", 1, {rm=204, rM=220, gm=152, gM=170, bm=0, bM=0, am=15, aM=60, radius=0.5, density=10, life=14, instop=150})
		return {
			particle = self:addParticles(particle)
					 }
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[If you would take damage over %d%% of your maximum life, that damage is reduced to 5%% of your maximum life at the cost of %d #4080ff# Psi. #LAST#  
For every 25%% of your maximum life the damage was, you receive a detrimental effect. First your movement is slowed by 50%% for 5 turns. If you are already slowed, you will be stunned for 3 turns.  If you are already stunned, you receive a multi-layer stun that is difficult to remove.

These effects ignore immunities and saves.

#{italic}#No one would really hurt you, not on purpose.  But they would try to control you.#{normal}#

Each point in Idol talents increases your mindpower by 2.]]):format(t.getThresh(self, t)*100, t.getPrice(self, t))
	end,
}
