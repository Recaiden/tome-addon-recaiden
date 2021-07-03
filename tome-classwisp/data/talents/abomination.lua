newTalent{
	name = "Telekinetic Supremacy", short_name = "REK_GLR_ABOMINATION_SUPREMACY",
	type = {"psionic/unleash-abomination", 1},
	require = {
		stat = { wil=function(level) return 22 + (level-1) * 2 end },
		level = function(level) return 10 + (level-1)  end,
		special={
			desc="No other Unleash tree",
			fct=function(self)
				return not (self:knowTalentType("psionic/unleash-nightmare") == true)
			end
		}
	},
	points = 5,
	cooldown = 18,
	no_energy = true,
	mode = "sustained",
	on_learn = function(self, t)
		local level = self:getTalentLevelRaw(t)
		if level == 1 then
			self:unlearnTalentType("psionic/unleash-nightmare")
			self.talents_types["psionic/unleash-nightmare"] = nil
		end
	end,
	on_unlearn = function(self, t)
		local level = self:getTalentLevelRaw(t)
		if level == 0 then
			self:learnTalentType("psionic/unleash-nightmare", false)
		end
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.6) end,
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.5, 1.5) end,
	callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam, talent)
		if talent == t then return end
		if talent == self.T_REK_GLR_ARROWSTORM_KALMANKA then return end
		local old_target_forced = game.target.forced
		game.target.forced = {target.x, target.y, target}
		local targets = self:archeryAcquireTargets({type = "hit"}, {one_shot=true, no_energy = true})
		if targets then --this mostly checks that we still have ammo
			self:attr("instant_shot", 1)
			self:archeryShoot(targets, t, {type = "bolt", start_x=target.x, start_y=target.y}, {mult=mult*t.getDamage(self, t) / (self.__global_accuracy_damage_bonus or 1), glr_pinpoint=true})
			self:attr("instant_shot", -1)
		end
		game.target.forced = old_target_forced
	end,
	callbackOnActBase = function(self, t)
		if self.psi < self.max_psi * self.rek_glr_unleash_timer / 20 then self:forceUseTalent(self.T_REK_GLR_ABOMINATION_SUPREMACY, {ignore_energy=true}) return end
		self:incPsi(self.max_psi * self.rek_glr_unleash_timer / -20)
		self.rek_glr_unleash_timer = self.rek_glr_unleash_timer + 1
	end,
	activate = function(self, t)
		self.rek_glr_unleash_timer = 1
		--TODO particle
		local ret  = {}
		self:talentTemporaryValue(ret, "movement_speed", t.getSpeed(self, t))
		self:talentTemporaryValue(ret, "pin_immune", 1)
		self:talentTemporaryValue(ret, "levitation", 1)
		self:talentTemporaryValue(ret, "avoid_pressure_traps", 1)
		return ret
	end,
	deactivate = function(self, t, p)
		self.rek_glr_unleash_timer = nil
		return true
	end,
	info = function(self, t)
		return ([[Surround yourself with a powerful nimbus of telekinetic energy.  Your movement speed is increased by %d%%, you gain %d%% pinning immunity, you can't trigger pressure traps, and whenever you shoot an arrow you shoot another arrow for %d%% damage.
Mindpower: improves	movement speed

This talent is difficult to maintain, draining 5%% of your maximum psi per turn (+100%% per turn). For example, on turn 2 it will drain 10%%, on turn 3 it will drain 15%%.

#{italic}#Your psionic core constantly roils with suppressed energy.  If you undid some mental safeguards, you could draw more power...#{normal}#

#YELLOW#You can only learn 1 Unleash tree.#LAST#]]):
		format(t.getSpeed(self, t)*100, 100, t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Shard Shot", short_name = "REK_GLR_ABOMINATION_SHARD_SHOT",
	type = {"psionic/unleash-abomination", 2},
	require = wil_req_high2,
	points = 5,
	cooldown = 12,
	range = 1,
	is_melee = true,
	psi = 15,
	tactical = { ATTACK = 2, RESOURCE = 2 },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getCount = function (self, t) return 1 + math.floor(self:combatTalentLimit(t, 4, 1, 2.5)) end,
	getConversionDamage = function (self, t) return self:combatTalentWeaponDamage(t, 0.30, 0.65) end,
	getAmmo = function (self, t) return math.ceil(self:combatTalentScale(t, 3, 8)) end,
	getReadySpeed = function (self, t) return self:combatTalentMindDamage(t, 0.10, 0.45) end,
	--on_pre_use = function(self, t, silent) return archerPreUse(self, t, silent, "bow") end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("bow") then if not silent then game.logPlayer(self, "You require a bow for this talent.") end return false end return true end,

	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		-- damaging arrow transmutation
		local old_target_forced = game.target.forced
		for i = 1, t.getCount(self, t) do
			game.target.forced = {target.x, target.y, target}
			local targets = self:archeryAcquireTargets({type = "hit"}, {infinite=true, one_shot=true, no_energy = true})
			self:archeryShoot(targets, t, {type = "bolt", start_x=sx, start_y=sy}, {mult=t.getConversionDamage(self, t)})
		end
		game.target.forced = old_target_forced

		-- 'reload' the transmuted shots
		local ammo, err = self:hasAmmo()
		if ammo then 
			ammo.combat.shots_left = math.min(ammo.combat.capacity, ammo.combat.shots_left + t.getAmmo(self, t))
		end

		-- go fast
		self:setEffect(self.EFF_REK_GLR_SHARDS_READY, 2, {power=t.getReadySpeed(self, t), src=self})
		
		return true
	end,
	info = function(self, t)
		return ([[Transmute part of an adjacent target's body into arrows and ready them for shooting.  The target is hit %d times for %d%% damage, you regain %d ammo, and your combat speed is increased by %d%% for 2 turns.]]):format(t.getCount(self, t), t.getConversionDamage(self, t)*100, t.getAmmo(self, t), t.getReadySpeed(self, t)*100)
	end,
}

newTalent{
	name = "Telepathic Aim", short_name = "REK_GLR_ABOMINATION_AIM",
	type = {"psionic/unleash-abomination", 3},
	require = wil_req_high3,
	points = 5,
	mode = "passive",
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.0, 0.6) end,
	getChance = function(self, t) return math.floor(self:combatTalentLimit(t, 40, 10, 30)) end,
	getReduction = function(self, t) return math.min(0.75, self:combatTalentScale(t, 0.20, 0.50)) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp)
		if not src.__is_actor then return end
		if src.turn_procs and src.turn_procs.rek_glr_telepathic_aim then return end
		if not rng.percent(t.getChance(self, t)) then return end
		
		-- shoot them
		local old_target_forced = game.target.forced
		game.target.forced = {src.x, src.y, src}
		local targets = self:archeryAcquireTargets({type = "hit", speed = 200}, {infinite=true, one_shot=true, no_energy = true})
		if not targets then
			game.target.forced = old_target_forced
			return {dam=dam}
		end
		
		game.logSeen(src, "%s is interrupted by a telepathically aimed shot!", src.name:capitalize())
		src.turn_procs = src.turn_procs or {}
		src.turn_procs.rek_glr_telepathic_aim = true
		dam = dam * (1 - t.getReduction(self, t))
		local shot_params_base = {mult = t.getDamage(self, t), phasing = true}
		local params = table.clone(shot_params_base)
		local target = targets.dual and targets.main[1] or targets[1]
		params.phase_target = game.level.map(target.x, target.y, game.level.map.ACTOR)
		self:attr("instant_shot", 1)
		self:archeryShoot(targets, t, {type = "hit", speed = 200}, params)
		self:attr("instant_shot", -1)
		game.target.forced = old_target_forced
		return {dam=dam}
	end,

	info = function(self, t)
		return ([[Reading an enemy's subtle impulses, you know when they're going to strike before  they do, and can interrupt the attack with a well-timed arrow.  When you would be damaged by an enemy, there is a %d%% chance that they are instantly struck by an arrow that you already fired, doing %d%% damage and reducing their damage to you by %d%%.
This can only happen once per enemy per turn.]]):format(t.getChance(self, t), t.getDamage(self, t)*100, t.getReduction(self, t)*100)
	end,
}

newTalent{
	name = "Black Arrow", short_name = "REK_GLR_ABOMINATION_SHOT",
	type = {"psionic/unleash-abomination", 4},
	require = wil_req_high4,
	points = 5,
	speed = "archery",
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	psi = 15,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 0.5 } },
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.3) end,
	getEffDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.25, 0.5) end,
	on_pre_use = function(self, t, silent) return archerPreUse(self, t, silent, "bow") end,
	target = function(self, t) return {type = "hit", range = self:getTalentRange(t), talent = t } end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return end
		
		local target = game.level.map(x, y, game.level.map.ACTOR)
		if not target then return nil end
		
		local countEff = 0
		for eff_id, p in pairs(target.tmp) do 
			local e = target.tempeffect_def[eff_id]
			if e.status == "detrimental" and target.save_for_effects[e.type] then
				countEff = countEff + 1
			end
		end
		
		local targets = self:archeryAcquireTargets(tg, {one_shot=true, x=target.x, y=target.y})
		if not targets then return end
		
		local dam = t.getDamage(self,t) + t.getEffDamage(self, t)*countEff
		self:archeryShoot(targets, t, nil, {mult=dam})
		return true
		end,
	info = function(self, t)
		return ([[Focus on an enemy, discern their weak points, and fire an arrow perfectly aimed and guided to exploit them. This shot does %d%% damage, plus %d%% for each detrimental effect the target had when the arrow was fired.]]):format(t.getDamage(self, t) * 100, t.getEffDamage(self, t) * 100)
	end,
}
