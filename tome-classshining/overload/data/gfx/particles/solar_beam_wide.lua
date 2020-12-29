-- Make the ray
local ray = {}
local tiles = math.ceil(math.sqrt(tx*tx+ty*ty))
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
local breakdir = math.rad(rng.range(-8, 8))
ray.dir = math.atan2(ty, tx)
ray.size = math.sqrt(tx*tx+ty*ty)

-- Populate the beam based on the forks
return { generator = function()
	local a = ray.dir
	local rad = rng.range(-2,2)
	local ra = math.rad(rad)
	local r = rng.range(1, 100)-- ray.size)
	local slide = rng.range(-20, 20)

	if rng.percent(25) then
		local r2 = rng.range(1, ray.size)
		local slide2 = rng.range(-20, 20)
		return {
		life = 12,
		size = 4, sizev = -0.1, sizea = 0,

		x = r2 * math.cos(a) + 2 * math.cos(ra) + slide2*2*math.sin(a), xv = 0, xa = 0,
		y = r2 * math.sin(a) + 2 * math.sin(ra) + slide2*2*math.cos(a), yv = 0, ya = 0,
		dir = rng.percent(50) and ray.dir + math.rad(90) or ray.dir - math.rad(90), dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0.01,

		r = rng.range(220, 255)/255,  rv = 0, ra = 0,
		g = rng.range(200, 230)/255,  gv = -0.04, ga = 0,
		b = 0,                        bv = 0, ba = 0,
		a = rng.range(25, 220)/255,   av = 0, aa = 0,
					 }
	end
	return {
		life = 12,
		size = rng.range(3, 6), sizev = -0.1, sizea = 0,

		x = r * math.cos(a) + 2 * math.cos(ra)+slide*2*math.sin(a), xv = 50*math.cos(a), xa = -3*math.cos(a),
		y = r * math.sin(a) + 2 * math.sin(ra)+slide*2*math.cos(a), yv = 50*math.sin(a), ya = -3*math.sin(a),
		dir = rng.percent(50) and
			ray.dir + math.rad(rng.range(50, 130)) or
			ray.dir - math.rad(rng.range(50, 130)), dirv = 0, dira = 0,
		vel = 0, velv = 0, vela = 0.00,

		r = rng.range(220, 255)/255,  rv = rng.percent(50) and 5/255 or -5/255, ra = 0,
		g = rng.range(180, 210)/255,  gv = rng.percent(50) and 5/255 or -5/255, ga = 0,
		b = rng.range(0, 10)/255,     bv = 0, ba = 0,
		a = rng.range(25, 220)/255,   av = 0, aa = 0,
	}
end, },
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 12 then
		self.ps:emit(120*tiles)
	end
end,
18*120*tiles,
"particle_torus"
