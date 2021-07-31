local _M = loadPrevious(...)

local getTalentRange = _M.getTalentRange
function _M:getTalentRange(t)
	local r = getTalentRange(self, t)
	if r > 1 and self:attr("generic_range_increase") then
		r = r + self.generic_range_increase
	end
	return r
end

return _M
