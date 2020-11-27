local _M = loadPrevious(...)

local baseDIMENSIONAL_ANCHOR = Talents.talents_def.T_DIMENSIONAL_ANCHOR.info
Talents.talents_def.T_DIMENSIONAL_ANCHOR.info = function(self, t)
   return baseDIMENSIONAL_ANCHOR(self, t)..([[

The duration of the field will scale with paradox, by up to 50%%.]]):format()
end

local baseBANISH = Talents.talents_def.T_BANISH.info
Talents.talents_def.T_BANISH.info = function(self, t)
   return baseBANISH(self, t)..([[

The duration will scale with paradox, by up to 50%%.]]):format()
end

local baseSPATIAL_TETHER = Talents.talents_def.T_SPATIAL_TETHER.info
Talents.talents_def.T_SPATIAL_TETHER.info = function(self, t)
   return baseSPATIAL_TETHER(self, t)..([[

The duration of the tether will scale with paradox, by up to 50%%.]]):format()
end

local baseWARP_MINES = Talents.talents_def.T_WARP_MINES.info
Talents.talents_def.T_WARP_MINES.info = function(self, t)
   return baseWARP_MINES(self, t)..([[

The duration of the mines will scale with paradox, by up to 50%%.]]):format()
end

return _M
