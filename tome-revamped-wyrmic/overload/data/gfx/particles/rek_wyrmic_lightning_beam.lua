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
		trail = 0,
		life = 10,
		size = rng.range(4,8), sizev = -0.1, sizea = 0,

		x = r * math.cos(a) + 2 * math.cos(ra), xv = 0, xa = 0,
		y = r * math.sin(a) + 2 * math.sin(ra), yv = 0, ya = 0,
		dir = rng.float(0,math.pi*2), dirv = rng.float(-1,1), dira = 0,
		vel = rng.float(0,2), velv = 0, vela = 0,

		r = 1, rv = -0.1, ra = 0,
		g = 1, gv = -0.05, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = rng.float(0.5,1), av = -0.1, aa = 0,
	}
end, },

function(self)
	if not self.emitted then
		self.ps:emit(64*tiles)
	end
	self.emitted = 1
end,
64*tiles,
"particles_images/lightningshield"