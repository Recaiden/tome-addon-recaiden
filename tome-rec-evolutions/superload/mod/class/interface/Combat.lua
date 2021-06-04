local _M = loadPrevious(...)

local base_combatSpellpower = _M.combatSpellpower
function _M:combatSpellpower(mod, add)
	add = add or 0
	if self:knowTalent(self.T_REK_ZEPHYR_STORM_ARCHER) then
		add = add + self:combatPhysicalpowerRaw() * self:callTalent(self.T_REK_ZEPHYR_STORM_ARCHER, "getPowerConversion")
	end

	return base_combatSpellpower(self, mod, add)
end

return _M
