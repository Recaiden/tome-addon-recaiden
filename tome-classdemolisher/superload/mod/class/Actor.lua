local _M = loadPrevious(...)

-- Hull regeneration  from life
local base_regenLife = _M.regenLife
function _M:regenLife(fake)
	if self:hasEffect(self.EFF_REK_DEML_RIDE) then
		local old_regen = self.life_regen
		if self.life_regen and not self:attr("no_life_regen") then
			local regen = self.life_regen * util.bound((self.healing_factor or 1), 0, 2.5)
			local hullMissing = self:getMaxHull() - self:getHull()
			local hullRestored = math.min(hullMissing, regen)
			if not fake then
				self.hull = self.hull + hullRestored
				self.life_regen = self.life_regen - (hullRestored / (self.healing_factor or 1))
				local rLife, rPsi = base_regenLife(self, false)
				self.life_regen = old_regen
				return rLife + hullRestored, rPsi
			end
		end
	else
		return base_regenLife(self, fake)
	end
	return 0, 0
end

-- hull stat scaling
local base_onStatChange = _M.onStatChange
function _M:onStatChange(stat, v)
	if stat == self.STAT_CON then
		local multi_hull = 2 + (self.inc_resource_multi.hull or 0)
		self:incMaxHull(multi_hull * v)
	elseif stat == self.STAT_WIL then
		local multi_hull = 4 + (self.inc_resource_multi.hull or 0)
		self:incMaxHull(multi_hull * v)
	end
	return base_onStatChange(self, stat, v)
end

--update hull with level
local base_levelup = _M.levelup
function _M:levelup()
	local rating = self.hull_rating or 3
	rating = math.max(self:getRankLifeAdjust(rating), rating)
	self:incMaxHull(rating * (1.1+(self.level/40)))
	return base_levelup(self)
end

local base_preUseTalent = _M.preUseTalent
function _M:preUseTalent(ab, silent, fake, ignore_ressources)
	if self.__runeplate_in_progress then
		self.__inscription_data_fake = nil
	end
	return base_preUseTalent(self, ab, silent, fake, ignore_ressources)
end

return _M
