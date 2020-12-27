newTalent{
	name = "Glow Beam", short_name = "REK_SHINE_GLOW_BEAM",
	type = {"demented/other", 1}, require = mag_req1, points = 5,
	cooldown = 3,
	tactical = { ATTACKAREA = { LIGHT = 2 } },
	range = 10,
	is_beam_spell = true,
	requires_target = true,
	target = function(self, t) return {type="beam",range=self:getTalentRange(t), talent=t, selffire=false, friendlyfire=self:spellFriendlyFire()} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 50, 180) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(t.getDamage(self, t))
		local grids = self:project(tg, x, y, DamageType.LIGHT, dam)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Shine a beam of light that deals %0.2f light damage.
		The damage will increase with your Spellpower.]]):tformat(damDesc(self, DamageType.LIGHT, damage))
	end,
}

newTalent{
	name = "Piercing Light", short_name = "REK_SHINE_PIERCING_LIGHT",
	type = {"demented/other", 1}, require = mag_req1, points = 5,
	cooldown = 10,
	tactical = { ATTACKAREA = { LIGHT = 4 } },
	range = 10,
	is_beam_spell = true,
	requires_target = true,
	target = function(self, t) return {type="beam", force_max_range=true, range=self:getTalentRange(t), talent=t, selffire=false, friendlyfire=self:spellFriendlyFire()} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 50, 240) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(t.getDamage(self, t))
		local grids = self:project(tg, x, y, DamageType.REK_SHINE_LIGHT_SLOW, dam)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Shine a beam of light that deals %0.2f light damage with a 15%% chance to slow and always goes as far as possible.
		The damage will increase with your Spellpower.]]):tformat(damDesc(self, DamageType.LIGHT, damage))
	end,
}

newTalent{
	name = "Stellar Nursery", short_name = "REK_SHINE_CORE_GATE_STELLAR_NURSERY",
	type = {"demented/core-gate", 1},	require = mag_req_high1, points = 5,
	cooldown = 14,
	insanity = -10,
	range = 5,
	tactical = { ATTACKAREA = { LIGHT = 3 } },
	target = function(self, t) return {type="ball", range=0, radius=10, talent=t} end,
	getCount = function(self, t) return 3 end,
	getChance = function(self, t) return 30 end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2.4, 4.8))+1 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 50, 180, self:rescaleCombatStats(self:getMag())) end,
	summon = function(self, t)
		local stat = self:getMag()
		local dur = t.getDuration(self, t)
		local x, y = util.findFreeGrid(self.x, self.y, self:getTalentRange(t), true, {[Map.ACTOR]=true})
		if not x then return nil end
		
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "horror", subtype = "eldritch",
			display = "h", blood_color = colors.GOLD,
			faction = self.faction,
			stats = { stat=dam, stat=dam, stat=dam, stat=dam, stat=dam, stat=dam },
			infravision = 10,
			no_breath = 1,
			fear_immune = 1,
			blind_immune = 1,
			sight = 15,
			infravision = 15,
			name = _t"glowing horror", color=colors.GOLD,
			is_glowing_horror = true,
			desc = _t"A bulbous inhuman shape composed of yellow light.",
			image = "npc/horror_eldritch_glowing_horror.png",
			level_range = {self.level, self.level}, exp_worth = 0,
			rank = 2,
			size_category = 2,
			autolevel = "caster",
			max_life = 100,
			life_rating = 4,
			life_regen = 4,
			movement_speed = 2,
			combat_armor = 16, combat_def = 1,
			combat = { dam=math.floor(5 + self.level/2), atk=self.level*2.2, apr=0, dammod={str=1.1}, physcrit = 10 },
			resists = { [DamageType.FIRE] = 100, [DamageType.LIGHT] = 100 },
			affinity = { [DamageType.FIRE] = 50, [DamageType.LIGHT] = 50 },
			resolvers.talents{
				[Talents.T_REK_SHINE_GLOW_BEAM]=1,			
			},
			resolvers.tmasteries{ ["demented/other"]=self:getTalentMastery(t)-1, },

			ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
			ai_tactic = resolvers.tactic"ranged",
			no_drops = true, keep_inven_on_death = false,
			faction = self.faction,
			summoner = self:resolveSource(), -- Objects can't be summoners for various reasons, so just summon them for the highest source
			summoner_gain_exp=true,
			summon_time = dur,
		}

		if self:knowTalent(self.T_REK_SHINE_CORE_GATE_PROTOSOLAR_RAYS) then
			m[#m+1] = resolvers.talents{
					 [self.T_REK_SHINE_PIERCING_LIGHT]=self:getTalentLevelRaw(self.T_REK_SHINE_CORE_GATE_PROTOSOLAR_RAYS)}
		end
		
		m:resolve()
		m:resolve(nil, true)

		game.zone:addEntity(game.level, m, "actor", x, y)
		if target then m:setTarget(target) end
		
		if game.party:hasMember(self) then
			m.remove_from_party_on_death = true
			game.party:addMember(m, {
				control=false,
				temporary_level = true,
				type="summon",
				title=_t"Summon",
			})
		end
	end,
	action = function(self, t)
		t.summon(self, t)
		t.summon(self, t)
		t.summon(self, t)

		return true
	end,
	callbackOnTalentPost = function(self, t, ab)
		if not self.in_combat then return end
		if not ab.is_spell then return end
		if ab.mode == "sustained" then return end
		if util.getval(ab.no_energy, self, ab) == true then return end
		if rng.percent(t.getChance(self, t)) then
			t.summon(self, t)
		end
	end,
	info = function(self, t)
		return ([[Your light is a beacon in the vastness of existence.  Whenever you cast a spell (that takes a turn) in combat, you have a %d%% chance to summon a Glowing Horror nearby for %d turns.  Glowing horrors attack with a beam of light doing %0.1f damage. The power of the horrors will increase with your Magic.

You can activate this talent to summon %d glowing horrors.]]):tformat(t.getChance(self, t), t.getDuration(self, t), t.getDamage(self, t), t.getCount(self, t)) --no damDesc since they're not you.
	end,
}

