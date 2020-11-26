newTalent{
	name = "Stellar Nursery", short_name = "REK_SHINE_CORE_GATE_STELLAR_NURSERY",
	type = {"demented/core-gate", 1},	require = mag_req_high1, points = 5,
	mode = "passive",
	range = 5,
	target = function(self, t) return {type="ball", range=0, radius=self:getTalentRadius(t), talent=t} end,
	getChance = function(self, t) return 30 end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2.4, 4.8)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 300) end,
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
			name = _t"glowing horror", color=colors.CRIMSON,
			desc = _t"A bulbous inhuman shape composed of yellow light.",
			image = "npc/horror_eldritch_glowing_horror.png",
			level_range = {self.summoner.level, self.summoner.level}, exp_worth = 0,
			rank = 2,
			size_category = 2,
			autolevel = "mage",
			max_life = 100,
			life_rating = 4,
			life_regen = 4,
			movement_speed = 2,
			combat_armor = 16, combat_def = 1,
			combat = { dam=math.floor(5 + self.summoner.level/2), atk=self.summoner.level*2.2, apr=0, dammod={str=1.1}, physcrit = 10 },
			resolvers.talents{
				[Talents.T_REK_SHINE_PRISM_CONVERGENCE]=1,			
			},

			ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
			no_drops = true, keep_inven_on_death = false,
			faction = self.faction,
			summoner = self:resolveSource(), -- Objects can't be summoners for various reasons, so just summon them for the highest source
			summoner_gain_exp=true,
			summon_time = dur,
		}

		--TODO if know 3rd talent teach them new talent

		m:resolve()
		m:resolve(nil, true)

		game.zone:addEntity(game.level, m, "actor", x, y)
		if target then m:setTarget(target) end
		
		if game.party:hasMember(self.summoner) then
			m.remove_from_party_on_death = true
			game.party:addMember(m, {
				control=false,
				temporary_level = true,
				type="summon",
				title=_t"Summon",
			})
		end
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
		local delay = t.getDelay(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[Your light is a beacon in the vastness of existence.  Whenever you cast a spell (that takes a turn), you have a %d%% chance to summon a Glowing Horror nearby for %d turns.  Glowing horrors attack with a beam of light doing %d damage. The power of the horrors will ncrease with your Magic.

--You can activate this talent to summon %d glowing horrors.]]):tformat(t.getChance(self, t), t.getDuration(self, t), t.getDamage(self, t)) --no damDesc since they're not you.
	end,
}

newTalent{
	name = "Supernova Shell", short_name = "REK_SHINE_CORE_GATE_SUPERNOVA_SHELL",
	type = {"demented/core-gate", 2}, require = mag_req_high2, points = 5,
	positive = function(self, t)
		local count = 0
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
	getShield = function(self, t) return self:combatTalentSpellDamage(t, 30, 150) end,
	on_pre_use = function(self, t, silent)
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

The shield power will increase with your Spellpower.]]):tformat(t.getShield(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Protosolar Rays", short_name = "REK_SHINE_CORE_GATE_PROTOSOLAR_RAYS",
	type = {"demented/core-gate", 3},
	require = mag_req_high3, points = 5,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	positive = 30,
	no_energy = true,
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 20, 12)) end,
	range = function(self, t) return math.floor(self.lite) end,
	requires_target = true,
	target = function(self, t)	return {type="hit", nolock=true, range=self:getTalentRange(t)} end,
	is_teleport = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then -- To prevent teleporting through walls
			game.logPlayer(self, "You do not have line of sight.")
			return nil
		end
		local _ _, x, y = self:canProject(tg, x, y)
		
		game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		if not self:teleportRandom(x, y, 0) then
			game.logSeen(self, "%s's space-time folding fizzles!", self:getName():capitalize())
		else
			game.logSeen(self, "%s emerges from a space-time rift!", self:getName():capitalize())
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		end
		
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Teleports you to up to %d tiles away, to a targeted location in line of sight.
The range will increase with your Light Radius.]]):tformat(range)
	end,
}

newTalent{
	name = "Grave of Suns", short_name = "REK_SHINE_CORE_GATE_GRAVE_OF_SUNS",
	type = {"demented/core-gate", 4},	require = mag_req_high4, points = 5,
	insanity = 25,
	cooldown = 15,
	tactical = { ATTACKAREA = { DARKNESS = 3 } },
	range = 8,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	radius = function (self, t) return 2 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 300) end,
	getProcDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 300) end,
	getDuration = function(self, t) return 5 end,
	getSlow = function(self, t) return self:combatTalentLimit(t, 75, 20, 66) end,
	getExecute = function(self, t) return 15 end,
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
		return ([[Open a tenuous gate to the vast emtpiness at the center of everything.  Targets in a radius %d area take %0.1f darkness damage and have their movement slowed by %d%% for 1 turn(#SLATE# no save#LAST#).  When a creature in the affected area takes damage from outside the area, they are doomed for 5 turns.  Each stack of doom inflcits an additional %0.1f darkness damage.  At %d stacks of doom, creatures are drawn into the gate and instantly killed.
The damage will increase with your Spellpower.]]):tformat(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)), t.getSlow(self, t), damDesc(self, DamageType.DARKNESS, t.getProcDamage(self, t)), t.getExecute(self, t))
	end,
}
class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)

	local seff = game.level.map:hasEffectType(src.x, src.y, DamageType.REK_SHINE_GRAVE)
	local deff = game.level.map:hasEffectType(target.x, target.y, DamageType.REK_SHINE_GRAVE)

	if deff and not seff then
		target:setEffect(target.EFF_REK_SHINE_GRAVE_OF_SUNS_DOOM, 5, {pow=deff.dam.dam, stacks=1, max_stacks=deff.dam.cap, src=deff.src})
	end
	return hd
end)