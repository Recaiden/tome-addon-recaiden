base_size = 32
can_shift = true

local dir_light = math.rad(os.time()%360) -- consistent direction for all the particle patches in one star_zone, rotating over the course of 6 minutes.

return { generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.range(1, 20)
	local dirv = math.rad(1)
	local col = rng.range(20, 80)/255

	local darkprams = {
		life = 10,
		size = 16, sizev = 0, sizea = 0,
		x = r * math.cos(a), xv = rng.float(-0.4, 0.4), xa = 0,
		y = r * math.sin(a), yv = rng.float(-0.4, 0.4), ya = 0,
		dir = dir, dirv = dirv, dira = dir / 20,
		vel = 0.4, velv = 0, vela = 0.0,
		r = col,  rv = 0, ra = 0,
		g = col,  gv = 0, ga = 0,
		b = col,  bv = 0, ba = 0,
		a = rng.range(110, 130)/255,  av = 0, aa = 0,
	}
	local lightprams = {
		life = 5,
		size = 4, sizev = -0.2, sizea = 0,
		x = r * math.cos(a), xv = rng.float(-0.4, 0.4), xa = 0,
		y = r * math.sin(a), yv = rng.float(-0.4, 0.4), ya = 0,
		dir = dir_light, dirv = 0, dira = 0,
		vel = 1, velv = 0, vela = 0.1,
		r = rng.range(220, 230)/255,  rv = 0, ra = 0,
		g = rng.range(200, 230)/255,  gv = 0, ga = 0,
		b = rng.range(200, 230)/255,  bv = 0, ba = 0,
		a = rng.range(25, 220)/255,   av = 0, aa = 0,
	}

	return rng.table{darkprams, darkprams, lightprams}
end, },
function(self)
	self.ps:emit(4)
end,
40
