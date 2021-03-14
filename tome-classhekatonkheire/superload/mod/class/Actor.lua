local _M = loadPrevious(...)

local base_canSeeNoCache = _M.canSeeNoCache
function _M:canSeeNoCache(actor, def, def_pct)
	if not actor then return false, 0 end

	if actor.is_wandering_eye and self:knowTalent(self.T_REK_HEKA_HEADLESS_EYES) then
		return true, 100
	end

	return base_canSeeNoCache(self, actor, def, def_pct)
end

return _M
