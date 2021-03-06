local Object = require "mod.class.Object"

newTalent{
	name = "Flame Bolts", short_name = "WANDER_ELEMENTAL_FIRE_BOLT",
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
			self:projectile(tg2, actor.x, actor.y, DamageType.FIRE, self:spellCrit(t.getDamage(self, t)), {type="flame"})
		end
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Hurls up to %d flame bolts dealing %0.2f fire damage to foes in sight when you hit in melee.
		The damage will increase with your Spellpower.]]):
		format(1+math.ceil(self:getTalentLevel(t) / 3), damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Summon: Faeros", short_name = "WANDER_SUMMON_FIRE",
	type = {"celestial/kolal", 1},
	require = spells_req1,
	points = 5,
	message = "@Source@ conjures a Faeros!",
	negative = -4.5,
	cooldown = 9,
	range = 5,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { FIRE = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You cannot summon; you are suppressed!") return end
		return not checkMaxSummonStar(self, silent)
	end,
	getStatMultiplier = function(self, t) return self:combatTalentScale(t, 0.2, 1, 0.75) end,
	incStats = function(self, t, fake)
		local mp = self:combatSpellpower()
		local mult = t.getStatMultiplier(self, t)
		return{ 
			str= (fake and mp or self:spellCrit(mp)) * 1.7 * mult,
			dex= (fake and mp or self:spellCrit(mp)) * 2 * mult,
			con= (fake and mp or self:spellCrit(mp)) * 1.2 * mult,
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
			stats = {str=16, dex=16, con=10, cun=10, wil=10, mag=10},
			inc_stats = t.incStats(self, t),
			level_range = {self.level, self.level}, exp_worth = 0,
			
			max_life = resolvers.rngavg(5,10),
			max_mana = 1000,
			combat_spellpower = self:combatSpellpowerRaw(),
			life_rating = 8,
			infravision = 10,
			movement_speed = 2.0, --very fast
			
			combat_armor = 0, combat_def = 20,
			combat = { dam=18+self:getTalentLevel(t) * 10, atk=10, apr=10, dammod={str=0.6, dex=0.2}, damtype=DamageType.FIRE},
			on_melee_hit = { [DamageType.FIRE] = resolvers.mbonus(20, 10), },
			
			resolvers.talents{
				[self.T_FIERY_HANDS]=self:getTalentLevelRaw(t),
											 },
			resolvers.tmasteries{ ["spell/other"]=self:getTalentMastery(t)-1,
														["spell/fire-alchemy"]=self:getTalentMastery(t)-1,
														["spell/enhancement"]=self:getTalentMastery(t)-1,},
			resists = { [DamageType.FIRE] = self:getTalentLevel(t)*20 },
			
			summoner = self, summoner_gain_exp=true, wild_gift_summon=false,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target},
			resolvers.sustains_at_birth(),
		}
		local augment = self:hasEffect(self.EFF_WANDER_UNITY_CONVERGENCE)
		if augment then
			if augment.ultimate then
				m[#m+1] = resolvers.talents{
					[self.T_BODY_OF_FIRE]=self:getTalentLevelRaw(t),
					[self.T_WANDER_ELEMENTAL_FIRE_BOLT]=self:getTalentLevelRaw(t)
																	 }
				m.name = "Ultimate "..m.name
				m.image = "npc/elemental_fire_ultimate_faeros_short.png"
			else
				m[#m+1] = resolvers.talents{ [self.T_WANDER_ELEMENTAL_FIRE_BOLT]=self:getTalentLevelRaw(t) }
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
	name = "Tectonic Fissure", short_name = "WANDER_FIRE_FISSURE",
	type = {"celestial/kolal", 2},
	require = spells_req2,
	points = 5,
	cooldown = 8,
	negative = -4,
	range = function(self, t)
		return math.floor(self:combatTalentScale(t, 4, 8))
	end,
	tactical = { ATTACKAREA = {FIRE = 2}, DISABLE = 3 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 400) end,
	getMinion = function(self, t) return 10 + self:combatTalentSpellDamage(t, 10, 30) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		local dam = self:spellCrit(t.getDamage(self, t))
		local grids = self:project(tg, x, y, DamageType.WANDER_FIRE_CRUSH, dam / 5)
		
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:addEffect(self, self.x, self.y, 4,
														 DamageType.WANDER_FIRE_CRUSH,
														 {
															 dam = dam/5,
															 pow=t.getMinion(self, t),
															 src = self, talent = t,
															 dur = 3
														 },
														 0, 5, grids,
														 MapEffect.new{color_br=255, color_bg=149, color_bb=60, alpha=100, effect_shader="shader_images/fire_effect.png"},
														 nil, true)
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Overlay the crushing volcanic rifts of Kolal onto a small line of land in front of you for %s turns.  Anyone standing on the rift will suffer %d fire damage each turn, and be marked (#SLATE#Spellpower vs. Spellsave#LAST#) to take %d%% more damage from your elementals for 3 turns.]]):format(5, damDesc(self, DamageType.FIRE, damage / 5), t.getMinion(self, t))
	end,
}


newTalent{
	name = "Fiery Purge", short_name = "WANDER_PURGE",
	type = {"celestial/kolal", 3},
	require = spells_req3,
	points = 5,
	cooldown = function(self, t) return self:combatTalentLimit(t, 10, 30, 12) end,
	negative = 5,
	no_energy = true,
	tactical = {
		DEFEND = 3,
		CURE = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type ~= "other" and e.status == "detrimental" then
					nb = nb + 1
				end
			end
			return nb
		end
	},
	getCost = function(self, t) return math.max(7.5, 16.5 - self:getTalentLevel(t)) end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2.5)) end,
	on_pre_use = function(self, t)
		if self.life <= self.max_life * t.getCost(self, t)/100 then return false end
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type ~= "other" then
				return true
			end
		end
		return false
	end,
	action = function(self, t)
		self:takeHit(self.max_life * t.getCost(self, t)/100, self)
		
		local target = self
		local effs = {}
		local force = {}

		self:removeEffectsFilter(self, {subtype={["cross tier"] = true}, status="detrimental"}, 3)
		local removed = self:removeEffectsFilter(self, function(t) return (t.type == "physical" or t.type == "mental" or t.type == "magical") and t.status == "detrimental" end, t.getNb(self, t))

		if removed > 0 then
			game.logSeen(self, "%s is cured!", self.name:capitalize())
		end
		
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healred", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1=colors.hex1alpha"c52505FF", beamColor2=colors.hex1alpha"f69566FF"}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healred", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1=colors.hex1alpha"c52505FF", beamColor2=colors.hex1alpha"f69566FF"}))
			game.level.map:particleEmitter(self.x, self.y, 1, "shader_ring_rotating", {rotation=0, radius=1.2, life=30, y=0.2, img="flamesshockwave"}, {type="firearcs"})
		end
		
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Spend %0.1f%% of your total life to burn away your afflictions, removing up to %d physical, mental or magical detrimental effects and all cross-tier effects.]]):
		format(t.getCost(self, t), t.getNb(self, t))
	end,
}

