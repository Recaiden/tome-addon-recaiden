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

		game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		if not self:teleportRandom(x, y, 0) then
			game.logSeen(self, "%s's teleport fizzles!", self:getName():capitalize())
		else
			game.logSeen(self, "%s emerges from nowhere!", self:getName():capitalize())
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
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
			self:setEffect(self.EFF_DAMAGE_SHIELD, 2, {color={0xe1/255, 0xcb/255, 0x3f/255}, power=self:spellCrit(t:_getShield(self))})
			game:playSoundNear(self, "talents/heal")
		end
		
		return true
	end,
	info = function(self, t)
		return ([[Withdraw into the other place and reemerge nearby, teleporting up to %d spaces.  If this brings you adjacent to an enemy, you create a shield of distorted space that blocks %d damage (based on spellpower) for 2 turns.]]):tformat(self:getTalentRange(t), t:_getShield(self))
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
		if src.size >= self.size then return end
		local dur = 3
		self:project(
			tg, self.x, self.y,
			function(tx, ty)
				local act = game.level.map(tx, ty, engine.Map.ACTOR)
				if act and act:reactionToward(self) < 0 and act:canBe("stun") then
					act:setEffect(act.EFF_DAZED, dur, {apply_power=self:combatPhysicalpower()})
				end
			end)
	end,
	info = function(self, t)
		return ([[You gain %d armor, plus %d per size category above medium you are.
In addition, whenever you kill a creature smaller than yourself, enemies within range %d are dazed (#SLATEPhysical vs physical#LAST#) for 5 turns.

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
	cooldown = function(self, t) return 15 end,
	range = 1,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 3 },
	--no_npc_use = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[!!!!!]]):tformat()
	end,
}