local _M = loadPrevious(...)

local baseTEMPORAL_VIGOUR = Talents.talents_def.T_TEMPORAL_VIGOUR.info
Talents.talents_def.T_TEMPORAL_VIGOUR.info = function(self, t)
   return baseTEMPORAL_VIGOUR(self, t)..([[

The duration at which your hounds can survive without health will scale with paradox, by up to 50%%.]]):format()
end

local baseCOMMAND_BREATHE = Talents.talents_def.T_COMMAND_BREATHE.info
Talents.talents_def.T_COMMAND_BREATHE.info = function(self, t)
   return baseCOMMAND_BREATHE(self, t)..([[

The duration of the stat reduction will scale with paradox, by up to 50%%.]]):format()
end

return _M