newTalent{
	name = "Supernova Shell", short_name = "REK_SHINE_CORE_GATE_SUPERNOVA_SHELL",
	type = {"demented/core-gate", 2}, require = mag_req_high2, points = 5,
	positive = function(self, t)
		local count = 0
		if not game or not game.level then return 0 end
		for uid, act in pairs(game.level.entities) do
			if act.summoner and act.summoner == self and act.is_glowing_horror then
				count = count + 1
			end
		end
		return -5 * count
	end,
	tactical = { DEFEND = 2 },
	cooldown = 10,
	getDuration = function(self, t) return 10 end,
	getAbsorb = function(self, t) return self:combatTalentSpellDamage(t, 0, 220) end,
	on_pre_use = function(self, t, silent)
		if not game or not game.level then return 0 end
		for uid, act in pairs(game.level.entities) do
			if act.summoner and act.summoner == self and act.is_glowing_horror then
				return true
			end
		end
		if not silent then game.logPlayer(self, "You require a glowing horror to consume") end
		return false
	end,
	action = function(self, t)
		local count = 0
		if not game or not game.level then return nil end
		for uid, act in pairs(game.level.entities) do
			if act.summoner and act.summoner == self and act.is_glowing_horror then
				count = count + 1
				act:die(self)
			end
		end
		self:setEffect(self.EFF_DAMAGE_SHIELD, t.getDuration(self, t), {power=self:spellCrit(self:getShieldAmount(t.getAbsorb(self, t)*1.3^count))})
		--give shield
		return true
	end,
	info = function(self, t)
		return ([[Dissolve your assembled glowing horrors and forge them into a shield of celestial energy that blocks at least %d damage over %d turns.  Each glowing horror strengthens the shield by 30%% and gives you 5 positive energy.

The shield power will increase with your Spellpower.]]):tformat(t.getAbsorb(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Protosolar Rays", short_name = "REK_SHINE_CORE_GATE_PROTOSOLAR_RAYS",
	type = {"demented/core-gate", 3},
	require = mag_req_high3, points = 5,
	mode = "passive",
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 50, 240, self:rescaleCombatStats(self:getMag())) end,
	-- implemented in first talent
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Strengthen your glowing horrors with the ability to cast Piercing Light at talent level %d. This is a long-range beam dealing %0.1f damage with a chance to slow enemies by 33%%]]):tformat(self:getTalentLevelRaw(t), t.getDamage(self, t))
	end,
}

newTalent{
	name = "Grave of Suns", short_name = "REK_SHINE_CORE_GATE_GRAVE_OF_SUNS",
	type = {"demented/core-gate", 4},	require = mag_req_high4, points = 5,
	insanity = -15,
	cooldown = 15,
	tactical = { ATTACKAREA = { DARKNESS = 3 } },
	range = 8,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	radius = function (self, t) return 2 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 0, 300) end,
	getProcDamage = function(self, t) return self:combatTalentSpellDamage(t, 4, 30) end,
	getDuration = function(self, t) return 5 end,
	getSlow = function(self, t) return self:combatTalentLimit(t, 75, 20, 66) end,
	getExecute = function(self, t) return 10 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local radius = self:getTalentRadius(t)

		local grids = self:project(tg, x, y, DamageType.REK_SHINE_DARKNESS_HINDER, {dam=t.getDamage(self, t), slow=t.getSlow(self, t)})

		local map_eff = game.level.map:addEffect(
			self, x, y, t.getDuration(self, t), DamageType.REK_SHINE_GRAVE, 
			{dam = {dam=t.getProcDamage(self, t), cap=t.getExecute(self, t)}, radius = radius, self = self, talent = t}, 
			0, 5, nil, 
			{type="warning_ring", args = {radius = radius}},
			function(e, update_shape_only) end)
		map_eff.name = t.name
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Open a tenuous gate to the vast emptiness at the center of everything that lasts for %d turns.  Targets in a radius %d area take %0.1f darkness damage and have their movement slowed by %d%% for 1 turn(#SLATE# no save#LAST#).  When a creature in the affected area takes damage from outside the area, they are doomed for 5 turns.  Each new stack of doom inflicts %0.1f darkness damage per stack.  At %d stacks of doom, creatures with less than 1/3 max life are instantly killed.
The damage will increase with your Spellpower.]]):tformat(t.getDuration(self, t), self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)), t.getSlow(self, t), damDesc(self, DamageType.DARKNESS, t.getProcDamage(self, t)), t.getExecute(self, t))
	end,
}
class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)

	local seff = game.level.map:hasEffectType(src.x, src.y, DamageType.REK_SHINE_GRAVE)
	local deff = game.level.map:hasEffectType(target.x, target.y, DamageType.REK_SHINE_GRAVE)

	if deff and not seff and not target.grave_of_suns_proc then
		target.grave_of_suns_proc = true
		target:setEffect(target.EFF_REK_SHINE_GRAVE_OF_SUNS_DOOM, 5, {pow=deff.dam.dam, stacks=1, max_stacks=deff.dam.cap, src=deff.src})
		target.grave_of_suns_proc = nil
	end
	return hd
end)