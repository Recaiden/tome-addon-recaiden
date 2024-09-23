local _M = loadPrevious(...)

local base_preUseTalent = _M.preUseTalent
function _M:preUseTalent(ab, silent, fake,ignore_ressources)
	local oldRestriction = nil
	local oldForbiddance = 0
	
	if self:knowTalent(self.T_REK_WIGHT_DODGE) then		
		if ab.is_inscription and ab.is_nature then
			local countInfusions = 0
			for i = 1, self.max_inscriptions do
				if self.inscriptions[i] then
					local t = self:getTalentFromId(self["T_"..self.inscriptions[i]])
					if t.type[1] == "inscriptions/infusions" then
						countInfusions = countInfusions + 1
					end
				end
			end
			if countInfusions > 1 then
				if not silent then game.logSeen(self, "%s has too many infusions for a Wight; nature rejects their greed.", self:getName():capitalize()) end
				return false
			end
			if self.inscription_forbids then
				oldRestriction = self.inscription_forbids["inscriptions/infusions"]
			end
			oldForbiddance = self:attr("forbid_nature") or 0
			self.inscription_forbids["inscriptions/infusions"] = nil
			self:attr("forbid_nature", -1 * oldForbiddance)
		end
	end
	
	local ret = base_preUseTalent(self, ab, silent, fake, ignore_ressources)
	if oldRestriction then
		self.inscription_forbids["inscriptions/infusions"] = oldRestriction
	end
	if oldForbiddance then
		self:attr("forbid_nature", oldForbiddance)
	end
	return ret
end

local base_canSeeNoCache = _M.canSeeNoCache
function _M:canSeeNoCache(actor, def, def_pct)
	if not actor then return false, 0 end
	
	if actor.is_dreadlord_minion and self:knowTalent(self.T_REK_DREAD_SUMMON_DREAD) then
		return true, 100
	end

	return base_canSeeNoCache(self, actor, def, def_pct)
end

return _M
