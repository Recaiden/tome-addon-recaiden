local _M = loadPrevious(...)

local baseCSDeactivate = Talents.talents_def.T_CALL_SHADOWS.deactivate
Talents.talents_def.T_CALL_SHADOWS.deactivate = function(self, t)
	if self:knowTalent(self.T_REK_EVOLUTION_DOOMED_HOLLOW) then
		game.logPlayer(self, "The shadow call can no longer be stopped.")
		return nil
	end
	return baseCSDeactivate(self, t)
end

return _M
