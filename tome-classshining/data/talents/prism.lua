-- @param[type=table] target  Actor to be cloned.
-- @param[type=int] duration  How many turns the clone lasts. Zero is allowed.  Nil for infinite
-- @param[type=table] alt_nodes  Optional, these nodes will use a specified key/value on the clone instead of copying from the target.
-- @  Table keys should be the nodes to skip/replace (field name or object reference).
-- @  Each key should be set to false (to skip assignment entirely) or a table with up to two nodes:
-- @    k = a name/ref to substitute for instances of this field,
-- @      or nil to use the default name/ref as keys on the clone
-- @    v = the value to assign for instances of this node,
-- @      or nil to use the default assignent value
-- @return a reference to the clone on success, or nil on failure
makeMirrorClone = function(target, duration, alt_nodes)
	if not target then return nil end
	if duration and duration < 0 then duration = 0 end

	-- Don't copy certain fields from the target
	alt_nodes = alt_nodes or {}

	-- Don't copy some additional fields for short-lived clones
	if duration == 0 then
		alt_nodes.__particles = {v = {} }
		alt_nodes.hotkey = false
		alt_nodes.talents_auto = {v = {} }
		alt_nodes.talents_confirm_use = {}
	end

	-- force some values in the clone
	local clone_copy = {name=("%s's reflection"):tformat(target:getName()),
		desc=_t[[A creature formed from light.]],
		faction=target.faction, exp_worth=0,
		life=util.bound(target.life, target.die_at, target.max_life),
		summoner=target, summoner_gain_exp=true, summon_time=duration,
		max_level=target.level,
		ai_target={actor=table.NIL_MERGE}, ai="summoned",
		ai_real="tactical", ai_tactic={escape=0},
		shader = "shadow_simulacrum",
	}
	
	-- Clone the target (Note: inventory access is disabled by default)
	local m = target:cloneActor(clone_copy, alt_nodes)

	mod.class.NPC.castAs(m)
	engine.interface.ActorFOV.init(m)
	engine.interface.ActorAI.init(m, m)

	-- Remove some unallowed talents
	local tids = {}
	for tid, _ in pairs(m.talents) do
		local t = m:getTalentFromId(tid)
		if tid == m.T_BATHE_IN_LIGHT then tids[#tids+1] = t end
		if t.type[1]:find("^demented/prism") and m:knowTalent(tid) then tids[#tids+1] = t end
		if t.type[1]:find("^demented/core%-gate") and m:knowTalent(tid) then tids[#tids+1] = t end
		if t.type[1]:find("^celestial/seals") and m:knowTalent(tid) then tids[#tids+1] = t end
		if (t.no_npc_use or t.unlearn_on_clone) and not t.allow_temporal_clones then tids[#tids+1] = t end
	end
	for i, t in ipairs(tids) do
		if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true, silent=true}) end
		m:unlearnTalentFull(t.id)
	end
	m:learnTalent(m.T_WTW_DESTRUCT, true, 1)

	-- Remove some timed effects
	m:removeTimedEffectsOnClone()

	-- shred life
	m.max_life = math.floor(m.max_life * 0.4)
	m.life = math.min(m.life, m.max_life)
	m.die_at = math.ceil((m.die_at or 0) * 0.4)
	
	if m.preferred_paradox and m.preferred_paradox > 600 then m.preferred_paradox = 600 end

	-- Prevent respawning
	m.self_resurrect = nil

	-- Mark as correct type of clone
	m.is_luminous_reflection = true
	
	return m
end

function hasPrismMatch(self, chirality)
	local prisms = {}
	for uid, act in pairs(game.level.entities) do
		if act.summoner and act.summoner == self and act.is_luminous_reflection and act.chirality == chirality then
			return true
		end
	end
	return false
end

function getPrisms(self)
	local prisms = {}
	if game.party and game.party:hasMember(self) then
		for act, def in pairs(game.party.members) do
			if act.is_luminous_reflection then
				prisms[#prisms+1] = act
			end
		end
	else
		for uid, act in pairs(game.level.entities) do
			if act.summoner and act.summoner == self and act.is_luminous_reflection then
				prisms[#prisms+1] = act
			end
		end
	end
	return prisms
end

newTalent{
	name = "Split Reflections", short_name = "REK_SHINE_PRISM_REFLECTIONS",
	type = {"demented/other", 1},
	require = mag_req_slow, points = 5,
	mode = "passive",
	unlearn_on_clone = true,
	getCount = function(self, t) return 2 end,
	getReduction = function(self, t) --return self:combatTalentLimit(t, 40, 75, 56.3) end,
		return math.max(55, 75 - self.level*0.8)
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "generic_damage_penalty", t.getReduction(self, t))
		self:talentTemporaryValue(p, "reflection_damage_amp", t.getReduction(self, t))
		self:talentTemporaryValue(p, "shield_factor", -0.50)
	end,
	callbackOnLevelup = function(self, t)
		self:updateTalentPassives(t)
	end,
	callReflections = function(self, t, chirality)
		if not chirality then chirality = "right" end
		if not self.stored_luminous_life then
			self.stored_luminous_life = self.max_life * 0.3
			self.max_life = self.max_life - self.stored_luminous_life 
			self.life = math.min(self.life, self.max_life)
		end
		
		-- Clone the caster
		local function makePrismClone(self, t)
			local m = makeMirrorClone(self, nil)
			-- Add and change some values
			m.name = ("%s's Reflection"):tformat(self:getName())
			m.desc = ([[The other %s, revealed by the light.]]):tformat(self:getName())
			
			-- Handle some AI stuff
			m.ai_state = { talent_in=1, ally_compassion=10 }
			m.ai_state.tactic_leash = 10
			-- Try to use stored AI talents to preserve tweaking over multiple summons
			m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
			
			return m
		end
		
		-- Add our clone
		local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if tx and ty then
			-- Make our clone and add to the party
			local m = makePrismClone(self, t)
			m.generic_damage_penalty = t.getReduction(self, t)
			m.reflection_damage_amp = t.getReduction(self, t)
			m.shield_factor = (m.shield_factor or 1.0) - 0.50
			m.chirality = chirality
			if game.party:hasMember(self) then
				game.party:addMember(m, {
															 control="full",
															 type="prism clone",
															 title=_t"Prism Reflection",
															 orders = {target=true, leash=true, anchor=true, talents=true},
																})
			end
			
			-- and the level
			game.zone:addEntity(game.level, m, "actor", tx, ty)
			game.level.map:particleEmitter(m.x, m.y, 1, "temporal_teleport")
			m.insanity = self.insanity
			m.positive = self.positive
		end

		local clones = getPrisms(self)
		clones[#clones+1] = self
		for i = 1, #clones do
			local target = clones[i]
			target:setEffect(target.EFF_REK_SHINE_REFLECTION_LINK, 10, {targets=clones})
		end
		return true
	end,
	callbackOnSummonDeath = function(self, t, summon, src, death_note)
		if summon.summoner ~= self then return end
		if not summon.is_luminous_reflection then return end
		if summon.chirality == "left" then
			self:setProc("shining_prism_recharging_left", true, 10)
		else
			self:setProc("shining_prism_recharging_right", true, 10)
		end
	end,
	callbackOnCombat = function(self, t, state)
		if self.resting then self:restStop(_t"combat started!") end
		if state == false then
			for uid, minion in pairs(game.level.entities) do
				if minion.is_luminous_reflection and minion.summoner and minion.summoner == self then
					if game.party:hasMember(minion) then
						game.party:removeMember(minion, true)
					end
					minion:disappear(self)
				end
			end
			if self.stored_luminous_life then
				self.max_life = self.max_life + self.stored_luminous_life
				self.life = self.life + self.stored_luminous_life
				self.stored_luminous_life = nil
			end
		end
		if state == true then
			local refs = getPrisms(self)
			if #refs == 0 then
				t.callReflections(self, t, "left")
				t.callReflections(self, t, "right")
			elseif #refs == 1 then
				if hasPrismMatch(self, "left") then
					t.callReflections(self, t, "right")
				else
					t.callReflections(self, t, "left")
				end
			end
		end
	end,
	callbackOnActBase = function(self, t)
		if not self.in_combat then return end
		if not self:hasProc("shining_prism_recharging_left") and not hasPrismMatch(self, "left") then
			t.callReflections(self, t, "left")
		end
		if not self:hasProc("shining_prism_recharging_right") and not hasPrismMatch(self, "right") then
			t.callReflections(self, t, "right")
		end
	end,
	info = function(self, t)
		return ([[Whenever you enter combat, you are joined by %d reflections of yourself, each with 40%% of your maximum life.  Your own maximum life is lowered by 30%% while they are present.  All damage taken is shared between you and your reflections.
You and your reflections deal %d%% less damage (based on level and shown in the tooltip of each talent) and shields affecting you have their power decreased by 50%%.
If killed, your reflections will reemerge after 10 turns.

Reflections cannot learn: Prism talents, Seal talents, Core Gate talents, or Bathe in Light.
]]):tformat(t.getCount(self, t), t.getReduction(self, t))
	end,
}

newTalent{
	name = "Convergence", short_name = "REK_SHINE_PRISM_CONVERGENCE",
	type = {"demented/prism", 1}, require = mag_req1, points = 5,
	cooldown = 3,
	positive = -5,
	insanity = 8,
	tactical = { ATTACKAREA = { LIGHT = 2 } },
	range = 10,
	is_beam_spell = true,
	requires_target = true,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), talent=t, selffire=false} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 120) end,
	getChance = function(self, t) return math.floor(self:combatTalentLimit(t, 25, 5, 15)) end,
	learnOnHit = function(self, t)
		self.talent_on_spell["REK_SHINE_PRISM_CONVERGENCE"] = {
			chance=t.getChance(self,t),
			talent=Talents.T_REK_SHINE_PRISM_CONVERGENCE,
			level=self:getTalentLevel(t)
		}
	end,
	-- TODO make this not an on-learn.
	on_learn = function(self, t)
		self:learnTalent(self.T_REK_SHINE_PRISM_REFLECTIONS, true, nil, {no_unlearn=true})
		self.talent_on_spell = self.talent_on_spell or {}
		self.talent_on_spell["REK_SHINE_PRISM_CONVERGENCE"] = nil
		t.learnOnHit(self, t)
	end,
	on_unlearn = function(self, t)
		self:unlearnTalent(self.T_REK_SHINE_PRISM_REFLECTIONS)
		self.talent_on_spell = self.talent_on_spell or {}
		self.talent_on_spell["REK_SHINE_PRISM_CONVERGENCE"] = nil
		if self:getTalentLevel(t) > 0 then
			t.learnOnHit(self, t)
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(t.getDamage(self, t))
		local refs = getPrisms(self)
		refs[#refs+1] = self
		for i, prism in ipairs(refs) do
			tg.x = prism.x
			tg.y = prism.y
			local old_source = self.__project_source
			self.__project_source = prism
			local _ _, px, py = prism:canProject(tg, x, y)
			if px and py then
				local grids = self:project(tg, x, y, DamageType.LIGHT, dam)
				game.level.map:particleEmitter(prism.x, prism.y, math.max(math.abs(x-prism.x), math.abs(y-prism.y)), "solar_beam", {tx=x-prism.x, ty=y-prism.y})
			end
			self.__project_source = old_source
		end
		game:playSoundNear(self, "talents/stardust")
		return true
	end,
	info = function(self, t)
		return ([[You and your reflections each fire a beam of solar energy, dealing %0.2f light damage.
You have a %d%% chance to cast this talent automatically on spell hit.

Learning this talent splits you into 3 reflections.]]):tformat(damDesc(self, DamageType.LIGHT, t:_getDamage(self)), t:_getChance(self))
	end,
}

newTalent{
	name = "Trinary", short_name = "REK_SHINE_PRISM_SYNCHRONY",
	type = {"demented/prism", 2},	require = mag_req2, points = 5,
	on_learn = function(self, t) self:learnTalent(self.T_REK_SHINE_PRISM_REFLECTIONS, true, nil, {no_unlearn=true}) end,
	on_unlearn = function(self, t) self:unlearnTalent(self.T_REK_SHINE_PRISM_REFLECTIONS) end,
	mode = "passive",
	getSpellpowerIncrease = function(self, t) return self:combatTalentScale(t, 5, 20, 1.0) end,
	passives = function(self, t, p)
		local nb = 0
		for i = 1, #self.fov.actors_dist do
			local act = self.fov.actors_dist[i]
			if act and core.fov.distance(act.x, act.y, self.x, self.y) <= 1 and act.is_luminous_reflection and act.summoner == self then nb = nb + 1 end
		end
		self:talentTemporaryValue(p, "combat_spellpower", t.getSpellpowerIncrease(self, t)*nb)
	end,
	callbackOnAct = function(self, t)
		self:updateTalentPassives(t)
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Your and your reflections are three suns shining as one.  You gain %d spellpower for each reflection adjacent to you.]]):tformat(t.getSpellpowerIncrease(self, t))
	end,
}

