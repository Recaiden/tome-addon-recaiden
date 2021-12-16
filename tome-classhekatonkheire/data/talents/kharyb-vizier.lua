newTalent{
	name = "Light Work", short_name = "REK_HEKA_VIZIER_RESERVOIR",
	type = {"spell/null-vizier", 1}, require = mag_req1, points = 5,
	drain_hands = 5,
	cooldown = 16,
	mode = "sustained",
	tactical = { ESCAPE = 2, DEFEND = 2 },
	getInvisibilityPower = function(self, t) return math.ceil(self:combatTalentSpellDamage(t, 10, 50)) end,
	getDamPower = function(self, t) return self:combatTalentScale(t, 10, 30) end,
	activate = function(self, t)
		local r = {}
		self:talentTemporaryValue(r, "invisible", t:_getInvisibilityPower(self))
		self:effectTemporaryValue(r, "blind_inc_damage", t:_getDamPower(self))
		if not self.shader then
			eff.set_shader = true
			self.shader = "invis_edge"
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		return r
	end,
	deactivate = function(self, t, r)
		if eff.set_shader then
			self.shader = nil
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		self:resetCanSeeCacheOf()
		return true
	end,
	info = function(self, t)
		return ([[Split your flesh with infinite precision and grasp the light itself, bending it around you to become invisible (%d power based on spellpower).  While invisible all damage you deal against blinded foes is increased by +%d%%.]]):tformat(t:_getInvisibilityPower(self), t:_getDamPower(self))
	end,
}

newTalent{
	name = "Photohammer", short_name = "REK_HEKA_VIZIER_BITE",
	type = {"spell/null-vizier", 2},	require = mag_req2, points = 5,
	mode = "passive",
	range = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 6, 10)) end,
	oneTarget = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire"}, friendlyblock=false, friendlyfire=false} end,
	cooldown = 3,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 230) end,
	fire = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 then
					tgts[#tgts+1] = a
				end
		end end
		
		-- Randomly take targets
		local tg = t.oneTarget(self, t)
		if #tgts <= 0 then break end
		local a, id = rng.table(tgts)
		table.remove(tgts, id)
		
		self:projectile(table.clone(tg), a.x, a.y, DamageType.RANDOM_POISON, self:spellCrit(t.getDamage(self, t)), {type="slime"})
		
		self:startTalentCooldown(t)
	end,
	callbackOnActBase = function(self, t)
		if self:isTalentCoolingDown(t) then return end
		t.fire(self, t)
	end,
	callbackOnWait = function(self, t)
		t.fire(self, t)
	end
	info = function(self, t)
		return ([[Your assistant has grown enough to extrude and project spines through your anchor. Every %d turns, it fires a poison needle at a nearby enemy within range %d, dealing %0.1f nature damage over 5 turns.
Moving reduces the cooldown by 1, and waiting causes it to fire immediately.]]):tformat(self:getTalentCooldown(t), self:getTalentRange(t), damDesc(self, DamageType.NATURE, t:_getDamage(self, t)))
	end,
}

newTalent{
	name = "Total Phase Shift", short_name = "REK_HEKA_VIZIER_FLIP",
	type = {"spell/null-vizier", 3}, require = mag_req3, points = 5,
	cooldown = function(self, t) return t:_getDuration(self) + 3 end,
	hands = 30,
	tactical = { DISABLE = 1 },
	range = 10,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		target:setEffect(target.EFF_REK_HEKA_PHASE_OUT, t.getDuration(self, t), {src=self, apply_power=self:combatSpellpower()})

		game:playSoundNear(self, "talents/arcane")
		investHands(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Seal a creture entirely into the Other Place (#SLATE#Spell save#LAST#) for %d turns. While there time does not pass for them - they are unable to act and immune to harm - except that their talents cool down, and at double speed.

This talent invests hands; your maximum hands will be reduced by its cost until it expires.]]):tformat(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Hyperevolution", short_name = "REK_HEKA_VIZIER_SEA",
	type = {"spell/null-vizier", 4}, require = mag_req4, points = 5,
	cooldown = 30,
	tactical = { ATTACK = 3 },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10)) end,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Your assistant crawls out through your anchor, summoning it onto the battlefield for %d turns.  Its statistics are based on your raw spellpower.
This talent activates automatically when your Reservoir is consumed.]]):tformat(t:_getDuration(self))
	end,
}
