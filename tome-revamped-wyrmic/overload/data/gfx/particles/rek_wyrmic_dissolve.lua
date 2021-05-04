-- Make the ray
local ray = {}
local tx = engine.Map.tile_w
local ty = engine.Map.tile_h
local breakdir = math.rad(rng.range(-8, 8))
ray.dir = math.atan2(ty, tx)
ray.size = math.sqrt(tx*tx+ty*ty)
local dir = 0

return {
	generator = function()
		local life = 6
		local angle = dir
		
		local ring = rng.range(-1,1)
		local r = ray.size*(0.4 + 0.1*ring)
		
		return {
			life = life, trail = 1,
			size = 4, sizev = 0, sizea = 0,
			
			x = r*math.cos(angle) + r*0.3*math.cos(angle+math.rad(90)*ring), xv = 0, xa = 0,
			y = r*math.sin(angle) + r*0.3*math.sin(angle+math.rad(90)*ring), yv = 0, ya = 0,
			
			dir = angle, dirv=0, dira=0,
			vel = -5, velv = 0, vela = 0,
			
			r = rng.range(180, 200)/255,  rv = 0, ra = 0,
			g = rng.range( 10,  10)/255,  gv = 0, ga = 0,
			b = rng.range( 10,  10)/255,  bv = 0, ba = 0,
			a = rng.range( 25, 190)/255,  av = 0, aa = 0,
		}

	end,
},
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 5 then
		dir = math.rad(rng.range(0,360))
		self.ps:emit(1000)
	end
end,
6*1500
