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
	local clone_copy = {name=("%s's temporal clone"):tformat(target:getName()),
		desc=_t[[A creature from another timeline.]],
		faction=target.faction, exp_worth=0,
		life=util.bound(target.life, target.die_at, target.max_life),
		summoner=target, summoner_gain_exp=true, summon_time=duration,
		max_level=target.level,
		ai_target={actor=table.NIL_MERGE}, ai="summoned",
		ai_real="tactical", ai_tactic={escape=0}, -- Clones never flee because they're awesome
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
		if t.type[1]:find("^demented/prism") and m:knowTalent(tid) then tids[#tids+1] = t end
		if (t.no_npc_use or t.unlearn_on_clone) and not t.allow_temporal_clones then tids[#tids+1] = t end
	end
	for i, t in ipairs(tids) do
		if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true, silent=true}) end
		m:unlearnTalentFull(t.id)
	end

	-- Remove some timed effects
	m:removeTimedEffectsOnClone()

	-- shred life
	m.max_life = math.floor(m.max_life / 2)
	m.life = math.min(m.life, m.max_life)
	m.die_at = math.ceil((m.die_at or 0) / 2)
	
	-- A bit of sanity in case anyone decides they should blow up the world.
	if m.preferred_paradox and m.preferred_paradox > 600 then m.preferred_paradox = 600 end

	-- Prevent respawning
	m.self_resurrect = nil

	-- Mark as correct type of clone
	m.is_luminous_reflection = true
	
	return m
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
	type = {"demented/prism", 1},
	require = mag_req_slow, points = 5,
	mode = "passive",
	unlearn_on_clone = true,
	getCount = function(self, t) return 2 end,
	getReduction = function(self, t) return self:combatTalentLimit(t, 40, 75, 50) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "generic_damage_penalty", t.getReduction(self, t))
		self:talentTemporaryValue(p, "reflection_damage_amp", t.getReduction(self, t))
	end,
	callReflections = function(self, t)
		
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
		self:setProc("shining_prism_recharging", true, 10)
		--todo separate death timers
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
		end
		if state == true then
			local refs = getPrisms(self)
			if #refs == 0 then
				t.callReflections(self, t)
				t.callReflections(self, t)
			elseif #refs == 1 then
				t.callReflections(self, t)
			end
		end
	end,
	callbackOnActBase = function(self, t)
		if not self.in_combat then return end
		if self:hasProc("shining_prism_recharging") then return end
		local refs = getPrisms(self)
		if #refs == 0 then
			t.callReflections(self, t)
			t.callReflections(self, t)
		elseif #refs == 1 then
			t.callReflections(self, t)
		end
	end,
	info = function(self, t)
		return ([[Whenever you enter combat, you are joined by %d reflections of yourself.  They are identical to you except that they lack Prism talents and have half your life.  
You and your reflections deal %d%% less damage.  
All damage taken is shared between you and your reflections.
If killed, your reflections will reemerge after 10 turns.
]]):tformat(t.getCount(self, t), t.getReduction(self, t))
	end,
}

newTalent{
	name = "Convergence", short_name = "REK_SHINE_PRISM_CONVERGENCE",
	type = {"demented/prism", 2}, require = mag_req2, points = 5,
	cooldown = 3,
	positive = -5,
	insanity = 4,
	tactical = { ATTACKAREA = { LIGHT = 2 } },
	range = 10,
	is_beam_spell = true,
	requires_target = true,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), talent=t, selffire=false} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 120) end,
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
			local _ _, px, py = self:canProject(tg, x, y)
			if px and py then
				local grids = self:project(tg, x, y, DamageType.LIGHT, dam)
				game.level.map:particleEmitter(prism.x, prism.y, math.max(math.abs(x-prism.x), math.abs(y-self.y)), "light_beam", {tx=x-prism.x, ty=y-prism.y})
			end
			self.__project_source = old_source
		end
		game:playSoundNear(self, "talents/reality_breach")
		return true
	end,
	info = function(self, t)
		return ([[Fire a beam of solar energy, dealing %0.2f light damage.  Your reflections also cast an identical beam at the same target.]]):tformat(damDesc(self, DamageType.LIGHT, t:_getDamage(self)))
	end,
}

newTalent{
	name = "Synchronicity", short_name = "REK_SHINE_PRISM_SYNCHRONY",
	type = {"demented/prism", 3},
	require = mag_req3, points = 5,
	mode = "passive",
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
		self.talent_on_spell = self.talent_on_spell or {}
		self.talent_on_spell["REK_SHINE_PRISM_CONVERGENCE"] = nil
		t.learnOnHit(self, t)
	end,
	on_unlearn = function(self, t)
		self.talent_on_spell = self.talent_on_spell or {}
		self.talent_on_spell["REK_SHINE_PRISM_CONVERGENCE"] = nil
		if self:getTalentLevel(t) > 0 then
			t.learnOnHit(self, t)
		end
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Your magic is aligned with solar cycles: day and night, zenith and nadir, apsis...in any case, not under your full control.
Whenever you deal damage with a spell, you have a %d%% chance to freely cast Convergence.
]]):tformat(t.getChance(self, t))
	end,
}

newTalent{
	name = "Mirror Barrier", short_name = "REK_SHINE_PRISM_MIRROR_SHIELD",
	type = {"demented/prism", 4},	require = mag_req4,	points = 5,
	cooldown = 15,
	positive = -15,
	insanity = -20,
	getAbsorb = function(self, t) return self:combatTalentSpellDamage(t, 25, 555) end,
	getDuration = function(self, t) return 6 end,
	action = function(self, t)
		local duration = t.getDuration(self, t)
		local x, y = self.x, self.y
		local radius = 1
		local refs = getPrisms(self)
		refs[#refs+1] = self
		-- TODO better way to find shape that covers all points
		local ax, ay = 0, 0
		for i, prism in ipairs(refs) do
			ax = ax + prism.x
			ay = ay + prism.y
		end
		ax = math.round(ax/#refs)
		ay = math.round(ay/#refs)
		for i, prism in ipairs(refs) do
			radius = math.max(radius, core.fov.distance(prism.x, prism.y, ax, ay))
		end
		
		local map_eff = game.level.map:addEffect(
			self, ax, ay, duration, DamageType.REK_SHINE_MIRROR, 
			{dam = self:getShieldAmount(self:spellCrit(t.getAbsorb(self, t))), radius = radius, self = self, talent = t}, 
			0, 5, nil, 
			{type="warning_ring", args = {radius = radius}},
			function(e, update_shape_only) end)
		map_eff.name = t.name
		return true
	end,
	info = function(self, t)
		return ([[Bend light into a stationary circular barrier that encompasses you and your clones.  Any attacks from outside the barrier going inward will be reflected, up to %d points of damage total.  The barrier lasts %d turns.
The maximum damage reflected will increase with your spellpower.]]):tformat(t.getAbsorb(self, t), t.getDuration(self, t))
	end,
}

class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)

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
		reflected = reflected * 100 / (target:attr("reflection_damage_amp") or 100)
		DamageType.defaultProjector(target, src.x, src.y, type, reflected, state)
		state.no_reflect = nil
	end
	return hd
end)