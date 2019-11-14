-- Auto-generated particle system
local nb = 12
local radius = radius or 6

return { generator = function()
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local a = rng.float(0,math.pi*2)
	local x = 0
	local y = 0
	local vel = sradius * ((24 - nb * 1.4) / 24) / 12
	local color = rng.range(1,4)

	return {
		trail = 1,
		life = 12,
		size = 12 - (12 - nb) * 0.7, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = color <= 2 and rng.float(-0.1,0.1) or 0, dira = 0,
		vel = rng.float(vel*0.6,vel*1.2), velv = 0, vela = 0,

		r = color == 1 and rng.float(0.9,1)
			or color == 2 and 0.4
			or color == 3 and 1
			or color == 4 and rng.float(0.6,0.8), rv = color == 1 and 0
			or color == 2 and 0
			or color == 3 and -0.1
			or color == 4 and 0, ra = 0,
		g = color == 1 and rng.float(0.8,0.9)
			or color == 2 and 0.7
			or color == 3 and 1
			or color == 4 and 0, gv = color == 1 and -0.04
			or color == 2 and 0
			or color == 3 and -0.05
			or color == 4 and 0, ga = 0,
		b = color == 1 and 0
			or color == 2 and 1
			or color == 3 and 1
			or color == 4 and rng.float(0.6,0.8), bv = 0, ba = 0,
		a = color == 1 and 1
			or color == 2 and rng.float(0.9,1)
			or color == 3 and rng.float(0.5,1)
			or color == 4 and rng.float(0.5,1), av = -0.07, aa = 0,
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
30*radius*7*12
