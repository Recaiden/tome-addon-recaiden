newTalent{
	name = "Electromagnetic Barrier", short_name = "REK_OCLT_VOIDSUIT_BARRIER",
	type = {"occultech/voidsuit", 1}, require = cun_req1, points = 5,
	mode = "passive",
	getResist = function(self, t) return self:combatTalentScale(t, 5, 13) end,
	getEvasion = function(self, t) return math.min(25, self:combatTalentScale(t, 5, 15, 0.75)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "resists", {all = t.getResist(self, t)})
		self:talentTemporaryValue(p, "cancel_damage_chance", t.getEvasion(self, t))
	end,
	info = function(self, t)
		local flavor = self.descriptor.race == "Dwarf" and _t"You wear a standard protective suit, whose barrier unit constantly adjusts to incoming forces." or _t"You strap the whirling, spark-emitting device to your chest, and instantly the temperature around you becomes comfortable.  You feel safe."
		return ([[%s

Passively increases your resist-all by +%d%%, and gives you a %d%% chance to negate any instance of incoming damage.]]):tformat(flavor, t.getResist(self, t), t.getEvasion(self, t))
	end,
}

newTalent{
	name = "Electroconduit Discharge", short_name = "REK_OCLT_VOIDSUIT_CONDUIT",
	type = {"occultech/voidsuit", 2},	require = cun_req2, points = 5,
	mode = "passive",
	coldown = 6,
	getBoost = function(self, t) return self:combatTalentScale(t, 20, 40) end,
	getResist = function(self, t) return self:combatTalentScale(t, 10, 20) end,
	getResistMax = function(self, t) return self:combatTalentLimit(t, 25, 3, 10) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 66, 20, 40) end,
	range = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 4, 9)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 300) end, -- lightning randomness
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "resists", {[DamageType.LIGHTNING] = t.getResist(self, t)})
		self:talentTemporaryValue(p, "resists_cap", {[DamageType.LIGHTNING] = t.getResistMax(self, t)})
		self:talentTemporaryValue(p, "inc_damage", {[DamageType.LIGHTNING] = t.getBoost(self, t)})
	end,
	callbackOnBlock = function(self, t, eff, dam, type, src)
		if not src.x or not src.y then return nil end
		if core.fov.distance(self.x, self.y, src.x, src.y) > self:getTalentRange(t) then return nil end
		if self:isTalentCoolingDown(t) then return nil end
		self:startTalentCooldown(t)

		local burst = {type="cone", cone_angle=30, range=0, radius=self:getTalentRange(t), force_target=src, selffire=false}

		local damage = self:mindCrit(t:_getDamage(self))
		self:project(burst, src.x, src.y, function(tx,ty)
									 local target = game.level.map(tx, ty, Map.ACTOR)
									 if not target or target == self then return end
									 
									 DamageType:get(DamageType.LIGHTNING).projector(self, tx, ty, DamageType.LIGHTNING, rng.avg(damage/3, damage, 3))
									 if target:canBe("stun") then
										 target:setEffect(target.EFF_STUNNED, t:_getDamage(self), {apply_power = self:combatMindpower()})
									 else
										 game.logSeen(target, "%s resists the stun!", target:getName():capitalize())
									 end
		end)
		game.level.map:particleEmitter(self.x, self.y, burst.radius, "breath_cold", {radius=burst.radius, tx=target.x-who.x, ty=target.y-who.y})
	end,
	info = function(self, t)
		local flavor = self.descriptor.race == "Dwarf" and _t"Your suit is woven with electrical fibers that can discharge excess energy through a designated protective device." or _t"You link the device to the metal of your shield with springs and wires.  Any sharp impact will violently unleash the energy within."
		return ([[%s

When you block damage from within range %d, release a narrow cone of lightning towards the attacker, dealing %0.1f damage and stunning (#SLATEMindpower vs Physical#LAST#)them for %d turns.

Passively increases your lightning damge by +%d%%, your lightning resistance by +%d%%, and your maximum lightning resistance by +%d%%.]]):tformat(flavor, self:getTalentRange(t), t.getResist(self, t), t.getEvasion(self, t))
	end,
}

