local _M = loadPrevious(...)

local base_phys = _M.physicalCrit
function _M:physicalCrit(dam, weapon, target, atk, def, add_chance, crit_power_add)
	local dam, didCrit = base_phys(self, dam, weapon, target, atk, def, add_chance, crit_power_add)
	if didCrit then
		self:updateGooglyEyes()
	end
	return dam, didCrit
end

local base_spell = _M.spellCrit
function _M:spellCrit(dam, add_chance, crit_power_add)
	local dam, didCrit = base_spell(self, dam, add_chance, crit_power_add)
	if didCrit then
		self:updateGooglyEyes()
	end
	return dam, didCrit
end

local base_mind = _M.mindCrit
function _M:mindCrit(dam, add_chance, crit_power_add)
	local dam, didCrit = base_mind(self, dam, add_chance, crit_power_add)
	if didCrit then
		self:updateGooglyEyes()
	end
	return dam, didCrit
end

return _M
