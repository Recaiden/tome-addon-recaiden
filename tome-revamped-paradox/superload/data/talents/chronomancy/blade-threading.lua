local _M = loadPrevious(...)

local baseWARP_BLADE = Talents.talents_def.T_WARP_BLADE.info
Talents.talents_def.T_WARP_BLADE.info = function(self, t)
   return baseWARP_BLADE(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
