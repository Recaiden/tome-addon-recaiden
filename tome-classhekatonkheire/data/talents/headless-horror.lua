newTalent{
	name = "Eye Lash", short_name = "REK_HEKA_EYE_EYE_LASH",
	type = {"spell/other", 1}, require = mag_req1, points = 5,
	cooldown = 3,
	tactical = { ATTACK = {ARCANE = 2} },
	range = 6,
	requires_target = true,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 130) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		if self.replace_display then
			self.replace_display = nil
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)
		end
		
		self:project(tg, x, y, DamageType.ARCANE, self:spellCrit(t.getDamage(self, t)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "arcane_drill_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Focus your attention into a destructive beam, dealing %0.2f arcane damage.
Spellpower: increases damage.]]):tformat(damDesc(self, DamageType.ARCANE, damage))
	end,
}

newTalent{
	name = "Stare Down", short_name = "REK_HEKA_EYE_STAREDOWN",
	type = {"spell/other", 1}, require = mag_req1, points = 5,
	cooldown = 3,
	tactical = { ATTACK = {MIND = 1} },
	range = 0,
	radius = 6,
	requires_target = true,
	target = function(self, t) return {type="cone", range=0, radius=self:getTalentRadius(t), talent=t} end,
	getDamage = function(self, t)
		if self.summoner then
			return self.summoner:callTalent(self.summoner.T_REK_HEKA_EYESIGHT_STARE, "getDamage")
		else return 1 end
	end,
	getSlow = function(self, t)
		if self.summoner then
			return self.summoner:callTalent(self.summoner.T_REK_HEKA_EYESIGHT_STARE, "getSlow")
		else return 0.1 end
	end,
	getOverwatch = function(self, t)
		if self.summoner and self.summoner:knowTalent(self.summoner.T_REK_HEKA_EYESIGHT_OVERWATCH) then
			return self.summoner:callTalent(self.summoner.T_REK_HEKA_EYESIGHT_OVERWATCH, "getOverwatch")
		else return 0 end
	end,
	getMultiplier = function(self, t)
		if self.summoner and self.summoner:knowTalent(self.summoner.T_REK_HEKA_EYESIGHT_INESCAPABLE) then
			return self.summoner:callTalent(self.summoner.T_REK_HEKA_EYESIGHT_INESCAPABLE, "getMultiplier")
		else return 1 end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		if self.replace_display then
			self.replace_display = nil
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)
		end

		local count = table.count(self:projectCollect(tg, x, y, Map.ACTOR))
		if count == 0 then
			self.ai_state.stare_down = nil
			local geff = game.level.map:hasEffectType(self.x, self.y, DamageType.COSMETIC)
			if geff and geff.src == self then
				game.level.map:removeEffect(geff)
			end
			return nil
		end
		self:project(tg, x, y, DamageType.REK_HEKA_STARE, {dam=self:spellCrit(t.getDamage(self, t)), slow=t.getSlow(self, t), overwatch=t.getOverwatch(self, t), multiplier=t.getMultiplier(self, t)})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_time", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Focus your attention into an unsettling cone, dealing %0.2f mind damage and slowing enemies by %d%%.
Spellpower: increases damage.]]):tformat(damDesc(self, DamageType.MIND, damage), t.getSlow(self, t)*100)
	end,
}

newTalent{
	name = "Phase Swim", short_name = "REK_HEKA_EYE_PHASE_DOOR",
	type = {"spell/other", 1}, points = 5,
	no_message = true,
	range = 7,
	tactical = { ESCAPE = 2 },
	is_teleport = true,
	action = function(self, t)
		if self.replace_display then
			self.replace_display = nil
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)
		end
		
		local x, y, range
		if self.ai_target.x and self.ai_target.y then
			x, y, range = self.ai_target.x, self.ai_target.y, 1
		else
			x, y, range = self.summoner.x, self.summoner.y, self.ai_state.location_range
		end
		
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
		local ox, oy = self.x, self.y
		self:teleportRandom(x, y, range)
		game.level.map:particleEmitter(self.x, self.y, 1, "arcane_teleport_stream", { dx = ox - self.x, dy = oy - self.y, dir_c=0, color_r=160, color_g=50, color_b=200})

		return true
	end,
	info = function(self, t)
		return ([[Leave the world and reenter, teleporting you within range 7.]])
	end,
}

