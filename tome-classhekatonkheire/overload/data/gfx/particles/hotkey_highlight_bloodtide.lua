life = 25
icon_w = icon_w or 64

local colors = {
	{.1, .3, 1},
	{.1, .3, 1},
	{.8, .9, 1},
}
	
size = icon_w/4

radius = icon_w/2 --- size/2

local tx = 0
local ty = 0

local points = {}

for fork_i = 1, nb_circles or 3 do
	local size = size or 2
	local vel = rng.table({-0.4, -0.2, 0, 0.2, 0.4})
	local a = 0
	points[#points+1] = {
		size=size, dir = a + math.rad(90),
		vel = vel,
		x=math.cos(a) * radius,
		y=math.sin(a) * radius,
		prev=-1}
	
	for i = 1, 70 do
		a = math.rad(i * 5)
		points[#points+1] = {
			size=size, 	dir = a + math.rad(90),
			vel = vel,
			x=math.cos(a)/math.sqrt(math.abs(math.cos(a))) * radius,
			y=math.sin(a)/math.sqrt(math.abs(math.sin(a))) * radius,
			prev=#points-1
		}
	end

	a = 0
	points[#points+1] = {
		size=size, dir = a + math.rad(90),
		vel = vel,
		x=math.cos(a) * radius,
		y=math.sin(a) * radius,
		prev=#points-1}
	points[1].prev = #points
end
local nbp = #points
local idx = 1

return { 
blend_mode=additive and core.particles.BLEND_SHINY or nil,
engine=core.particles.ENGINE_LINES,
generator = function()
	local p = points[idx]
	idx = (idx + 1) % (nbp+1)
	if idx == 0 then idx = 1 end

	return {
		life = life, trail=p.prev,
		size = p.size, sizev = 0, sizea = 0,

		x = p.x, xv = 0, xa = 0,
		y = p.y, yv = 0, ya = 0,
		dir = p.dir, dirv = 0, dira = 0,
		vel = p.vel, velv = 0, vela = 0,

		r = rng.float(colors[1][1], colors[1][2]), rv = 0, ra = 0,
		g = rng.float(colors[2][1], colors[2][2]), gv = 0, ga = 0,
		b = rng.float(colors[3][1], colors[3][2]), bv = 0, ba = 0,
		a = 1, av = 0, aa = -0.002,
	}
end, },

function(self)
	if nbp > 0 then
		self.ps:emit(18)
	end
end,
nbp, "particles_images/beam"
