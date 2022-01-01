newTalent{
	name = "Hundredfold Bite", short_name = "REK_HEKA_WURM_RANGED", image = "talents/rek_heka_moonwurm_bite.png",
	type = {"wild-gift/other", 1}, points = 5,
	cooldown = 3,
	tactical = { ATTACK = { NATURE = 1 } },
	range = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 6, 10)) end,
	requires_target = true,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t} end,
	oneTarget = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire"}, friendlyblock=false, friendlyfire=false} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 230) end,
	callbackOnTeleport = function(self, t, teleported, ox, oy, x, y)
		if not teleported then return end
		local cooldown = self.talents_cd[t.id] or 0
		if cooldown > 0 then
			self.talents_cd[t.id] = math.max(cooldown - 3, 0)
		end
	end,
	callbackOnMove = function(self, t, moved, force, ox, oy)
		if (self.x == ox and self.y == oy) or force then return end
		local cooldown = self.talents_cd[t.id] or 0
		if cooldown > 0 then
			self.talents_cd[t.id] = math.max(cooldown - 1, 0)
		end
	end,
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 then
					tgts[#tgts+1] = a
				end
		end end
		
		local tg = t.oneTarget(self, t)
		while #tgts > 0 do
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			
			self:projectile(table.clone(tg), a.x, a.y, DamageType.RANDOM_POISON, {dam=self:spellCrit(t.getDamage(self, t)), power=10+self:getTalentLevel(t), random_chance=50, apply_power=self:combatSpellpower()}, {type="slime"})
		end
		return true
	end,
	info = function(self, t)
		return ([[Fires a poison needle at every nearby enemy within range %d, dealing %0.1f nature damage over 5 turns with a 50%% chance for disabling effects.
Moving reduces the cooldown by 1 and teleporting refreshes it completely.]]):tformat(self:getTalentRange(t), damDesc(self, DamageType.NATURE, t:_getDamage(self)))
	end,
}

newTalent{
	name = "Reaving Crescent", short_name = "REK_HEKA_WURM_MELEE", image = "talents/rek_heka_moonwurm_distraction.png",
	type = {"wild-gift/other", 1}, points = 5,
	cooldown = 5,
	equilibrium = 10,
	tactical = { ATTACKAREA = { PHYSICAL = 1}, DISABLE = 1 },
	range = 0,
	radius = 2,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, friendlyfire=false, radius=self:getTalentRadius(t)}
	end,
	getAmp = function(self, t) return self:combatTalentScale(t, 0.2, 0.5) end,
	getDamage = function(self, t) return 1.2 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				local hit = self:attackTarget(target, DamageType.PHYSICAL, t.getDamage(self, t), true)
				if hit then
					target:setEffect(target.EFF_REK_HEKA_WURMDISTRACTION, 2, {src=self, power=t:_getAmp(self)})
				end
			end
		end)
		self:addParticles(Particles.new("meleestorm", 1, {radius=self:getTalentRadius(t)}))
		return true
	end,
	info = function(self, t)
		return ([[Flail wildly with your tentacles, doing %d%% unarmed damage to enemies in radius %d and distracting them, applying %d%% vulnerability for 2 turns.]]):tformat(t:_getDamage(self)*100, self:getTalentRadius(t), t:_getAmp(self)*100)
	end,
}

newTalent{
	name = "Ravening Reservoir", short_name = "REK_HEKA_WURM_HEAL", image = "talents/rek_heka_moonwurm_reservoir.png",
	type = {"wild-gift/other", 1}, points = 5,
	mode = "passive",
	getLeech = function(self, t) return self:combatTalentScale(t, 10, 35) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "life_leech_chance", 100)
		self:talentTemporaryValue(p, "life_leech_value", t:_getLeech(self))
		self.heal = function(self, val, ...)
			local ret = mod.class.NPC.heal(self, val, ...)
			if self.summoner then
				if self.summoner:attr("dead") or not game.level:hasEntity(self.summoner) then
					self.summoner = nil
				else
					game.logSeen(self, "%s duplicates the healing forces to %s!", self:getName():capitalize(), self.summoner:getName())
					self.summoner:heal(val, self)
				end
			end
			return ret
		end
	end,
	info = function(self, t)
		return ([[Here in this place, you can gather biomass much more efficiently, healing you and your summoner for %d%% of the damage you do.]]):tformat(t:_getLeech(self))
	end,
}

