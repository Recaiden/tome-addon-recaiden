
base_size = 32

local first = true

local color = color or {r=127, g=127, b=127}
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
		vel = vel*2, velv = 0, vela = 0,
		-- ??? <-- I was ACTUALLY hoping for a more "oval-shaped" revolution (to give the illusion of depth), but it seems particles are limited in this way...

		r = 240 / 255,  rv = 0, ra = 0,
		g = 240 / 255,  gv = 0, ga = 0,
		b = 70 / 255,  bv = 0, ba = 0,
		a = 0.7,   av = 0, aa = 0,
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
3, "particles_images/stars"
