local _M = loadPrevious(...)

local baseINVIGORATE = Talents.talents_def.T_INVIGORATE.info
Talents.talents_def.T_INVIGORATE.info = function(self, t)
   return baseINVIGORATE(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

local baseWEAPON_MANIFOLD = Talents.talents_def.T_WEAPON_MANIFOLD.info
Talents.talents_def.T_WEAPON_MANIFOLD.info = function(self, t)
   return baseWEAPON_MANIFOLD(self, t)..([[

The duration of the debuffs will scale with paradox, by up to 50%%.]]):format()
end

local baseBREACH = Talents.talents_def.T_BREACH.info
Talents.talents_def.T_BREACH.info = function(self, t)
   return baseBREACH(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

return _M