newTalent{
	name = "Anchor Walk", short_name = "REK_HEKA_WURM_RUSH", image = "talents/rek_heka_moonwurm_summon.png",
	type = {"wild-gift/other", 1}, points = 5,
	cooldown = 4,
	tactical = { ATTACK = { PHYSICAL = 1, }, CLOSEIN = 3 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	is_melee = true,
	is_teleport = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.5) end,
	action = function(self, t)
		if self:attr("never_move") then return end
		
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not target or not self:canProject(tg, x, y) then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end -- To prevent teleporting through walls
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
		local ox, oy = self.x, self.y
		if not self:teleportRandom(x, y, 0) then 
			game.logSeen(self, "%s's Anchor Walk fizzles!", self:getName():capitalize()) 
			return true 
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "arcane_teleport_stream", { dx = ox - self.x, dy = oy - self.y, dir_c=0, color_r=160, color_g=50, color_b=200})
		if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
			local DamageType = require "engine.DamageType"
			self:attackTarget(target, DamageType.PHYSICAL, t.getDamage(self, t), true)
			game:playSoundNear(self, "talents/teleport")
		end
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Teleport to a target within range 10 and strike them with your fangs dealing %d%% unarmed damage as physical.]]):tformat(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Orbital Wurm", short_name = "REK_HEKA_MOONWURM_RESERVOIR",
	type = {"spell/moon-wurm", 1}, require = mag_req_high1, points = 5,
	mode = "passive",
	getLife = function(self, t) return self.max_life * self:combatTalentLimit(t, 1.5, 0.2, 0.5) + 2 * (self:getCon() - 10) end,
	callbackOnKill = function (self, t, target)
		if target.summoner then return end
		if target.summoned_time then return end
		if target.exp_worth == 0 then return end
		local power = t:_getLife(self) * target.level * target.rank * target.rank / (self.level * 200)
		self:setEffect(self.EFF_REK_HEKA_RESERVOIR, 1, {src=self, max=t:_getLife(self), power=power})
	end,
	info = function(self, t)
		return ([[You are assisted by a small creature that isn't you, and isn't quite here.  It collects bits and scraps whenever you kill an enemy, giving you a Reservoir of up to %d (based on your max life and constitution). If you would take lethal damage, you are healed for your Reservoir, possibly saving you.
Rarer and higher-level enemies fill the reservoir faster.

When summoned, your assistant gains healing abilities based on levels in this talent.]]):tformat(t:_getLife(self))
	end,
}

newTalent{
	name = "Wurm's Bite", short_name = "REK_HEKA_MOONWURM_BITE",
	type = {"spell/moon-wurm", 2},	require = mag_req_high2, points = 5,
	mode = "passive",
	range = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 6, 10)) end,
	oneTarget = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire"}, friendlyblock=false, friendlyfire=false} end,
	cooldown = 3,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 230) end,
	fire = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 then
					tgts[#tgts+1] = a
				end
		end end
		
		local tg = t.oneTarget(self, t)
		if #tgts <= 0 then return end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)
		
		self:projectile(table.clone(tg), a.x, a.y, DamageType.RANDOM_POISON, {dam=self:spellCrit(t.getDamage(self, t)), power=10+self:getTalentLevel(t), apply_power=self:combatSpellpower()}, {type="slime"})
		
		self:startTalentCooldown(t)
	end,
	callbackOnActBase = function(self, t)
		if self:isTalentCoolingDown(t) then return end
		t.fire(self, t)
	end,
	callbackOnWait = function(self, t)
		t.fire(self, t)
	end,
	callbackOnTeleport = function(self, t, teleported, ox, oy, x, y)
		if not teleported then return end
		t.fire(self, t)
	end,
	callbackOnMove = function(self, t, moved, force, ox, oy)
		if (self.x == ox and self.y == oy) or force then return end
		local cooldown = self.talents_cd[t.id] or 0
		if cooldown > 0 then
			self.talents_cd[t.id] = math.max(cooldown - 1, 0)
		end
	end,
	info = function(self, t)
		return ([[Your assistant has grown enough to extrude and project spines through your anchor. Every %d turns, it fires a poison needle at a nearby enemy within range %d, dealing %0.1f nature damage over 5 turns with a 25%% chance for disabling effects.
Moving reduces the cooldown by 1, and waiting or teleporting causes it to fire immediately.

When summoned, your assistant gains a ranged attack based on levels in this talent.]]):tformat(self:getTalentCooldown(t), self:getTalentRange(t), damDesc(self, DamageType.NATURE, t:_getDamage(self, t)))
	end,
}

