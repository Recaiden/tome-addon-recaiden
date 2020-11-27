local _M = loadPrevious(...)

local baseTIME_SKIP = Talents.talents_def.T_TIME_SKIP.info
Talents.talents_def.T_TIME_SKIP.info = function(self, t)
   return baseTIME_SKIP(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

local baseTEMPORAL_REPRIEVE = Talents.talents_def.T_TEMPORAL_REPRIEVE.info
Talents.talents_def.T_TEMPORAL_REPRIEVE.info = function(self, t)
   return baseTEMPORAL_REPRIEVE(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
