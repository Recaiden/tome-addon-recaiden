max_alpha = max_alpha or 120

local r = r or 255
local g = g or 255
local b = b or 255

local stretch_x = stretch_x or 1.0
local stretch_y = stretch_y or 1.0

local nb = 0
local phase = rng.float(-1, 1)
local phase_off = rng.float(-1, 1)
local emitted = false
return { generator = function()
	local radius = radius
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(0, 360)
	local a = math.rad(ad)
	local rad = rng.float(sradius - 12, sradius)
	local stretch_x = phase / 2
	local stretch_y = phase_off / 2
	local x = rad * math.cos(a) * stretch_x
	local y = rad * math.sin(a) * stretch_y
	local bx = math.floor(x / engine.Map.tile_w)
	local by = math.floor(y / engine.Map.tile_h)
	local core = rng.percent(30)
	if core then
		local scale = 0.5
		return {
			trail = 1,
			life = 24,
			size = 3, sizev = 0.05, sizea = 0,
			
			x = 0, xv = 0, xa = 0,
			y = 0, yv = 0, ya = 0,
			dir = a + math.rad(90 + rng.range(10, 20)), dirv = 0, dira = 0,
			vel = 1 * scale, velv = 0.1 * scale, vela = -0.05 * scale,
			
			r = r/255, rv = 0, ra = 0,
			g = g/255, gv = 0, ga = 0,
			b = b/255, bv = 0, ba = 0,
			a = rng.range(25, max_alpha)/255, av = -0.034, aa = 0.005,
		}
	end

	return {
		trail = 1,
		life = 24,
		size = 3, sizev = 0.05, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a + math.rad(90 + rng.range(10, 20)), dirv = 0, dira = 0,
		vel = 2*phase/math.abs(phase), velv = 0, vela = 0.01*phase,

		r = r/255, rv = 0, ra = 0,
		g = g/255, gv = 0, ga = 0,
		b = b/255, bv = 0, ba = 0,
		a = rng.range(25, max_alpha)/255, av = -0.034, aa = 0.005,
	}
end, },
	function(self)
		if not emitted then
			self.ps:emit(radius*266)
			emitted = true
		end
end,
5*radius*266
