local _M = loadPrevious(...)


function _M:extraEye(radius, eyeActor, checker)
	x = eyeActor and eyeActor.x or self.x
	y = eyeActor and eyeActor.y or self.y
	radius = math.floor(radius)

	local ox, oy

	self.x, self.y, ox, oy = x, y, self.x, self.y
	self:computeFOV(
		radius, "block_sense",
		function(x, y)
			if not eyeActor or eyeActor:hasLOS(x, y) then
				game.level.map:applyLite(x, y)
				game.level.map.remembers(x, y, true)
			end
		end,
		true, true, true)

	self.x, self.y = ox, oy
end

local base_playerFOV = _M.playerFOV
function _M:playerFOV()
	if self:knowTalent(self.T_REK_HEKA_HEADLESS_EYES) and game and game.zone and not game.zone.wilderness then
		local sightRangeOld = self.sight
		self.sight = 1
		base_playerFOV(self)
		self.sight = sightRangeOld
		
		local t = self:getTalentFromId(self.T_REK_HEKA_HEADLESS_EYES)
		local range = self:getTalentRange(t)
		local sqsense = range * range
		
		for actor, _ in pairs(game.party.members) do
			if actor.is_wandering_eye and not actor.dead and actor.x then
				self:extraEye(range, actor)
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
	else
		base_playerFOV(self)
	end
end

local base_onTalentCooledDown = _M.onTalentCooledDown
function _M:onTalentCooledDown(tid)
	if not self:knowTalent(tid) then return end
	base_onTalentCooledDown(self, tid)
	local t = self:getTalentFromId(tid)
	if self:knowTalent(self.T_REK_HEKA_BLOODTIDE_BUFF) and t.hands then
		game.flyers:add(x, y, 30, -0.3, -3.5, ("Tempo: %s!"):tformat(t.name:capitalize()), {255,0,00})
		self:setEffect(self.EFF_REK_HEKA_TEMPO, 1, {src=self, talents={[tid]=1}})
		local eff = self:hasEffect(self.EFF_REK_HEKA_TEMPO)
		if eff then eff.dur = 0 end
	end
end
return _M
