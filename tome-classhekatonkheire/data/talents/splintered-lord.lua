newTalent{
	name = "Thirsty Teeth", short_name = "REK_HEKA_SPLINTER_TEETH",
	type = {"technique/splintered-lord", 1}, require = str_req_high1, points = 5,
	mode = "sustained",
	cooldown = 10,
	tactical = { BUFF = 2 },
	getDamage = function(self, t) return 7 + self:combatSpellpower(0.092) * self:combatTalentScale(t, 1, 7) end,
	getPanicMult = function(self, t) return self:combatTalentScale(t, 2, 3) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if not hitted then return end
		local tg = {type="ball", range = 10, radius=0, selffire = false, friendlyfire = false}
		local damtype = DamageType.PHYSICAL
		local damage = t.getDamage(self, t) * mult
		local ichor = mult
		if self.life < self.max_life then
			damage = damage * t.getPanicMult(self, t)
			ichor = ichor * t.getPanicMult(self, t)
		end
		if crit then
			damage = damage * (1.5 (self.combat_critical_power or 0) / 100)
			ichor = ichor * (1.5 (self.combat_critical_power or 0) / 100)
		end
		self:setEffect(self.EFF_REK_HEKA_ICHOR, 5, {stacks=ichor, src=self})
		self:project(tg, target.x, target.y, damtype, damage)
	end,
	info = function(self, t)
		return ([[Your strikes briefly crack the boundaries between places, letting you slip in the tiny parts of yourself for just a moment: your teeth.

Weapon attacks dealing an additional %0.1f physical damage, increased by %d%% if you are missing any life at all, and giving you Flow based on the damage.
Spellpower: increases damage.
Critical hits: increase damage.

Flow increases your physical power by 5 per stack.]]):tformat(damDesc(self, DamageType.PHYSICAL, t:_getDamage(self)), t:_getPanicMult(self)*100)
	end,
}

newTalent{
	name = "Diffuse Anatomy", short_name = "REK_HEKA_SPLINTER_ORGANS",
	type = {"technique/splintered-lord", 2},	require = str_req_high2, points = 5,
	mode = "passive",
	critResist = function(self, t) return self:combatTalentScale(t, 15, 50, 0.75) end,
	immunities = function(self, t) return self:combatTalentLimit(t, 1, 0.20, 0.55) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "ignore_direct_crits", t.critResist(self, t))
	end,
	info = function(self, t)
		return ([[Now that your vital organs have no need to be connected in normal space, you can hide them away from harm.

You take %d%% less damage from direct critical hits.
Flow also increases your life regeneration by 2.5 per stack.]]):tformat(t.critResist(self, t), 100*t.immunities(self, t))
	end,
}

newTalent{
	name = "Divided Arms", short_name = "REK_HEKA_SPLINTER_ARMS",
	type = {"technique/splintered-lord", 3}, require = str_req_high3, points = 5,
	speed = "weapon",
	hands = 30,
	tactical = { ATTACK = { weapon = 1 }, },
	cooldown = 25,
	range = 6,
	radius = function (self, t) return 1 end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, nowarning=true} end,
	getDuration = function(self, t) return 12 end,
	getAttacks = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		
		local map_eff = game.level.map:addEffect(
			self, x, y, duration, DamageType.REK_SHINE_MIRROR, 
			{dam = self:getShieldAmount(self:spellCrit(t.getAbsorb(self, t))), radius=radius, self=self, talent = t}, 
			radius, 5, nil, 
			--{type="warning_ring", args = {r=220, g=220, b=220, nb=120, size=3, radius=radius}},
			MapEffect.new{color_br=233, color_bg=233, color_bb=233, alpha=180, effect_shader="shader_images/radiation_effect.png"},
			function(e, update_shape_only) end)
		map_eff.name = t.name
		return true
	end,
	info = function(self, t)
		local dur = t.getDur(self, t)
		local timer = math.floor(dur / t.getAttacks(self, t))
		return ([[Your body parts no longer need to stay together; send a few arms out to attack distant enemies.
Every %d turns for the next %d turns, all enemies in the targeted area will be attacked for %d%% damage.
Flow also increases your Defense by 5 per stack.]]):tformat(timer, dur, t.getDamage(self, t))
	end,
}

newTalent{
	name = "Corporeal Disassembly", short_name = "REK_HEKA_SPLINTER_ATTACK",
	type = {"technique/splintered-lord", 4}, require = str_req_high4, points = 5,
	speed = "weapon",
	hands = 25,
	tactical = { ATTACK = { weapon = 2}, DISABLE = 1 },
	cooldown = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentScale(t, 1.0, 1.0) end,
	getDuration = function(self, t) return self:combatTalentScale(t, 3, 6) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local flow = 1
		local eff = self:hasEffect(self.EFF_REK_HEKA_ICHOR)
		if eff then flow = eff.stacks end
		
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit then
			target:setEffect(target.EFF_CRIPPLE, t.getDuration(self, t), {speed=0.1*flow, apply_power=self:combatAttack()})
		end

		game:onTickEnd(function()
										 if self:hasEffect(self.EFF_REK_HEKA_ICHOR) then
											 self:removeEffect(self.EFF_REK_HEKA_ICHOR)
										 end
									 end)

		return true
	end,
	info = function(self, t)
		return ([[Separate an enemy into many parts, just like you!
Of course, for them it is rather more dangerous.

Spend all of your Flow to make an attackthat does %d%% damage and cripples (#SLATE#Accuracy vs Physical#LAST#) the target for %d turns.  The cripple is more intense for each stack of Flow.
Flow also increases your Accuracy by 5 per stack.]]):tformat(t.getDamage(self, t)*100, t.getDuration(self, t)*100)
	end,
}

