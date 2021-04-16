base_size = 32

local distributionOffset = math.rad(rng.range(0, 360))

return { generator = function()
	local life = rng.float(6, 10)
	local size = 1
	local angle = math.rad(rng.range(0, 360))
	local distribution = (math.sin(angle + distributionOffset) + 1) / 2
	local distance = engine.Map.tile_w * rng.float(0.3, 0.9)
	local startX = distance * math.cos(angle) + dx * engine.Map.tile_w
	local startY = distance * math.sin(angle) + dy * engine.Map.tile_h
	local alpha = (80 - distribution * 50) / 255

	local r = color_r or 100
	local g = color_g or 100
	local b = color_b or 100

	local dir_r = ((dir_c or 1) + 1)%3 - 1
	local dir_g = ((dir_c or 1) + 0)%3 - 1
	local dir_b = ((dir_c or 1) - 1)%3 - 1
	
	local speed = 0.02
	local dirv = math.pi * 2 * speed
	local vel = math.pi * distance * speed
	
	return {
		trail = 1,
		life = life,
		size = size, sizev = size / life / 3, sizea = 0,

		x = -size / 2 + startX, xv = -startX / life, xa = 0,
		y = -size / 2 + startY, yv = -startY / life, ya = 0,
		dir = angle + math.rad(90), dirv = dirv, dira = 0,
		vel = vel, velv = -vel / life, vela = 0,
		
		r = (r + distribution * dir_r * 100) / 255,  rv = 0, ra = 0,
		g = (g + distribution * dir_g * 100) / 255,  gv = 0, ga = 0,
		b = (b - distribution * dir_b * 100) / 255,  bv = 0, ba = 0,
		a = 20 / 255,  av = alpha / life / 2, aa = 0,
	}
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb <= 5 then
		self.ps:emit(500 - 60 * self.nb)
	end
end,
500 * 10
