local _M = loadPrevious(...)

local basePRECOGNITION = Talents.talents_def.T_PRECOGNITION.info
Talents.talents_def.T_PRECOGNITION.info = function(self, t)
   return basePRECOGNITION(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

local baseSEE_THE_THREADS = Talents.talents_def.T_SEE_THE_THREADS.info
Talents.talents_def.T_SEE_THE_THREADS.info = function(self, t)
   return baseSEE_THE_THREADS(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
