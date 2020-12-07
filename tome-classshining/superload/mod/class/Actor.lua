local _M = loadPrevious(...)

local base_insanityEffect = _M.insanityEffect
function _M:insanityEffect(min, max)
	local madness = base_insanityEffect(self, max, min)
	local madness_alt = base_insanityEffect(self, max, min)
	if self:getSustainSlot("shining_mantra") then
		if self:knowTalent(self.T_REK_SHINE_MANTRA_ADEPT) then
			if math.abs(madness_alt) > math.abs(madness) then madness = madness_alt end
		end
	
		if madness > 0 and self:knowTalent(self.T_REK_SHINE_MANTRA_PROPHET) then
			madness = math.min(50 * self:callTalent(self.T_REK_SHINE_MANTRA_PROPHET, "getCapBoost"), madness * (1 + self:callTalent(self.T_REK_SHINE_MANTRA_PROPHET, "getBoost")/100)
		end
	end
	return madness
end

return _M
