base_size = 64

local shader = shader or false

if core.shader.active(4) then
	if shader then use_shader = {type="volumetric_aura"} end
else
	shader = false
end

local speed = speed or 0.023
local a = ((type(a) == "number" and a) or 60) / 255
local basesize = (shader and 1.75 or 1) * 2 * radius * (engine.Map.tile_w + engine.Map.tile_h) / 2 + engine.Map.tile_w * 1.8 * (oversize or 1)
local r = (r or 255) / 255
local g = (g or 255) / 255
local b = (b or 255) / 255

if grow then grow = basesize / limit_life end

local nb = 0
local angle  = base_rot or rng.range(0, 360)
local radian = math.rad(angle)

local wobbl = rng.range(-150, 150)/1000

return {
	blend_mode = shader and core.particles.BLEND_SHINY or nil,
	system_rotation = angle, system_rotationv = speed,
	generator = function()
		return {
			trail = 0,
			life = limit_life or 1000,
			size = grow and 0 or basesize, sizev = grow, sizea = 0,

			--x = math.sqrt(x*x+y*y) * math.cos(-radian), xv = 0, xa = 0,
			--y = math.sqrt(x*x+y*y) * math.sin(-radian), yv = 0, ya = 0,
			x = x * math.cos(-radian) - y * math.sin(-radian), xv = 0, xa = 0,
			y = x * math.sin(-radian) + y * math.cos(-radian), yv = 0, ya = 0,
			
			dir = 0, dirv = 1, dira = 0,
			vel = wobbl, velv = 0, vela = 0,

			r = r, rv = 0, ra = 0,
			g = g, gv = 0, ga = 0,
			b = b, bv = 0, ba = 0,
			a = a, av = 0, aa = 0,
		}
end, },
function(self)
	if (nb < 1) or not limit_life then
		if self.ps:emit(1) > 0 then
			nb = nb + 1
		end
	end
end, 1, "particles_images/"..img
