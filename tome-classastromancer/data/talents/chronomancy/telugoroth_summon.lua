local Object = require "mod.class.Object"

newTalent{
	name = "Summon: Teluvorata", short_name = "WANDER_SUMMON_TIME",
	type = {"chronomancy/morass", 1},
	require = spells_req_high1,
	points = 5,
	message = "@Source@ conjures a Teluvorata!",
	paradox = function (self, t) return getParadoxCost(self, t, 18) end,
	cooldown = 9,
	range = 5,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { TEMPORAL = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "You cannot summon; you are suppressed!") return end
		return not checkMaxSummonStar(self, silent)
	end,
	incStats = function(self, t, fake)
		local mp = self:combatSpellpower()
		return{ 
			mag=(fake and mp or self:spellCrit(mp)) * 1.25 * self:combatTalentScale(t, 0.2, 1, 0.75),
			wil=(fake and mp or self:spellCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75),
			con=(fake and mp or self:spellCrit(mp)) * 1.2 * self:combatTalentScale(t, 0.2, 1, 0.75)
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
		
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "elemental", subtype = "time",
			display = "E", color=colors.DARK_TAN, image = "npc/elemental_temporal_teluvorta.png",
			name = "Teluvorta", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			ai_tactic = resolvers.tactic"ranged",
			stats = {str=15, dex=27, con=25, cun=27, wil=27, mag=27},
			inc_stats = t.incStats(self, t),
			level_range = {self.level, self.level}, exp_worth = 0,
			
			max_life = resolvers.rngavg(5,10),
			combat_spellpower = self:combatSpellpowerRaw(),
			life_rating = 10,
			infravision = 10,
			movement_speed = 1.0,
			
			combat_armor = 0, combat_def = 20,
			combat = { dam=1, atk=1, damtype=DamageType.TEMPORAL },
			on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },
			
			resolvers.talents{
				[self.T_DUST_TO_DUST]=self:getTalentLevel(t),
				[self.T_REALITY_SMEARING]=self:getTalentLevel(t),
				[self.T_TEMPORAL_WAKE]=self:getTalentLevel(t),
				[self.T_DIMENSIONAL_STEP]=self:getTalentLevel(t),
											 },
			talent_cd_reduction = {
				[Talents.T_DUST_TO_DUST]=3,
				[Talents.T_DIMENSIONAL_STEP]=8
			},

			resists = { [DamageType.TEMPORAL] = self:getTalentLevel(t)*20 },
			
			no_breath = 1,
			poison_immune = 1,
			cut_immune = 1,
			disease_immune = 1,
			stun_immune = 1,
			blind_immune = 1,
			knockback_immune = 1,
			confusion_immune = 1,
			
			summoner = self, summoner_gain_exp=true, wild_gift_summon=false,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target},
			resolvers.sustains_at_birth(),
		}
		local augment = self:hasEffect(self.EFF_WANDER_UNITY_CONVERGENCE)
		if augment then
			if augment.ultimate then
				m[#m+1] = resolvers.talents{
					[self.T_TIME_DILATION]=self:getTalentLevelRaw(t),
					[self.T_SPEED_SAP]=self:getTalentLevelRaw(t)
																	 }
				m.size_category = 5
				m.name = "Ultimate "..m.name
			else
				m[#m+1] = resolvers.talents{ [self.T_TIME_DILATION]=self:getTalentLevelRaw(t) }
				m.size_category = 4
				m.name = "Greater "..m.name
			end
			augment.count = augment.count-1
			if augment.count <= 0 then self:removeEffect(self.EFF_WANDER_UNITY_CONVERGENCE) end
		end
		
		setupSummonStar(self, m, x, y)
		game:playSoundNear(self, "talents/warp")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		return ([[Conjure a teluvorta from the weave of time for %d turns. These living Time Storms disintegrate and stun enemies as they teleport around.
Its attacks improve with your level and talent level.
It will gain bonus stats (increased further by spell criticals): %d Constitution, %d Magic, %d Willpower.
It gains bonus Spellpower equal to your own.
It inherits your: increased damage%%, resistance penetration, pin immunity, armour penetration.]]):format(t.summonTime(self, t), incStats.con, incStats.mag, incStats.wil)
	end,
}

