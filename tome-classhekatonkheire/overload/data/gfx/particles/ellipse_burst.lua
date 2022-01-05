max_alpha = max_alpha or 120

local r = r or 255
local g = g or 255
local b = b or 255

local stretch_x = stretch_x or 1.0
local stretch_y = stretch_y or 1.0

local nb = 0
return { generator = function()
	local radius = radius
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local rad = rng.float(sradius - 12, sradius)
	local x = rad * math.cos(a) * stretch_x
	local y = rad * math.sin(a) * stretch_y
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local static = rng.percent(40)

	return {
		trail = 1,
		life = 24,
		size = 3, sizev = static and 0.05 or 0.15, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = static and a + math.rad(90 + rng.range(10, 20)) or a, dirv = 0, dira = 0,
		vel = static and 2 or 0.5 * (-1-nb) * radius / 2.7, velv = 0, vela = static and 0.01 or rng.float(-0.3, -0.2) * 0.3,

		r = r/255, rv = 0, ra = 0,
		g = g/255, gv = 0, ga = 0,
		b = b/255, bv = 0, ba = 0,
		a = rng.range(25, max_alpha)/255, av = static and -0.034 or 0, aa = 0.005,
	}
end, },
function(self)
	if nb < 5 then
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
		self.ps:emit(radius*266)
		nb = nb + 1
	end
end,
5*radius*266
