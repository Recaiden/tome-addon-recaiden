newTalent{
	name = "Orbital Wurm", short_name = "REK_HEKA_MOONWURM_RESERVOIR",
	type = {"spell/moon-wurm", 1}, require = mag_req1, points = 5,
	mode = "passive",
	getLife = function(self, t) return self.max_life * self:combatTalentLimit(t, 1.5, 0.2, 0.5) + 2 * (self:getCon() - 10) end,
	callbackOnKill = function (self, t, target)
		if target.summoner then return end
		if target.summoned_time then return end
		if target.exp_worth == 0 then return end
		local power = t:_getLife(self) * target.level * target.rank / (self.level * 200)
		self:setEffect(self.EFF_REK_HEKA_RESERVOIR, 1, {src=self, max=t:_getLife(self), power=power})
	end,
	info = function(self, t)
		return ([[You are assisted by a small creature that isn't you, and isn't quite here.  It collects bits and scraps whenever you kill an enemy, giving you a Reservoir of up to %d (based on your max life and constitution). If you would take lethal damage, you are healed for your Reservoir, possibly saving you.
Rarer and higher-level enemies fill the reservoir faster.]]):tformat(t:_getLife(self))
	end,
}

newTalent{
	name = "Wurm's Bite", short_name = "REK_HEKA_MOONWURM_BITE",
	type = {"spell/moon-wurm", 2},	require = mag_req2, points = 5,
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
		
		-- Randomly take targets
		local tg = t.oneTarget(self, t)
		if #tgts <= 0 then break end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)
		
		self:projectile(table.clone(tg), a.x, a.y, DamageType.RANDOM_POISON, self:spellCrit(t.getDamage(self, t)), {type="slime"})
		
		self:startTalentCooldown(t)
	end,
	callbackOnActBase = function(self, t)
		if self:isTalentCoolingDown(t) then return end
		t.fire(self, t)
	end,
	callbackOnWait = function(self, t)
		t.fire(self, t)
	end
	info = function(self, t)
		return ([[Your assistant has grown enough to extrude and project spines through your anchor. Every %d turns, it fires a poison needle at a nearby enemy within range %d, dealing %0.1f nature damage over 5 turns.
Moving reduces the cooldown by 1, and waiting causes it to fire immediately.]]):tformat(self:getTalentCooldown(t), self:getTalentRange(t), damDesc(self, DamageType.NATURE, t:_getDamage(self, t)))
	end,
}

newTalent{
	name = "Crescent Motion", short_name = "REK_HEKA_MOONWURM_DISTRACTION",
	type = {"spell/moon-wurm", 3}, require = mag_req3, points = 5,
	mode = "passive",
	range = 10,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getChance = function(self, t) return 3 + self:getTalentLevel(t) end,
	getAmp = function(self, t) return math.floor(self:combatTalentScale(t, 0.2, 0.5)) end,
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
		
		-- Randomly take targets
		local tg = t.oneTarget(self, t)
		if #tgts <= 0 then break end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)
		a:setEffect(a.EFF_REK_HEKA_WURMDISTRACTION, 1, {src=self, power=t:_getAmp(self)})
	end,
	info = function(self, t)
		return ([[Your assistant stretches its tether, with a %d%% chance each round of reaching out to distract a nearby enemy for 1 turn, during which they take %d%% increased damage.]]):tformat(t:_getChance(self), t:_getAmp(self)*100)
	end,
}

newTalent{
	name = "Anchor Eclipse", short_name = "REK_HEKA_MOONWURM_SUMMON",
	type = {"spell/moon-wurm", 4}, require = mag_req4, points = 5,
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
		
		local npc = require("mod.class.NPC").new{
			type = "horror", subtype = "eldritch",
			name = "kharybdian wurm",
			desc = [[A long, unearthly creature with no eyes and many teeth in its ponited maw.]],
			display = 'h', color=colors.BLUE,
			image = ("npc/%s.png"):format(imageStr),
			
			never_anger = true,
			summoner = self,
			summoner_gain_exp=true,
			summon_time = t:_getSummonDuration(self),
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
			combat_armor = 10, combat_def = 5,
			combat = {
				dam=math.floor(self:combatScale(self.level, 1.5, 1, 75, 50, 0.75)),
				atk=10 + self.level,
				apr=8,
				dammod={str=0.5, mag=0.5}
			},
			summoner_hate_per_kill = self.hate_per_kill,
			resolvers.talents{
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
		return ([[Your assistant crawls out through your anchor, summoning it onto the battlefield for %d turns.  Its statistics are based on your raw spellpower, and its talents are based on your level in this talent.
This talent activates automatically when your Reservoir is consumed.]]):tformat(t:_getDuration(self))
	end,
}
