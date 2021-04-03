local rot = rng.range(0,359)
local img = img or "spinningwinds_black"
local radius = radius or 1

use_shader = {type="spinningwinds", ellipsoidalFactor={1,1}, time_factor=2000, noup=0.0, verticalIntensityAdjust=-3.0}
base_size = 64

local first = true
return {
	system_rotation = rot, system_rotationv = 0,
	generator = function()
	return {
		trail = 0,
		life = 8,
		size = 90, sizev = 12 * radius, sizea = 0,

		x = 0, xv = 0, xa = 0,
		y = 0, yv = 0, ya = 0,
		dir = 0, dirv = dirv, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = 1, av = -0.05, aa = 0,
	}
end, },
function(self)
	self.ps:emit(1)
end,
1, "particles_images/"..img
