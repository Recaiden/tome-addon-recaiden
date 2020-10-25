local Object = require "mod.class.Object"

newTalent{
	name = "Flame Bolts", short_name = "WANDER_ELEMENTAL_WATER_BOLT",
	type = {"spell/other",1},
	points = 5,
	range = 5,
	radius = 5,
	proj_speed = 7,
	mode = "passive",
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	callbackOnMeleeAttack = function(self, t, _, hitted)
		if not hitted then return end
		
		local tg = self:getTalentTarget(t)
		local tgts = {}
		local grids = self:project(tg, self.x, self.y, function(px, py)
																 local actor = game.level.map(px, py, Map.ACTOR)
																 if actor and self:reactionToward(actor) < 0 then
																	 tgts[#tgts+1] = actor
																 end
																									 end)
		
		local nb = 1+math.ceil(self:getTalentLevel(t)/3)
		while nb > 0 and #tgts > 0 do
			local actor = rng.tableRemove(tgts)
			local tg2 = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"}}
			self:projectile(tg2, actor.x, actor.y, DamageType.WATER, self:spellCrit(t.getDamage(self, t)), {type="flame"})
		end
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Hurls up to %d flame bolts dealing %0.2f fire damage to foes in sight when you hit in melee.
		The damage will increase with your Spellpower.]]):
		format(1+math.ceil(self:getTalentLevel(t) / 3), damDesc(self, DamageType.WATER, damage))
	end,
}

newTalent{
	name = "Summon: Nenagoroth", short_name = "WANDER_SUMMON_WATER",
	type = {"celestial/nekal", 1},
	require = spells_req1,
	points = 5,
	message = "@Source@ conjures a Faeros!",
	negative = -4.5,
	cooldown = 9,
	range = 5,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { WATER = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You cannot summon; you are suppressed!") return end
		return not checkMaxSummonStar(self, silent)
	end,
	incStats = function(self, t, fake)
		local mp = self:combatSpellpower()
		return{ 
			str= (fake and mp or self:spellCrit(mp)) * 1.7 * self:combatTalentScale(t, 0.2, 1, 0.75),
			dex= (fake and mp or self:spellCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75),
			con= (fake and mp or self:spellCrit(mp)) * 1.2 * self:combatTalentScale(t, 0.2, 1, 0.75),
					}
	end,
	speed = astromancerSummonSpeed,
	display_speed = function(self, t)
		return ("Swift Spell (#LIGHT_GREEN#%d%%#LAST# of a turn)"):
		format(t.speed(self, t)*100)
	end,
	summonTime = function(self, t)
		local duration = math.floor(self:combatScale(self:getTalentLevel(t), 4, 0, 9, 5))
		local augment = self:hasEffect(self.EFF_WANDER_UNITY_CONVERGENCE)
		if augment then
			duration = duration + augment.extend
		end
		return duration
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end
		
		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end
		
		local image = "npc/elemental_fire_faeros.png"
		
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "elemental", subtype = "fire",
			display = "E", color=colors.ORGANE, image = "npc/elemental_fire_faeros.png",
			name = "Faeros", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			ai_tactic = resolvers.tactic"melee",
			stats = {str=25, dex=31, con=23, cun=15, wil=15, mag=21},
			inc_stats = t.incStats(self, t),
			level_range = {self.level, self.level}, exp_worth = 0,
			
			max_life = resolvers.rngavg(5,10),
			max_mana = 1000,
			combat_spellpower = self:combatSpellpowerRaw(),
			life_rating = 8,
			infravision = 10,
			movement_speed = 2.0, --very fast
			
			combat_armor = 0, combat_def = 20,
			combat = { dam=18+self:getTalentLevel(t) * 10, atk=10, apr=10, dammod={str=0.6, dex=0.2}, damtype=DamageType.WATER},
			on_melee_hit = { [DamageType.WATER] = resolvers.mbonus(20, 10), },
			
			resolvers.talents{
				[self.T_FIERY_HANDS]=self:getTalentLevelRaw(t),
											 },
			resists = { [DamageType.WATER] = self:getTalentLevel(t)*20 },
			
			summoner = self, summoner_gain_exp=true, wild_gift_summon=false,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target},
			resolvers.sustains_at_birth(),
		}
		local augment = self:hasEffect(self.EFF_WANDER_UNITY_CONVERGENCE)
		if augment then
			if augment.ultimate then
				m[#m+1] = resolvers.talents{
					[self.T_BODY_OF_WATER]=self:getTalentLevelRaw(t),
					[self.T_WANDER_ELEMENTAL_WATER_BOLT]=self:getTalentLevelRaw(t)
																	 }
				m.name = "Ultimate "..m.name
				m.image = "npc/elemental_fire_ultimate_faeros_short.png"
			else
				m[#m+1] = resolvers.talents{ [self.T_WANDER_ELEMENTAL_WATER_BOLT]=self:getTalentLevelRaw(t) }
				m.name = "Greater "..m.name
				m.image = "npc/elemental_fire_greater_faeros.png"
			end
			augment.count = augment.count-1
			if augment.count <= 0 then self:removeEffect(self.EFF_WANDER_UNITY_CONVERGENCE) end
		end
		
		setupSummonStar(self, m, x, y)
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		return ([[Summon a Faeros for %d turns to incinerate your foes. These Fire Elementals charge into melee at high speed and attack with their burning hands.
Its attacks improve with your level and talent level.
It will gain bonus stats (increased further by spell criticals): %d Strength, %d Dexterity, %d Constitution.
It gains bonus Spellpower equal to your own.
It inherits your: increased damage%%, resistance penetration, stun/pin/confusion/blindness immunity, armour penetration.]]):format(t.summonTime(self, t), incStats.str, incStats.dex, incStats.con)
	end,
}

