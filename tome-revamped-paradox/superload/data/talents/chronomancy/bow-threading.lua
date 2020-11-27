local _M = loadPrevious(...)

local baseARROW_ECHOES = Talents.talents_def.T_ARROW_ECHOES.info
Talents.talents_def.T_ARROW_ECHOES.info = function(self, t)
   return baseARROW_ECHOES(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