newTalent{
	name = "Blink", short_name = "REK_HEKA_EYE_BLINDSIDE",
	type = {"spell/other", 1}, points = 5,
	range = 10,
	requires_target = true,
	tactical = { CLOSEIN = 2 },
	is_melee = true,
	target = function(self, t) return {type="hit", pass_terrain = true, range=self:getTalentRange(t)} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		self.replace_display = mod.class.Actor.new{image=self.image_alt}
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

		local ox, oy = self.x, self.y
		local start = rng.range(0, 8)
		for i = start, start + 8 do
			local x = target.x + (i % 3) - 1
			local y = target.y + math.floor((i % 9) / 3) - 1
			if game.level.map:isBound(x, y)
				and self:canMove(x, y)
				and not game.level.map.attrs(x, y, "no_teleport") then
			game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
			self:move(x, y, true)
			game.level.map:particleEmitter(self.x, self.y, 1, "arcane_teleport_stream", { dx = ox - self.x, dy = oy - self.y, dir_c=0, color_r=160, color_g=50, color_b=200})

			local multiplier = self:combatTalentWeaponDamage(t, 0.9, 1.9)
			local hit = self:attackTarget(target, nil, multiplier, true)
			if hit then
				self:heal(self.max_life / 10)
			end
			return true
			end
		end
		
		return false
	end,
	info = function(self, t)
		local multiplier = self:combatTalentWeaponDamage(t, 0.9, 1.9)
		return ([[Dive towards a target up to %d spaces away and bite them for %d%% damage.]]):tformat(self:getTalentRange(t), multiplier * 100)
	end,
}

newTalent{
	name = "Staggering Gaze", short_name = "REK_HEKA_EYE_KNOCKBACK",
	type = {"spell/other", 1}, points = 5,
	cooldown = 1,
	requires_target = true,
	tactical = { DISABLE = { knockback = 2, STUN = 1 } },
	is_melee = true,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		if not self.summoner then return end
		
		if target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95) then
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatSpellpower())
			if target:canBe("knockback") then
				target:pull(self.summoner.x, self.summoner.y, 3)
			else
				game.logSeen(target, "%s resists the knockback!", target:getName():capitalize())
			end
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 3, {src=self})
			end
		end

		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "eye_knockback", {tx=x-self.x, ty=y-self.y})

		return true
	end,
	info = function(self, t)
		return ([[Blast an enemy with force, throwing them 3 spaces towards your summoner and stunning them for 3 turns.]]):tformat(chance)
	end,
}

