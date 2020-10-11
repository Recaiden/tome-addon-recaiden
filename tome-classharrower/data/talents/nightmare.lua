newTalent{
	name = "Cosmic Awareness", short_name = "REK_GLR_NIGHTMARE_AWARENESS",
	type = {"psionic/unleash-nightmare", 1},
	require = wil_req_high1,
	points = 5,
	cooldown = 20,
	no_energy = true,
	psi = 20,
	getDuration = function(self, t) return self:combatTalentWeaponDamage(t, 5, 10) end,
	getConversion = function(self, t) return math.min(2/3, self:combatTalentMindDamage(t, 0.33, 0.6)) end,
	getResist = function(self, t) return self:combatTalentScale(t, 4, 9) end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_GLR_COSMIC_AWARENESS, t.getDuration(self, t) {power=t.getConversion(self, t), resist=t.getResist(self, t), src=self})
		return true
	end,
	info = function(self, t)
		return ([[Awaken the mind within your mind and let it bear witness to the false world around you. For the next %d turns, you can act while asleep, %d%% of incoming damage is converted to mind damage, and your mind resistance and maximum mind resistance are increased by +%d%%.
Mindpower: improves	conversion to mind damage.

#{italic}#I am awake.  I am aware.#{normal}#

#YELLOW#You can only learn 1 Unleash tree.#LAST#]]):
		format(t.getDuration(self, t), t.getConversion(self, t)*100, t.getResist(self, t))
	end,
}

newTalent{
	name = "Narcolepsy", short_name = "REK_GLR_NIGHTMARE_NARCOLESPY",
	type = {"psionic/unleash-nightmare", 2},
	require = wil_req_high2,
	points = 5,
	cooldown = 9,
	range = 10,
	psi = 7,
	tactical = { DISABLE = {SLEEP = 2 } },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDuration = function(self, t) return 4 end,
	getInsomniaPower = function(self, t)
		if not self:knowTalent(self.T_SANDMAN) then return 20 end
		local t = self:getTalentFromId(self.T_SANDMAN)
		local reduction = t.getInsomniaPower(self, t)
		return 20 - reduction
	end,
	getSleepPower = function(self, t)
		local power = self:combatTalentMindDamage(t, 15, 80)
		if self:knowTalent(self.T_SANDMAN) then
			local t = self:getTalentFromId(self.T_SANDMAN)
			power = power * t.getSleepPowerBonus(self, t)
		end
		return math.ceil(power)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		local is_waking =0
		if self:knowTalent(self.T_RESTLESS_NIGHT) then
			local t = self:getTalentFromId(self.T_RESTLESS_NIGHT)
			is_waking = t.getDamage(self, t)
		end

		local power = self:mindCrit(t.getSleepPower(self, t))
		if target:canBe("sleep") then
			target:setEffect(target.EFF_SLUMBER, t.getDuration(self, t), {src=self, power=power, waking=is_waking, insomnia=t.getInsomniaPower(self, t), no_ct_effect=true, apply_power=self:combatMindpower()})
			game.level.map:particleEmitter(target.x, target.y, 1, "generic_charge", {rm=180, rM=200, gm=100, gM=120, bm=30, bM=50, am=70, aM=180})
		else
			game.logSeen(self, "%s resists the sleep!", target.name:capitalize())
		end
		game:playSoundNear(self, "talents/dispel")
		return true
	end,
	info = function(self, t)
		return([[Puts the target into a sudden sleep for %d turns, rendering it mostly unable to act.  Every %d points of damage the target suffers will reduce the effect duration by one turn.
Mindpower: increases damage threshold 
When they wake, the target will benefit from Insomnia for a number of turns equal to the amount of time it was asleep (up to ten turns max), granting it %d%% sleep immunity.]]):format(t.getDuration(self, t), t.getSleepPower(self, t), t.getInsomniaPower(self, t))
	end,
}

newTalent{
	name = "Dream Shift", short_name = "REK_GLR_NIGHTMARE_SHIFT",
	type = {"psionic/unleash-nightmare", 3},
	require = wil_req_high3,
	points = 5,
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	psi = 15,
	range = 10,
	requires_target = true,
	tactical = { DISABLE = { stun = 1 } },
	getStat = function(self, t) return self:combatTalentMindDamage(t, 15, 85) end,
	getDuration = function(self, t) return self:combatTalentScale(t, 3, 6) end,
	target = function(self, t) return {type = "hit", range = self:getTalentRange(t), talent = t } end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return end
		local target = game.level.map(x, y, game.level.map.ACTOR)
		if not target then return nil end
		if not target:attr("sleep") then return end

		target:setEffect(target.EFF_REK_GLR_DREAM_SHIFT, 5, {power=t.getStat(self, t), lockin=t.getDuration(self, t), save=self:combatMindpower(), src=self})
		return true
		end,
	info = function(self, t)
		return ([[Transform a sleeping target into a harmless animal.  In this state all their stats are reduced by %d.
They spend at least %d turns in animal form (and turns while sleeping do not count).  After this they make a mental save each round to return to normal.]]):format(t.getDamage(self, t) * 100, t.getEffDamage(self, t) * 100)
	end,
}

newTalent{
	name = "Nightmare Overlay", short_name = "REK_GLR_NIGHTMARE_OVERLAY",
	type = {"psionic/unleash-nightmare", 4},
	require = wil_req_high4,
	points = 5,
	cooldown = 24,
	psi = 16,
	range = function(self, t) return 10 - t.radius(self, t) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4.5)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.6) end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 4, 7)) end,
	getHallucination = function(self, t) return math.min(0.5, self:combatTalentMindDamage(t, 0.20, 0.33)) end,
	getNightmareSummon = function(self, t)
		local gaunt =  {
			name = "nightgaunt",
			display = "h", color=colors.DARK_GREY, image="npc/horror_eldritch_nightmare_horror.png",
			blood_color = colors.BLUE,
			desc = "A formless terror that seems to cut through the air, and its victims, like a knife.",
			type = "horror", subtype = "eldritch",
			rank = 2,
			size_category = 2,
			body = { INVEN = 10 },
			no_drops = true,
			autolevel = "warrior",
			level_range = {1, nil}, exp_worth = 0,
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
			stats = { str=16, dex=20, wil=15, con=15 },
			infravision = 10,
			can_pass = {pass_wall=20},
			resists = {[DamageType.LIGHT] = -50, [DamageType.DARKNESS] = 100},
			silent_levelup = true,
			no_breath = 1,
			fear_immune = 1,
			blind_immune = 1,
			infravision = 10,
			see_invisible = 80,
			no_wake = true,
			max_life = resolvers.rngavg(50, 80),
			combat_armor = 1, combat_def = 10,
			combat = {
				dam=resolvers.levelup(resolvers.rngavg(15,20), 1, 1.1),
				atk=resolvers.rngavg(5,15), apr=5, dammod={str=1}
			},
			resolvers.talents{}
		}
		local hallucination =  {
			name = "hallucination",
			display = "h", color=colors.DARK_GREY, image="npc/horror_eldritch_nightmare_horror.png",
			blood_color = colors.BLUE,
			type = "horror", subtype = "eldritch",
			rank = 2,
			size_category = 2,
			body = { INVEN = 10 },
			level_range = {self.level, self.level},
			no_drops = true,
			autolevel = "warriorwill",
			exp_worth = 0,
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2 },
			stats = { str=15, dex=15, wil=15, con=15, cun=15},
			infravision = 10,
			silent_levelup = true,
			no_breath = 1,
			negative_status_effect_immune = 1,
			infravision = 10,
			resists = {all = 50},
			no_wake = true,
			hallucination = true,
			max_life = resolvers.rngavg(20, 20),
			life_rating = 6,
			combat_armor = 1, combat_def = 10,
			combat = { dam=1, atk=1, apr=1, damtype=DamageType.DARKNESS },
			resolvers.talents{}
		}
		if rng.percent() < 50 then return gaunt else return hallucination end
	end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		--local dam = self:spellCrit(t.getDamage(self, t))
		--self:project({type="hit", talent=t}, x, y, DamageType.LIGHT, dam, {type="light"})
		
		-- Add a lasting map effect
		game.level.map:addEffect(
			self,
			x, y, 4,
			DamageType.REK_GLR_ETERNAL_SLEEP, 1,
			self:getTalentRadius(t),
			5, nil,
			MapEffect.new{color_br=50, color_bg=type.12, color_bb=199, alpha=100, effect_shader="shader_images/nightmare_effect.png"},
			function(e, update_shape_only)
				if not update_shape_only then 
					-- attempt one summon per turn
					if not e.src:canBe("summon") then return end
					
					local caster = e.src
					if not caster then return end
						
					local locations = {}
					local grids = core.fov.circle_grids(e.x, e.y, e.radius, true)
					for lx, yy in pairs(grids) do
						for ly, _ in pairs(grids[lx]) do
							if not game.level.map:checkAllEntities(lx, ly, "block_move") then
								locations[#locations+1] = {lx, ly}
							end
						end
					end
					if #locations == 0 then return true end
					local location = rng.table(locations)

					local m = require("mod.class.NPC").new(caster:callTalent(self.T_REK_GLR_NIGHTMARE_OVERLAY, "getNightmareSummon")
																								)
					if m.hallucination then
						m.hallucination_power = t.getHallucination(self, t)
						m.on_act = function(self)
							local tg = {type="ball", range=0, friendlyfire=false, radius=3}
							self:project(
								tg, self.x, self.y,
								function(tx, ty)
									local act = game.level.map(tx, ty, engine.Map.ACTOR)
									if act then
										act:setEffect(act.EFF_REK_GLR_HALLUCINATING, 1, {power=self.hallucination_power, src=self})
									end
								end)
							self.energy.value = 0
						end,
					end
					m.faction = e.src.faction
					m.summoner = e.src
					m.summoner_gain_exp = true
					m.summon_time = 3
					m:resolve() m:resolve(nil, true)
					m:forceLevelup(e.src.level)
					
					-- Add to the party
					if e.src.player then
						m.remove_from_party_on_death = true
						game.party:addMember(m, {control="no", type="nightmare", title="Nightmare"})
					end
					
					game.zone:addEntity(game.level, m, "actor", location[1], location[2])
					
					return true
				end
			end,
			false, false)
		
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[Merge dreams and reality within a radius %d area for %d turns. Within this area stun, daze, and sleep effects do not expire, and nightguants and hallucinations continually spawn.
Nightguants are weak attackers that do not interrupt sleep or daze.
Hallucinations do no harm but reduce damage dealt to nearby non-hallucination targets by %d%%.
Mindpower: improves summon powers]]):format(self:getTalentRadius(t), t.getDuration(self, t), t.getHallucination(self, t))
	end,
}