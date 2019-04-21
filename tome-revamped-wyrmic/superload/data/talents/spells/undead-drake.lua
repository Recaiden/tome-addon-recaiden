local _M = loadPrevious(...)

Talents.talents_def.T_RAZE.getResists = function(self, t) return self:combatTalentScale(t, 10, 30) end

return _M
