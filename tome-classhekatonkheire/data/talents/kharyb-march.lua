newTalent{
	name = "Unbleeding Heart", short_name = "REK_HEKA_MARCH_HEART",
	type = {"spell/marching-sea", 1}, require = mag_req1, points = 5,
	cooldown = 11,
	hands = 20,
	tactical = { ATTACK = {PHYSICAL = 1} },
	range = 10,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 31) end,
	getDuration = function(self, t) return 11 end,
	doSpike = function(self, t, damage)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 then
					tgts[#tgts+1] = a
				end
		end end

		if #tgts <= 0 then return false end
		local target, id = rng.table(tgts)
		table.remove(tgts, id)
		
		local x, y = target.x, target.y
		if not target then return nil end

		local moveSpike = function(self, src)
			self.energy.mod = 1
			if self.homing.count <= 0 then
				game.level:removeEntity(self, true)
			 	self.dead = true
			end
		end

		local arriveSpike = function(self, src, target)
			local target = game.level.map(self.x, self.y, engine.Map.ACTOR)
			if target and src:reactionToward(target) < 0 then
				engine.DamageType:get(engine.DamageType.PHYSICAL).projector(self, self.x, self.y, engine.DamageType.PHYSICAL, self.def.dam)
			end

			game.level:removeEntity(self, true)
			self.dead = true
		end
		
		local proj = require("mod.class.Projectile"):makeHoming(
			self,
			{particle="image", particle_args={image="particles_images/birds_tropical_03", size=64}},
			{speed=5, name="Blood Spike", dam=damage},
			target, self:getTalentRange(t),
			moveSpike,	arriveSpike,	true
		)
		proj.energy.value = 1500 -- Give it a boost so it moves before our next turn
		proj.homing.count = 10  -- 10 turns max to find target
		game.zone:addEntity(game.level, proj, "projectile", self.x, self.y)

		return true
	end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_HEKA_UNBLEEDING_HEART, t:_getDuration(self), {src=self, power=t.getDamage(self, t)*getKharybdianTempo(self, t.id)})

		-- invest cost
		game:onTickEnd(function() 
				self:setEffect(self.EFF_REK_HEKA_INVESTED, t:_getDuration(self),
											 {investitures={{power=util.getval(t.hands, self, t)}}, src=self})
		end)
		
		return true
	end,
	info = function(self, t)
		return ([[Your heart beats in the sky above your anchor, pumping out homing blood spikes that deal %0.1f physical damage each.
This lasts for %d turns, and although this talent cannot critically strike, each other critical strike of yours will create an extra blood spike.
Spellpower: increases damage.
This talent invests hands; your maximum hands will be reduced by its cost until it expires.]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), t:_getDuration(self))
	end,
}

newTalent{
	name = "Smother the Flame", short_name = "REK_HEKA_MARCH_DISPEL",
	type = {"spell/marching-sea", 2},	require = mag_req2, points = 5,
	cooldown = 25,
	hands = 10,
	random_boss_rarity = 50,
	tactical = {
		DISABLE = function(self, t, aitarget)
			local nb = 0
			for eff_id, p in pairs(aitarget.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type ~= "other" and e.status == "beneficial" then nb = nb + 1 end
			end
			for tid, act in pairs(aitarget.sustain_talents) do nb = nb + 1 end
			return nb^0.5
		end
	},
	direct_hit = true,
	requires_target = function(self, t) return self:getTalentLevel(t) >= 3 and (self.player or t.tactical.cure(self, t) <= 0) end,
	range = 10,
	getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty = self:getTarget(tg)
		if tx and ty and game.level.map(tx, ty, Map.ACTOR) then
			local _ _, tx, ty = self:canProject(tg, tx, ty)
			if not tx then return nil end
			target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return nil end
			
			target = game.level.map(tx, ty, Map.ACTOR)
		else
			return nil
		end

		local effs = {}

		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type ~= "other" and e.status == "beneficial" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end
		
		for tid, act in pairs(target.sustain_talents) do
			if act then
				local talent = target:getTalentFromId(tid)
				effs[#effs+1] = {"talent", tid}
			end
		end

		if #effs == 0 then return nil end
		self:takeHit(self:getMaxLife()*0.15)
		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)
			
			target:dispel(eff[2], self)
		end
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Removes up to %d beneficial effects or sustains from the target, at the cost of 15%% of your maximum life.]]):tformat(t:_getRemoveCount(self))
	end,
}

newTalent{
	name = "Streams of Salt", short_name = "REK_HEKA_MARCH_SALT",
	type = {"spell/marching-sea", 3}, require = mag_req3, points = 5,
	mode = "passive",
	range = 5,
	target = function(self, t) return {type="ball", range=0, friendlyfire=false, radius=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 9, 2, 5)) end,
	callbackOnActBase = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(
			tg, self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				if target:hasProc("heka_salt") then return end
				target:setProc("heka_salt", true, 10)
				target:setEffect(target.EFF_REK_HEKA_SALTED, t:_getDuration(self), {src=self, apply_power=self:combatSpellpower()})
		end)
		return dam
	end,
	info = function(self, t)
		return ([[Your anchor is surrounded by a vast desolation, and enemies that approach within range %d may be lost there for %d turns (#SLATE#spell save#LAST#), during which they are pinned and made brittle (dying instantly if struck for more than 30%% of their maximum life).  This can only affect a given creature once every 10 of their turns.

#{italic}#Between us lie seas that melt and seas that have dried away, sands made silver and salt that cuts like steel.  Even there, things live.#{normal}#]]):tformat(self:getTalentRange(t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Lingering Destruction", short_name = "REK_HEKA_MARCH_DESTRUCTION",
	type = {"spell/marching-sea", 4}, require = mag_req4, points = 5,
	mode = "passive",
	getSp = function(self, t) return 1 + self:getTalentLevel(t) end,
	applyBoost = function(self, t)
		if not self.in_combat then return nil end
		self:setEffect(self.EFF_REK_HEKA_LINGERING_DESTRUCTION, 3, {src=self, power=t:_getSp(self)})
	end,
	info = function(self, t)
		return ([[Whenever you beat an opponent's saving throw or defense in combat, you gain %d spellpower for the next 3 turns.

#{italic}#It is better to torment your enemies, to weaken and bind them, rather than allow them a quick defeat.#{normal}#]]):tformat(t:_getSp(self))
	end,
}
