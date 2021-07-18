return {
	name = "Fearscape: Invasion Beachhead",
	level_range = {30, 50},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 1,
	width = 50, height = 50,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
	all_remembered = true,
	all_lited = true,
	-- day_night = true,
	no_worldport = true,
	is_demon_plane = true,
	ambient_music = "Straight Into Ambush.ogg",
	effects = {"EFF_ZONE_AURA_FEARSCAPE"},
	allow_respec = "limited",

	min_material_level = 3,
	max_material_level = 3,
	store_levels_by_restock = { 15, 30, 45 },
	nicer_tiler_overlay = "DungeonWallsGrass",

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "campaign-hammer+towns/fearscape",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			filters = {{max_ood=2}},
			nb_npc = {10, 10},
			rate = 0.27,
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},

	levels = {
		[1] = { all_remembered = true, all_lited = true, day_night = true, },
	},

	-- inaccessible once the siege begins, until it is cleared
	on_enter = function(lev)
		local q = game.player:hasQuest("campaign-hammer+demon-siege")
		if q and not q:isCompleted("victory") then
			game:changeLevel(1, "campaign-hammer+beachhead-siege")
		end
		if game:isAddonActive("orcs") and not game.level.data.hammer_tinker_shop and game.state.birth.merge_tinkers_data then
			game.level.data.hammer_tinker_shop = true

			local spot = game.level:pickSpot{type="pop", subtype="bonus-shop"}
			
			local m = mod.class.NPC.new{
				define_as = "BASE_STEAM_DRONE",
				type = "construct", subtype = "mechanical",
				display = "A", color=colors.UMBER, image = "npc/construct_mechanical_ancient_automated_archive.png",
				name = ("Ancient Automated Archive (%s)"):tformat(_t"tinkers"),
				desc = _t[[An ancient archive of knowledge! You've heard tales of those triangular store devices, holding items and restoring them. For a price.]],
				level_range = {50, nil}, exp_worth = 1,
				faction = "unaligned",
				repairable = 1,
				never_anger = true,
				
				combat = { dam=1, atk=1, apr=1 },
				
				life_rating = 0, max_life = 1500,
				rank = 3,
				size_category = 3,
				power_source = {steamtech=true},
				can_talk = "orcs+aaa",
			}
			m:resolve()
			m:resolve(nil, true)
			
			m.store = game:getStore("ORC_AAA_TINKER")
			m.store.faction = m.faction
			m.store.store.sell_percent = rng.range(100, 220)
			m.store.onBuy_real = m.store.onBuy
			m.store.onBuy = function(self, ...)
				world:gainAchievement("ORCS_AAA_BUY", game.player)
				local inven = self:getInven("INVEN")
				if #inven == 0 then
					world:gainAchievement("ORCS_AAA_BUY_ALL", game.player)
				end
				return self:onBuy_real(...)
			end

			game.zone:addEntity(game.level, m, "actor", spot.x, spot.y)
			
			-- Grab items
			for i = game.level.map:getObjectTotal(x, y), 1, -1 do
				local o = game.level.map:getObject(x, y, i)
				game.level.map:removeObject(x, y, i)
				
				o:identify(true)
				m.store:addObject(m.store.INVEN_INVEN, o)
			end	
		end
	end,
	
	-- show the planet
		post_process = function(level)
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
