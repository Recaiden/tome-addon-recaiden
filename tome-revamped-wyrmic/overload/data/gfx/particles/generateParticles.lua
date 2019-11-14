-- From Crystalists

-- Auto-generate particle effects
-- This way you can add a new damage type without manually writing 4 new
-- particle systems
local function g(field,def)
   return curParams[cur] and curParams[cur][field] or curParams[field] or def
end
generators = {
   beam = function(params)
      cur = "beam"
      curParams = params
      return string.format([[
-- Auto-generated particle system
local ray = {}
local tiles = math.ceil(math.sqrt(tx*tx+ty*ty))
local tx = tx * engine.Map.tile_w
local ty = ty * engine.Map.tile_h
ray.dir = math.atan2(ty, tx)
ray.size = math.sqrt(tx*tx+ty*ty)

-- Populate the beam based on the forks
return { generator = function()
	local a = ray.dir
	local rad = rng.range(-3,3)
	local ra = math.rad(rad)
	local r = rng.range(1, ray.size)
	%s

	return {
		trail = %s,
		life = %s,
		size = %s, sizev = %s, sizea = %s,

		x = r * math.cos(a) + 2 * math.cos(ra), xv = 0, xa = 0,
		y = r * math.sin(a) + 2 * math.sin(ra), yv = 0, ya = 0,
		dir = %s, dirv = %s, dira = %s,
		vel = %s, velv = %s, vela = %s,

		r = %s, rv = %s, ra = %s,
		g = %s, gv = %s, ga = %s,
		b = %s, bv = %s, ba = %s,
		a = %s, av = %s, aa = %s,
	}
end, },

%s,
%s
%s]],
g("prework",""),
g("trail","nil"),
g("life","14"),
g("size",'4'), g("sizev","-0.1"), g("sizea",'0'),
g("dir","rng.percent(50) and ray.dir + math.rad(90) or ray.dir - math.rad(90)"), g("dirv",'0'), g("dira",'0'),
g("vel","rng.percent(80) and 1 or 0"), g("velv","-0.2"), g("vela", "0.01"),
g('r','0'),g("rv",'0'),g("ra",'0'),
g('g','0'),g("gv",'0'),g("ga",'0'),
g('b','0'),g("bv",'0'),g("ba",'0'),
g('a',"rng.float(0.5,1)"),g("av",'-0.07'),g("aa",'0'),
g("emitter",[[function(self)
	self.nb = (self.nb or 0) + 1
	if self.nb < 4 then
		self.ps:emit(100*tiles)
	end
end]]),
g("count", "8*100*tiles")..(g("image",nil) and "," or ""),
g("image",nil) and "\""..g("image").."\"" or "") end,

   ball = function(params)
      cur = "ball"
      curParams = params
      return string.format([[
-- Auto-generated particle system
local nb = 12
local radius = radius or 6

return { generator = function()
	local sradius = (radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local a = rng.float(0,math.pi*2)
	local x = 0
	local y = 0
	local vel = sradius * ((24 - nb * 1.4) / 24) / 12
	%s

	return {
		trail = %s,
		life = %s,
		size = %s, sizev = %s, sizea = %s,

		x = x, xv = 0, xa = 0,
		y = y, yv = 0, ya = 0,
		dir = %s, dirv = %s, dira = %s,
		vel = %s, velv = %s, vela = %s,

		r = %s, rv = %s, ra = %s,
		g = %s, gv = %s, ga = %s,
		b = %s, bv = %s, ba = %s,
		a = %s, av = %s, aa = %s,
	}
end, },

%s,
%s
%s]],
g("prework",""),
g("trail","1"),
g("life","12"),
g("size","12 - (12 - nb) * 0.7"), g("sizev","0"), g("sizea",'0'),
g("dir","a"), g("dirv",'0'), g("dira",'0'),
g("vel","rng.float(vel*0.6,vel*1.2)"), g("velv","0"), g("vela", "0"),
g('r','0'),g("rv",'0'),g("ra",'0'),
g('g','0'),g("gv",'0'),g("ga",'0'),
g('b','0'),g("bv",'0'),g("ba",'0'),
g('a',"rng.float(0.5,1)"),g("av",'-0.07'),g("aa",'0'),
g("emitter",[[function(self)
	if nb > 0 then
		local i = math.min(nb, 6)
		i = (i * i) * radius
		self.ps:emit(i)
		nb = nb - 1
	end
end]]),
g("count", "30*radius*7*12")..(g("image",nil) and "," or ""),
g("image",nil) and "\""..g("image").."\"" or "") end,

   storm = function(params)
      cur = "storm"
      curParams = params
      return string.format([[
-- Auto-generated particle system
local radius, density = radius or 3, density or 200
base_size = 32
can_shift = true

return { generator = function()
	local radius = radius
	local sradius = 1 --(radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
	local ad = rng.range(0, 360)
	local a = math.rad(ad)
	local dir = math.rad(ad + 90)
	local r = rng.avg(1, sradius)
	local dirv = math.rad(5)

	return {
		trail = %s,
		life = %s,
		size = %s, sizev = %s, sizea = %s,

		x = r * math.cos(a), xv = 0, xa = 0,
		y = r * math.sin(a), yv = 0, ya = 0,
		dir = %s, dirv = %s, dira = %s,
		vel = %s, velv = %s, vela = %s,

		r = %s, rv = %s, ra = %s,
		g = %s, gv = %s, ga = %s,
		b = %s, bv = %s, ba = %s,
		a = %s, av = %s, aa = %s,
	}
end, },

%s,
%s
%s]],
g("trail","1"),
g("life","50"),
g("size","rng.range(1, 3)"), g("sizev","-0.1"), g("sizea",'0'),
g("dir","a"), g("dirv","0"), g("dira","0"),
g("vel","5"), g("velv","0"), g("vela", "0"),
g('r','0'),g("rv",'0'),g("ra",'0'),
g('g','0'),g("gv",'0'),g("ga",'0'),
g('b','0'),g("bv",'0'),g("ba",'0'),
g('a',"rng.float(0.5,1)"),g("av",'-0.07'),g("aa",'0'),
g("emitter",[[function(self)
	self.ps:emit(10)
end]]),
g("count", "density * (math.min(4, radius)^2+0.5)")..(g("image",nil) and "," or ""),
g("image",nil) and "\""..g("image").."\"" or "") end,
}
colors = {
   acid = {
      r = '0',
      g = "rng.float(0.3,0.6)", 
      b = '0',
      a = "rng.float(0.5,1)", aa = "-0.006",
   },
   arcane = {
      r = "rng.float(0.6,0.8)",
      g = "0",
      b = "rng.float(0.6,0.8)",
      a = "rng.float(0.5,1)", aa = "-0.006",
   },
   blight = {
      r = "rng.float(0.1,0.2)",
      g = "rng.float(0.2,0.4)", 
      b = '0',
      a = "rng.float(0.5,1)", aa = "-0.006",
   },
   cold = {
      prework = "local white = rng.chance(3)",
      size = "rng.range(2,4)",
      
      r = "white and 1 or 0.4",
      g = "white and 1 or 0.7",
      b = "1",
      a = "rng.float(0.9,1)",
      aa = "-0.004",
      beam={
	 dir = "rng.float(0,math.pi*2)",
	 dirv = "rng.float(-0.2,0.2)",
	 vel = "rng.float(0,1)",
	 velv = '0',
	 vela = '0',
      },
      ball={
	 trail = 0,
	 dirv = "rng.float(-0.4,0.4)",
      },
      image = "particle_torus",
   },
   darkness = {
      prework = "local intensity = rng.float(0,0.1)",
      r = "intensity",
      g = "intensity",
      b = "intensity",
   },
   fire = {
      r = "rng.float(0.9,1)",
      g = "rng.float(0.8,0.9)", gv = -0.04,
      b = '0',
      dirv = "rng.float(-0.1,0.1)",
      image = "particle_drop",
   },
   light = {
      r = "rng.float(0.9,1)",
      g = "rng.float(0.8,0.9)",
      b = 'rng.float(0.4,0.6)',
   },
   lightning = {
      r = '1', rv = -0.1,
      g = '1', gv = -0.05,
      b = '1',
      a = 'rng.float(0.5,1)', av = -0.1,
      size = "rng.range(4,8)",
      beam={
	 dir = "rng.float(0,math.pi*2)",
	 dirv = "rng.float(-1,1)",
	 vel = "rng.float(0,2)",
	 velv = '0',
	 vela = '0',
	 count = "64*tiles",
	 emitter = [[function(self)
	if not self.emitted then
		self.ps:emit(64*tiles)
	end
	self.emitted = 1
end]],
      },
      ball={
	 vel = "rng.float(0,1)^0.5*vel*4",
	 count = "256*radius",
	 emitter = [[function(self)
	if not self.emitted then
		self.ps:emit(256*radius)
	end
	self.emitted = 1
end]],
      },
      life = '10',
      trail = '0',
      image = "particles_images/lightningshield",
   },
   mind = {
      r = '0.9',
      g = '1',
      b = '0.7',
      image = "particles_images/temporal_bolt",
      size = "rng.range(4,10)",
   },
   nature = {
      r = '0',
      g = "rng.float(0.8,0.9)", 
      b = '0',
   },
   physical = {
      r = '1',
      g = '0.9', 
      b = '0.5',
      image = "weather/snowflake",
   },
   temporal = {
      r = '1',
      g = 'rng.float(0.5,1)', 
      b = '1',
      image = "weather/snowflake",
   },
   elemental = {
      prework = "local color = rng.range(1,4)",
      
      r = [[color == 1 and rng.float(0.9,1)
			or color == 2 and 0.4
			or color == 3 and 1
			or color == 4 and rng.float(0.6,0.8)]],
      g = [[color == 1 and rng.float(0.8,0.9)
			or color == 2 and 0.7
			or color == 3 and 1
			or color == 4 and 0]],
      b = [[color == 1 and 0
			or color == 2 and 1
			or color == 3 and 1
			or color == 4 and rng.float(0.6,0.8)]],
      a = [[color == 1 and 1
			or color == 2 and rng.float(0.9,1)
			or color == 3 and rng.float(0.5,1)
			or color == 4 and rng.float(0.5,1)]],
      
      rv = [[color == 1 and 0
			or color == 2 and 0
			or color == 3 and -0.1
			or color == 4 and 0]],
      
      gv = [[color == 1 and -0.04
			or color == 2 and 0
			or color == 3 and -0.05
			or color == 4 and 0]],
      
      bv = "0",
      
      av = "-0.07",
      
      dirv = "color <= 2 and rng.float(-0.1,0.1) or 0",
   },
}

function main()
   for colorName,params in pairs(colors) do
      for particleType,gen in pairs(generators) do
	 local filename = "rek_wyrmic_"..colorName.."_"..particleType..".lua"
	 local file = io.open(filename,"w+")
	 file:write(gen(params))
	 file:close()
	 print("Wrote "..filename)
      end
   end
end

main()
