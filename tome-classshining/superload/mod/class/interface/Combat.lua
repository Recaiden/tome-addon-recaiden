local _M = loadPrevious(...)

local base_spellCrit = _M.spellCrit
function _M:spellCrit(dam, add_chance, crit_power_add)
	local dam, didCrit = base_spellCrit(self, dam, add_chance, crit_power_add)
	if self:knowTalent(self.T_REK_SHINE_NUCLEAR_FUEL_ENRICHMENT) and not didCrit then
		self:callTalent(self.T_REK_SHINE_NUCLEAR_FUEL_ENRICHMENT, "critFailed")
	end
	return dam, didCrit
end

local base_bumpInto = _M.bumpInto
function _M:bumpInto(target, x, y)
	--local reaction = self:reactionToward(target)
	if self:isTalentActive(self.T_REK_SHINE_MANTRA_PRECESSION) then
		self.shining_precession_jump = true
		local dx = target.x - self.x
		local dy = target.y - self.y
		if not game.level.map:checkAllEntities(self.x+dx*2, self.y+dy*2, "block_move", self) then
			self:move(self.x+dx*2, self.y+dy*2, true)
			local energy = game.energy_to_act * self:combatMovementSpeed(x, y)
			self:useEnergy(energy)
			self.did_energy = true
		else
			return base_bumpInto(self, target, x, y)
		end
	else return base_bumpInto(self, target, x, y) end
end

local base_combatDefenseBase = _M.combatDefenseBase
function _M:combatDefenseBase(fake)
	local def = base_combatDefenseBase(self, fake)
	if self:isTalentActive(self.T_REK_SHINE_MANTRA_PRECESSION) then
		def = def + self:callTalent(self.T_REK_SHINE_MANTRA_PRECESSION,"getDefense")
	end
	return def
end

return _M
