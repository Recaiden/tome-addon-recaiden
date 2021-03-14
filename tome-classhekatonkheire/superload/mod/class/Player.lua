local _M = loadPrevious(...)


function _M:extraEye(radius, x, y, checker)
	x = x or self.x
	y = y or self.y
	radius = math.floor(radius)

	local ox, oy

	self.x, self.y, ox, oy = x, y, self.x, self.y
	self:computeFOV(
		radius, "block_sense",
		function(x, y)
			if not checker or checker(x, y) then
				game.level.map:applyLite(x, y)
				game.level.map.remembers(x, y, true)
			end
		end,
		true, true, true)

	self.x, self.y = ox, oy
end

local base_playerFOV = _M.playerFOV
function _M:playerFOV()
	base_playerFOV(self)

	if self:knowTalent(self.T_REK_HEKA_HEADLESS_EYES) then
		local t = self:getTalentFromId(self.T_REK_HEKA_HEADLESS_EYES)
		local range = self:getTalentRange(t)
		local sqsense = range * range
		
		for actor, _ in pairs(game.party.members) do
			if actor.is_wandering_eye and not actor.dead and actor.x then
				self:extraEye(range, actor.x, actor.y)
				local arr = actor.fov.actors_dist
				local tbl = actor.fov.actors
				local act
				game.level.map:apply(actor.x, actor.y, 0.6)
				game.level.map:applyLite(actor.x, actor.y)
				--game.level.map:applyExtraLite(actor.x, actor.y)
				for i = 1, #arr do
					act = arr[i]
					if act and not act.dead and act.x and tbl[act] and actor:canSee(act) and tbl[act].sqdist <= sqsense then
						game.level.map.seens(act.x, act.y, 1.0)
					end
				end
			end
		end
	end
end

return _M
