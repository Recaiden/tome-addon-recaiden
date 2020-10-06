newTalent{
	name = "Glass Wings", short_name = "REK_GLR_MATERIAL_WINGS",
	type = {"psionic/mindshaped-material", 1},
	require = wil_req1,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentScale(t, 24, 12)) end,
	mode = "passive",
	getResist = function(self, t) return self:combatTalentMindDamage(t, 20, 50) end,
	getArmor = function(self, t) return self:combatTalentMindDamage(t, 5, 45) end,
	getHP = function(self, t) return self:combatTalentMindDamage(t, 10, 1000) end,
	target = function(self, t) return {type="ball", nowarning=true, radius=3, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t} end,
	callbackOnTakeDamage = function (self, t, src, x, y, type, dam, tmp, no_martyr)
		if not src then return end
		if not src.x then return end
		if src == self then return end
		if src.summoner and src.summoner == self then return end
		if self:isTalentCoolingDown(t) then return end
		if not rng.percent(10) then return end
		if t.callGuardian(self, t, src) then self:startTalentCooldown(t) end
	end,
	info = function(self, t)
		return ([[Something is watching over you.  When damaged, there is a 10%% chance that a psionic guardian will appear to distract your enemies.  The guardian lasts for 3 turns and does no damage but constantly taunts enemies within 2 spaces to attack it.
The guardian has %d life (increased by mental critical), %d armor, and %d%% resistance to all damage.
Mindpower: improves	damage, life, resists, and armor]]):
		format(t.getHP(self, t), t.getArmor(self, t), t.getResist(self, t))
	end,
}

newTalent{
	name = "Silken Armor", short_name = "REK_GLR_MATERIAL_ARMOR",
	type = {"psionic/mindshaped-material", 2},
	require = wil_req2,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	tactical = { BUFF = 2 },
	getCost = function(self, t) return 3 end,
	getReduction = function(self, t) return self:combatTalentMindDamage(t, 25, 230) + self.level end,
	callbackOnHit = function(self, t, cb, src, death_note)
		if not self:hasLightArmor() then return end
		if self:getPsi() < self:getMaxPsi() / 2 then return end
		local dam = cb.value
		local cost = t.getCost(self, t)
		if dam < t.getReduction(self, t) then cost = cost * dam / t.getReduction(self, t) end
		if self:getPsi() < cost then return end -- in case max psi is really tiny?
		
		if dam > 0 and state and not self:attr("invulnerable") then					
			local reduce = math.min(t.getReduction(self, t), dam)
			dam = dam - reduce
			local d_color = DamageType:get(type).text_color or "#4080ff#"
			game:delayedLogDamage(src, self, 0, ("%s(%d to silken armor)"):format(d_color, reduce, stam_txt, d_color), false)
			cb.value = dam
			self:incPsi(-1 * cost)
		end
		return cb
	end,
	activate = function(self, t)
		--TODO particle
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Rearrange the fibers of your armor into a psionically conductive matrix that protect you from harm. Incoming damage will be reduced by %d, costing up to #4080ff#%d psi#LAST# per hit.
This only takes effect while wearing light or cloth armor and while your psi pool over 50%% full.
Mindpower: increases damage reduction.
]]):format(t.getReduction(self, t), t.getCost(self, t))
	end,
}

newTalent{
	name = "Thread Wall", short_name = "REK_GLR_MATERIAL_WALL",
	type = {"psionic/mindshaped-material", 3},
	require = wil_req3,
	points = 5,
	cooldown = 10,
	psi = 5,
	range = 3,
	requires_target = true,
	tactical = { ATTACKAREA = { MIND = 1.5 } },
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 320)
	end,
	getSpreadFactor = function(self, t) return self:combatTalentLimit(t, .95, .75, .85) end,
	getBaseDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	getInvisibilityPower = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRange(t), range=0, friendlyfire=false} end,
	action = function(self, t)
		local tg, targets = self:getTalentTarget(t), {}

		self:project(tg, self.x, self.y, function(px, py, t)
			local target = game.level.map(px, py, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					targets[#targets + 1] = target
				end
			
			end, 0)
		if #targets == 0 then return false end

		local spreadFactor = t.getSpreadFactor(self, t)^(#targets - 1)
		local damage = self:mindCrit(t.getDamage(self, t)) * spreadFactor

		for i, t2 in ipairs(table.shuffle(targets)) do
			self:project({type="hit", talent=t, x=t2.x,y=t2.y}, t2.x, t2.y, DamageType.MIND, {dam=damage})
			damage = damage
			game.level.map:particleEmitter(t2.x, t2.y, 1, "reproach", { dx = self.x - t2.x, dy = self.y - t2.y })
		end
		local duration = t.getBaseDuration(self, t) - (#targets - 1)
		self:setEffect(self.EFF_INVISIBILITY, duration, {power=t.getInvisibilityPower(self, t), src=self})

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local spreadFactor = t.getSpreadFactor(self, t)
		return ([[In Progress...]]):format(damDesc(self, DamageType.MIND, damage), t.getInvisibilityPower(self, t), t.getBaseDuration(self, t), (1 - spreadFactor) * 100)
	end,
}


newTalent{
	name = "Coccoon", short_name = "REK_GLR_MATERIAL_COCCOON",
	type = {"psionic/mindshaped-material", 4},
	require = wil_req4,
	points = 5,
	cooldown = 12,
	getCount = function(self, t) return math.floor(self:combatTalentMindDamage(t, 2, 5)) end,
	getDuration = function(self, t) return self:combatTalentScale(t, 3, 5) end,
	range = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end		
		target:setEffect(target.EFF_REK_GLR_BRAINSEALED, t.getDuration(self, t), {count=t.getCount(self, t) or 1, src=self, apply_power=self:combatMindpower()})
		return true
	end,
	info = function(self, t)
		return ([[Seal away a target's thoughts (#SLATE#Mindpower vs. Mental#LAST#), reducing them to base instinct.  They will have %d talents put on cooldown and for %d turns be silenced, disarmed, and have talents cooldown at only half speed.]]):format(t.getCount(self, t), t.getDuration(self, t))
	end,
}