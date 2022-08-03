newTalent{
	name = "Eternal Flame", short_name = "REK_IMP_ETERNAL_FLAME",
	type = {"corruption/imp-claws", 1}, require = { stat = { mag=function(level) return 10 + level * 6 end }, }, points = 5,
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
		return ([[You have melded your hands with the everburning stone of the fearscape, gaining an endless supply of magical destructive potential, but becoming permanently unable to wield items in those hands.
		
Increases unarmed Physical Power by %d (increases with character level), and increases all unarmed damage by %d%%.
Additionally, your hand gear will use 60%% Dexterity and 60%% Magic as base damage modifiers.
You naturally gain 0.5 Physical Power per character level and attack 20%% faster while unarmed.]]):format(damage, 100*inc)
	end,
}

newTalent{
	name = "Flame Thrower", short_name = "REK_IMP_THROW",
	type = {"corruption/imp-claws", 2}, require = racial_req2, points = 5,
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
	name = "Cinder Power", short_name = "REK_IMP_FLAME_FRENZY",
	type = {"corruption/imp-claws", 3}, require = racial_req3,	points = 5,
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
	name = "Daelach Hross", short_name = "REK_IMP_DANCING_FLAME",
	type = {"corruption/imp-claws", 4}, require = racial_req4, points = 5,
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
