local _M = loadPrevious(...)

_M:addCombatTraining("bow", "T_REK_GLR_MARKSMAN_ACCELERATE")

local base_isAccuracyEffect = _M.isAccuracyEffect
function _M:isAccuracyEffect(weapon, kind)
	if weapon and weapon.talented == "bow" and self:knowTalent(self.T_REK_GLR_MARKSMAN_PINPOINT) then
		if kind == "staff" then
			return true, "staff"
		end
	end
	return base_isAccuracyEffect(self, weapon, kind)
end

return _M