local _M = loadPrevious(...)
local base_ParadoxDoAnomaly = _M.paradoxDoAnomaly

function _M:paradoxDoAnomaly(chance, paradox, def)
   -- execute the original function
   local retval = base_ParadoxDoAnomaly(self, chance, paradox, def)

   if retval then
      game:playSoundNear(self, "talents/dispel")
   end

   -- Never cancel the original talent
   return false
end

return _M