newTalent{
	name = "Whirlpool", short_name = "WANDER_WATER_WHIRLPOOL",
	type = {"celestial/nekal", 2},
	require = spells_req2,
	points = 5,
	cooldown = 8,
	negative = 7,
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	tactical = { ATTACKAREA = {PHYSICAL = 2}, PULL = 3 },
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), firsttarget="friend", friendlyfire=false, selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 320) end,
	on_pre_use = function(self, t, silent)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.type == "elemental" then
					return true
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.type == "elemental" then
					return true
				end
			end
		end
		if not silent then game.logPlayer(self, "You require an elemental to center the whirlpool") end
		return false
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or target.summoner ~= self or not target.type == elemental then return nil end

		self.__project_source = target
		self:project(tg, tx, ty, DamageType.WANDER_WATER_PULL, self:spellCrit(t.getDamage(self, t)))
		self.__project_source = nil
		
		return true
	end,
	info = function(self, t)
		return ([[Overlay a swirling vortex of water around one of your elementals.  This whirlpool does %0.2f physical damage in radius %d and pulls enemies in (#SLATE#Spellpower vs Physical#LAST#).
Spellpower: increased damage]]):format(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Dancing Waves", short_name = "WANDER_WATER_DANCE",
	type = {"celestial/nekal", 3},
	require = spells_req3,
	points = 5,
	mode = "passive",
	getHeal = function(self, t) return self:combatTalentScale(t, 0.02, 0.06) end,
	callbackOnHit = function(self, t, cb, src, death_note)
		if src == self then return cb
		self:setEffect(self.EFF_WANDER_WATER_DANCE, 2, {hits={{life-2, power-cb.value}}, src=self})
		return cb
	end,
	callbackOnMove = function(self, t, moved, force, ox, oy, x, y)
		if not moved then return end
		if force then return end
		if ox == self.x and oy == self.y then return end

		-- not while free moving
		if self:attr("move_stamina_instead_of_energy") and self:getStamina() > self:attr("move_stamina_instead_of_energy") then return end
		if self:attr("free_movement") then return end
		if self:attr("walk_sun_path") then
			for i, e in ipairs(game.level.map.effects) do
				if e.damtype == DamageType.SUN_PATH and e.grids[x] and e.grids[x][y] then
					return end
			end
		end
		local dance = self:hasEffect(self.EFF_WANDER_WATER_DANCE)
		if not dance then return end

		self:attr("allow_on_heal", 1)
		self:heal(t.getHeal(self, t) * dance.damage, self)
		self:attr("allow_on_heal", -1)
	end,
	info = function(self, t)
		return ([[The ocean is in constant flow, eternal renewal.  Whenever you move (and spend part of a turn), you regain life equal to %01.f%% of the damage you've taken in the last 2 turns.]]):format(t.getHeal(self, t)*100)
	end,
}

newTalent{
	name = "Drowning Depths", short_name = "WANDER_WATER_DETONATE",
	type = {"celestial/nekal", 4},
	require = spells_req4,
	points = 5,
	cooldown = 10,
	negative = 20,
	range = 10,
	radius = 1,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 1 } },
	targetElemental = function(self, t) return {type="hit", nowarning=true, selffire=false, range=self:getTalentRange(t), talent=t} end,
	targetSplash = function(self, t) return {type="ball", nowarning=true, selffire=false, friendlyfire=false, range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	getExecute = function(self, t) return self:combatTalentScale(t, 0.1, 0.2) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	on_pre_use = function(self, t, silent)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.type == "elemental" and act.subtype == "water" then
					return true
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.type == "elemental" and act.subtype == "water"  then
					return true
				end
			end
		end
		if not silent then game.logPlayer(self, "You require a nenagoroth to banish") end
		return false
	end,
	callbackOnSummonDeath = function(self, t, summon, killer, death_note)
		if summon.type == "elemental" and summon.subtype == "water" then
			local tg = t.targetSplash(self, t)
			self:project(tg, summon.x, summon.y, DamageType.WANDER_DEEP_OCEAN, self:spellCrit(t.getDamage(self, t)))
		end
	end,
	action = function(self, t)
		local tg = t.targetElemental(self, t)
		local count = 0
		local target = nil
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.type == "elemental" and act.subtype == "water" then
					count = count + 1
					target = act
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.type == "elemental" and act.subtype == "water"  then
					count = count + 1
					target = act
				end
			end
		end
		if count == 0 then return nil end
		if count > 1 then
			x, y, target = self:getTarget(tg)
		end
		if not target then return end
		if target.type ~= "elemental" or target.subtype ~= "water" then return end
		if target.summoner ~= self then return end

		target:die(self)
		
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[When your summoned nenagoroth disappears, it pulls in adjacent enemies, dealing %d physical damage.  Enemies reduced to less than %d%% health are dragged to the abyssal depths of Nekal, instantly killing them. 

You can activate this talent to make one of your nenagoroths disappear.
Spellpower: increases damage.]]):format(damDesc(self, DamageType.PHYSICAL, dam), t.getExecute(self, t)*100)
	end,
}
