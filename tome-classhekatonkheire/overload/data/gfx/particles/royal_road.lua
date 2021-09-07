base_size = 32
num = 1
life = 20
frame = 0
	
local color1 = {1, 1, 1}
local color2 = {.8, .8, 0}
local colorD = {color2[1] - color1[1], color2[2] - color1[2], color2[3] - color1[3]}

return { blend_mode=core.particles.BLEND_SHINY, generator = function()
	local width = base_size * .5

	return {
		life = life,
		size = 6, sizev = 0, sizea = 0,

		x = rng.range(-width, width), xv = .5*rng.float(-width, width)/life, xa = 0,
		y = rng.range(-width, width), yv = 0, ya = 0,
		dir = 0, dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0,

		r = color1[1],  rv = colorD[1]/life, ra = 0,
		g = color1[2],  gv = colorD[2]/life, ga = 0,
		b = color1[3],  bv = colorD[3]/life, ba = 0,
		a = .4, av = -.4/life, aa = 0,
	}
end, },
function(self)
	if frame == 0 then
		for i = 1, num do
			self.ps:emit(1)
		end
	end
	frame = (frame + 1) % 4
end,
num * (life+1), "particles_images/frog_square"
