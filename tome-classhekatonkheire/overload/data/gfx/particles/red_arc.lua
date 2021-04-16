local nb = 12
local dir = 0
local spread = spread or 21
local radius = radius or 6

dir = math.deg(math.atan2(ty, tx))

return { generator = function()
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.float(dir - spread, dir + spread)
	local a = math.rad(ad)
	local r = 0
	local x = r * math.cos(a)
	local y = r * math.sin(a)
	local static = rng.percent(40)
	local vel = (sradius / 48)
	local trail = rng.range(0, 100)
	if trail < 8 or ad > (dir + 0.98 * spread) or ad < (dir - 0.98 * spread) then
		trail = 6
	else
		trail = 0
	end

	return {
		trail = trail,
		life = 12,
		size = 12 - (12 - nb) * 0.7, sizev = -1, sizea = 0,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = a, dirv = 0, dira = 0,
		vel = (2.2 * vel), velv = -(vel / 5), vela = 0,

		r = rng.range(150, 205)/255,    rv = 0.08, ra = 0,
		g = rng.range(10, 10)/255,      gv = 0, ga = 0,
		b = rng.range(10, 10)/255,      bv = 0, ba = 0,
		a = rng.range(157, 187)/255,    av = static and -0.034 or 0, aa = 0.005,
	}
end, },
function(self)
	if nb > 0 then
		local i = math.min(nb, 12)
		i = (i * i) * radius
		if nb == 12 then
			self.ps:emit(i)
		end
		nb = nb - 1
	end
end,
30*radius*7*12,
"particle_cloud"
