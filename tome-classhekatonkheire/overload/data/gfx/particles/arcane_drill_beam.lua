-- Make the ray
local ray = {}
local tiles = math.ceil(math.sqrt(tx*tx+ty*ty))
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
local breakdir = math.rad(rng.range(-8, 8))
ray.dir = math.atan2(ty, tx)
ray.size = math.sqrt(tx*tx+ty*ty)

return {
	generator = function()
		local life = 14
		local a = ray.dir
		local as = a+math.pi/2
		
		local static = rng.percent(30)
		if not static then
			local rad = rng.range(-3,3)
			local ra = math.rad(rad)
			local r = rng.range(ray.size*0.2, ray.size*0.8)
			local slide = rng.range(-6, 6)
			local h = rng.range(1, math.sqrt(ray.size*ray.size+slide*slide))
			local ah = a - math.tan(slide/ray.size)
			return {
				life = life,
				size = 4, sizev = -0.1, sizea = 0,
				
				x = h * math.cos(ah) + 2 * math.cos(ra) + slide * math.cos(as), xv = 0, xa = 0,
				y = h * math.sin(ah) + 2 * math.sin(ra) + slide * math.sin(as), yv = 0, ya = 0,

				dir = ray.dir, dirv=0, dira=0,
				vel = rng.percent(80) and 0 or 0.2*ray.size/life, velv = 0, vela = 0,
				
				r = rng.range(140, 180)/255,  rv = 0, ra = 0,
				g = rng.range(0, 0)/255,      gv = 0, ga = 0,
				b = rng.range(160, 215),      bv = 0, ba = 0,
				a = rng.range(25, 190)/255,   av = 0, aa = 0,
						 }
		else
			local r = ray.size
			ar = a + math.rad(rng.range(-180, 180))

			return {
				life = life,
				trail = 3, 
				size = 2, sizev = -0.1, sizea = 0,
				
				x = r * math.cos(a), xv = 0, xa = 0,
				y = r * math.sin(a), yv = 0, ya = 0,
				dir = ar, dirv=0, dira=0,
				vel = 0.025 * ray.size*1, velv = 0, vela = 0,
				
				r = rng.range(180, 220)/255,  rv = 0, ra = 0,
				g = rng.range(0, 0)/255,      gv = 0, ga = 0,
				b = rng.range(160, 215),      bv = 0, ba = 0,
				a = rng.range(25, 220)/255,   av = 0, aa = 0,
						 }
		end
	end,
},
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 13 then
		self.ps:emit(100*tiles)
	end
end,
8*100*tiles
