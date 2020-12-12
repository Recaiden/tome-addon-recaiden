local _M = loadPrevious(...)
local base_combatMovementSpeed = _M.combatMovementSpeed

function _M:combatMovementSpeed(x, y)
   if self:knowTalent(self.T_REK_HEKA_SHAMBLER_STEADY_GAIT) then
		 return 1
	 end

   return base_combatMovementSpeed(self, x, y)
end

return _M
