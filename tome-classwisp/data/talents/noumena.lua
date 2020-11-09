newTalent{
	name = "Unseen Guardian", short_name = "REK_GLR_NOUMENA_UNSEEN_GUARDIAN",
	type = {"psionic/noumena", 1},
	require = wil_req1,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentScale(t, 24, 12)) end,
	mode = "passive",
	getResist = function(self, t) return self:combatTalentMindDamage(t, 20, 50) end,
	getArmor = function(self, t) return self:combatTalentMindDamage(t, 5, 45) end,
	getHP = function(self, t) return self:combatTalentMindDamage(t, 10, 1000) end,
	target = function(self, t) return {type="ball", nowarning=true, radius=3, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t} end,
	callGuardian = function(self, t, target)
		-- Find space
		local x, y = util.findFreeGrid(target.x, target.y, 3, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space for guardian to arrive!")
			return nil
		end
		
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "psionic", subtype = "???",
			display = "*", color=colors.BLUE,
			name = "unseen guardian", faction = self.faction, image = "npc/noumena_guardian.png",
			desc = [[A shapeless force of mental energy, barely visible as a distortion in the air.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented", ai_state = { talent_in=1, },
			level_range = {1, 1}, exp_worth = 0,
			
			max_life = self:mindCrit(t.getHP(self, t)),
			life_rating = 0,
			never_move = 1,
			cant_be_moved = 1,
			
			inc_damage = table.clone(self.inc_damage),
			resists_pen = table.clone(self.resists_pen),

			combat_armor_hardiness = 50,
			combat_armor = t.getArmor(self, t),
			resists = {all = t.getResist(self, t)},

			negative_status_effect_immune = 1,
			
			on_act = function(self)
				local tg = {type="ball", range=0, friendlyfire=false, radius=2}	
				self:project(
					tg, self.x, self.y,
					function(px, py)
						local target = game.level.map(px, py, Map.ACTOR)
						if not target then return end
						
						if self:reactionToward(target) < 0 then
							if self.ai_target then self.ai_target.target = target end
							target:setTarget(self)
						end
					end)
				self.energy.value = 0
			end,

			summoner = self, summoner_gain_exp=true,
			summon_time = 3,
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		m.energy.value = game.energy_to_act * 2
		
		game.zone:addEntity(game.level, m, "actor", x, y)
		return true
	end,
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
	name = "Crystal Flare", short_name = "REK_GLR_NOUMENA_CRYSTAL_FLARE",
	type = {"psionic/noumena", 2},
	require = wil_req2,
	points = 5,
	psi = 18,
	cooldown = 12,
	tactical = { DISABLE = { blind = 2, } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 25, 230) + self.level end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		local crit = self:mindCrit(1.0)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.REK_GLR_CRYSTAL_LIGHT, {dam=t.getDamage(self, t)*crit, dur=math.floor(t.getDuration(self, t)*crit), power=self:combatMindpower()})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_earth", {radius=tg.radius, tx=x-self.x, ty=y-self.y})

		return true
	end,
	info = function(self, t)
		return ([[Create a burst of blinding light in a radius %d cone. Tiles will be lit and all creatures will take %0.2f light damage and be blinded (#SLATE#Mindpower vs Physical#LAST#) for %d turns.
Mindpower: increases damage
Mind Critical: increases blind duration as well as damage]]):format( self:getTalentRadius(t), damDesc(self, DamageType.FIRE, t.getDamage(self, t)), t.getDuration(self,t))
	end,
}

newTalent{
	name = "Esper Cut", short_name = "REK_GLR_NOUMENA_ESPER_CUT",
	type = {"psionic/noumena", 3},
	require = wil_req3,
	points = 5,
	cooldown = 10,
	psi = 5,
	range = 4,
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
		return ([[Erase perceptions of yourself from the minds of nearby enemies, inflicing %0.2f mind damage and rendering you invisible (%d power) for %d turns. Each target after the first will reduce the damage by %d%% and the duration of the invisiblity by 1.  You require an enemy in range to use this talent.
Mindpower: increases damage and invisibility power]]):format(damDesc(self, DamageType.MIND, damage), t.getInvisibilityPower(self, t), t.getBaseDuration(self, t), (1 - spreadFactor) * 100)
	end,
}


newTalent{
	name = "Lockdown", short_name = "REK_GLR_NOUMENA_LOCKDOWN",
	type = {"psionic/noumena", 4},
	require = wil_req4,
	points = 5,
	cooldown = 12,
	getCount = function(self, t) return math.max(1, math.floor(self:combatTalentMindDamage(t, 2, 5))) end,
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
		return ([[Seal away a target's thoughts (#SLATE#Mindpower vs. Mental#LAST#), reducing them to base instinct.  They will have %d talents put on cooldown and for %d turns be silenced, disarmed, and have talents cooldown at only half speed.
Mindpower: increases talents affected.]]):format(t.getCount(self, t), t.getDuration(self, t))
	end,
}