local _M = loadPrevious(...)

local baseGUARDIAN_UNITY = Talents.talents_def.T_GUARDIAN_UNITY.info
Talents.talents_def.T_GUARDIAN_UNITY.info = function(self, t)
   return baseGUARDIAN_UNITY(self, t)..([[

The clone's lifespan will scale with paradox, by up to 50%%.]]):format()
end

local baseWARDEN_S_FOCUS = Talents.talents_def.T_WARDEN_S_FOCUS.info
Talents.talents_def.T_WARDEN_S_FOCUS.info = function(self, t)
   return baseWARDEN_S_FOCUS(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
