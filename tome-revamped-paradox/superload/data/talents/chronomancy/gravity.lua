local _M = loadPrevious(...)

local baseGRAVITY_WELL = Talents.talents_def.T_GRAVITY_WELL.info
Talents.talents_def.T_GRAVITY_WELL.info = function(self, t)
   return baseGRAVITY_WELL(self, t)..([[

The duration of the gravity well will scale with paradox, by up to 50%%.]]):format()
end

return _M
