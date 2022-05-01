local _M = loadPrevious(...)

local base_die = _M.die
function _M:die(src, death_note)
	if self.define_as == "CARAVAN_MASTER" and game.state:allowRodRecall() then
		world:gainAchievement("HAMMER_FIRST_BOSS_CARAVAN", src)
	end
	base_die(self, src, death_note)
end

return _M
