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
	

	return {
		trail = nil,
		life = 14,
		size = rng.range(4,10), sizev = -0.1, sizea = 0,

		x = r * math.cos(a) + 2 * math.cos(ra), xv = 0, xa = 0,
		y = r * math.sin(a) + 2 * math.sin(ra), yv = 0, ya = 0,
		dir = rng.percent(50) and ray.dir + math.rad(90) or ray.dir - math.rad(90), dirv = 0, dira = 0,
		vel = rng.percent(80) and 1 or 0, velv = -0.2, vela = 0.01,

		r = 0.9, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 0.7, bv = 0, ba = 0,
		a = rng.float(0.5,1), av = -0.07, aa = 0,
	}
end, },

function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 4 then
		self.ps:emit(100*tiles)
	end
end,
8*100*tiles,
"particles_images/temporal_bolt"