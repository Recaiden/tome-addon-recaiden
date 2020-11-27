local _M = loadPrevious(...)

local baseMATERIALIZE_BARRIER = Talents.talents_def.T_MATERIALIZE_BARRIER.info
Talents.talents_def.T_MATERIALIZE_BARRIER.info = function(self, t)
   return baseMATERIALIZE_BARRIER(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
