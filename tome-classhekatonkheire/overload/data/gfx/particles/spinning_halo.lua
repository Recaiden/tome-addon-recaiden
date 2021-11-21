base_size = 32

local first = true
local color = color or {r=240, g=240, b=240, a=178}
local r = 6
local speed = 50
local dirv = math.pi * 2 / speed
local vel = math.pi * 2 * r / speed
local start = 0.00

return { generator = function()
	local angle = math.rad(360 * start)
	local dir = math.rad(360 * start + 90)

	return {
		life = core.particles.ETERNAL,
		size = rng.range(4,7), sizev = 0, sizea = 0,

		x = (x or 0)*32 +r * math.cos(angle), xv = 0, xa = 0,
		y = (y or -0.25)*32 -8 + r/3 * math.sin(angle), yv = 0, ya = 0,
		dir = dir, dirv = dirv, dira = 0,
		vel = vel, velv = 0, vela = 0,

		r = color.r / 255,  rv = 0, ra = 0,
		g = color.g / 255,  gv = 0, ga = 0,
		b = color.b / 255,  bv = 0, ba = 0,
		a = color.a / 255,   av = 0, aa = 0,
	}
end, },
function(self)
	if first then
		first = false
		
		start = 0.00
		self.ps:emit(1)
		start = 0.33
		self.ps:emit(1)
		start = 0.66
		self.ps:emit(1)
	end
end,
3, "particles_images/"..img
