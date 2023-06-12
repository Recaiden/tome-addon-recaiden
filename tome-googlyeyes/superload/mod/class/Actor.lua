local _M = loadPrevious(...)

local Particles = require "engine.Particles"

function _M:updateGooglyEyes()
	if self.__googly_particles then
		self:removeParticles(self.__googly_particles[1])
		self:removeParticles(self.__googly_particles[2])
		self.__googly_particles = nil
	end

	local bx, by, offset, offsetV
	bx, by = self:attachementSpot("head", true)
	offset = 6
	offsetV = 0
	if not bx then
		bx = 0
		by = 0 ---0.3
		offset = 8
		offsetV = -3
	end
	self.__googly_particles = {
		self:addParticles(Particles.new("level_circle", 0.15, {x=(bx*64-offset) * (self._flipx and -1 or 1), y=by*64+offsetV, oversize=0.15, a=255, speed=0, img="googl", radius=0})),
		self:addParticles(Particles.new("level_circle", 0.15, {x=(bx*64+offset) * (self._flipx and -1 or 1), y=by*64+offsetV, oversize=0.15, a=255,  speed=0, img="googl", radius=0}))
	}
	--TODO extra eyes for spiders no eyes for headless enemies, etc.
end

local MOflipX = _M.MOflipX
function _M:MOflipX(v)
	local oldflip = self._flipx
	MOflipX(self, v)
	
	if v ~= oldflip then
		self:updateGooglyEyes()
	end
end

local base_umtp = _M.updateModdableTilePrepare
function _M:updateModdableTilePrepare()
	self:updateGooglyEyes()
	
	return base_umtp(self)
end

return _M
