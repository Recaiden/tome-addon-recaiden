local _M = loadPrevious(...)

local baseBRAID_LIFELINES = Talents.talents_def.T_BRAID_LIFELINES.info
Talents.talents_def.T_BRAID_LIFELINES.info = function(self, t)
   return baseBRAID_LIFELINES(self, t)..([[

The duration of the braiding will scale with paradox, by up to 50%%.]]):format()
end

local baseTEMPORAL_FUGUE = Talents.talents_def.T_TEMPORAL_FUGUE.info
Talents.talents_def.T_TEMPORAL_FUGUE.info = function(self, t)
   return baseTEMPORAL_FUGUE(self, t)..([[

The lifespan of the Fugue Clones will scale with paradox, by up to 50%%.]]):format()
end

return _M
