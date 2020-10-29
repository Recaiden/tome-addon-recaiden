local Object = require "mod.class.Object"

newTalent{
	name = "Undertow", short_name = "WANDER_ELEMENTAL_UNDERTOW",
	type = {"spell/other",1},
	points = 5,
	cooldown = 10,
	range = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 4, 9)) end,
	tactical = { DISABLE = 1, CLOSEIN = 3 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 140) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), friendlyblock=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		local dam = self:spellCrit(t.getDamage(self, t))
		self:project(
			tg, x, y,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				
				DamageType:get(DamageType.WANDER_WATER).projector(self, target.x, target.y, DamageType.WANDER_WATER, dam)
				
				local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
				if not target:canBe("teleport") or not hit then
					game.logSeen(target, "%s resists being teleported by the undertow!", target.name:capitalize())
					return true
				end
				
				-- Grab the closest adjacent grid that doesn't have block_move or no_teleport
				local grid = util.closestAdjacentCoord(self.x, self.y, target.x, target.y, true, function(x, y) return game.level.map.attrs(x, y, "no_teleport") end)							
				if not grid then return true end
				target:teleportRandom(grid[1], grid[2], 0)
			end)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Envelop a target in rushing water and teleport it (#SLATE#Spellpower vs Spell#LAST#) to your side, dealing %0.2f water damage.
Spellpower: increases damage]]):format(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Water Whip", short_name = "WANDER_ELEMENTAL_WATER_WHIP",
	type = {"spell/other", 1},
	points = 5,
	cooldown = 4,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	range = 7,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1.1) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		--local dam = self:spellCrit(t.getDam(self, t))
		-- Compute damage
		local dam = self:combatDamage(combat)
		local damrange = self:combatDamageRange(combat)
		dam = rng.range(dam, dam * damrange)
		dam = self:spellCrit(dam)
		dam = dam * t.getDamage(self, t)
		self:project(
			tg, x, y,
			function(px, py)
				local tgts = {}
				self:project(
					{type="ball", radius=1, x=px, y=py}, px, py,
					function(ppx, ppy)
						local a = game.level.map(ppx, ppy, Map.ACTOR)
						if a and self:reactionToward(a) < 0 and self:hasLOS(px, py) and (px ~= ppx or py ~= ppy) then tgts[#tgts+1] = a end
					end)
				DamageType:get(DamageType.WANDER_WATER_WHIP).projector(self, px, py, DamageType.WANDER_WATER_WHIP, dam)
				game.level.map:particleEmitter(px, py, 1, "image", {once=true, image="particles_images/mindwhip_hit_0"..rng.range(1, 4), life=14, av=-0.6/14, size=64})
				game.level.map:particleEmitter(px, py, 1, "shockwave", {radius=1, distort_color=colors.simple1(colors.ROYAL_BLUE), allow=core.shader.allow("distort")})
				for i = 1, 2 do
					if #tgts > 0 then
						local a = rng.tableRemove(tgts)
						game.level.map:particleEmitter(a.x, a.y, 1, "image", {once=true, image="particles_images/mindwhip_hit_0"..rng.range(1, 4), life=14, av=-0.6/14, size=64})
						game.level.map:particleEmitter(a.x, a.y, 1, "shockwave", {radius=1, distort_color=colors.simple1(colors.ROYAL_BLUE), allow=core.shader.allow("distort")})
						DamageType:get(DamageType.WANDER_WATER_WHIP).projector(self, a.x, a.y, DamageType.WANDER_WATER_WHIP, dam)
					end
				end
			end)

		game:playSoundNear(self, "actions/whip_hit")
		return true
	end,
	info = function(self, t)
		return ([[Lash out at a distant enemy with a high-speed blast of water, doing %d%% attack damage as water.
The whip can cleave to two other nearby foes.
Each hit of the whip tries to knock the target Off-Balance (#SLATE#using spellpower#LAST#)]]):format(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)*100))
	end,
}

newTalent{
	name = "Flash Flood", short_name = "WANDER_ELEMENTAL_FLASH_FLOOD",
	type = {"spell/other", 1},
	points = 5,
	cooldown = 30,
	tactical = { ATTACKAREA = { PHYSICAL = 3 }, DISABLE = 2 },
	range = 7,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 360) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getSlow = function(self, t) return self:combatTalentLimit(t, 100, 10, 40) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		self:project(tg, x, y, DamageType.WANDER_WATER, self:spellCrit(t.getDamage(self, t)))
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.SLOW, {dam=t.getSlow(self, t), dur=2},
			self:getTalentRadius(t),
			5, nil,
			MapEffect.new{color_br=20, color_bg=120, color_bb=255, effect_shader="shader_images/water_effect1.png"},
			nil, false, false
		)

		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		return ([[A radius %d rush of water covers the target location, doing %0.2f water damage.  The area remains flooded for %d turns, inflciting a %d%% slow.
Spellpower: increases damage]]):format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), t.getDuration(self, t), t.getSlow(self, t))
	end,
}

