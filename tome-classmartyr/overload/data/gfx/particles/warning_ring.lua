local nb = nb or 60

local r = (r or 235) / 255
local g = (g or 205) / 255
local b = (b or 0) / 255
local size = size or 12

return { blend_mode=core.particles.BLEND_ADDITIVE, generator = function()
	local radius = radius or 3
	local sradius = radius * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local a = math.rad(rng.float(0, 360))
	local rvariance = math.cos(rng.float(-math.pi, math.pi))
	local rad = (1 + rvariance * 0.05) * sradius
	local x = rad * math.cos(a)
	local y = rad * math.sin(a)
	local v = 0.03

	return {
		trail = 2,
		life = 12,
		size = size, sizev = 0, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a + math.rad(90), 	dirv = v, 	dira = 0,
		vel = v * rad, 			velv = 0, 	vela = 0,

                r = r,  rv = 0, ra = 0,
                g = g,  gv = 0, ga = 0,
                b = b,  bv = 0, ba = 0,
		a = 0.06 * math.sqrt(1 - math.abs(rvariance)),  av = 0, aa = 0,
	}
end, },
function(self)
	self.ps:emit(nb)
end,
600