local _M = loadPrevious(...)

local baseCHRONO_TIME_SHIELD = Talents.talents_def.T_CHRONO_TIME_SHIELD.info
Talents.talents_def.T_CHRONO_TIME_SHIELD.info = function(self, t)
   return baseCHRONO_TIME_SHIELD(self, t)..([[

The duration of the shield will scale with paradox, by up to 50%%.]]):format()
end

local baseSTOP = Talents.talents_def.T_STOP.info
Talents.talents_def.T_STOP.info = function(self, t)
   return baseSTOP(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

local baseSTATIC_HISTORY = Talents.talents_def.T_STATIC_HISTORY.info
Talents.talents_def.T_STATIC_HISTORY.info = function(self, t)
   return baseSTATIC_HISTORY(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
