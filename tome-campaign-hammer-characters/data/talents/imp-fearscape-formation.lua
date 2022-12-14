newTalent{
	name = "Blazing Ground", short_name = "REK_IMP_FORMATION_BLAZING_GROUND",
	type = {"corruption/fearscape-formation", 1}, require = { stat = { mag=function(level) return 10 + level * 6 end }, }, points = 5,
	mode = "passive",
	is_unarmed  = true,
	no_unlearn_last = true,
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	on_learn = function(self, t, level)
		local oldCanWear = self.canWearObjectCustom
		self.canWearObjectCustom = function(self, o, try_slot)
			if try_slot == "MAINHAND" or try_slot == "OFFHAND" then return _t"No usable hands!" end
			if oldCanWear then return oldCanWear(self, o, try_slot) end
		end
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[When you damage an enemy, you have a %d%% chance to create a patch of Blazing Ground near them for %d turns.  Blazing Ground decreases the effective defense of enemies and increases that of allies by %d.]]):format(damage, 100*inc, 5)
	end,
}

--todo have darkfire's target routine save the target, then create a shadow projectile after it's posted if that value is set

newTalent{
	name = "Erupting Flames", short_name = "REK_IMP_FORMATION_ERUPTING_FLAMES",
	type = {"corruption/fearscape-formation", 2}, require = racial_req2, points = 5,
	innate = true,
	cooldown = 0,
	tactical = { ATTACK = 1 },
	range = 10,
	requires_target = true,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t)} end,
	getDamage = function(self, t) return 10 + self:combatTalentSpellDamage(t, 10, 70) end,
	proj_speed = 4,
	speed = "weapon",
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "melee_project", {[DamageType.FIRE] = t.getDamage(self, t)})
	end,
	throw = function(self, x, y)
		local tg = {
			speed = 4, type="bolt", range=10, selffire=false, friendlyfire=false, friendlyblock=false,
			display={particle="bolt_fire", trail="firetrail"}
		}
		local proj = self:projectile(
			tg, x, y,
			function(px, py, tg, self)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if target and target ~= self then
					-- if not self:getInven("HANDS") then return end
					-- local weaponGlove = table.clone(self:getInven("HANDS")[1])
					-- if not weaponGlove or not weaponGlove.combat then return end
					-- local combat = table.clone(weaponGlove.combat)
					local combat = table.clone(self:getObjectCombat(nil, "barehand"))
					local multiplier = 1
					local dam = self:callTalent(self.T_REK_IMP_ETERNAL_FLAME, "getPercentInc")
					local power = self:callTalent(self.T_REK_IMP_ETERNAL_FLAME, "getDamage")

					combat.dam = combat.dam * (1 + multiplier)
					local tempPow = self:addTemporaryValue("combat_dam", power)
					local hit = self:attackTargetWith(target, combat, DamageType.FIRE, dam)
					self:removeTemporaryValue("combat_dam", tempPow)
					
					if combat.sound and hit then game:playSoundNear(self, combat.sound)
					elseif combat.sound_miss then game:playSoundNear(self, combat.sound_miss) end
				end
			end)
		return proj
	end,
	action = function(self, t)
		if not self:isUnarmed() then return nil end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then
			game.logPlayer(self, "The target is out of range")
			return
		end

		t.throw(self, x, y)

		return true
	end,
	info = function(self, t)
		return ([[Gather flames into a swirling fireball and launch it towards an enemy. This counts as an unarmed attack that deals pure fire damage.  The fireball slows down as it travels.

This talent is innate and always usable, like a basic attack.

Learning this talent passively adds %d fire damage to your attacks.]]):tformat(t.getDamage(self, t))
	end,
}

newTalent{
	name = "Scorched Flesh", short_name = "REK_IMP_FORMATION_SCORCHED_FLESH",
	type = {"corruption/fearscape-formation", 3}, require = racial_req3,	points = 5,
	mode = "passive",
	autolearn_talent = "T_VIM_POOL",
	getDamage = function(self, t) return self:combatTalentScale(t, 0.10, 0.20) end,
	info = function(self, t)
		return ([[You deal more damage as your vim decreases, up to %d%% at 0 vim.

#{italic}#As you burn through your supplies of stolen vim, your flames grow hotter and hotter.#{normal}#]]):tformat(t:_getDamage(self)*100)
	end,
}
class:bindHook("DamageProjector:beforeResists", function(self, hd)
	local src = hd.src
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)
	if not target or not src then return hd end

	if src.knowTalent and src:knowTalent(src.T_REK_IMP_FLAME_FRENZY) then
		local max = (src:maxVim() or 1)
		hd.dam = dam * (1 + ((max - (src:getVim() or 1))/max) * self:callTalent(self.T_REK_IMP_FLAME_FRENZY, "getDamage"))
	end
	return hd
end)

newTalent{
	name = "Pyromancer's Domain", short_name = "REK_IMP_FORMATION_PYRO_DOMAIN",
	type = {"corruption/fearscape-formation", 4}, require = racial_req4, points = 5,
	mode = "passive",
	getFatiguedDefense = function(self, t)
		local def = self:combatDefense(fake)
		local ftg = math.max(0, combatFatigue() - t:_getAllowedFatigue(self))
		return def / ( 1 + ftg / 5)
	end,
	getThresholdDodge = function(self, t) return self:combatTalentScale(t, 20, 45) + self:combatDefense(fake) - 20 end,
	getThresholdHurt = function(self, t) return return self:combatTalentScale(t, 20, 45) + self:combatDefense(fake) + 20 end,
	getMinReduction = function(self, t) return 0.1 end,
	getAllowedFatigue = function(self, t) return self:getTalentLevel(t)	end,
	calcReduction = function(self, t, dam)
		local dodge = t:_getThresholdDodge(self)
		--100% dodged
		if dam >= t:_getThresholdDodge(self) then return dam end
		
		local hurt = t:_getThresholdHurt(self)
		--50% to 100% dodged
		if dam <= hurt then return dam*(1.0 - (dam-dodge)*0.0125) end 

		-- minimum to 50% dodged
		local count = 0
		local amount = dam
		while amount > 40 do
			count = count + 1
			amount = amount / 2
		end
		local base = 0.5 / (2^count)
		return math.max(t:_getMinReduction(self), base) * dam*(1.0 - (dam-dodge)*0.0125)
	end,
	info = function(self, t)
		return ([[You move with the grace of the flame, reducing the damage you take from non-attack sources.  Damage less than %d is completely negated.  Damage over %d is reduced by only %d%%.  These thresholds are improved by defense and decrease sharply if you exceed %d fatigue.]]):format(self:_getThresholdDodge(t), self:_getThresholdHurt(t), self:_getMinReduction(t), self:_getAllowedFatigue(t))
	end,
}
