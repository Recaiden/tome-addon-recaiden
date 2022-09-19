newTalent{
	name = "Steady Gait", short_name = "REK_HEKA_SHAMBLER_STEADY_GAIT",
	type = {"spell/shambler", 1},	require = mag_req1, points = 5,
	mode = "passive",
	no_unlearn_last = true,
	getResistKnockback = function(self, t) return math.min(1, self:combatTalentScale(t, 0.1, 0.90, 0.5)) end,
	getResistTeleport = function(self, t) return math.min(1, self:combatTalentScale(t, 0.05, 0.45, 0.5)) end,
	getHandRegen = function(self, t) return 5 end,
	-- superloaded in /mod/class/interface/Combat.lua
	info = function(self, t)
		return ([[You approach at a constant, unimpeded pace.  Your movement speed is always exactly 100%%, and you gain %d%% resistance to knockbacks and %d%% resistance to hostile teleports.  If your global speed is not 100%%, your movement speed is changed to compensate.
When an enemy becomes adjacent to you, you immediately recover %d hands.

#{italic}#You are never late nor early.  Rather, things begin when you arrive.#{normal}#]]):tformat(t.getResistKnockback(self, t)*100, t.getResistTeleport(self, t)*100, t.getHandRegen(self, t))
	end,
}

newTalent{
	name = "Towering Wrath", short_name = "REK_HEKA_SHAMBLER_TOWERING_WRATH",
	type = {"spell/shambler", 2}, require = mag_req2, points = 5,
	speed = "weapon",
	hands = 15,
	tactical = { BUFF = 1 },
	cooldown = 0,
	passives = function(self, t, p) self:talentTemporaryValue(p, "size_category", 1) end,
	getPower = function(self, t) return self:combatTalentScale(t, .94, 1.35) end,
	getMaxStacks = function(self, t) return 3 end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_HEKA_TOWERING_WRATH, 2, {power=t.getPower(self, t), stacks=1, max_stacks=t.getMaxStacks(self, t), src=self})
		return true
	end,
	info = function(self, t)
		return ([[Grasp your weapon tightly and gather your strength for a mighty strike.  Your next weapon attack (within 2 turns) will do an additional %0.2fx damage. This stacks up to %d times.
Learning this talent increases your size category, and activating it temporarily increases it again.]]):tformat(t.getPower(self, t), t.getMaxStacks(self, t))
	end,
}
class:bindHook(
	"Combat:attackTargetWith",
	function(self, hd)
		-- check unarmed
		if hd.weapon == self.combat then return hd end
		
		-- remove in the normal case, after the attack but before the on-hit effects.
		if self:hasEffect(self.EFF_REK_HEKA_TOWERING_WRATH) then
			self:removeEffect(self.EFF_REK_HEKA_TOWERING_WRATH)
		end
		return hd
	end)
class:bindHook(
	"Combat:attackTargetWith:attackerBonuses",
	function(self, hd)
		-- check for buff
		local wrath = self:hasEffect(self.EFF_REK_HEKA_TOWERING_WRATH)
		if not wrath then return hd end

		-- check unarmed
		if hd.weapon == self.combat then return hd end

		-- power up
		hd.mult = hd.mult * (1 + wrath.power * wrath.stacks)
		game:onTickEnd(function() -- remove anyway if something goes wrong with the attack flow
										 if self:hasEffect(self.EFF_REK_HEKA_TOWERING_WRATH) then
											 self:removeEffect(self.EFF_REK_HEKA_TOWERING_WRATH)
										 end
									 end)
		return hd
	end)

newTalent{
	name = "Contempt", short_name = "REK_HEKA_SHAMBLER_CONTEMPT",
	type = {"spell/shambler", 3},
	require = mag_req3, points = 5,
	hands = 10,
	cooldown = 6,
	tactical = { ATTACK = 1, DISABLE = { knockback = 2 } },
	is_melee = true,
	speed = "weapon",
	on_learn = function(self, t) self:attr("show_gloves_combat", 1) end,
	on_unlearn = function(self, t) self:attr("show_gloves_combat", -1) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getAutoPunchDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 1.5) end,
	getActivePunchDamage = function(self, t) return 0.5 end,
	callbackOnAct = function(self, t) t.autopunch(self, t) end,
	callbackOnMove = function(self, t, moved, force, ox, oy, x, y) if moved then t.autopunch(self, t) end end,
	autopunch = function (self, t)
		if game.zone.wilderness then return false end
		self.adjacent_enemies = self.adjacent_enemies or {}
		local new_enemies = {}
		self:project(
			{type="ball", range=0, radius=1, friendlyfire=false}, self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				if self:reactionToward(target) > 0 then return end
				new_enemies[target.uid] = target
			end)
		local multBase = t.getAutoPunchDamage(self, t)
		for uid, target in pairs(new_enemies) do
			if not self.adjacent_enemies[uid] and not target:hasProc("heka_contempt") then
				local mult = multBase
				if target.rank <= 1 then mult = mult * 3 elseif target.rank <= 1 then mult = mult * 2 end
				target:setProc("heka_contempt", true, 5)
				self:attackTarget(target, nil, mult, true, true)
				game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(target.x-self.x), math.abs(target.y-self.y)), "red_arc", {tx=target.x-self.x, ty=target.y-self.y})
			end
		end
		self.adjacent_enemies = new_enemies
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local hit = self:attackTarget(target, nil, t.getActivePunchDamage(self, t), true, true)
		if hit then
			if target:hasProc("heka_contempt") then
				target.turn_procs.multi["heka_contempt"] = nil
			end
			if target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95) and target:canBe("knockback") then
				target:knockback(self.x, self.y, 3)
				target:crossTierEffect(target.EFF_OFFBALANCE, self:combatPhysicalpower())
			else
				game.logSeen(target, "%s resists the knockback!", target:getName():capitalize())
			end
		end
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[You can defeat lesser creatures with a single blow, no need even to draw your weapon.  When an enemy becomes adjacent to you, you automatically make an unarmed attack doing %d%% damage.  This does 2x damage to normal-rank enemies and 3x damage to critters and has a 5-turn cooldown per enemy.

Activate this talent to shove an adjacent enemy, dealing %d%% unarmed damage, knocking them back 3 spaces, and resetting their Contempt cooldown.]]):tformat(t.getAutoPunchDamage(self, t)*100, t.getActivePunchDamage(self, t)*100)
	end,
}

newTalent{
	name = "Hands-Off", short_name = "REK_HEKA_SHAMBLER_UNSTOPPABLE_MARCH",
	type = {"spell/shambler", 4},	require = mag_req4, points = 5,
	mode = "passive",
	getDamageChange = function(self, t)
		return -self:combatTalentLimit(t, 50, 12, 25)
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp, no_martyr)
		if src and src.x and src.y then
			local dist = core.fov.distance(self.x, self.y, src.x, src.y)
			if dist > 2 then
				dam = dam * (100 + t.getDamageChange(self, t)) / 100 * (math.min(8, (dist-2)) / 8)
				print("[PROJECTOR] Unstoppable March (source) dam", dam)
			end
		end
		return {dam=dam}
	end,
	--TODO If you've moved in the last turn?
	info = function(self, t)
		return ([[
You take less damage from distant sources: %d%% at range 3 up to %d%% at range 10 or above.

#{italic}#Slings and arrows are nothing to you.  Only those brave enough to face you in hand-to-hand combat have a chance of victory!#{normal}#]]):tformat(t.getDamageChange(self, t), t.getDamageChange(self, t)*2)
	end,
}
