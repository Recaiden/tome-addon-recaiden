local function getMaxResistIncrease(self)
	local combined_TL = self:getTalentLevel(self.T_REK_SHINE_NUCLEAR_SEARING_CORE) + self:getTalentLevel(self.T_REK_SHINE_NUCLEAR_FUEL_ENRICHMENT) + self:getTalentLevel(self.T_REK_SHINE_NUCLEAR_CRITICALITY_EXCURSION) + self:getTalentLevel(self.T_REK_SHINE_NUCLEAR_SUPERCRITICAL)
	local resists = math.round(54 * (combined_TL / 20)^.5)
	return resists
end

local function getResistBlurb(self)
	return ("#GOLD#Working with solar energy improves your ability to survive it, increasing your resistance to Light and Fire Damage based on the combined level of your Inner Power talents (current bonus: %d)#LAST#"):format(getMaxResistIncrease(self))
end


newTalent{
	name = "Searing Core", short_name = "REK_SHINE_NUCLEAR_SEARING_CORE",
	type = {"demented/inner-power", 1},
	require = mag_req1, points = 5,
	mode = "passive",
	getAffinity = function(self, t) return self:combatTalentScale(t, 9, 26, 0.75) end,
	on_learn = function(self, t) self.blood_color = colors.GOLD end,
	passives = function(self, t, p)
		self:talentTemporaryValue(
			p, "damage_affinity", {
				[DamageType.LIGHT] = t.getAffinity(self, t),
				[DamageType.FIRE] = t.getAffinity(self, t)
														})
		self:talentTemporaryValue(
			p, "resists", {
				[DamageType.LIGHT]=getMaxResistIncrease(self),
				[DamageType.FIRE]=getMaxResistIncrease(self)
										})
	end,
	info = function(self, t)
		return ([[All life comes from the sun, and all brightness and warmth is a reminder of this.  You gain %d%% Light and Fire damage affinity.

In addition, when hitting allies, your light and fire penetration do not apply, but you do 10%% less damage.

%s]]):tformat(t.getAffinity(self, t), getResistBlurb(self))
	end,
}

-- 'superload' damage projectors for fire and light
local base_FireProjector = DamageType.dam_def.FIRE.projector
DamageType.dam_def.FIRE.projector = function(src, x, y, type, dam, state)
	if src.__is_actor == nil or not src.knowTalent then
		return base_FireProjector(src, x, y, type, dam, state)
	end
	local target = game.level.map(x, y, Map.ACTOR)
	local pen_old = src:combatGetResistPen(type) or 0
	local penalty = nil
	if src:knowTalent(src.T_REK_SHINE_NUCLEAR_SEARING_CORE) and target and src:reactionToward(target) < 0 then
		dam = dam * 0.9
		penalty = src:addTemporaryValue("resists_pen", {[DamageType.FIRE]= -1 * pen_old})
	end
	local dam_dealt = base_FireProjector(src, x, y, type, dam, state)
	if penalty then
		src:removeTemporaryValue("resists_pen", penalty)
	end
	return dam_dealt 
end

local base_LightProjector = DamageType.dam_def.LIGHT.projector
DamageType.dam_def.LIGHT.projector = function(src, x, y, type, dam, state)
	if src.__is_actor == nil or not src.knowTalent then
		return base_LightProjector(src, x, y, type, dam, state)
	end
	local target = game.level.map(x, y, Map.ACTOR)
	local pen_old = src:combatGetResistPen(type) or 0
	local penalty = nil
	if src:knowTalent(src.T_REK_SHINE_NUCLEAR_SEARING_CORE) and target and src:reactionToward(target) < 0 then
		dam = dam * 0.9
		penalty = src:addTemporaryValue("resists_pen", {[DamageType.LIGHT]= -1 * pen_old})
	end
	local dam_dealt = base_LightProjector(src, x, y, type, dam, state)
	if penalty then
		src:removeTemporaryValue("resists_pen", penalty)
	end
	return dam_dealt 
end

newTalent{
	name = "Fuel Enrichment", short_name = "REK_SHINE_NUCLEAR_FUEL_ENRICHMENT",
	type = {"demented/inner-power", 2},
	require = mag_req2, points = 5,

	on_learn = function(self, t)
		self:updateTalentPassives(self:getTalentFromId(self.T_REK_SHINE_NUCLEAR_SEARING_CORE))
	end,
	on_unlearn = function(self, t)
		self:updateTalentPassives(self:getTalentFromId(self.T_REK_SHINE_NUCLEAR_SEARING_CORE))
	end,
	
	mode = "passive",
	getChance = function(self, t) return math.floor(self:combatTalentScale(t, 4.4, 9)) end,
	getDuration = function(self, t) return 5 end,
	passives = function(self, t, p)
		local crit = self:combatSpellCrit()
		local eff = self:hasEffect(self.EFF_REK_SHINE_ENRICHMENT)
		if eff then crit = crit - eff.power end
		if crit >= 40 then
			local boost = (crit-40) / 2
			self:talentTemporaryValue(p, "combat_critical_power", boost)
		end
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_CUN or stat == self.STAT_LCK then self:updateTalentPassives(t) end
	end,
	callbackOnWear = function(self, t, o, fBypass) self:updateTalentPassives(t) end,
	callbackOnTakeoff = function(self, t, o, fBypass) self:updateTalentPassives(t) end,
	-- triggered in Combat.lua:spellCrit superload
	critFailed = function(self, t)
		self:setEffect(self.EFF_REK_SHINE_ENRICHMENT, t.getDuration(self,t), {power=t.getChance(self, t), src=self})
	end,
	callbackOnStatChange = function(self, t, stat, v)	self:updateTalentPassives(t) end,
	callbackOnWear = function(self, t, o, bypass_set) self:updateTalentPassives(t) end,
	callbackOnTakeoff = function(self, t, o, bypass_set)	self:updateTalentPassives(t) end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Whenever one of your spells fails to be a critical hit, you gain a stack of Enrichment (up to 5 stacks) for %d turns, which increases your spell critical strike chance by +%d%%.
If your unenriched spell critical rate is over 40%%, you passively gain 1%% critical power for every 2%% extra critical rate.

%s]]):tformat(t.getDuration(self, t), t.getChance(self, t), getResistBlurb(self))
	end,
}

