newTalent{
	name = "Unify Reflections", short_name = "REK_SHINE_PRISM_REMOVER",
	type = {"demented/other", 1},
	require = mag_req_slow, points = 1,
	unlearn_on_clone = true,
	no_unlearn_last = true,
	unlearnTalents = function(self, t, cats)
		local tids = {}
		local types = {}
		for id, lvl in pairs(self.talents) do
			local t = self.talents_def[id]
			if t.type[1] and cats[t.type[1]] ~= nil then
				types[t.type[1]] = true
				tids[id] = lvl
			end
		end
		local unlearnt = 0
		for id, lvl in pairs(tids) do self:unlearnTalent(id, lvl, nil, {no_unlearn=true}) unlearnt = unlearnt + lvl end
		self.unused_talents = self.unused_talents + unlearnt
		
		for cat, v in pairs(cats) do
			if self.__increased_talent_types[cat] then
				self.unused_talents_types = self.unused_talents_types + 1
			end
			self.talents_types[cat] = nil
		end
	end,
	action = function(self, t)
		-- remove reflections
		for uid, minion in pairs(game.level.entities) do
			if minion.is_luminous_reflection and minion.summoner and minion.summoner == self then
				if game.party:hasMember(minion) then
					game.party:removeMember(minion, true)
				end
				minion:disappear(self)
			end
		end

		-- remove the main talents
		t.unlearnTalents(self, t, {["demented/prism"] = true})

		-- get the new talents
		self:learnTalentType("demented/broken-prism", true)
		self:setTalentTypeMastery("demented/broken-prism", 1.3)

		-- unlearn this
		self:unlearnTalentFull(t.id)
	end,
	info = function(self, t)
		return ([[Use this talent to exchange the Prism tree for the Broken Prism tree, which is similar but has no clones. This is permanent and irreversible.
This talent will dissappear when you learn Trinary.]]):tformat()
	end,
}
	
newTalent{
	name = "Divergence", short_name = "REK_SHINE_PRISM_DIVERGENCE",
	type = {"demented/broken-prism", 1}, require = mag_req1, points = 5,
	cooldown = 3,
	positive = -5,
	insanity = 8,
	tactical = { ATTACKAREA = { LIGHT = 2 } },
	range = 10,
	is_beam_spell = true,
	requires_target = true,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), talent=t, selffire=false} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 40) end,
	getChance = function(self, t) return math.floor(self:combatTalentLimit(t, 25, 5, 15)) end,
	learnOnHit = function(self, t)
		self.talent_on_spell["REK_SHINE_PRISM_DIVERGENCE"] = {
			chance=t.getChance(self,t),
			talent=Talents.T_REK_SHINE_PRISM_DIVERGENCE,
			level=self:getTalentLevel(t)
		}
	end,
	on_learn = function(self, t)
		self.talent_on_spell = self.talent_on_spell or {}
		self.talent_on_spell["REK_SHINE_PRISM_DIVERGENCE"] = nil
		t.learnOnHit(self, t)
	end,
	on_unlearn = function(self, t)
		self.talent_on_spell = self.talent_on_spell or {}
		self.talent_on_spell["REK_SHINE_PRISM_DIVERGENCE"] = nil
		if self:getTalentLevel(t) > 0 then
			t.learnOnHit(self, t)
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(t.getDamage(self, t))

		-- main
		local _ _, px, py = self:canProject(tg, x, y)
		if px and py then
			self:project(tg, x, y, DamageType.LIGHT, dam)
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "solar_beam", {tx=x-self.x, ty=y-self.y})
		end

		-- secondary
		local targets = {}
		self:project({type="ball", selffire=false, x=px, y=py, radius=10, range=0}, px, py, function(bx, by)
				local actor = game.level.map(bx, by, Map.ACTOR)
				if actor and self:reactionToward(actor) < 0 then
					targets[#targets+1] = actor
				end
		end)

		for i = 1, 2 do
			if #targets > 0 then
				local act = rng.tableRemove(targets)
				local tgr = {type="beam", range=self:getTalentRange(t), selffire=false, talent=t, x=px, y=py}
				self:project(tgr, act.x, act.y, DamageType.LIGHT, dam)			
				game.level.map:particleEmitter(px, py, math.max(math.abs(act.x-px), math.abs(act.y-py)), "solar_beam", {tx=act.x-px, ty=act.y-py})
			end
		
		end
		game:playSoundNear(self, "talents/stardust")
		return true
	end,
	info = function(self, t)
		return ([[You each fire a beam of solar energy, and two more beams will fire from the original destination towards random targets, each dealing %0.2f light damage.
You have a %d%% chance to cast this talent automatically on spell hit.]]):tformat(damDesc(self, DamageType.LIGHT, t:_getDamage(self)), t:_getChance(self))
	end,
}

newTalent{
	name = "Unitary", short_name = "REK_SHINE_PRISM_UNITARY",
	image = "talents/rek_shine_prism_synchrony.png",
	type = {"demented/broken-prism", 2},	require = mag_req2, points = 5,
	mode = "passive",
	getSpellpowerIncrease = function(self, t) return self:combatTalentScale(t, 5, 20, 1.0) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellpower", t.getSpellpowerIncrease(self, t))
	end,
	info = function(self, t)
		return ([[You shine alone in the darkened sky. You gain %d spellpower and deal increased damage to distant enemies, up to %d%% more at range 10.]]):tformat(t.getSpellpowerIncrease(self, t), 10)
	end,
}

class:bindHook("DamageProjector:base", function(self, hd)
	local src = hd.src
	local type = hd.type
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)

	if not src or not target then return end
	if src and src.knowTalent and src:knowTalent(src.T_REK_SHINE_PRISM_UNITARY) then
		local range = math.floor(core.fov.distance(src.x, src.y, target.x, target.y))
		local mult = math.min(1.1, 1.0 + 0.01*range)
		hd.dam = dam * mult
	end
	return hd
end)

newTalent{
	name = "Kindle", short_name = "REK_SHINE_PRISM_KINDLE",
	image = "talents/rek_shine_prism_reflections.png",
	type = {"demented/broken-prism", 3},
	require = mag_req3, points = 5,
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 5, 50, 20)) end,
	fixed_cooldown = true,
	getReset = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self.max_life*0.25)
		self:attr("allow_on_heal", -1)
		for tid, cd in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.is_spell then
				self:alterTalentCoolingdown(tid, -t.getReset(self, t))
			end
		end
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[A slight shift can reveal new inner light. Heal for 25%% of your maximum life and reduce the cooldown of cooling down spell talents by %d turns.]]):tformat(t.getReset(self, t))
	end,
}

newTalent{
	name = "Mirror Barrier", short_name = "REK_SHINE_PRISM_MIRROR_SHIELD_TWO",
	image = "talents/rek_shine_prism_mirror_shield.png",
	type = {"demented/broken-prism", 4},	require = mag_req4,	points = 5,
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
