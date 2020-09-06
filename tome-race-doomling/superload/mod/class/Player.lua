local _M = loadPrevious(...)

local base_playerFOV = _M.playerFOV
function _M:playerFOV()
	base_playerFOV(self)

	--Handle Mark Prey Vision
	local eff = self:hasEffect(self.EFF_REK_DOOMLING_HUNTER)
	if eff then
		local uid, e = next(game.level.entities)
		while uid do
			if uid == eff.target then
				game.level.map.seens(e.x, e.y, 0.6)
			end
			uid, e = next(game.level.entities, uid)
		end
	end
end

return _M