newTalent{
	name = "Criticality Excursion", short_name = "REK_SHINE_NUCLEAR_CRITICALITY_EXCURSION",
	type = {"demented/inner-power", 3},
	require = mag_req3, points = 5,
	
	on_learn = function(self, t)
		self:updateTalentPassives(self:getTalentFromId(self.T_REK_SHINE_NUCLEAR_SEARING_CORE))
	end,
	on_unlearn = function(self, t)
		self:updateTalentPassives(self:getTalentFromId(self.T_REK_SHINE_NUCLEAR_SEARING_CORE))
	end,
	
	mode = "sustained",
	cooldown = 20,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getCost = function(self, t) return 3 end,
	getDamage = function(self,t) return self:combatTalentSpellDamage(t, 20, 60) end,
	getDisease = function(self,t) return math.floor(self:combatTalentSpellDamage(t, 20, 7)) end,
	getDuration = function(self,t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	callbackOnCrit = function(self, t, type, dam, chance, target)
		if type ~= "spell" then return end
		if self:hasProc("shining_excursion_field") then return end
		if self:getInsanity() < t.getCost(self, t) and not self:attr("force_talent_ignore_ressources") then return end
		self:setProc("shining_excursion_field", true, 1)
		if not self:attr("zero_resource_cost") then self:incInsanity(-1*t.getCost(self, t)) end
		local dam = t.getDamage(self, t) * (1.25 + (self.combat_critical_power or 0) / 200)
		game.level.map:addEffect(
			self, self.x, self.y,
			t.getDuration(self, t),
			DamageType.REK_SHINE_LIGHT_WEAK, {dam=dam, power=t.getDisease(self, t)},
			self:getTalentRange(t),
			5, nil,
			MapEffect.new{color_br=187, color_bg=132, color_bb=10, alpha=100, effect_shader="shader_images/radiation_effect.png"},
			nil, self:spellFriendlyFire()
			)
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Whenever one of your spells is a critical hit, the surging energy overflows your body, creating a radiant field in radius %d for %d turns.  This field does %0.2f light damage per turn and weakens enemies, reducing their strength and dexterity by %d.  The weakness from multiple different radiant fields can stack, up to 10 times.
The field damage cannot trigger a critical hit but is increased by half your critical power.

This costs #INSANE_GREEN#%d insanity#LAST# when it triggers and will only trigger if you have enough insanity.

%s]]):tformat(self:getTalentRange(t), t.getDuration(self, t), damDesc(self, DamageType.LIGHT, t.getDamage(self, t)), t.getDisease(self, t), t.getCost(self, t), getResistBlurb(self))
	end,
}

newTalent{
	name = "Supercritical", short_name = "REK_SHINE_NUCLEAR_SUPERCRITICAL",
	type = {"demented/inner-power", 4},	require = mag_req4,	points = 5,

	on_learn = function(self, t)
		self:updateTalentPassives(self:getTalentFromId(self.T_REK_SHINE_NUCLEAR_SEARING_CORE))
	end,
	on_unlearn = function(self, t)
		self:updateTalentPassives(self:getTalentFromId(self.T_REK_SHINE_NUCLEAR_SEARING_CORE))
	end,
	
	mode = "passive",
	getSurge = function(self, t) return self:combatTalentScale(t, 4, 12, 1.0) end,
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.22, 0.55) end,
	getEvasion = function(self, t) return self:combatTalentLimit(t, 25, 5, 15) end,
	getPrice = function(self, t) return self:getTalentLevelRaw(t) / 2 end,
	callbackOnCrit = function(self, t, type, dam, chance, target)
		if type ~= "spell" then return end
		if self:hasProc("shining_supercritical") then return end
		self:setProc("shining_supercritical", true, 1)

		local price = t.getPrice(self, t)
		game:delayedLogDamage(self, self, 0, ("#GOLD#%d#LAST#"):tformat(self.max_life * price / 100), false)
		self:takeHit(self.max_life * price / 100, self, {special_death_msg=_t"was consumed by solar fire"})
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "spellsurge_on_crit", t.getSurge(self, t))
		self:talentTemporaryValue(p, "cancel_damage_chance", t.getEvasion(self, t))
	end,
	info = function(self, t)
		return ([[Your spells surge in barely-controlled chain reactions, burning through your mortal body with unstoppable force.  You gain %d spellpower on crit (stacks 3 times) and have a %d%% chance to ignore any instance of damage, but spell criticals burn up %0.1f%% of your life (at most once per turn). This loss of life bypasses shields and is not split with your reflections.

%s]]):tformat(t.getSurge(self, t), t.getEvasion(self, t), t.getPrice(self, t), getResistBlurb(self))
	end,
}
