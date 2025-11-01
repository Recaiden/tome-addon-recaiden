local _M = loadPrevious(...)

_M:addCombatTraining("pick", "T_REK_OCLT_LEGACY_TOOL_RESERVE")

-- best of normal critical chances, uses CON as bonus LUCK
function _M:occultCrit(dam, add_chance, crit_power_add)
	self.turn_procs.is_crit = nil
	
	crit_power_add = crit_power_add or 0
	local chance = math.max(self:combatSpellCrit(), self:combatMindCrit(), self:combatCrit())  + (add_chance or 0) + (self:getCun() - 10) * 0.3
	chance = util.bound(chance, 0, 100)
	local crit = false
	
	if rng.percent(chance) then
		self.turn_procs.is_crit = "physical"
		self.turn_procs.crit_power = (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100)
		dam = dam * (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100)
		crit = true
		game.logSeen(self, "#{bold}#%s's machinery attains critical power!#{normal}#", self:getName():capitalize())

		if self:attr("mana_on_crit") then self:incMana(self:attr("mana_on_crit")) end
		if self:attr("vim_on_crit") then self:incVim(self:attr("vim_on_crit")) end
		if self:attr("paradox_on_crit") then self:incParadox(self:attr("paradox_on_crit")) end
		if self:attr("positive_on_crit") then self:incPositive(self:attr("positive_on_crit")) end
		if self:attr("negative_on_crit") then self:incNegative(self:attr("negative_on_crit")) end
		
		if self:knowTalent(self.T_EYE_OF_THE_TIGER) then self:triggerTalent(self.T_EYE_OF_THE_TIGER, nil, "physical") end

		self:fireTalentCheck("callbackOnCrit", "physical", dam, chance)
	end
	return dam, crit
end

return _M
