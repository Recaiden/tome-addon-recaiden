local _M = loadPrevious(...)

local baseREDUX = Talents.talents_def.T_REDUX.info
Talents.talents_def.T_REDUX.info = function(self, t)
   return baseREDUX(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

local baseENTROPY = Talents.talents_def.T_ENTROPY.info
Talents.talents_def.T_ENTROPY.info = function(self, t)
   return baseENTROPY(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
