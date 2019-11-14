-- Auto-generated particle system
local nb = 12
local radius = radius or 6

return { generator = function()
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local a = rng.float(0,math.pi*2)
	local x = 0
	local y = 0
	local vel = sradius * ((24 - nb * 1.4) / 24) / 12
	

	return {
		trail = 0,
		life = 10,
		size = rng.range(4,8), sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = 0, dira = 0,
		vel = rng.float(0,1)^0.5*vel*4, velv = 0, vela = 0,

		r = 1, rv = -0.1, ra = 0,
		g = 1, gv = -0.05, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = rng.float(0.5,1), av = -0.1, aa = 0,
	}
end, },

function(self)
	if not self.emitted then
		self.ps:emit(256*radius)
	end
	self.emitted = 1
end,
256*radius,
"particles_images/lightningshield"