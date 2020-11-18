local _M = loadPrevious(...)

local base_spellCrit = _M.spellCrit
function _M:spellCrit(dam, add_chance, crit_power_add)
	local dam, didCrit = base_spellCrit(self, dam, add_chance, crit_power_add)
	if self:knowTalent(self.T_REK_SHINE_NUCLEAR_FUEL_ENRICHMENT) and not didCrit then
		self:callTalent(self.T_REK_SHINE_NUCLEAR_FUEL_ENRICHMENT, "critFailed")
	end
	return dam, didCrit
end

return _M
