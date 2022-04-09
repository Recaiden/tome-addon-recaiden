return {
	name = "Daikara",
	display_name = function(x, y)
		if game.level.level == 1 then return _t"Shasshhiy'Kaish's Sanctum" end
		return "Daikara Mountains"
	end,
	level_range = {25, 40},
	level_scheme = "player",
	max_level = 2,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 55, height = 55,
	persistent = "zone",
	color_shown = {0.5, 1, 0.7, 1},
	color_obscure = {0.5*0.6, 1*0.6, 0.7*0.6, 0.6},
	ambient_music = "World of Ice.ogg",
	min_material_level = 2,
	max_material_level = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			edge_entrances = {2,8},
			rooms = {"forest_clearing", "rocky_snowy_trees", {"lesser_vault",7}},
			rooms_config = {forest_clearing={pit_chance=5, filters={{}}}},
			lesser_vaults_list = {"snow-giant-camp", "perilous-cliffs"},
			['.'] = {"ROCKY_GROUND", "SAND", "ROCKY_GROUND"},
			['T'] = "ROCKY_SNOWY_TREE",
			['#'] = {"MOUNTAIN_WALL", "SPACETIME_RIFT_BELOW"},
			up = "ROCKY_UP2",
			down = "ROCKY_DOWN8",
			door = "ROCKY_GROUND",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "SHASSY_ABOMINATION",
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
	levels = {
		[1] = {
			all_remembered = true,
			all_lited = true,
			day_night = false,
			generator = { 
				map = {
					class = "engine.generator.map.Static",
					map = "campaign-hammer+zones/daikara-sanctum",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {0, 0},
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {0, 0},
				},
			},
		},
		[2] = {
			generator = { 
				map = { up = "CAVE_LADDER_UP",}, 
				actor = {class = "engine.generator.actor.Random" },
			},
		},
	},

	on_turn = function(self)
		if game.level.turn_counter then
			game.level.turn_counter = game.level.turn_counter - 1
			game.player.changed = true
			
			if game.level.turn_counter % 10 == 0 then
				local Zone = require "engine.Zone"
				local Map = require "engine.Map"
				
				local w = game.level.map.w
				local locsRift = {}
				local locsSand = {}

				core.fov.calc_circle(
					27, 27, game.level.map.w, game.level.map.h, 3*(13-math.floor(game.level.turn_counter/10)),
					function(_, lx, ly)
						if not game.level.map:isBound(lx, ly) then return true end
					end,
					function(_, tx, ty)
						local oe = game.level.map(tx, ty, Map.TERRAIN)
						if oe.define_as == "SPACETIME_RIFT_BELOW" then
							locsRift[#locsRift+1] = {x=tx,y=ty,oe=oe}
						elseif oe.define_as == "SAND" then
							locsSand[#locsSand+1] = {x=tx,y=ty,oe=oe}
						end
					end,
					nil)
				
				while #locsRift > 0 do
					local l = rng.tableRemove(locsRift)
					
					local e = game.zone:makeEntityByName(game.level, "terrain", "MOUNTAIN_WALL")
					game.zone:addEntity(game.level, e, "terrain", l.x, l.y)
				end
				while #locsSand > 0 do
					local l = rng.tableRemove(locsSand)
					
					local e = game.zone:makeEntityByName(game.level, "terrain", "ROCKY_GROUND")
					game.zone:addEntity(game.level, e, "terrain", l.x, l.y)
				end
				
				game.level.map:cleanFOV()
				game.level.map.changed = true
				game.level.map:redisplay()
			end
		
			if game.level.turn_counter < 0 then
				game.level.turn_counter = nil
			end
		end
	end,

	on_enter = function(lev)
		if game and game.player and lev == 2 and not game.level.data.hammer_visited_rift then
			game.level.data.hammer_visited_rift = true
			require("engine.ui.Dialog"):simplePopup(_t"The Daikara That Was And Will Be", _t"As you climb up from the demon's sanctum, you pass your own future self fleeing down the stairs.  Outside, the mountains are faded and insubstantial, exposing the blue-white threads of the Calendar.  The sun is hidden by a massive temporal rift that splits the skies.  Shimmering figures flit around the edges of the rift, trying to contain the anomaly, but more nightmare creatures emerge every moment.")
		end
	end,
	
	post_process = function(level)
		game.state:makeAmbientSounds(level, {
																	 dungeon2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/dungeon/dungeon1","ambient/dungeon/dungeon2","ambient/dungeon/dungeon3","ambient/dungeon/dungeon4","ambient/dungeon/dungeon5"}},
		})
		if level.level == 2 then
			local Map = require "engine.Map"
			if core.shader.allow("volumetric") then
				level.starfield_shader = require("engine.Shader").new("starfield", {size={Map.viewport.width, Map.viewport.height}})
			else
				level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})
			end
			if config.settings.tome.weather_effects and core.shader.allow("distort") then
				level.foreground_particle = require("engine.Particles").new("temporalsnow", 1, {width=Map.viewport.width, height=Map.viewport.height, r=0.65, g=0.25, b=1, rv=-0.001, gv=0, bv=-0.001, factor=2, dir=math.rad(110+180)})
			end
			game.state:makeWeather(level, 6, {max_nb=7, chance=1, dir=120, speed={0.1, 0.9}, r=0.2, g=0.4, b=1, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})
		end
	end,
}
