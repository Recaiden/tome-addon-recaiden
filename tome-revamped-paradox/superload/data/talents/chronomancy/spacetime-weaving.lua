local _M = loadPrevious(...)

local baseWORMHOLE = Talents.talents_def.T_WORMHOLE.info
Talents.talents_def.T_WORMHOLE.info = function(self, t)
   return baseWORMHOLE(self, t)..([[

The duration of the wormhole will scale with paradox, by up to 50%%.]]):format()
end

local basePHASE_PULSE = Talents.talents_def.T_PHASE_PULSE.info
Talents.talents_def.T_PHASE_PULSE.info = function(self, t)
   return basePHASE_PULSE(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
