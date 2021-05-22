newTalent{
	name = "Hidden Paths", short_name = "REK_HEKA_OTHERNESS_HIDDEN_PATHS",
	type = {"spell/otherness", 1}, require = mag_req1, points = 5,
	tactical = { ESCAPE = 1, CLOSEIN = 2 },
	cooldown = 12,
	hands = 10,
	radius = 1,
	range = function(self, t) return math.max(2, math.floor(self:combatTalentLimit(t, 8, 2, 7))) end,
	requires_target = true,
	target = function(self, t)	return {type="hit", nolock=true, range=self:getTalentRange(t)} end,
	getShield = function(self, t) return self:combatTalentSpellDamage(t, 30, 370) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then -- To prevent teleporting through walls
			game.logPlayer(self, "You do not have line of sight.")
			return nil
		end
		local _ _, x, y = self:canProject(tg, x, y)

		game.level.map:particleEmitter(self.x, self.y, 1, "otherside_teleport_gate_in", nil, nil, 15)
		if not self:teleportRandom(x, y, 0) then
			game.logSeen(self, "%s's teleport fizzles!", self:getName():capitalize())
		else
			game.logSeen(self, "%s emerges from nowhere!", self:getName():capitalize())
			game.level.map:particleEmitter(self.x, self.y, 1, "otherside_teleport_gate_out", nil, nil, 5)
		end

		local hit = false
		self:project(
			{type="ball", range=0, radius=1, friendlyfire=false}, self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				if self:reactionToward(target) > 0 then return end
				hit = true
			end)
		if hit then
			self:setEffect(self.EFF_DAMAGE_SHIELD, 2, {color={0xe1/255, 0x20/255, 0xe6/255}, power=self:spellCrit(t:_getShield(self))})
			game:playSoundNear(self, "talents/heal")
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Withdraw into the other place and reemerge nearby, teleporting up to %d spaces.  If this brings you adjacent to an enemy, you create a shield of distorted space that blocks %d damage (based on spellpower) for 2 turns.]]):tformat(self:getTalentRange(t), self:getShieldAmount(t:_getShield(self)))
	end,
}

newTalent{
	name = "Storied Behemoth", short_name = "REK_HEKA_OTHERNESS_STORIED_BEHEMOTH",
	type = {"spell/otherness", 2}, require = mag_req2, points = 5,
	mode = "passive",
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
	getArmorBase = function(self, t) return self:combatTalentScale(t, 4, 10) end,
	getArmorSize = function(self, t) return self:combatTalentScale(t, 3, 6) end,
	--implemented in superload Combat.lua
	callbackOnKill = function(self, t, src, death_note)
		if src.size_category >= self.size_category then return end
		local dur = 3
		self:project(
			{type="ball", radius=self:getTalentRange(t), friendlyfire=false, x=self.x, y=self.y}, self.x, self.y,
			function(tx, ty)
				local act = game.level.map(tx, ty, engine.Map.ACTOR)
				if act and act:reactionToward(self) < 0 and act:canBe("stun") then
					act:setEffect(act.EFF_DAZED, dur, {apply_power=self:combatPhysicalpower()})
				end
			end)
	end,
	info = function(self, t)
		return ([[You gain %d armor, plus %d per size category above medium you are.
In addition, whenever you kill a creature smaller than yourself, enemies within range %d are dazed (#SLATE#Physical vs physical#LAST#) for 5 turns.

#{italic}#A warrior of your stature has little to fear from petty wounds.#{normal}#
]]):tformat(t:_getArmorBase(self), t:_getArmorSize(self), self:getTalentRange(t))
	end,
}

newTalent{
	name = "Sudden Insight", short_name = "REK_HEKA_OTHERNESS_SUDDEN_INSIGHT",
	type = {"spell/otherness", 3}, require = mag_req3, points = 5,
	cooldown = 5,
	mode = "passive",
	getChance = function(self, t) return self:combatTalentScale(t, 10, 20) end,
	getCritPower = function(self, t) return self:combatTalentScale(t, 15, 25) end,
	callbackOnAct = function(self, t) t.checkInsight(self, t) end,
	callbackOnMove = function(self, t, moved, force, ox, oy, x, y) if moved then t.checkInsight(self, t) end end,
	checkInsight = function(self, t)
		self.adjacent_sudden_insight = self.adjacent_sudden_insight or {}
		local new_enemies = {}
		self:project(
			{type="ball", range=0, radius=1, friendlyfire=false}, self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				if self:reactionToward(target) > 0 then return end
				new_enemies[target.uid] = target
			end)
		local hit = false
		for uid, target in pairs(new_enemies) do
			if not self.adjacent_sudden_insight[uid] and not target:hasProc("heka_insight") then
				target:setProc("heka_insight", true, self:getTalentCooldown(t))
				hit = true
			end
		end
		if hit then
			self:setEffect(self.EFF_REK_HEKA_SUDDEN_INSIGHT, 2, {src=self, chance=t:_getChance(self), power=t:_getCritPower(self)})
		end
		self.adjacent_sudden_insight = new_enemies
	end,
	info = function(self, t)
		return ([[When an enemy becomes adjacent to you, gain +%d%% physical and spell critical chance and +%d%% critical power for 2 turns.  This has a cooldown per enemy.]]):tformat(t:_getChance(self), t:_getCritPower(self))
	end,
}

newTalent{
	name = "Metafold", short_name = "REK_HEKA_OTHERNESS_METAFOLD",
	type = {"spell/otherness", 4},	require = mag_req_high4, points = 5,
	cooldown = 50,
	fixed_cooldown = true,
	tactical = {
		BUFF = function(self, t, aitarget)
			local maxcount, maxlevel = t.getTalentCount(self, t), t.getMaxLevel(self, t)
			local count, tt = 0, nil
			for tid, _ in pairs(self.talents_cd) do
				tt = self:getTalentFromId(tid)
				if (tt.hands or tt.sustain_hands or tt.drain_hands) and not tt.fixed_cooldown and tt.type[2] <= maxlevel then
					count = count + 1
				end
				if count >= maxcount then break end
			end
			return count ^.5
		end
	},
	getTalentCount = function(self, t) return math.floor(self:combatTalentScale(t, 2, 7, "log")) end,
	getMaxLevel = function(self, t) return util.bound(math.floor(self:getTalentLevel(t)), 1, 4) end,
	getDur = function(self, t) return math.max(2, math.floor(self:combatTalentScale(t, 2, 5))) end,
	action = function(self, t)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if not tt.fixed_cooldown then
				if tt.type[2] <= t.getMaxLevel(self, t) and (tt.hands or tt.sustain_hands or tt.drain_hands) then
					tids[#tids+1] = tid
				end
			end
		end
		for i = 1, t.getTalentCount(self, t) do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		game.level.map:particleEmitter(self.x, self.y, 1, "otherside_sunrise", nil, nil, 5)
		self:setEffect(self.EFF_REK_HEKA_METAFOLD, t:_getDur(self), {power=1})
		self.changed = true
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Pull yourself closer to the world, allowing you to reset the cooldown of up to %d of your talents of tier %d or less.  Only talents that cost Hands are affected.
In addition, for %d turns you grow by 2 size categories and your attacks never miss (but can still be evaded, blocked, etc).
(The 1st talent in a tree is Tier 1, the second Tier 2, etc.)]]):tformat(t.getTalentCount(self, t), t.getMaxLevel(self, t), t:_getDur(self))
	end,
}
