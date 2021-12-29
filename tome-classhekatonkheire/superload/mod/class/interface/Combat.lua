local _M = loadPrevious(...)

local base_combatMovementSpeed = _M.combatMovementSpeed
function _M:combatMovementSpeed(x, y)
   if self:knowTalent(self.T_REK_HEKA_SHAMBLER_STEADY_GAIT) then
		 return math.max(1, 1 * (self.global_speed or 1))
	 end

   return base_combatMovementSpeed(self, x, y)
end

local base_combatArmor = _M.combatArmor
function _M:combatArmor()
	local armor = base_combatArmor(self)
	if self:knowTalent(self.T_REK_HEKA_OTHERNESS_STORIED_BEHEMOTH) then
		armor = armor + self:callTalent("T_REK_HEKA_OTHERNESS_STORIED_BEHEMOTH", "getArmorBase")
		if self.size_category > 3 then
			local sizeBonus = self.size_category - 3
			armor = armor + sizeBonus * self:callTalent("T_REK_HEKA_OTHERNESS_STORIED_BEHEMOTH", "getArmorSize")
		end
	end
	return armor
end

local base_combatSpellpowerRaw = _M.combatSpellpowerRaw
function _M:combatSpellpowerRaw(add)
	add = add or 0
	if self.summoner and self.summoner.knowTalent and self.summoner:knowTalent(self.summoner.T_REK_HEKA_WATCHER_HATCHERY) then
		local mult = self.summoner:callTalent(self.summoner.T_REK_HEKA_WATCHER_HATCHERY, "getInherit") / 100
		add = add + mult * self.summoner:combatSpellpowerRaw()
	end
	if self:knowTalent(self.T_REK_HEKA_HEADLESS_ADAPT) then
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.is_wandering_eye then
				add = add + self:callTalent(self.T_REK_HEKA_HEADLESS_ADAPT,"getSelfSP")
			end
		end
	end
	
	return base_combatSpellpowerRaw(self, add)
end

local base_attackTargetWith = _M.attackTargetWith
function _M:attackTargetWith(target, weapon, damtype, mult, force_dam)
	if self:hasEffect(self.EFF_REK_HEKA_METAFOLD) then
		self.turn_procs.auto_melee_hit = true
	end
	return base_attackTargetWith(self, target, weapon, damtype, mult, force_dam)
end

local base_combatGetResistPen = _M.combatGetResistPen
function _M:combatGetResistPen(type, straight)
	local pen = base_combatGetResistPen(self, type, straight)
	if self.summoner and self.summoner.knowTalent and self.summoner:knowTalent(self.summoner.T_REK_HEKA_WATCHER_HATCHERY) then
		local highest = self.summoner.resists_pen.all or 0
		for kind, v in pairs(self.summoner.resists_pen) do
			if kind ~= "all" then
				local inc = self.summoner:combatGetResistPen(kind, true)
				highest = math.max(highest, inc)
			end
		end
		local mult = self.summoner:callTalent(self.summoner.T_REK_HEKA_WATCHER_HATCHERY,"getInherit") / 100
		pen = math.min(70, pen + highest*mult)
	end
	return pen
end

local base_combatGetDamageIncrease = _M.combatGetDamageIncrease
function _M:combatGetDamageIncrease(type, straight)
	local amp = base_combatGetDamageIncrease(self, type, straight)
	if self.summoner and self.summoner.knowTalent and self.summoner:knowTalent(self.summoner.T_REK_HEKA_WATCHER_HATCHERY) then
		local highest = self.summoner.inc_damage.all or 0
		for kind, v in pairs(self.summoner.inc_damage) do
			if kind ~= "all" then
				local inc = self.summoner:combatGetDamageIncrease(kind, true)
				highest = math.max(highest, inc)
			end
		end
		local mult = self.summoner:callTalent(self.summoner.T_REK_HEKA_WATCHER_HATCHERY, "getInherit") / 100
		amp = amp + highest*mult
	end
	return amp
end

local base_checkHit = _M.checkHit
function _M:checkHit(atk, def, min, max, factor, p)
	local hit, chance = base_checkHit(self, atk, def, min, max, factor, p)
	if hit and self:knowTalent(self.T_REK_HEKA_MARCH_DESTRUCTION) then
		self:callTalent(self.T_REK_HEKA_MARCH_DESTRUCTION, "applyBoost")
	end
	return hit, chance
end

return _M
