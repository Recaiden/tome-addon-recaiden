local _M = loadPrevious(...)

local baseREALITY_SMEARING = Talents.talents_def.T_REALITY_SMEARING.info
Talents.talents_def.T_REALITY_SMEARING.info = function(self, t)
   return baseREALITY_SMEARING(self, t)..([[

The number of turns the paradox is spreadd over will scale with paradox, by up to 50%%.]]):format()
end

local baseTWIST_FATE = Talents.talents_def.T_TWIST_FATE.info
Talents.talents_def.T_TWIST_FATE.info = function(self, t)
   return baseTWIST_FATE(self, t)..([[

The duration the anomaly is held for will scale with paradox, by up to 50%%.]]):format()
end

local baseATTENUATE = Talents.talents_def.T_ATTENUATE.info
Talents.talents_def.T_ATTENUATE.info = function(self, t)
   return baseATTENUATE(self, t)..([[

The duration will scale with paradox, by up to 50%%.  This does not change damage-per-turn.]]):format()
end

return _M