newTalent{
	name = "Realtime Health Monitoring", short_name = "REK_OCLT_VOIDSUIT_SAVES",
	type = {"occultech/voidsuit", 3}, require = cun_req3, points = 5,
	speed = "weapon",
	mode = "sustained",
	sustain_hands = 10,
	tactical = { ATTACK = { weapon = 2}, DISABLE = 1 },
	cooldown = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentScale(t, 0.80, 1.5) end,
	getDuration = function(self, t) return 2 end,
	getCD = function(self, t) return 10 end,
	callbackOnMeleeHit = function(self, t, target, dam)
		if target:hasProc("heka_magpie") then return end
		if target:isUnarmed() then return end
		if target:canBe("disarm") and self:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5) then
			-- get weapon's combat table
			if target:getInven(self.INVEN_MAINHAND) then
				for i, o in ipairs(target:getInven(self.INVEN_MAINHAND)) do
					local combat = target:getObjectCombat(o, "mainhand")
					self:setEffect(self.EFF_REK_OCLT_MAGPIE_WEAPONS, t.getDuration(self, t), {weapon=combat, mult=t.getDamage(self, t), src=self})
					break
				end
			end
			target:setEffect(self.EFF_DISARMED, 3, {src=self})
			target:setProc("heka_magpie", true, t.getCD(self, t))
		end
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		if self:hasEffect(self.EFF_REK_OCLT_MAGPIE_WEAPONS) then
			self:removeEffect(self.EFF_REK_OCLT_MAGPIE_WEAPONS)
		end
		return true
	end,
	info = function(self, t)
		local flavor = self.descriptor.race == "Dwarf" and _t"Your suit's micro-medical machinery interfaces with your circulatory system, constantly adjusting blood chemistry for optimal performance." or _t"When you first got this thing stuck on your arm, you were worried.  When the needles came out, you started to panic.  But now you feel great, actually."
		return ([[%s

Passively increases your physical and mental saves by %d.

Once every %d turns, completely blocks a physical or mental effect that you failed to save against.]]):tformat(flavor, t.getSaves(self, t), t.getCooldown(self, t))
	end,
}

newTalent{
	name = "Reactive Propulsion Unit", short_name = "REK_OCLT_VOIDSUIT_JETPACK",
	type = {"occultech/voidsuit", 4}, require = cun_req4, points = 5,
	cooldown = 15,
	radius = 1,
	range = function(self, t) return math.max(2, math.floor(self:combatTalentLimit(t, 8, 2, 7))) end,
	requires_target = true,
	target = function(self, t)	return {type="hit", nolock=true, range=self:getTalentRange(t)} end,
	getShield = function(self, t) return self:combatTalentStatDamage(t, "con", 30, 370) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.0) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then -- To prevent teleporting through walls
			game.logPlayer(self, "You do not have line of sight.")
			return nil
		end
		local _ _, x, y = self:canProject(tg, x, y)
		
		if not self:move(x, y, true) then
			game.logSeen(self, "%s's jump fails!", self:getName():capitalize())
			return false
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
			self:setEffect(self.EFF_DAMAGE_SHIELD, 2, {color={0xe1/255, 0x20/255, 0xe6/255}, power=self:occultCrit(t:_getShield(self))})

			self:project({type="ball", range=0, selffire=false, radius=1}, self.x, self.y,
				function(px, py, tg, self)
					local target = game.level.map(px, py, Map.ACTOR)
					if target and target ~= self then
						self:attackTarget(target, nil, t:_getDamage(self), true)
					end
			end)
			
			game:playSoundNear(self, "talents/heal")
		end
		
		return true
	end,
	info = function(self, t)
		local flavor = self.descriptor.race == "Dwarf" and _t"Overcharge your suit's maneuver system to briefly lift yourself off the ground." or _t"Adding these nozzles and handles to the harness allows you to throw yourself through the air at great speeds, and even land safely at the other end."
		return ([[%s

Move to an open space within range %d.  If this brings you adjacent to an enemy, you attack them for %d%% damage and gain a shield that blocks %0.1f damage for 2 turns.

Shield power and crit chance increase with your Constitution.]]):tformat(flavor, self:getTalentRange(t), t.getDamage(self, t)*100, t.getShield(self, t))
	end,
}
