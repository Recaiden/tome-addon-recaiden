local dur = 24
local life = 16

return {
	generator = function()
		local life = life
		local a = math.rad(rng.range(0,360))
		local dist = 32
		
		local static = rng.percent(33)
		if static then
			return {
				life = life,
				size = 5, sizev = 0.1, sizea = 0,
				
				x = dist * math.cos(a), xv = 0, xa = 0,
				y = dist * math.sin(a), yv = 0, ya = 0,
				dir = a+math.pi/2, dirv=0, dira=0,
				vel = 0, velv = 0, vela = 0,
				
				r = rng.range(245, 255)/255,  rv = 0, ra = 0,
				g = rng.range(245, 255)/255,  gv = 0, ga = 0,
				b = rng.range(245, 255)/255,  bv = 0, ba = 0,
				a = rng.range(220, 220)/255,  av = 0, aa = 0,
						 }
		else
			return {
				life = life,
				trail = 0.5,
				size = 6, sizev = -0.2, sizea = 0,
				
				x = dist * math.cos(a), xv = 0, xa = 0,
				y = dist * math.sin(a), yv = 0, ya = 0,
				dir = a+math.pi*1.1, dirv=0, dira=0,
				vel = dist/life*0.3, velv = dist/life*0.2, vela = 0,
				
				r = rng.range(245, 255)/255,  rv = -10/255, ra = 0,
				g = rng.range(245, 255)/255,  gv = -10/255, ga = 0,
				b = rng.range(245, 255)/255,  bv = -10/255, ba = 0,
				a = rng.range(220, 220)/255,  av = 0, aa = 0,
						 }
		end
	end,
},
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < dur - 1 then
		self.ps:emit(300)
	end
end,
dur*300