newTalent{
	name = "Summon: Nenagoroth", short_name = "WANDER_SUMMON_WATER",
	type = {"celestial/nekal", 1},
	require = spells_req1,
	points = 5,
	message = "@Source@ conjures a Nenagoroth!",
	negative = -4.5,
	cooldown = 9,
	range = 6,
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
			str= (fake and mp or self:spellCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75),
			dex= (fake and mp or self:spellCrit(mp)) * 1.6 * self:combatTalentScale(t, 0.2, 1, 0.75),
			con= (fake and mp or self:spellCrit(mp)) * 1.6 * self:combatTalentScale(t, 0.2, 1, 0.75),
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
		
		local image = "npc/elemental_water_nenagoroth.png"	
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "elemental", subtype = "water",
			display = "E", color=colors.LIGHT_BLUE, image = image,
			name = "Nenagoroth", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			ai_tactic = resolvers.tactic"melee",
			stats = {str=31, dex=23, con=25, cun=15, wil=15, mag=21},
			inc_stats = t.incStats(self, t),
			level_range = {self.level, self.level}, exp_worth = 0,
			
			max_life = resolvers.rngavg(5,10),
			max_mana = 1000,
			combat_spellpower = self:combatSpellpowerRaw(),
			life_rating = 8,
			infravision = 10,
			movement_speed = 1.0,
			
			combat_armor = 0, combat_def = 20,
			combat = { dam=18+self:getTalentLevel(t) * 10, atk=10, apr=10, dammod={str=0.4, dex=0.2, con=0.2}, damtype=DamageType.WANDER_WATER},
			on_melee_hit = { [DamageType.WANDER_WATER] = resolvers.mbonus(20, 10), },
			
			resolvers.talents{
				[self.T_WANDER_ELEMENTAL_UNDERTOW]=self:getTalentLevelRaw(t),
											 },
			resists = { [DamageType.PHYSICAL] = self:getTalentLevel(t)*10 },
			
			summoner = self, summoner_gain_exp=true, wild_gift_summon=false,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target},
			resolvers.sustains_at_birth(),
		}
		local augment = self:hasEffect(self.EFF_WANDER_UNITY_CONVERGENCE)
		if augment then
			if augment.ultimate then
				m[#m+1] = resolvers.talents{
					[self.T_WANDER_ELEMENTAL_WATER_WHIP]=self:getTalentLevelRaw(t),
					[self.T_WANDER_ELEMENTAL_FLASH_FLOOD]=self:getTalentLevelRaw(t)
																	 }
				m.name = "Ultimate "..m.name
				m.image = "npc/elemental_water_ultimate_nenagoroth.png"
			else
				m[#m+1] = resolvers.talents{ [self.T_WANDER_ELEMENTAL_WATER_WHIP]=self:getTalentLevelRaw(t) }
				m.name = "Greater "..m.name
				m.image = "npc/elemental_water_greater_nenagoroth.png"
			end
			augment.count = augment.count-1
			if augment.count <= 0 then self:removeEffect(self.EFF_WANDER_UNITY_CONVERGENCE) end
		end
		
		setupSummonStar(self, m, x, y)
		game:playSoundNear(self, "talents/water")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		return ([[Summon a Nenagoroth for %d turns to incinerate your foes. These Water Elementals drag enemies closer and crush them with waves.
Its attacks improve with your level and talent level.
It will gain bonus stats (increased further by spell criticals): %d Strength, %d Dexterity, %d Constitution.
It gains bonus Spellpower equal to your own.
It inherits your: increased damage%%, resistance penetration, stun/pin/confusion/blindness immunity, armour penetration.

The nenagoroth can be summoned further away than your other summons.

Water damage is physical that uses your best bonuses among fire/cold/lightning damage.]]):format(t.summonTime(self, t), incStats.str, incStats.dex, incStats.con)
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
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), first_target="friend", nolock=true, friendlyfire=false, selffire=false, talent=t}
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
		game.level.map:particleEmitter(tx, ty, tg.radius, "generic_sploom", {rm=50, rM=50, gm=100, gM=140, bm=220, bM=240, am=35, aM=90, radius=tg.radius, basenb=60})
		self.__project_source = nil
		
		return true
	end,
	info = function(self, t)
		return ([[Overlay a swirling vortex of water around one of your elementals.  This whirlpool does %0.2f water damage in radius %d, pulls enemies in (#SLATE#Spellpower vs Physical#LAST#), and makes them wet for 3 turns.
Spellpower: increased damage

Water damage is physical that uses your best bonuses among fire/cold/lightning damage.]]):format(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), self:getTalentRadius(t))
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
		if src == self then return cb end
		self:setEffect(self.EFF_WANDER_WATER_DANCE, 2, {hits={{life=2, power=cb.value}}, src=self})
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
	negative = 5,
	range = 10,
	radius = 1,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 1 } },
	targetElemental = function(self, t) return {type="hit", nowarning=true, selffire=false, first_target=friend, range=self:getTalentRange(t), talent=t} end,
	targetSplash = function(self, t) return {type="ball", nowarning=true, selffire=false, friendlyfire=false, range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	getExecute = function(self, t) return self:combatTalentScale(t, 0.1, 0.2) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 200) end,
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
			game.logSeen(summon, "%s's disappearing nenagoroth drags its foes with it!", self.name:capitalize())
			local tg = t.targetSplash(self, t)
			self:project(tg, summon.x, summon.y, DamageType.WANDER_WATER_DEEP, {dam=self:spellCrit(t.getDamage(self, t)), execute=t.getExecute(self, t)})
			game.level.map:particleEmitter(summon.x, summon.y, tg.radius, "generic_sploom", {rm=50, rM=50, gm=100, gM=140, bm=220, bM=240, am=35, aM=90, radius=tg.radius, basenb=60})
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
		return ([[When your summoned nenagoroth disappears, it pulls in adjacent enemies, dealing %d water damage.  Enemies reduced to less than %d%% health are dragged to the abyssal depths of Nekal, instantly killing them. 
Spellpower: increases damage.

You can activate this talent to make one of your nenagoroths disappear.

Water damage is physical that uses your best bonuses among fire/cold/lightning damage.]]):format(damDesc(self, DamageType.PHYSICAL, dam), t.getExecute(self, t)*100)
	end,
}