newTalent{
	name = "Kaleidoscope", short_name = "REK_SHINE_PRISM_SCOPE",
	image = "talents/rek_shine_prism_reflections.png",
	type = {"demented/prism", 3},
	require = mag_req3, points = 5,
	on_learn = function(self, t) self:learnTalent(self.T_REK_SHINE_PRISM_REFLECTIONS, true, nil, {no_unlearn=true}) end,
	on_unlearn = function(self, t) self:unlearnTalent(self.T_REK_SHINE_PRISM_REFLECTIONS) end,
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 5, 50, 20)) end,
	fixed_cooldown = true,
	on_pre_use = function(self, t, silent)
		if not self:hasProc("shining_prism_recharging_left") and not self:hasProc("shining_prism_recharging_right") then
			if not silent then game.logPlayer(self, "Your reflections are ready.") end
			return false
		end
		return true
	end,
	action = function(self, t)
		if not self:hasProc("shining_prism_recharging_left") and not self:hasProc("shining_prism_recharging_right") then return nil end
		self.turn_procs.multi["shining_prism_recharging_left"] = nil
		self.turn_procs.multi["shining_prism_recharging_right"] = nil
		return true
	end,
	callbackOnAct = function(self, t)
		self:updateTalentPassives(t)
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[A slight shift can reveal new reflections. If your reflections are dead, remove the cooldown before they can reemerge.]]):tformat()
	end,
}

