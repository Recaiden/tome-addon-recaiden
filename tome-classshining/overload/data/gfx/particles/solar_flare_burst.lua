max_alpha = max_alpha or 120

local nb = 0
return { generator = function()
	local radius = radius
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local r = rng.float(sradius - 12, sradius)
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local static = (all_static or false) or rng.percent(40)

	if static then
		return {
		trail = 3,
		life = rng.range(8, 16),
		size = 3, sizev = static and 0.05 or 0.15, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a + math.rad(90 + rng.range(10, 20)), dirv = 0, dira = 0,
		vel = 2, velv = 0, vela = 0,

		r = rng.range(235, 255)/255,  rv = 0, ra = 0,
		g = rng.range(170, 200)/255,  gv = 0, ga = 0,
		b = 0,                        bv = 0, ba = 0,
		a = rng.range(25, max_alpha)/255,    av =  -0.034, aa = 0.005,
	}
	end
	
	return {
		trail = 1,
		life = 24,
		size = 3, sizev = 0.15, sizea = 0,

		x = 0, xv = 0, xa = 0,
		y = 0, yv = 0, ya = 0,
		dir = a, dirv = 0, dira = 0,
		vel = -0.5 * radius / 2.7, velv = -.42 * radius, vela = 0.03 * radius,

		r = rng.range(220, 255)/255,  rv = 0, ra = 0,
		g = rng.range(200, 230)/255,  gv = 0, ga = 0,
		b = 0,                        bv = 0, ba = 0,
		a = rng.range(25, max_alpha)/255,    av = 0, aa = 0.005,
	}
end, },
function(self)
	if all_static or nb < 24 then
		self.ps:emit(radius*266)
	end
	nb = nb + 1
end,
5*radius*266
