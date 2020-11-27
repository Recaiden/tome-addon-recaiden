local _M = loadPrevious(...)

local baseWEBS_OF_FATE = Talents.talents_def.T_WEBS_OF_FATE.info
Talents.talents_def.T_WEBS_OF_FATE.info = function(self, t)
   return baseWEBS_OF_FATE(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

local baseSEAL_FATE = Talents.talents_def.T_SEAL_FATE.info
Talents.talents_def.T_SEAL_FATE.info = function(self, t)
   return baseSEAL_FATE(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
