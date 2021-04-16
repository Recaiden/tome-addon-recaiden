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
	if self:knowTalent(self.T_REK_HEKA_STORIED_BEHEMOTH) then
		armor = armor + self:callTalent("T_REK_HEKA_STORIED_BEHEMOTH", "getArmorBase")
		if self.size_category > 3 then
			local sizeBonus = self.size_category - 3
			armor = armor + sizeBonus * self:callTalent("T_REK_HEKA_STORIED_BEHEMOTH", "getArmorSize")
		end
	end
	return armor
end

local base_combatSpellpowerRaw = _M.combatSpellpowerRaw
function _M:combatSpellpowerRaw(add)
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
return _M
