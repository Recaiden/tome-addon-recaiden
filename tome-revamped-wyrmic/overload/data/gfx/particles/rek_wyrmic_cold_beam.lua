-- Auto-generated particle system
local ray = {}
local tiles = math.ceil(math.sqrt(tx*tx+ty*ty))
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
ray.dir = math.atan2(ty, tx)
ray.size = math.sqrt(tx*tx+ty*ty)

-- Populate the beam based on the forks
return { generator = function()
	local a = ray.dir
	local rad = rng.range(-3,3)
	local ra = math.rad(rad)
	local r = rng.range(1, ray.size)
	local white = rng.chance(3)

	return {
		trail = nil,
		life = 14,
		size = rng.range(2,4), sizev = -0.1, sizea = 0,

		x = r * math.cos(a) + 2 * math.cos(ra), xv = 0, xa = 0,
		y = r * math.sin(a) + 2 * math.sin(ra), yv = 0, ya = 0,
		dir = rng.float(0,math.pi*2), dirv = rng.float(-0.2,0.2), dira = 0,
		vel = rng.float(0,1), velv = 0, vela = 0,

		r = white and 1 or 0.4, rv = 0, ra = 0,
		g = white and 1 or 0.7, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = rng.float(0.9,1), av = -0.07, aa = -0.004,
	}
end, },

function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 4 then
		self.ps:emit(100*tiles)
	end
end,
8*100*tiles,
"particle_torus"