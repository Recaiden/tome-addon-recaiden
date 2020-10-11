local _M = loadPrevious(...)

local base_onTakeHit = _M.onTakeHit
function _M:onTakeHit(value, src, death_note)
	src = src or {}
	if value <=0 then return 0 end

	if src.hasEffect then
		local eff = src:hasEffect(src.EFF_REK_GLR_HALLUCINATING)
		if eff and not self:attr("hallucination") then
			value = value * (1-eff.power)
		end
	end
	
	local unwaking = false
	if src:attr("no_wake") then
		unwaking = true
		local effs = {}
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.sleep then
				effs[#effs+1] = {"effect", eff_id}
			end
		end
		-- apply buffer of temp_power equal to damage
		for i = 1, #effs do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" then
				local e = self:hasEffect(eff[2])
				e.temp_power = (e.temp_power or e.power) + value
			end
		end

		self:attr("damage_dont_undaze", 1)
	end

	-- Un-daze
	if self:hasEffect(self.EFF_REK_GLR_DAZE) and not self:attr("damage_dont_undaze") and (not src or not src.turn_procs or not src.turn_procs.dealing_damage_dont_undaze) then
		self:removeEffect(self.EFF_REK_GLR_DAZE)
	end

	return base_onTakeHit(self, value, src, death_note)

	if unwaking then
		self:attr("damage_dont_undaze", -1)
	end
end

return _M