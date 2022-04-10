return {
	name = "Somewhere Else",
	level_range = {10, 30},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 1,
	width = 30, height = 30,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
	all_remembered = true,
	all_lited = true,
	-- day_night = true,
	ambient_music = "Anne_van_Schothorst_-_Passed_Tense.ogg",
	effects = {"EFF_HAMMER_ZONE_AURA_VERGE"},
	allow_respec = "limited",
	no_planechange = true,
	color_shown = {1.0, 0.5, 0.7, 1},
	color_obscure = {1.0*0.6, 0.5*0.6, 0.7*0.6, 0.6},

	min_material_level = 2,
	max_material_level = 3,

	generator =  {
		map = {
			class = "engine.generator.map.Forest",
			zoom = 3,
			sqrt_percent = 45,
			noise = "fbm_perlin",
			floor = "CLOUD",
			wall = "OUTERSPACE",
			up = "CLOUD",
			down = "CLOUD",
			door = "CLOUD",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {10, 15},
			guardian = "BELL_ARCHON",
		},
	},
	foreground = function(level, dx, dx, nb_keyframes)
		local tick = core.game.getTime()
		local sr, sg, sb
		sr = 3 + math.sin(tick / 4000)
		sg = 3 + math.sin(tick / 2700)
		sb = 3 + math.sin(tick / 3200)
		local max = math.max(sr, sg, sb)
		sr = sr / max
		sg = sg / max
		sb = sb / max
		
		level.map:setShown(sr, sg, sb, 1)
		level.map:setObscure(sr * 0.6, sg * 0.6, sb * 0.6, 1)
	end,
	
	levels = {
		[1] = { all_remembered = true, all_lited = true, day_night = true, },
	},
	
	on_enter = function(lev)
		world:gainAchievement("HAMMER_BELL_ENTER", p)

		local o, item, inven = game.player:findInAllInventoriesBy("define_as", "ROD_RECALL")
		if not o or not item or not inven then
			world:gainAchievement("HAMMER_NO_RECALL", p)
		end
	end,

	post_process = function(level)
		game.state:makeWeather(level, 6, {max_nb=2, chance=1, dir=120, r=0.8, g=0.4, b=0.8, speed={0.1, 0.9}, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})

		if core.renderer then
			local Map = require "engine.Map"
			level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height, speed=200000})
		else
			local Map = require "engine.Map"
			local Quadratic = require "engine.Quadratic"
			if core.shader.allow("volumetric") then
				level.starfield_shader = require("engine.Shader").new("starfield", {size={Map.viewport.width, Map.viewport.height}})
			else
				level.background_particle1 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.8, size_min = 1, size_max = 3})
				level.background_particle2 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.9, size_min = 4, size_max = 8})
			end
			level.world_sphere = Quadratic.new()
			game.zone.world_sphere_rot = (game.zone.world_sphere_rot or 0)
			game.zone.cloud_sphere_rot = (game.zone.world_cloud_rot or 0)
		end
	end,

	background = function(level, x, y, nb_keyframes)
		if core.renderer then
			local Map = require "engine.Map"
			local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
			if level.background_particle then
				level.background_particle.ps:toScreen(x, y, true, 1)
			end

			if not level.tmpdata.planet_renderer then
				local StellarBody = require "mod.class.StellarBody"
				local planettex = core.loader.png("/data/gfx/shockbolt/stars/eyal.png")
				local cloudtex = core.loader.png("/data/gfx/shockbolt/stars/clouds.png")
				local planet = StellarBody.makePlanet(planettex, cloudtex, {160/255, 160/255, 200/255, 0.5}, 300, {planet_time_scale=900000, clouds_time_scale=700000, rotate_angle=math.rad(22), light_angle=math.pi})
				level.tmpdata.planet_renderer = core.renderer.renderer("static"):add(planet)
			end
			level.tmpdata.planet_renderer:toScreen():translate(x + 350 - parx * 60, y + 350 - pary * 60)
		else
			local Map = require "engine.Map"
			local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
			if level.starfield_shader and level.starfield_shader.shad then
				level.starfield_shader.shad:use(true)
				core.display.drawQuad(x, y, Map.viewport.width, Map.viewport.height, 1, 1, 1, 1)
				level.starfield_shader.shad:use(false)
			elseif level.background_particle1 then
				level.background_particle1.ps:toScreen(x, y, true, 1)
				level.background_particle2.ps:toScreen(x - parx * 40, y - pary * 40, true, 1)
			end

			core.display.glDepthTest(true)
			core.display.glMatrix(true)
			core.display.glTranslate(x + 350 - parx * 60, y + 350 - pary * 60, 0)
			core.display.glRotate(120, 0, 1, 0)
			core.display.glRotate(300, 1, 0, 0)
			core.display.glRotate(game.zone.world_sphere_rot, 0, 0, 1)
			core.display.glColor(1, 1, 1, 1)

			local tex = Map.tiles:get('', 0, 0, 0, 0, 0, 0, "stars/eyal.png")
			tex:bind(0)
			level.world_sphere.q:sphere(300)

			local tex = Map.tiles:get('', 0, 0, 0, 0, 0, 0, "shockbolt/terrain/cloud-world.png")
			tex:bind(0)
			core.display.glRotate(game.zone.cloud_sphere_rot, 0, 0, 1)
			level.world_sphere.q:sphere(304)

			game.zone.world_sphere_rot = game.zone.world_sphere_rot + 0.01 * nb_keyframes
			game.zone.cloud_sphere_rot = game.zone.cloud_sphere_rot + rng.float(0.01, 0.02) * nb_keyframes

			core.display.glMatrix(false)
			core.display.glDepthTest(false)
		end
	end,
}
