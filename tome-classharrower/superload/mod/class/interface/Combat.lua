local _M = loadPrevious(...)

_M:addCombatTraining("bow", "T_REK_GLR_MARKSMAN_ACCELERATE")

-- local base_getAccuracyEffect = _M:getAccuracyEffect
-- _M:getAccuracyEffect = function(weapon, atk, def, scale, max)
-- 	max = max or 10000000
-- 	scale = scale or 1
-- 	return math.min(max, math.max(0, atk - def) * scale * (weapon.accuracy_effect_scale and 0.5 or 1))
-- end

local base_isAccuracyEffect = _M.isAccuracyEffect
function _M:isAccuracyEffect(weapon, kind)
	if weapon.talented == "bow" and self:knowTalent(self.T_REK_GLR_MARKSMAN_PINPOINT) then
		if kind == "staff" then
			return true, "staff"
		end
	end
	return base_isAccuracyEffect(self, weapon, kind)
end

return _M