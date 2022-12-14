local _M = loadPrevious(...)

local base_gainAchievement = _M.gainAchievement
function _M:gainAchievement(id, src, ...)
	if game.difficulty == 1.5 then return end
	base_gainAchievement(self, id, src, ...)
end

return _M
