local dur = 24
local life = 16

return {
	generator = function()
		local life = life
		local a = math.rad(rng.range(-160,-20))
		local dist = rng.range(32, 64)
		
		return {
			life = life,
			trail = 0.5,
			size = 3, sizev = 0.2, sizea = 0,
			
			x = 0, xv = 0, xa = 0,
			y = 0, yv = 0, ya = 0,
			dir = a, dirv=0, dira=0,
			vel = dist/life*1.2, velv = dist/(life*life)*2.4, vela = dist/(life*life)*-0.6,
			
			r = rng.range(80, 95)/255,  rv = 10/255, ra = 0,
			g = rng.range(80, 95)/255,  gv = 10/255, ga = 0,
			b = rng.range(80, 95)/255,  bv = 10/255, ba = 0,
			a = rng.range(220, 220)/255,  av = 0, aa = 0,
		}
	end,
},
function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < dur - 1 then
		self.ps:emit(10)
	end
end,
dur*30
