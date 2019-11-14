local _M = loadPrevious(...)

-- Just ignore this bizarre stat
local base_ccr = _M.combatCritReduction
function _M:combatCritReduction()
   return 0
end

return _M