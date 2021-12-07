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

local base_recomputeGlobalSpeed = _M.recomputeGlobalSpeed
function _M:recomputeGlobalSpeed()
	local ret = base_recomputeGlobalSpeed(self)
	self.hands_regen = 10 * self.global_speed
	if self:knowTalent(self.T_REK_HEKA_BLOODTIDE_SHIELD) then
		return 1.0
	end
	return ret
end

local base_takeHit = _M.takeHit
function _M:takeHit(value, src, death_note)
	local dead, val = base_takeHit(self, value, src, death_note)
	if src and src.summoner and src.summoner.knowTalent and src.summoner:knowTalent(src.summoner.T_REK_HEKA_TENTACLE_EXECUTE) then
		src.summoner:callTalent(src.summoner.T_REK_HEKA_TENTACLE_EXECUTE, "kill", self)
	end

	return dead, val
end

local base_canBe = _M.canBe
function _M:canBe(what, eid)
	if self:attr("negative_status_effect_immune") or self:attr("physical_negative_status_effect_immune") then
		return base_canBe(self, what, eid)
	end
	if self:knowTalent(self.T_REK_HEKA_BLOODTIDE_WATERS) and what == "stun" then
		return false
	end
	return base_canBe(self, what, eid)
end

return _M
