-- Make the ray
local ray = {}
local tiles = math.ceil(math.sqrt(tx*tx+ty*ty))
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
local breakdir = math.rad(rng.range(-8, 8))
ray.dir = math.atan2(ty, tx)
ray.size = math.sqrt(tx*tx+ty*ty)

-- Populate the beam based on the forks
return {
	generator = function()
		local life = 14
		local a = ray.dir
		local as = a+math.pi/2
		
		local r = ray.size*0.1
		local a_def = math.rad(rng.range(-30, 30))
		ar = a + a_def
		
		return {
			life = life,
			trail = 1, 
			size = 2, sizev = -0.1, sizea = 0.1,
			
			x = r * math.cos(a), xv = 0, xa = 0,
			y = r * math.sin(a), yv = 0, ya = 0,
			dir = ar, dirv=a_def*-2/life, dira=0,
			vel = ray.size/life*1.5, velv = ray.size/(life*life)*-1, vela = 0,
			
			r = rng.range(140, 180)/255,  rv = 0, ra = 0,
			g = rng.range(140, 180)/255,      gv = 0, ga = 0,
			b = rng.range(160, 180),      bv = 0, ba = 0,
			a = rng.range(60, 100)/255,   av = 0, aa = 0,
					 }
	end,
},
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 13 then
		self.ps:emit(50)
	end
end,
8*50
