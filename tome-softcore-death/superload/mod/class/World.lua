local _M = loadPrevious(...)

local base_gainAchievement = _M.gainAchievement
function _M:gainAchievement(id, src, ...)
	local pd = game.permadeath
	if src.flag_false_exploration then
		game.permadeath = game.PERMADEATH_INFINITE
	end

	local ret = base_gainAchievement(self, id, src, ...)

	game.permadeath = pd
	
	return ret
end
	 
return _M
