newTalent{
	name = "Acid Spit", short_name = "REK_HEKA_ACID_POLYP",
	type = {"wild-gift/other", 1},	points = 5,
	equilibrium = 2,
	cooldown = 0,
	tactical = { ATTACK = { ACID = 1 } },
	range = 5,
	requires_target = true,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t} end,
	getDamage=function(self, t) return self:combatTalentStatDamage(t, "wil", 30, 110) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ACID, self:mindCrit(t:_getDamage(self)), {type="acid"})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Spit acid on a foe, doing %0.2f damage.
		The damage will increase with your Willpower.]]):tformat(damDesc(self, DamageType.ACID, t:_getDamage(self)))
	end,
}

newTalent{
	name = "Tentacle Whirl", short_name = "REK_HEKA_WHIRL_POLYP", image = "talents/death_dance.png",
	type = {"wild-gift/other", 1}, points = 5,
	cooldown = 5,
	equilibrium = 10,
	tactical = { ATTACKAREA = { ACID = 2, PHYSICAL = 1} },
	range = 0,
	radius = 2,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, friendlyfire=false, radius=self:getTalentRadius(t)}
	end,
	getDamage=function(self, t) return self:combatTalentStatDamage(t, "wil", 30, 430) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.ACID, self:mindCrit(t:_getDamage(self)), {type="acid"})
		self:addParticles(Particles.new("meleestorm", 1, {radius=self:getTalentRadius(t)}))
		return true
	end,
	info = function(self, t)
		return ([[Flail wildly with your tentacles, doing %0.1f acid damage to enemies in radius %d.
		The damage will increase with your Willpower.]]):tformat(amDesc(self, DamageType.ACID, t:_getDamage(self)), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Anchor Polyp", short_name = "REK_HEKA_POLYP_POLYP",
	type = {"spell/polyp", 1}, require = mag_req1, points = 5,
	cooldown = 3,
	hands = 15,
	tactical = { ATTACK = {PHYSICAL = 1, BLIGHT = 1} },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getSummonDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	summon = function(self, t, target)
		local colors = {"red", "green", "blue"}
		local imageStr = ("horror_eldritch_wandering_eye_%s"):format(colors[rng.range(1, #colors)])
		local stat = self:combatSpellpowerRaw()*0.5
		local x, y = util.findFreeGrid(target.x, target.y, 5, true, {[Map.ACTOR]=true})
		if not x then return nil end
		local npc = require("mod.class.NPC").new{
			type = "horror", subtype = "eldritch",
			name = "kharybdian polyp",
			desc = [[A solid-looking little creature with more tentacles than you'd prefer.]],
			display = 'h', color=colors.SLATE,
			image = ("npc/%s.png"):format(imageStr),
			
			never_anger = true,
			summoner = self,
			summoner_gain_exp=true,
			summon_time = t:_getSummonDuration(self),
			faction = self.faction,
			size_category = 1,
			rank = 2,
			autolevel = "none",
			level_range = {self.level, self.level},
			exp_worth = 0,
			minion_be_nice = 1,
			
			max_life = 20, life_rating = 7, life_regen = 1,
			stats = {
				str=stat, dex=stat, mag=stat, wil=stat, cun=stat, con=stat,
			},
			combat_armor = 5, combat_def = 3,
			combat = {
				dam=math.floor(self:combatScale(level, 1.5, 1, 75, 50, 0.75)),
				atk=10 + level,
				apr=8,
				dammod={str=0.5, mag=0.5}
			},
			summoner_hate_per_kill = self.hate_per_kill,
			resolvers.talents{
				[self.T_REK_HEKA_ACID_POLYP]=self:getTalentLevel(t),
				[self.T_REK_HEKA_WHIRL_POLYP]=self:getTalentLevel(t),
			},
			no_breath = 1,
			stone_immune = 1,
			confusion_immune = 1,
			fear_immune = 1,
			teleport_immune = 1,
			blind_immune = 1,
			see_invisible = 80,
			resists_pen = { all=25 },
			frenzy_factor = self:callTalent(self.T_REK_HEKA_POLYP_SPEED, getSpeed) or 0
			on_act = function(self)
				self.global_speed_add = self.global_speed_add + self.frenzy_factor
				-- clean up
				if self.summoner.dead then
					self:die(self)
				end
			end

			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			ai_target = {
				actor=target
			},
		}
		self:attr("summoned_times", 1)
		
		npc:resolve()
		npc:resolve(nil, true)
		npc:forceLevelup(level)
		game.zone:addEntity(game.level, npc, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "teleport_in")
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 230) end,
	getDamageEnd = function(self, t) return self:combatTalentSpellDamage(t, 10, 150) end,
	getDuration = function(self, t) return 3 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		if self:knowTalent(self.T_REK_HEKA_POLYP_SPREAD) then
			target:setEffect(target.EFF_REK_HEKA_POLYP, t:_getDuration(self), {src=self, apply_power=self:combatSpellpower(), dam=t.getDamage(self, t), damEnd=t.getDamageEnd(self, t), spreadRange=self:getTalentRange(self.T_REK_HEKA_POLYP_SPREAD), spreadAmp=self:callTalent(self.T_REK_HEKA_POLYP_SPREAD, "getIncrease")})
		else
			target:setEffect(target.EFF_REK_HEKA_POLYP, t:_getDuration(self), {src=self, apply_power=self:combatSpellpower(), dam=t.getDamage(self, t), damEnd=t.getDamageEnd(self, t)})
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Infects the target with parasitoid polyps for %d turns. Each turn the growing polyp will deal %0.1f blight damage.

If not removed early it will inflict %0.1f physical damage as the polyp hatches and appears near the target's location for %d turns.
This effect ignores immunities but is considered a disease.
Spellpower: increases damage.

The polyp summon scales with your level and raw spellpower.]]):tformat(t:_getDuration(self), damDesc(self, DamageType.BLIGHT, t.getDamage(self, t)), damDesc(self, DamageType.PHYSICAL, t.getDamageEnd(self, t)), t:_getSummonDuration(self))
	end,
}

newTalent{
	name = "Contagion of Anchors", short_name = "REK_HEKA_POLYP_SPREAD",
	type = {"spell/polyp", 2},	require = mag_req2, points = 5,
	mode = "passive"
	range = 3,
	getIncrease = function(self, t) return self:combatTalentScale(t, 1.0, 1.5) end,
	info = function(self, t)
		return ([[On the second and third turn of infection, the polyp status will spread to a nearby uninfected enemy. If it cannot, the original target takes %d%% damage that turn.
]]):tformat(t:_getIncrease(self) * 100)
	end,
}

newTalent{
	name = "Emplacement Frenzy", short_name = "REK_HEKA_POLYP_SPEED",
	type = {"spell/polyp", 3}, require = mag_req3, points = 5,
	mode = "passive",
	getSpeed = function(self, t) return self:combatTalentLimit(t, 0.5, 0.1, 0.2) end,
	info = function(self, t)
		return ([[Your polyps are driven wild by exposure to this place, and gain %d%% global speed every time they act.]]):tformat(t:_getSpeed(self)*100)
	end,
}

newTalent{
	name = "Sacrificial Reef", short_name = "REK_HEKA_POLYP_REEF",
	type = {"spell/polyp", 4}, require = mag_req4, points = 5,
	mode = "sustained",
	cooldown = 0,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
	callbackOnTemporaryEffect = function(self, t, eff_id, e, p)
		if e.status ~= "detrimental" then return end
		if e.type == "other" or e.type == "magical" then return end

		local nb = self.turn_procs.rek_heka_reef or t:_getCount(self, t)

		if nb < t:_getCount(self, t) then
			self.turn_procs.rek_heka_reef = self.turn_procs.rek_heka_reef + 1
			return true
		end
		
		local lyps = {}
		if not game.level then return end
		for _, e in pairs(game.level.entities) do
			if e.summoner == self and e.name == "kharybdian polyp" then 
				lyps[#lyps]+1 = e
			end
		end
		if #lyps <= 0 then return end

		self.turn_procs.rek_heka_reef = 1
		
		local m = rng.table(lyps)
		game.logSeen(self, "%s sacrifices a polyp to avoid being affected by %s!", self:getName():capitalize(), self:getEffectFromId(eff_id).desc)
		m:die(self)		
		return true
	end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,	
	deactivate = function(self, t, p)
		return true
	end,	
	info = function(self, t)
		return ([[Whenever you would be affected by a detrimental physical or mental effect you instead transfer it to one of your polyps, which dies instantly.  A given polyp can absorb %d effects in a turn.
Cross-tier effects are never affected.]]):tformat(t:_getCount(self))
	end,
}
