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
				return self:knowTalent(self.T_GLR_IDOL_FASCINATING) or self.level >= numIdolAurasKnown(self)*4
	    end
			},
	},
	points = 5,
	cooldown = 12,
	no_energy = function(self, t) return not self:isTalentActive(t.id) end,
	mode = "sustained",
	sustain_psi = 10,
	range = 7,
	getSpikeCost = function(self, t) return 20 end,
	spikeTarget = function(self, t) return {type="hit", nolock=true, range=self:getTalentRange(t)} end,
	getAuraCost = function(self, t) return 1.0 end,
	auraRange = function(self, t) return 0 end,
	auraRadius = function(self, t) return 10 end,
	auraTarget = function(self, t)
		return {type="ball", range=t.auraRange(self, t), radius=t.auraRadius(self, t), selffire=false, friendlyfire=false}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5.6)) end,
	getImmunityDuration = function(self, t) return 15 end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	callbackOnAct = function(self, t)
		local tg = t.auraTarget(self, t)
		local dur = t.getDuration(self, t)
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
					act:setEffect(act.EFF_REK_GLR_DAZE, dur, {immunity=durImm, src=self, apply_power=self:combatMindpower()})
				end
			end)
	end,
	deactivate = function(self, t, p)
		--self:removeParticles(p.particle)

		local cost = t.getSpikeCost(self, t)
		if self:getPsi() <= cost and not self:attr("force_talent_ignore_ressources") then
			game.logPlayer(self, "The aura dissipates without producing a spike.")
			return true
		end

		local tg = t.spikeTarget(self, t)
		local x, y = self:getTarget(tg)
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
		if not actor then return end		
		local missing = (actor.max_life - actor.life) / actor.max_life
		actor.energy.value = actor.energy.value - game.energy_to_act * (missing / 0.2)
		incPsi2(self, -cost)
		return true
	end,
	info = function(self, t)
		return ([[

While Active: Each turn, enemies within range 10 will be Dazed (#SLATE#Mindpower vs Mind#LAST#) for %d turns.  Once they recover from the daze, they are immune for %d turns.  If any targets are dazed, this costs #4080ff#1 Psi#LAST#.

Deactivate: focus your presence to overwhelm a single creature, causing it to lose 1 turn for every 20%% of its life it was missing.
Costs #4080ff#%d psi#LAST#
Uses Mind Speed

#{italic}#All who look upon you lose the will to fight.#{normal}#]]):
		format(t.getDuration(self, t), t.getImmunityDuration(self, t), t.getSpikeCost(self, t))
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
				return self:knowTalent(self.T_GLR_IDOL_TERRIFIC) or self.level >= numIdolAurasKnown(self)*4
	    end
			},
	},
	points = 5,
	cooldown = 16,
	no_energy = function(self, t) return not self:isTalentActive(t.id) end,
	mode = "sustained",
	sustain_psi = 10,
	range = 4,
	getSpikeCost = function(self, t) return 12 end,
	getAuraCost = function(self, t) return 1.0 end,
	spikeTarget = function(self, t) return {type="hit", nolock=true, range=self:getTalentRange(t)} end,
	auraRange = function(self, t) return 0 end,
	auraRadius = function(self, t) return 4 end,
	auraTarget = function(self, t)
		return {type="ball", range=t.auraRange(self, t), radius=t.auraRadius(self, t), selffire=false, friendlyfire=false}
	end,
	getDuration = function(self, t) return math.min(5, self:combatTalentScale(t, 1, 4)) end,
	getPower = function(self,t) return self:getTalentLevel(t) * 10 end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	callbackOnAct = function(self, t)
		local tg = t.auraTarget(self, t)
		local dur = 3
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
		--self:removeParticles(p.particle)

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
		local actor = game.level.map(x, y, Map.ACTOR)
		if core.fov.distance(self.x, self.y, x, y) == 0 then return true end
		if not actor then return end
		actor:setEffect(actor.EFF_DELIRIOUS_CONCUSSION, t.getDuration(self, t), {apply_power=self:combatMindpower()})
		incPsi2(self, -cost)
		return true
	end,
	info = function(self, t)
		return ([[

While Active: Enemies within %d have their mental save reduced by %d. (#SLATE#No Save#LAST#)

Deactivate: Focus the terror on a single creature, preventing them from using talents for %d turns.
Costs #4080ff#%d psi#LAST#
Uses Mind Speed

#{italic}#All who approach you are overwhelmed by your presence.#{normal}#]]):format(t.auraRadius(t), t.getPower(self, t), t.getDuration(self, t), t.getSpikeCost(self, t))
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
				return self:knowTalent(self.T_GLR_IDOL_THOUGHT_DRINKER) or self.level >= numIdolAurasKnown(self)*4
	    end
			},
	},
	points = 5,
	mode = "passive",
	auraRange = function(self, t) return 0 end,
	auraRadius = function(self, t) return 4 end,
	auraTarget = function(self, t)
		return {type="ball", range=t.auraRange(self, t), radius=t.auraRadius(self, t), selffire=false, friendlyfire=false}
	end,
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
		game.logPlayer(self, ("DEBUG: %s"):format(death_note))
		if not self:attr("zero_resource_cost") then
			self:incPsi(t.getKillMultiplier(self, t) * t.getPsiRefund(self, t))
		end
		self:setEffect(self.EFF_REK_GLR_QUENCHED_SPEED, 2, {speed=t.getSpeedBoost(self, t), steps=math.ceil(t.getSpeedBoost(self, t)), src=self})
	end,
	info = function(self, t)
		return ([[Each round, you gain %0.2f #4080ff#psi #LAST#for each visible enemy within range %d.
When you kill an enemy, you gain %0.2f #4080ff#psi #LAST#and %d%% movement speed (which lasts 2 turns or %d steps, whichever comes first).

#{italic}#Fighting is challenging.  Challenge is fun.#{normal}#]]):
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
	getThresh = function(self, t) return self:combatTalentLimit(t, 0.10, 0.33, 0.16) end,
	callbackOnTakeDamage = function (self, t, src, x, y, type, dam, tmp, no_martyr)
		local thresh = t.getThresh(self, t) * self.max_life
		--game.logPlayer(self, ("DEBUG: Beloved %d incoming damage"):format(dam))
		if dam >= thresh then
			--game.logPlayer(self, ("DEBUG: Beloved blocking damage"):format(dam))
			local caged = false
			if not self:hasEffect(self.EFF_SLOW_MOVE) then
				self:setEffect(self.EFF_SLOW_MOVE, 5, {power=50, src=self})
				caged = true
			elseif not self:hasEffect(self.EFF_PINNED) then
				self:setEffect(self.EFF_PINNED, 4, {src=self})
				caged = true
			else
				self:setEffect(self.EFF_STUNNED, 3, {src=self})
				caged = true
			end
			if caged then
				return {stopped=0}
			end
		end

		return {dam=dam}
	end,
	callbackOnDeath = function(self, t, src, death_note)
		death_note.special_death_msg = ("was taken captive by %s and never seen again"):format(src.name or "someone")
	end,
	-- onHit is late
	-- callbackOnHit = function(self, t, cb, src, death_note)
	-- 	game.logPlayer(self, "DEBUG: - onHit.")
	-- end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local particle = Particles.new("ultrashield", 1, {rm=204, rM=220, gm=102, gM=120, bm=0, bM=0, am=15, aM=60, radius=0.5, density=10, life=28, instop=100})
		return {
			particle = self:addParticles(particle)
					 }
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[If you would take damage over %d%% of your maximum life, instead your movement is slowed by 50%% for 5 turns.
If you are already slowed, you will be pinned for 4 turns.
If you are already pinned, you will be stunned for 3 turns.

These effects ignore immunities and saves.

#{italic}#No one would really hurt you, not on purpose.  But they would try to control you.#{normal}#]]):format(t.getThresh(self, t)*100)
	end,
}