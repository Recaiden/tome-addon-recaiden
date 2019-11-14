-- Auto-generated particle system
local radius, density = radius or 3, density or 200
base_size = 32
can_shift = true

return { generator = function()
	local radius = radius
	local sradius = 1 --(radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.avg(1, sradius)
	local dirv = math.rad(5)

	return {
		trail = 1,
		life = 50,
		size = rng.range(4,10), sizev = -0.1, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = a, dirv = 0, dira = 0,
		vel = 5, velv = 0, vela = 0,

		r = 0.9, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 0.7, bv = 0, ba = 0,
		a = rng.float(0.5,1), av = -0.07, aa = 0,
	}
end, },

function(self)
	self.ps:emit(10)
end,
density * (math.min(4, radius)^2+0.5),
"particles_images/temporal_bolt"