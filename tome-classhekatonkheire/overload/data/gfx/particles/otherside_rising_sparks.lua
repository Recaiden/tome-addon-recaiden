local dur = 24
local life = 16
local nb = nb or 1
return {
	system_rotation = base_rot or 0,
	generator = function()
		local a = math.rad(rng.range(-160,-20))
		local dist = rng.range(4, 16+nb*4)
		local life = life
		
		return {
			life = life,
			trail = 1,
			size = 1, sizev = 0, sizea = 0,
			
			x = dist*math.cos(a), xv = 0, xa = 0,
			y = dist*math.sin(a)+16, yv = 0, ya = 0,
			dir = math.rad(-90), dirv=0, dira=0,
			vel = 24*(1+(nb-1)/4)/life*1.2, velv = 0, vela = 0,
			
			r = rng.range(80, 95)/255,  rv = 10/255, ra = 0,
			g = rng.range(80, 95)/255,  gv = 10/255, ga = 0,
			b = rng.range(80, 95)/255,  bv = 10/255, ba = 0,
			a = rng.range(220, 220)/255,  av = 0, aa = 0,
		}
	end,
},
function(self)
	self.ps:emit(1)
end,
5*nb*nb
