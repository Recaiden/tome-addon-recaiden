require "engine.Game"

local _M = loadPrevious(...)

Talents.talents_def.T_SUN_VENGEANCE.callbackOnKill = function(self, t, src, msg)
   if src.getHate and src:getHate() > 0 then
      game:setAllowedBuild("rek_paladin_fallen", true)
   end
end

return _M
