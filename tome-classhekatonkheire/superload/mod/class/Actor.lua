local _M = loadPrevious(...)

local base_canSeeNoCache = _M.canSeeNoCache
function _M:canSeeNoCache(actor, def, def_pct)
	if not actor then return false, 0 end

	if actor.is_wandering_eye and self:knowTalent(self.T_REK_HEKA_HEADLESS_EYES) then
		return true, 100
	end

	return base_canSeeNoCache(self, actor, def, def_pct)
end

local base_lineFOV = _M.lineFOV
function _M:lineFOV(tx, ty, extra_block, block, sx, sy)
	local sightRangeOld = self.sight
	if self:knowTalent(self.T_REK_HEKA_HEADLESS_EYES) then
		self.sight = 1
	end
	local ret = base_lineFOV(self, tx, ty, extra_block, block, sx, sy)
	self.sight = sightRangeOld
	return ret
end

local base_hasLOS = _M.hasLOS
function _M:hasLOS(x, y, what, range, source_x, source_y)
	local sightRangeOld = self.sight
	if self:knowTalent(self.T_REK_HEKA_HEADLESS_EYES) then
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.is_wandering_eye then
				if e:hasLOS(x, y, what, range) then return true, x, y end
			end
		end
		self.sight = 1
	end
	local ret = base_hasLOS(self, x, y, what, range, source_x, source_y)
	self.sight = sightRangeOld
	return ret
end

return _M
