-- Auto-generated particle system
local nb = 12
local radius = radius or 6

return { generator = function()
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local a = rng.float(0,math.pi*2)
	local x = 0
	local y = 0
	local vel = sradius * ((24 - nb * 1.4) / 24) / 12
	local white = rng.chance(3)

	return {
		trail = 0,
		life = 12,
		size = rng.range(2,4), sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = rng.float(-0.4,0.4), dira = 0,
		vel = rng.float(vel*0.6,vel*1.2), velv = 0, vela = 0,

		r = white and 1 or 0.4, rv = 0, ra = 0,
		g = white and 1 or 0.7, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = rng.float(0.9,1), av = -0.07, aa = -0.004,
	}
end, },

function(self)
	if nb > 0 then
		local i = math.min(nb, 6)
		i = (i * i) * radius
		self.ps:emit(i)
		nb = nb - 1
	end
end,
30*radius*7*12,
"particle_torus"