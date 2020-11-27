local _M = loadPrevious(...)

local baseCELERITY = Talents.talents_def.T_CELERITY.info
Talents.talents_def.T_CELERITY.info = function(self, t)
   return baseCELERITY(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

local baseTIME_DILATION = Talents.talents_def.T_TIME_DILATION.info
Talents.talents_def.T_TIME_DILATION.info = function(self, t)
   return baseTIME_DILATION(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

local baseHASTE = Talents.talents_def.T_HASTE.info
Talents.talents_def.T_HASTE.info = function(self, t)
   return baseHASTE(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

local baseTIME_STOP = Talents.talents_def.T_TIME_STOP.info
Talents.talents_def.T_TIME_STOP.info = function(self, t)
   return baseTIME_STOP(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