newTalent{
	name = "Mirror Barrier", short_name = "REK_SHINE_PRISM_MIRROR_SHIELD",
	type = {"demented/prism", 4},	require = mag_req4,	points = 5,
	on_learn = function(self, t) self:learnTalent(self.T_REK_SHINE_PRISM_REFLECTIONS, true, nil, {no_unlearn=true}) end,
	on_unlearn = function(self, t) self:unlearnTalent(self.T_REK_SHINE_PRISM_REFLECTIONS) end,
	cooldown = 15,
	positive = -15,
	insanity = -20,
	range = 6,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, nowarning=true} end,
	radius = function (self, t) return 1 end,
	getAbsorb = function(self, t) return self:combatTalentSpellDamage(t, 20, 555) end,
	getDuration = function(self, t) return 6 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		
		local map_eff = game.level.map:addEffect(
			self, x, y, duration, DamageType.REK_SHINE_MIRROR, 
			{dam = self:getShieldAmount(self:spellCrit(t.getAbsorb(self, t))), radius=radius, self=self, talent = t}, 
			radius, 5, nil, 
			--{type="warning_ring", args = {r=220, g=220, b=220, nb=120, size=3, radius=radius}},
			MapEffect.new{color_br=233, color_bg=233, color_bb=233, alpha=180, effect_shader="shader_images/radiation_effect.png"},
			function(e, update_shape_only) end)
		map_eff.name = t.name
		return true
	end,
	info = function(self, t)
		return ([[Bend light into a stationary circular barrier of radius 1.  Any attacks from outside the barrier going inward will be reflected, up to %d points of damage total.  The barrier lasts %d turns.
The maximum damage reflected will increase with your spellpower.]]):tformat(t.getAbsorb(self, t), t.getDuration(self, t))
	end,
}

class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	if not src then return hd end
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)
	if not target then return hd end

	local seff = game.level.map:hasEffectType(src.x, src.y, DamageType.REK_SHINE_MIRROR)
	local deff = game.level.map:hasEffectType(target.x, target.y, DamageType.REK_SHINE_MIRROR)
	if deff and deff ~= seff and not hd.state.no_reflect then
		local state = hd.state
		local type = hd.type
		local reflected = math.min(dam, deff.dam.dam)
		deff.dam.dam = deff.dam.dam - reflected
		if deff.dam.dam <= 0 then game.level.map:removeEffect(deff) end
		game:delayedLogMessage(src, target, "reflect_damage"..(target.uid or ""), "#CRIMSON##Target# reflects damage back to #Source#!")
		
		game:delayedLogDamage(src, target, 0, ("#GOLD#(%d to mirror barrier)#LAST#"):format(reflected), false)
		hd.dam = dam - reflected
		state.no_reflect = true
		reflected = reflectAmp(target, reflected)
		DamageType.defaultProjector(target, src.x, src.y, type, reflected, state)
		state.no_reflect = nil
	end
	return hd
end)
