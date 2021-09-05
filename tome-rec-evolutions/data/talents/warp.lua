knowRessource = Talents.main_env.knowRessource
makeParadoxClone = Talents.main_env.makeParadoxClone
doWardenWeaponSwap = Talents.main_env.doWardenWeaponSwap
wardenPreUse = Talents.main_env.wardenPreUse
doWardenPreUse = Talents.main_env.doWardenPreUse
archerPreUse = Talents.main_env.archerPreUse
archeryWeaponCheck = Talents.main_env.archeryWeaponCheck
archery_range = Talents.main_env.archery_range

newTalent{
	name = "Warp Rider", short_name = "REK_EVOLUTION_TEMPORAL_WARDEN_WARP_RIDER",
	type = {"uber/dexterity", 1},
	uber = true,
	require = {
		stat = {dex = 50},
		level = 25,
		birth_descriptors={{"subclass", "Temporal Warden"}},
		special={
			desc="Have not learned Threaded Combat",
			fct=function(self)
				return self:knowTalentType("chronomancy/threaded-combat") == false
			end,
		},
		special2={
			desc="Wield Epoch's Curve",
			fct=function(self)
				if game.state.birth.ignore_prodigies_special_reqs then return true end
				local o, item, inven_id = self:findInAllInventoriesBy("define_as", "EPOCH_CURVE")
				if not o or not self:getInven(inven_id).worn then return false end
				return true
			end,
		}
	},
	is_class_evolution = "Temporal Warden",
	cant_steal = true,
	mode = "passive",
	is_spell = true,
	no_npc_use = true,
	unlearn_on_clone = true,
	getChance = function(self, t) return 50 end,
	findTarget = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local target_type = Map.ACTOR
				local a = game.level.map(x, y, Map.ACTOR)
				if a and not a.dead and self:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
					tgts[#tgts+1] = a
				end
			end
		end
		return tgts
	end,
	cleanupClone = function(self, t, clone)
		if not self or not clone then return false end
		if not clone.dead then clone:die() end
		for _, ent in pairs(game.level.entities) do
			-- Replace clone references in timed effects so they don't prevent GC
			if ent.tmp then
				for _, eff in pairs(ent.tmp) do
					if eff.src and eff.src == clone then eff.src = self end
				end
			end
		end
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted)
		if not hitted then return end
		if not rng.percent(t.getChance(self, t)) then return end

		-- Make our clone
		local m = makeParadoxClone(self, self, 0)
		m:attr("archery_pass_friendly", 1)
		doWardenWeaponSwap(m, t, "bow")
		m.on_added_to_level = function(self)
			if not self.blended_target.dead then
				local targets = self:archeryAcquireTargets(nil, {one_shot=true, x=self.blended_target.x, y=self.blended_target.y, no_energy = true})
				if targets then
					self:forceUseTalent(self.T_SHOOT, {ignore_cd=true, ignore_energy=true, force_target=self.blended_target, ignore_ressources=true, silent=true})
				end
			end
			self:die()
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		end
		
		-- Find a good location for our shot
		local function find_space(self, target, clone)
			local poss = {}
			local range = util.getval(archery_range, clone, t)
			local x, y = target.x, target.y
			for i = x - range, x + range do
				for j = y - range, y + range do
					if game.level.map:isBound(i, j) and
						core.fov.distance(x, y, i, j) <= range and -- make sure they're within arrow range
						core.fov.distance(i, j, self.x, self.y) <= range/2 and -- try to place them close to the caster so enemies dodge less
						self:canMove(i, j) and target:hasLOS(i, j) then
						poss[#poss+1] = {i,j}
					end
				end
			end
			if #poss == 0 then return end
			local pos = poss[rng.range(1, #poss)]
			x, y = pos[1], pos[2]
			return x, y
		end
		
		local tgts = t.findTarget(self, t)
		if #tgts > 0 then
			local a, id = rng.tableRemove(tgts)
			local tx, ty = find_space(self, target, m)
			if tx and ty then
				m.blended_target = a
				game.logSeen(self, "%s calls forth a temporal warden from another timeline.", self:getName():capitalize())
				game.zone:addEntity(game.level, m, "actor", tx, ty)
			end
		end
		t.cleanupClone(self, t, m)
	end,
	passives = function(self, t, p)
	self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_WARP_BLADE] = 4})
	self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_BLINK_BLADE] = 4})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_BLADE_SHEAR] = 6})

		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_FOLD_FATE] = 1})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_FOLD_WARP] = 4})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_FOLD_GRAVITY] = 1})
	end,
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
	on_learn = function(self, t)
		t.unlearnTalents(self, t, {["chronomancy/bow-threading"]=true})
		self.talents_types["chronomancy/threaded-combat"] = nil
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_SHOOT)
			if pos then self.hotkey[pos] = nil end
		end
	end,
	info = function(self, t)
		return ([[#{italic}#Lay down the bow.  In this timeline, you only need the blades.#{normal}#

You forget Bow Threading, and become unable to learn Threaded Combat.
Blade Threading talents have their cooldowns greatly reduced, and you can trigger Weapon Manifold more often.
All melee attacks have a %d%% chance to trigger your alternate selves to fire an arrow into this timeline.
]]):tformat(t:_getChance(self))
	end,
}
