-- Auto-generated particle system
local ray = {}
local tiles = math.ceil(math.sqrt(tx*tx+ty*ty))
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
ray.dir = math.atan2(ty, tx)
ray.size = math.sqrt(tx*tx+ty*ty)

-- Populate the beam based on the forks
return { generator = function()
	local a = ray.dir
	local rad = rng.range(-3,3)
	local ra = math.rad(rad)
	local r = rng.range(1, ray.size)
	local color = rng.range(1,4)

	return {
		trail = nil,
		life = 14,
		size = 4, sizev = -0.1, sizea = 0,

		x = r * math.cos(a) + 2 * math.cos(ra), xv = 0, xa = 0,
		y = r * math.sin(a) + 2 * math.sin(ra), yv = 0, ya = 0,
		dir = rng.percent(50) and ray.dir + math.rad(90) or ray.dir - math.rad(90), dirv = color <= 2 and rng.float(-0.1,0.1) or 0, dira = 0,
		vel = rng.percent(80) and 1 or 0, velv = -0.2, vela = 0.01,

		r = color == 1 and rng.float(0.9,1)
			or color == 2 and 0.4
			or color == 3 and 1
			or color == 4 and rng.float(0.6,0.8), rv = color == 1 and 0
			or color == 2 and 0
			or color == 3 and -0.1
			or color == 4 and 0, ra = 0,
		g = color == 1 and rng.float(0.8,0.9)
			or color == 2 and 0.7
			or color == 3 and 1
			or color == 4 and 0, gv = color == 1 and -0.04
			or color == 2 and 0
			or color == 3 and -0.05
			or color == 4 and 0, ga = 0,
		b = color == 1 and 0
			or color == 2 and 1
			or color == 3 and 1
			or color == 4 and rng.float(0.6,0.8), bv = 0, ba = 0,
		a = color == 1 and 1
			or color == 2 and rng.float(0.9,1)
			or color == 3 and rng.float(0.5,1)
			or color == 4 and rng.float(0.5,1), av = -0.07, aa = 0,
	}
end, },

function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 4 then
		self.ps:emit(100*tiles)
	end
end,
8*100*tiles
