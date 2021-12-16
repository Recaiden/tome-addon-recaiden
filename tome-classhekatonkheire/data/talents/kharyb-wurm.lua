newTalent{
	name = "Orbital Wurm", short_name = "REK_HEKA_MOONWURM_RESERVOIR",
	type = {"spell/moon-wurm", 1}, require = mag_req1, points = 5,
	mode = "passive",
	getLife = function(self, t) return self.max_life * self:combatTalentLimit(t, 1.5, 0.2, 0.5) + 2 * (self:getCon() - 10) end,
	callbackOnKill = function (self, t, target)
		if target.summoner then return end
		if target.summoned_time then return end
		if target.exp_worth == 0 then return end
		local power = t:_getLife(self) * target.level * target.rank / (self.level * 200)
		self:setEffect(self.EFF_REK_HEKA_RESERVOIR, 1, {src=self, max=t:_getLife(self), power=power})
	end,
	info = function(self, t)
		return ([[You are assisted by a small creature that isn't you, and isn't quite here.  It collects bits and scraps whenever you kill an enemy, giving you a Reservoir of up to %d (based on your max life and constitution.). If you would take lethal damage, you are healed for your Reservoir, possibly saving you.
Rarer and stronger enemies fill the reservoir faster.]]):tformat(t:_getLife(self))
	end,
}

newTalent{
	name = "Wurm's Bite", short_name = "REK_HEKA_MOONWURM_BITE",
	type = {"spell/moon-wurm", 2},	require = mag_req2, points = 5,
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
	name = "Total Phase Shift", short_name = "REK_HEKA_MOONWURM_FLIP",
	type = {"spell/moon-wurm", 3}, require = mag_req3, points = 5,
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
	name = "Hyperevolution", short_name = "REK_HEKA_MOONWURM_SEA",
	type = {"spell/moon-wurm", 4}, require = mag_req4, points = 5,
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