local function createEye(self, level, tCallEyes, tPhylactery, tBlink, tStagger, duration, target)
	local colors = {"red", "green", "blue"}
	local imageStr = ("horror_eldritch_wandering_eye_%s"):format(colors[rng.range(1, #colors)])
	local npc = require("mod.class.NPC").new{
		type = "horror", subtype = "eldritch",
		name = "wandering eye",
		desc = [[A disembodied eye the size of a fist, floating through the air.]],
		display = 'h', color=colors.SLATE,
		image = ("npc/%s.png"):format(imageStr),
		image_alt = ("npc/%s.png"):format(imageStr.."_fangs"),
		
		never_anger = true,
      summoner = self,
      summoner_gain_exp=true,
      summon_time = duration,
      faction = self.faction,
      size_category = 1,
      rank = 2,
      autolevel = "none",
      level_range = {level, level},
      exp_worth = 0,
      avoid_traps = 1,
			levitation = 1,
			minion_be_nice = 1,
      is_wandering_eye = true,
      
      max_life = resolvers.rngavg(20,20), life_rating = 7, life_regen = 1+self:getTalentLevel(tPhylactery),
      stats = { -- affected by stat limits
         str=math.floor(self:combatScale(level, 5, 0, 55, 50, 0.75)),
         dex=math.floor(self:combatScale(level, 10, 0, 85, 50, 0.75)),
         mag=math.floor(self:combatScale(level, 10, 0, 85, 50, 0.75)),
         wil=math.floor(self:combatScale(level, 5, 0, 55, 50, 0.75)),
         cun=math.floor(self:combatScale(level, 5, 0, 40, 50, 0.75)),
         con=math.floor(self:combatScale(level, 10, 0, 40, 50, 0.75)),
      },
      combat_armor = 0, combat_def = 3,
      combat = {
         dam=math.floor(self:combatScale(level, 1.5, 1, 75, 50, 0.75)),
         atk=10 + level,
         apr=8,
         dammod={str=0.5, dex=0.5}
      },
      summoner_hate_per_kill = self.hate_per_kill,
      resolvers.talents{
				[self.T_REK_HEKA_EYE_STAREDOWN]=1,
				[self.T_REK_HEKA_EYE_PHASE_DOOR]=tCallEyes.getPhaseDoorLevel(self, tCallEyes),
				[self.T_REK_HEKA_EYE_BLINDSIDE]=tCallEyes.getBlindsideLevel(self, tCallEyes),
				[self.T_REK_HEKA_EYE_EYE_LASH]=tCallEyes.getLashLevel(self, tCallEyes),
				[self.T_REK_HEKA_EYE_KNOCKBACK]=tStagger and tStagger.getStaggerLevel(self, tStagger) or 0,
                       },
			
      no_breath = 1,
      stone_immune = 1,
      confusion_immune = 1,
      fear_immune = 1,
      teleport_immune = 1,
      disease_immune = 1,
      poison_immune = 1,
      stun_immune = 1,
      blind_immune = 1,
      see_invisible = 80,
      resists = { [DamageType.ARCANE] = 50 },
      resists_pen = { all=25 },

      avoid_master_damage = 0,

      ai = "heka_eye",
      ai_state = {
         summoner_range = 5,
         actor_range = 8,
         location_range = 4,
         target_time = 0,
         target_timeout = 10,
         focus_on_target = false,

         blindside_chance = 15,
         phasedoor_chance = 5,
         close_attack_spell_chance = 0,
         far_attack_spell_chance = 33,
      },
      ai_target = {
         actor=target,
         x = nil,
         y = nil
      },
      closeAttackSpell = function(self)
				return self:useTalent(self.T_REK_HEKA_EYE_KNOCKBACK)
      end,
      farAttackSpell = function(self)
				return self:useTalent(self.T_REK_HEKA_EYE_EYE_LASH)
      end,
      feed = function(self)
				if self.summoner:knowTalent(self.summoner.T_REK_HEKA_HEADLESS_ADAPT) then
					local tStagger = self.summoner:getTalentFromId(self.summoner.T_REK_HEKA_HEADLESS_ADAPT)
					self.ai_state.close_attack_spell_chance = tStagger.getKnockChance(self.summoner, tStagger)
				end
				if self.ai_state.feed_temp1 then self:removeTemporaryValue("combat_atk", self.ai_state.feed_temp1) end
				self.ai_state.feed_temp1 = nil
				if self.ai_state.feed_temp2 then self:removeTemporaryValue("inc_damage", self.ai_state.feed_temp2) end
				self.ai_state.feed_temp2 = nil
				if self.summoner:knowTalent(self.summoner.T_REK_HEKA_HEADLESS_BLINK) then
				   local tEyeWarriors = self.summoner:getTalentFromId(self.summoner.T_REK_HEKA_HEADLESS_BLINK)
				   self.ai_state.feed_temp1 = self:addTemporaryValue("combat_atk", tEyeWarriors.getCombatAtk(self.summoner, tEyeWarriors))
					 self.ai_state.feed_temp2 = self:addTemporaryValue("inc_damage", {all=tEyeWarriors.getIncDamage(self.summoner, tEyeWarriors)})
				end
      end,
      onTakeHit = function(self, value, src)
				if src == self.summoner and self.avoid_master_damage then
					value = value * self.avoid_master_damage
				end
				
				return mod.class.Actor.onTakeHit(self, value, src)
      end,
      on_act = function(self)
         -- clean up
         if self.summoner.dead then
            self:die(self)
         end
      end
                                           }
   self:attr("summoned_times", 1)
   return npc
end

newTalent{
	name = "Wandering Eyes", short_name="REK_HEKA_HEADLESS_EYES",
	type = {"spell/headless-horror", 1},
	mode = "sustained",
	no_energy = true,
	require = mag_req1,
	points = 5,
	cooldown = 10,
	range = function(self, t) return self.sight - 3 end,
	unlearn_on_clone = true,
	tactical = { BUFF = 5 },
	getLevel = function(self, t) return self.level end,
	getMaxEyes = function(self, t)
		return math.min(3, math.max(1, math.floor(self:getTalentLevel(t) * 0.55)))
	end,
	getPhaseDoorLevel = function(self, t) return self:getTalentLevelRaw(t) end,
	getLashLevel = function(self, t) return self:getTalentLevelRaw(t) end,
	getBlindsideLevel = function(self, t) return self:getTalentLevelRaw(t) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "blind_immune", 1.0)
		--self:talentTemporaryValue(p, "sight", -9)
	end,
	
	activate = function(self, t)
		local ret = {}
		if core.shader.active() then
			self:talentParticles(ret, {type="shader_shield", args={toback=true,  size_factor=1, img="call_shadows"}, shader={type="rotatingshield", noup=2.0, cylinderRotationSpeed=1.7, appearTime=0.2}})
			self:talentParticles(ret, {type="shader_shield", args={toback=false, size_factor=1, img="call_shadows"}, shader={type="rotatingshield", noup=1.0, cylinderRotationSpeed=1.7, appearTime=0.2}})
		end
		return ret
	end,
	deactivate = function(self, t, p)
		-- unsummon the eyes
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.is_wandering_eye then
				e.summon_time = 0
			end
		end
		return true
	end,
	
	nbEyesUp = function(self, t)
		if not game.level then return 0 end
		local eyeCount = 0
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.is_wandering_eye then eyeCount = eyeCount + 1 end
		end
		return eyeCount
	end,
	summonEye = function(self, t)
		local eyeCount = 0
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.is_wandering_eye then eyeCount = eyeCount + 1 end
		end
		
		if eyeCount >= t.getMaxEyes(self, t) then
			return false
		end
		
		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 8, true, {[Map.ACTOR]=true})
		if not x then
			return false
		end
		
		local level = t.getLevel(self, t)
		local tBlink = self:knowTalent(self.T_REK_HEKA_HEADLESS_BLINK) and self:getTalentFromId(self.T_REK_HEKA_HEADLESS_BLINK) or nil
		local tPhylactery = self:knowTalent(self.T_REK_HEKA_HEADLESS_SHIELD) and self:getTalentFromId(self.T_REK_HEKA_HEADLESS_SHIELD) or nil
		local tStagger = self:knowTalent(self.T_REK_HEKA_HEADLESS_ADAPT) and self:getTalentFromId(self.T_REK_HEKA_HEADLESS_ADAPT) or nil
		
		local eye = createEye(self, level, t, tPhylactery, tBlink, tStagger, 1000, nil)
		
		eye:resolve()
		eye:resolve(nil, true)
		eye:forceLevelup(level)
		game.zone:addEntity(game.level, eye, "actor", x, y)
		eye:feed()
		game.level.map:particleEmitter(x, y, 1, "teleport_in")
		
		-- Reduce power of eyes for low level rares
		if self.inc_damage and self.inc_damage.all and self.inc_damage.all < 0 then
			eye.inc_damage.all = (eye.inc_damage.all or 0) + self.inc_damage.all
		end
		
		eye.no_party_ai = true
		eye.unused_stats = 0
		eye.unused_talents = 0
		eye.unused_generics = 0
		eye.unused_talents_types = 0
		eye.no_points_on_levelup = true
		if game.party:hasMember(self) then
			eye.remove_from_party_on_death = true
			game.party:addMember(eye, { control="no", type="summon", title="Summon"})
		end
		
		game:playSoundNear(self, "talents/spell_generic")
	end,
	callbackOnActBase = function(self, t)
		if not self.eyes then
			self.eyes = {
				remainingCooldown = 0
			}
		end
		
		if game.zone.wilderness then return false end
		
		self.eyes.remainingCooldown = self.eyes.remainingCooldown - 1
		if self.eyes.remainingCooldown > 0 then return false end
		self.eyes.remainingCooldown = 10
		
		t.summonEye(self, t)
		return true
	end,
	info = function(self, t)
		local maxEyes = t.getMaxEyes(self, t)
		return ([[Reorganize your head, allowing your eyes to fly free.
Each Wandering Eye is a weak combatant that can attack with magical blasts or a life-draining bite attack. You can have %d wandering eyes at once and they will regrow after 10 turns if killed.
Your sight radius becomes 1, but you cannot be blinded and can see through each eye out to a range of 7.  Any other increases and decreases to your sight radius apply to your eyes.  
You cannot hurt or be hurt by your own eyes.]]):tformat(maxEyes)
	end,
}


newTalent{
	name = "Ocular Phylactery", short_name="REK_HEKA_HEADLESS_SHIELD",
	type = {"spell/headless-horror", 2}, require = mag_req2, points = 5,
	mode = "passive",
	getRedirectThreshold = function(self, t) return self:combatTalentLimit(t, 15, 66, 30) end,
	getReinforcement = function(self, t) return self.level*0.8 end,
	callbackOnTakeDamage = function (self, t, src, x, y, type, dam, state, no_martyr)
		local split = dam / 3
		local remaining = dam
		local sent = 0
		local factor = (100-t.getReinforcement(self, t))/100
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.is_wandering_eye then
				if e.life > (e.max_life * t.getRedirectThreshold(self, t) / 100) then
					local blocked = math.min(e.life/factor, split)
					remaining = math.max(0, remaining - blocked)
					sent = sent + blocked
					state.no_reflect = true
					e.avoid_master_damage = 1
					-- takeHit since it already went through the player and to skip log
					--DamageType.defaultProjector(src, e.x, e.y, type, blocked*factor, state)
					e:takeHit(blocked*factor, src)
					e.avoid_master_damage = 0
					state.no_reflect = nil
				end
			end
		end
		if sent > 0 then
			game:delayedLogDamage(src, self, 0, ("%s(%d to eyes)#LAST#"):tformat(DamageType:get(type).text_color or "#aaaaaa#", sent), false)
		end
		return {dam=remaining}
   end,
		info = function(self, t)
		local threshold = t.getRedirectThreshold(self, t)
		return ([[Your body is just an anchor; it is able to endure any hardship as long as your attention holds.  Each wandering eye absorbs 1/3 of the damage you take as long as the its life is above %d%% of its maximum.  This absorbed damage is further reduced by %0.1f%%, based on level.
Each level in this talent also increases your the life regeneration of your eyes.]]):tformat(threshold, t.getReinforcement(self, t))
		end,
}

newTalent{
	name = "Blink", short_name="REK_HEKA_HEADLESS_BLINK",
	type = {"spell/headless-horror", 3}, require = mag_req3, points = 5,
	cooldown = 6,
	range = 7,
	requires_target = true,
	tactical = { ATTACK = 2, HEAL = 1 },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nowarning=true} end,
	on_pre_use = function(self, t, silent)
		if not self:isTalentActive(self.T_REK_HEKA_HEADLESS_EYES) then
			if not silent then game.logPlayer(self, "You have no eyes to blink!") end
			return false
		end
		if self:callTalent(self.T_REK_HEKA_HEADLESS_EYES, "nbEyesUp") == 0 then
			if not silent then game.logPlayer(self, "You have no eyes to blink!") end
			return false
		end
		return true
	end,
	getIncDamage = function(self, t)
		return math.floor(math.sqrt(self:getTalentLevel(t)) * 45)
	end,
	getCombatAtk = function(self, t)
		return math.floor(math.sqrt(self:getTalentLevel(t)) * 28)
	end,
	action = function(self, t)
		local target = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(target)
		if not target then return nil end
		
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.is_wandering_eye then
				-- reset target and set to focus
				e.ai_target.x = nil
				e.ai_target.y = nil
				e.ai_target.actor = target
				e.ai_target.focus_on_target = true
				e.ai_target.blindside_chance = 100
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Passively strengthen the attacks of your eyes, giving them %d%% extra Accuracy and %d%% extra damage.
You can activate this talent to have each eye use its bite attack on a chosen target.]]):tformat(t.getCombatAtk(self, t), t.getIncDamage(self, t))
	end
}

newTalent{
	name = "Reproachful Gaze", short_name="REK_HEKA_HEADLESS_ADAPT",
	type = {"spell/headless-horror", 4}, require = mag_req4, points = 5,
	mode = "passive",
	getStaggerLevel = function(self, t) return self:getTalentLevelRaw(t) end,
	getSP = function(self, t) return self.level + self:combatTalentScale(t, 10, 50) end,
	getSelfSP = function(self, t) return math.floor((self.level + self:combatTalentScale(t, 10, 50))/8) end,
	getKnockChance = function(self, t) return self:combatTalentScale(t, 25, 66) end,
	info = function(self, t)
		return ([[Your eyes open upon realms of distortion and impossibility, increasing their spellpower by %d, your spellpower by %d per eye, and giving them a %d%% chance to cast Staggering Gaze on enemies in melee range.  This talent stuns for 3 turns and pushes the target towards you, their summoner.
The spellpower bonuses increase with level.]]):tformat(t.getSP(self, t), t.getSelfSP(self, t), t.getKnockChance(self, t))
	end,
}
