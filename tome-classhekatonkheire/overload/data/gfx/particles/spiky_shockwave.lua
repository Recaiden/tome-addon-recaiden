rm, rM = rm or 0.8, rM or 1
gm, gM = gm or 0.8, gM or 1
bm, bM = bm or 0.8, bM or 1
am, aM = am or 1, aM or 1

-- calculate direction and length from caster to target
local ray = {}
local tiles = math.ceil(math.sqrt(tx*tx+ty*ty))
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
local breakdir = math.rad(rng.range(-8, 8))
ray.dir = math.atan2(ty, tx)
ray.size = math.sqrt(tx*tx+ty*ty)

local distortion_factor = 1 + (distortion_factor or 0.1)
local life = life or 10
local fullradius = (radius or 2) * engine.Map.tile_w
local basespeed = fullradius / life
local points = {}

minangle = function(x, y)
	x = x % (math.pi*2)
	y = y % (math.pi*2)
	local a = math.abs(x-y)
	if a > math.pi then
		a = 2*math.pi - a
	end
	return a
end

for fork_i = 1, nb_circles or 3 do
	local size = size or 2
	local r = 10
	local a = 0
	local dc = 0.33
	local vspike = 10
	local firstspeed = basespeed
	points[#points+1] = {size=size,
											 dir = a + math.rad(90),
											 vel = basespeed - basespeed * dc * minangle(a + math.rad(90), ray.dir)/(math.pi) + vspike*(math.abs(math.rad(15)-a%math.rad(30))),
											 x=math.cos(a) * r + math.cos(ray.dir) * ray.size * 0.8,
											 y=math.sin(a) * r + math.sin(ray.dir) * ray.size * 0.8,
											 prev=-1}

	for i = 1, 142 do
		local a = math.rad(i * 2.5)
		points[#points+1] = {
			size=size,
			dir = a + math.rad(90),
			vel = basespeed - basespeed * dc * minangle(a + math.rad(90), ray.dir)/(math.pi) + vspike*(math.abs(math.rad(15)-a%math.rad(30))),
			x=math.cos(a) * r + math.cos(ray.dir) * ray.size * 0.8,
			y=math.sin(a) * r + math.sin(ray.dir) * ray.size * 0.8,
			prev=#points-1
		}
	end

	a = 0
	points[#points+1] = {size=size, dir = a + math.rad(90),
											 vel = basespeed - basespeed * dc * minangle(a + math.rad(90), ray.dir)/(math.pi) + vspike*(math.abs(math.rad(15)-a%math.rad(30))),
											 x=math.cos(a) * r + math.cos(ray.dir) * ray.size * 0.8,
											 y=math.sin(a) * r + math.sin(ray.dir) * ray.size * 0.8, prev=#points-1}
	--points[1].prev = #points-1
end
local nbp = #points

return { 
blend_mode=additive and core.particles.BLEND_SHINY or nil,
engine=core.particles.ENGINE_LINES,
generator = function()
	local p = table.remove(points, 1)

	return {
		life = life, trail=p.prev,
		size = p.size, sizev = 0, sizea = 0,

		x = p.x, xv = 0, xa = 0,
		y = p.y, yv = 0, ya = 0,
		dir = p.dir, dirv = 0, dira = 0,
		vel = p.vel, velv = 0, vela = 0,

		r = rng.float(rm, rM), rv = 0, ra = 0,
		g = rng.float(gm, gM), gv = 0, ga = 0,
		b = rng.float(bm, bM), bv = 0, ba = 0,
		a = rng.float(am, aM), av = 0, aa = -0.001,
	}
end, },
function(self)
	if nbp > 0 then
		self.ps:emit(144)
		nbp = nbp - 144
	end
end,
nbp, "particles_images/beam"
