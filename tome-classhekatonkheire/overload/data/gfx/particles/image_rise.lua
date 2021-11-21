base_size = 64
local life = life or 8
local fade_in = fade_in or false
local nb = 0
return { generator = function()
	return {
		life = life,
		size = 64, sizev = 0, sizea = 0,

		x = 0, xv = 0, xa = 0,
		y = 0, yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = 1, rv = 0, ra = 0,
		g = 1, gv = 0, ga = 0,
		b = 1, bv = 0, ba = 0,
		a = fade_in and 0.25 or 1, av = fade_in and 0.5/life or 0, aa = fade_in and -2/life/life or -1/life/life,
	}
end, },
function(self)
	nb = nb + 1
	if nb <= 1 then
		self.ps:emit(1)
	end
end, 1, "particles_images/"..img