newTalent{
	name = "Time Slide", short_name = "WANDER_TIME_SKIP",
	type = {"chronomancy/morass",2},
	require = spells_req_high2,
	points = 5,
	cooldown = 6,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	tactical = { ATTACK = {TEMPORAL = 1}, DISABLE = 1 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDuration = function(self, t) return math.max( 1, getExtensionModifier(self, t, 2 + math.ceil(self:combatTalentScale(t, 0.3, 2.3)))) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		if target:attr("timetravel_immune") then
			game.logSeen(target, "%s is immune to temporal manipulation!", target.name:capitalize())
			return true
		end
		
		game.level.map:particleEmitter(x, y, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		
		-- If they're dead don't remove them from time
		if target.dead or target.player then return true end
		
		-- Check hit
		local power = getParadoxSpellpower(self, t)
		local hit = self:checkHit(power, target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
		if not hit then game.logSeen(target, "%s resists!", target.name:capitalize()) return true end
		
		-- Apply spellshock and destabilization
		target:crossTierEffect(target.EFF_SPELLSHOCKED, getParadoxSpellpower(self, t))
		target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=getParadoxSpellpower(self, t, 0.3)})
		
		-- Placeholder for the actor
		local oe = game.level.map(x, y, Map.TERRAIN+1)
		if (oe and oe:attr("temporary")) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then game.logPlayer(self, "Something has prevented the timetravel.") return true end
		local e = mod.class.Object.new{
			old_feat = oe, type = "temporal", subtype = "instability",
			name = "temporal instability",
			display = '&', color=colors.LIGHT_BLUE,
			temporary = t.getDuration(self, t),
			canAct = false,
			target = target,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				-- return the rifted actor
				if self.temporary <= 0 then
					-- remove ourselves
					if self.old_feat then game.level.map(self.target.x, self.target.y, engine.Map.TERRAIN+1, self.old_feat)
					else game.level.map:remove(self.target.x, self.target.y, engine.Map.TERRAIN+1) end
					game.nicer_tiles:updateAround(game.level, self.target.x, self.target.y)
					game.level:removeEntity(self)
					game.level.map:removeParticleEmitter(self.particles)
					
					-- return the actor and reset their values
					local mx, my = util.findFreeGrid(self.target.x, self.target.y, 20, true, {[engine.Map.ACTOR]=true})
					local old_levelup = self.target.forceLevelup
					local old_check = self.target.check
					self.target.forceLevelup = function() end
					self.target.check = function() end
					game.zone:addEntity(game.level, self.target, "actor", mx, my)
					self.target.forceLevelup = old_levelup
					self.target.check = old_check
				end
			end,
			summoner_gain_exp = true, summoner = self,
																	}
		
		-- Remove the target
		game.logSeen(target, "%s has moved forward in time!", target.name:capitalize())
		game.level:removeEntity(target, true)
		
		-- add the time skip object to the map
		local particle = Particles.new("wormhole", 1, {image="shockbolt/terrain/temporal_instability_yellow", speed=1})
		particle.zdepth = 6
		e.particles = game.level.map:addParticleEmitter(particle, x, y)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN+1, e)
		game.level.map:updateMap(x, y)
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Perform an inverted summoning to banish a target into the future.  They will be removed from time (#SLATE#Spellpower vs. Spell#LAST#) for %d turns, unable to act or be affected by anything.
Paradox: Affects duration]]):format(duration)
	end,
}

--Give summons turns
newTalent{
	name = "Braided Threads", short_name = "WANDER_TIME_BOOST",
	type = {"chronomancy/morass", 3},
	require = spells_req_high3,
	points = 5,
	--cooldown = 1,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	getTicks = function(self, t) return self:combatTalentSpellDamage(t, 50, 750, getParadoxSpellpower(self, t)) end,
	on_pre_use = function(self, t, silent)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.type == "elemental" then
					return true
				end
			end
		end
		if not silent then game.logPlayer(self, "You require allies to speed up") end
		return false
	end,
	action = function(self, t)
		local apply = function(a)
			local gain = t.getTicks(self, t)
			gain = math.min(gain, 1000)
			a.energy.value = a.energy.value + gain
		end
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.type == "elemental" then
					apply(act)
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.type == "elemental" then
					apply(act)
				end
			end
		end
		game:playSoundNear(self, "talents/wander_bell")
		return true
	end,
	info = function(self, t)
		local ticks = math.min(1000, t.getTicks(self, t)) / 10
		return ([[Diffuse your temporal energy across your allies, giving each of your elemental summons %d%% of a turn.
This has no cooldown.
Paradox: Affects turn gain.]]):format(ticks)
	end,
}

--Spells cooldown faster, generates paradox each turn, deactivates on major anomaly
newTalent{
   name = "Time Flood", short_name = "WANDER_TIME_COOLDOWN",
   type = {"chronomancy/morass", 4},
   require = spells_req_high4,
   points = 5,
   cooldown = 30,
   mode = "sustained",
   fixed_cooldown = true,
   no_npc_use = true,
   getParadox = function(self, t) return self:combatTalentScale(t, 100, 60) end,

   callbackOnActBase = function(self, t)
      local chance = self:paradoxFailChance()
      local anom_type = "normal"
      if rng.percent(chance) then
	 -- if minor anomaly, carry on
	 if self:getModifiedParadox() >= 600 then
	    anom_type = "major"
	 end
	 self:paradoxDoAnomaly(100, t.getParadox(self, t),
			       {anomaly_type=anom_type,
				ignore_energy=true, allow_target=false})
      end

      if anom_type == "major" then
	 -- if major anomaly, deactivate
	 self:forceUseTalent(self.T_WANDER_TIME_COOLDOWN, {ignore_energy=true})
      else
	 -- if no anomaly, double cooldown rate
	 if not self:attr("no_talents_cooldown") then
	    for tid, _ in pairs(self.talents_cd) do
	       local t = self:getTalentFromId(tid)
	       if t and not t.fixed_cooldown then
		  self.talents_cd[tid] = self.talents_cd[tid] - 1
	       end
	    end
	 end
	 self:incParadox(t.getParadox(self, t))
      end
   end,
   activate = function(self, t)
      local ret = {}
      game:playSoundNear(self, "talents/wander_tick")
      return ret
   end,
   deactivate = function(self, t, p)
      return true
   end,
   info = function(self, t)
      return ([[Summon raw temporal energy from the weave and funnel it into yourself, causing your talents to recharge twice as fast.  This will increase your paradox by %d per turn, possibly causing an anomaly.  If it causes an major anomaly, the spell will be forcibly deactivated.]]):
	 format(t.getParadox(self, t))
   end,
}
