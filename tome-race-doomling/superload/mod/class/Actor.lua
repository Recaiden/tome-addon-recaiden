local _M = loadPrevious(...)

local base_canSeeNoCache = _M.canSeeNoCache
function _M:canSeeNoCache(actor, def, def_pct)
	if not actor then return false, 0 end

	if self:hasEffect(self.EFF_REK_DOOMLING_HUNTER) then
		if actor:hasEffect(actor.EFF_REK_DOOMLING_VICTIM) then
			return true, 100
		elseif actor == self then
			return true, 100
		else
			return false, 0
		end
	end

	return base_canSeeNoCache(self, actor, def, def_pct)
end

return _M