newTalent{
	name = "Raise Volcano", short_name = "WANDER_FIRE_VOLCANO",
	type = {"celestial/kolal", 4},
	require = spells_req4,
	points = 5,
	message = "A volcano erupts!",
	cooldown = 10,
	negative = 20,
	range = 10,
	proj_speed = 2,
	requires_target = true,
	tactical = { ATTACK = { FIRE = 1, PHYSICAL = 1 } },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nolock=true, talent=t} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	nbProj = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end
		
		local oe = game.level.map(x, y, Map.TERRAIN)
		if not oe or oe:attr("temporary") then return end
		
		local e = Object.new{
			old_feat = oe,
			type = rawget(oe, "type"), subtype = oe.subtype,
			name = "raging volcano", image = oe.image, add_mos = {{image = "terrain/lava/volcano_01.png"}},
			display = '&', color=colors.LIGHT_RED, back_color=colors.RED,
			always_remember = true,
			temporary = t.getDuration(self, t),
			x = x, y = y,
			canAct = false,
			nb_projs = t.nbProj(self, t),
			dam = t.getDamage(self, t),
			act = function(self)
				local tgts = {}
				local grids = core.fov.circle_grids(self.x, self.y, 5, true)
				for x, yy in pairs(grids) do
					for y, _ in pairs(grids[x]) do
						local a = game.level.map(x, y, engine.Map.ACTOR)
						if a and self.summoner:reactionToward(a) < 0 then tgts[#tgts+1] = a end
					end
				end
				
				-- Randomly take targets
				local tg = {type="bolt", range=5, x=self.x, y=self.y, talent=self.summoner:getTalentFromId(self.summoner.T_VOLCANO), display={image="object/lava_boulder.png"}, friendlyblock=false}
				for i = 1, self.nb_projs do
					if #tgts <= 0 then break end
					local a, id = rng.table(tgts)
					table.remove(tgts, id)
					
					local proj = self.summoner:projectile(tg, a.x, a.y, engine.DamageType.FIRE, self.dam, {type="flame"})
					proj.name = "volcano"
					game:playSoundNear(self, "talents/fire")
				end
				
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					game.level.map:updateMap(self.x, self.y)
					game.nicer_tiles:updateAround(game.level, self.x, self.y)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
												}
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		game.nicer_tiles:updateAround(game.level, x, y)
		game.level.map:updateMap(x, y)
		game:playSoundNear(self, "talents/wander_fireball")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[Summons a small raging volcano for %d turns. Every turn, it will fire a molten boulder towards up to %d of your foes, dealing %0.2f fire damage.
		The damage will scale with your Spellpower.]]):
		format(t.getDuration(self, t), t.nbProj(self, t), damDesc(self, DamageType.FIRE, dam))
	end,
}
