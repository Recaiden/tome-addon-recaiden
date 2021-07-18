return {
	name = "Orbital Invasion Platform",
	level_range = {1, 10},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_remembered = false,
	all_lited = true,
	persistent = "zone",
	no_worldport = true,
	is_demon_plane = true,
	ambient_music = "Straight Into Ambush.ogg",
	effects = {"EFF_ZONE_AURA_FEARSCAPE"},
	min_material_level = 1,
	max_material_level = 1,
	generator =  {
		map = {
			class = "engine.generator.map.MapScript",
			['<'] = "PORTAL_PREV", ['>'] = "PORTAL_NEXT",
			['.'] = "FLOATING_ROCKS", ['+'] = "FLOATING_ROCKS", ['#'] = "OUTERSPACE",
			['&'] = "FLOATING_ROCKS", [';'] = "OUTERSPACE",
			mapscript = "!fringes",
		},
		-- map = {
		-- 	class = "engine.generator.map.Cavern",
		-- 	zoom = 16,
		-- 	min_floor = 1100,
		-- 	floor = "FLOATING_ROCKS",
		-- 	wall = "OUTERSPACE",
		-- 	up = "PORTAL_PREV",
		-- 	down = "PORTAL_NEXT",
		-- 	door = "MALROK_DOOR",
		-- },
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {30, 40},
			guardian = "VOID_VORTEX",
			guardian_spot = "default_down",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =
		{
			[3] = {
				generator = {
					map = {
						class = "engine.generator.map.Building",
						wall = "MALROK_WALL",
						floor = "FLOATING_ROCKS",
						up = "PORTAL_PREV",
						down = "PORTAL_NEXT",
						door = "MALROK_DOOR",
						margin_w = 0, margin_h = 0,
						max_block_w = 15, max_block_h = 15,
						max_building_w = 5, max_building_h = 5,
						down = "PORTAL_EYAL",
						force_last_stair = true,
					},
				},
			},
			[2] = {
				generator = {
					map = {
						mapscript = "!outlying",
						-- class = "engine.generator.map.Town",
						-- building_chance = 80,
						-- max_building_w = 10, max_building_h = 10,
						-- edge_entrances = {4,6},
						-- floor = "FLOATING_ROCKS",
						-- external_floor = {"FLOATING_ROCKS","FLOATING_ROCKS","FLOATING_ROCKS","FLOATING_ROCKS","FLOATING_ROCKS","FLOATING_ROCKS","FLOATING_ROCKS","FLOATING_ROCKS", "OUTERSPACE"},
						-- wall = "MALROK_WALL",
						-- up = "PORTAL_PREV",
						-- down = "PORTAL_NEXT",
						-- door = "MALROK_DOOR",
						['#'] = "MALROK_WALL",
						-- ['.'] = "MALROK_FLOOR",
						['+'] = "MALROK_DOOR",
						-- nb_rooms = {1,1,2},
						-- lite_room_chance = 100,
					},
				},
			},
			[1] = {
				generator = {
					map = {
						up = "MALROK_FLOOR",
						['<'] = "MALROK_FLOOR",
					},
				},
			},
		},

	on_enter = function(level)
		game.player:resolveSource().faction = "fearscape"
	end,
	
	post_process = function(level)
		game:placeRandomLoreObject("NOTE"..level.level)
		
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
