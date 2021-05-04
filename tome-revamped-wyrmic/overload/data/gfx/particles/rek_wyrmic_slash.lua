-- Make the ray
local ray = {}
local tiles = math.ceil(math.sqrt(tx*tx+ty*ty))
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
local breakdir = math.rad(rng.range(-8, 8))
local side = rng.table({-1, 1})
ray.dir = math.atan2(ty, tx)
ray.size = math.sqrt(tx*tx+ty*ty)

return {
	generator = function()
		local life = 20
		local a = ray.dir
		
		local ring = rng.range(-1,1)
		local r = ray.size*(0.7 + 0.2*ring)

		angle = a + math.rad(60*side)
		
		return {
			life = life+3*ring, trail = 1,
			size = 4, sizev = 0, sizea = 0,
			
			x = r*math.cos(angle), xv = 0, xa = 0,
			y = r*math.sin(angle), yv = 0, ya = 0,
			
			dir = angle+math.rad(-90*side), dirv=-0.05*side, dira=-0.0025*side,
			vel = 3*tiles, velv = 0, vela = 0,
			
			r = rng.range(100, 130)/255,  rv = 0, ra = 0,
			g = rng.range( 10,  10)/255,  gv = 0, ga = 0,
			b = rng.range( 10,  10)/255,  bv = 0, ba = 0,
			a = rng.range( 25, 190)/255,  av = 0, aa = 0,
		}

	end,
},
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 11 then
		self.ps:emit(1000)
	end
end,
6*1500
