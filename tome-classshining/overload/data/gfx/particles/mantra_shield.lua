can_shift = true
base_size = 32

return { blend_mode=core.particles.BLEND_SHINY, generator = function()
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.range(12, 20)
	local dirv = math.rad(1)

	return {
		trail = 0,
		life = rng.range(10, 20),
		size = rng.range(3, 5), sizev = -0.1, sizea = 0,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = dir, dirv = -dirv, dira = 0,
		vel = 1, velv = 0, vela = 0,

		r = rng.range(220, 255)/255,  rv = 0, ra = 0,
		g = rng.range(120, 150)/255,  gv = 0, ga = 0,
		b = rng.range(000, 030)/255,  bv = 0, ba = 0,
		a = rng.range(065, 160)/255,  av = -0.03, aa = 0,
	}
end, },
function(self)
	self.ps:emit(10)
end,
200, "particle_torus"

