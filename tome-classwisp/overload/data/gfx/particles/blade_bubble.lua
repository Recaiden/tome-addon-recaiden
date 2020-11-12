local nb = 1
local radius = 10

return { generator = function()
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local vel = sradius * ((24 - nb * 1.4) / 24) / 12

	return {
		trail = 3,
		life = 60,
		size = rng.range(2,4), sizev = 0, sizea = 0,

		x = 0, xv = 0, xa = 0,
		y = 0, yv = 0, ya = 0,
		dir = rng.float(0,360), dirv = rng.float(-10,10), dira = 0,
		vel = rng.float(0,1)^0.5*vel+3, velv = -0.2, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = 1, av = rng.float(-1/60,-1/30),
	}
end, },

function(self)
	if nb > 0 then
		self.ps:emit(100*radius)
		nb = nb - 1
	end
end,
100*radius,
"particle_torus"
