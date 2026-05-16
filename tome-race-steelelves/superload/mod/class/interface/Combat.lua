local _M = loadPrevious(...)

local base_getOffHandMult = _M.getOffHandMult

function _M:getOffHandMult(combat, mult)
	mult = mult or 1
	local offmult = base_getOffHandMult(self, combat, mult)
	offmult = offmult / mult
	if self:knowTalent(self.T_REK_STEEL_WIELDING) then
		offmult = offmult + self:callTalent(self.T_REK_STEEL_WIELDING,"getoffmult")
	end

	return offmult * mult
end

return _M