newTalent{
	name = "Crescent Motion", short_name = "REK_HEKA_MOONWURM_DISTRACTION",
	type = {"spell/moon-wurm", 3}, require = mag_req_high3, points = 5,
	mode = "passive",
	range = 10,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getChance = function(self, t) return 3 + self:getTalentLevel(t) end,
	getAmp = function(self, t) return self:combatTalentScale(t, 0.2, 0.5) end,
	callbackOnActBase = function (self, t)
		if not self.in_combat then return end
		if not rng.percent(t:_getChance(self)) then return end
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 then
					tgts[#tgts+1] = a
				end
		end end

		local tg = t.target(self, t)
		if #tgts <= 0 then return end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)
		a:setEffect(a.EFF_REK_HEKA_WURMDISTRACTION, 2, {src=self, power=t:_getAmp(self)})
	end,
	info = function(self, t)
		return ([[Your assistant stretches its tether, with a %d%% chance each round of reaching out to distract an enemy within range %d for 2 turns, during which they take %d%% increased damage.

When summoned, your assistant gains a disabling melee attack based on levels in this talent.]]):tformat(t:_getChance(self), self:getTalentRange(t), t:_getAmp(self)*100)
	end,
}

newTalent{
	name = "Anchor Eclipse", short_name = "REK_HEKA_MOONWURM_SUMMON",
	type = {"spell/moon-wurm", 4}, require = mag_req_high4, points = 5,
	cooldown = 30,
	tactical = { ATTACK = 3 },
	range = 5,
	target = function(self, t) return {type="bolt", nowarning=true, pass_terrain = true, friendlyblock=false, nolock=true, talent=t} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10)) end,
	summon = function(self, t, tx, ty)
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then return nil end

		target = self.ai_target.actor
		if target == self then target = nil end

		local colors = {"red", "green", "blue"}
		local imageStr = ("horror_eldritch_wandering_eye_%s"):format(colors[rng.range(1, #colors)])
		local stat = self:combatSpellpowerRaw()

		local l1, l2, l3 = 0, 0, 0
		if self:knowTalent(self.T_REK_HEKA_MOONWURM_RESERVOIR) then
			l1 = self:getTalentLevel(self:getTalentFromId(self.T_REK_HEKA_MOONWURM_RESERVOIR))
		end
		if self:knowTalent(self.T_REK_HEKA_MOONWURM_BITE) then
			l2 = self:getTalentLevel(self:getTalentFromId(self.T_REK_HEKA_MOONWURM_BITE))
		end
		if self:knowTalent(self.T_REK_HEKA_MOONWURM_DISTRACTION) then
			l3 = self:getTalentLevel(self:getTalentFromId(self.T_REK_HEKA_MOONWURM_DISTRACTION))
		end
		
		local npc = require("mod.class.NPC").new{
			type = "horror", subtype = "eldritch",
			name = "kharybdian wurm",
			desc = [[A long, unearthly creature with three eyes and many teeth in its pointed maw.]],
			display = 'h', color=colors.BLUE,
			image = ("npc/%s.png"):format(imageStr),
			
			never_anger = true,
			summoner = self,
			summoner_gain_exp=true,
			summon_time = t:_getDuration(self),
			remove_from_party_on_death = true,
			faction = self.faction,
			size_category = 4,
			rank = 3.5,
			autolevel = "none",
			level_range = {self.level, self.level},
			exp_worth = 0,
			minion_be_nice = 1,
			
			max_life = 100, life_rating = 15, life_regen = 5,
			stats = {
				str=stat, dex=stat, mag=stat, wil=stat, cun=stat, con=stat,
			},
			combat_armor = 10+self.level * 2, combat_def = 5+self.level,
			combat = {
				dam=math.floor(self:combatScale(self.level, 1.5, 1, 75, 50, 0.75)),
				atk=10 + self.level,
				apr=8,
				dammod={str=0.5, mag=0.5}
			},
			summoner_hate_per_kill = self.hate_per_kill,
			resolvers.talents{
				[self.T_REK_HEKA_WURM_MELEE]=l3,
				[self.T_REK_HEKA_WURM_RANGED]=l2,
				[self.T_REK_HEKA_WURM_HEAL]=l1,
				[self.T_REK_HEKA_WURM_RUSH]=self:getTalentLevel(t),
			},
			no_breath = 1,
			stone_immune = 1,
			confusion_immune = 1,
			fear_immune = 1,
			stun_immune = 1,
			teleport_immune = 1,
			blind_immune = 1,
			see_invisible = 100,
			resists_pen = { all=50 },
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			ai_target = {actor=target}
		}
		self:attr("summoned_times", 1)
		
		npc:resolve()
		npc:resolve(nil, true)
		npc:forceLevelup(self.level)
		game.zone:addEntity(game.level, npc, "actor", x, y)
		game.party:addMember(npc, { control="no", type="summon", title="Summon" })
		game.level.map:particleEmitter(x, y, 1, "teleport_in")
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then return nil end
		t.summon(self, t, tx, ty)
		return true
	end,
	info = function(self, t)
		return ([[Your assistant crawls out through your anchor, summoning it onto the battlefield for %d turns.  Its statistics are based on your raw spellpower, and its talents are based on your level in all Moon Wurm talents.
This talent activates automatically when your Reservoir is consumed.]]):tformat(t:_getDuration(self))
	end,
}
