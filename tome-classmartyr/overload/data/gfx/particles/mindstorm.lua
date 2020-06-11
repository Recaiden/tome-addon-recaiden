can_shift = true
base_size = 16

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.avg(1, 40 * 3)
	local dirv = math.rad(5)

	return {
		trail = 1,
		life = 50,
		size = rng.range(3, 6), sizev = -0.1, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = dirv, dira = 0,
		vel = 5, velv = 0, vela = 0,

		r = rng.range(200, 255)/255,   rv = 0.005, ra = 0.0005,
		g = rng.range(200, 255)/255,   gv = 0.005, ga = 0.0005,
		b = rng.range(0, 10)/255,      bv = 0, ba = 0,
		a = rng.range(200, 255)/255,    av = 0, aa = 0.005,
	}
end, },
function(self)
	self.ps:emit(10)
end,
500,
"weather/snowflake"
