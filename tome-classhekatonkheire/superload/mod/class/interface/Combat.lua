local _M = loadPrevious(...)

local base_combatMovementSpeed = _M.combatMovementSpeed
function _M:combatMovementSpeed(x, y)
   if self:knowTalent(self.T_REK_HEKA_SHAMBLER_STEADY_GAIT) then
		 return 1
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

return _M
