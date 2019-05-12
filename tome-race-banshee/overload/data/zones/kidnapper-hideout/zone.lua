return {
   name = "Kidnappers' Hideout",
   level_range = {1, 5},
   level_scheme = "player",
   max_level = 3,
   actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
   width = 30, height = 30,
   ambient_music = "Zangarang.ogg",
   no_worldport = true,
   max_material_level = 1,
   all_lited = true,
   generator =  {
      map = {
	 class = "engine.generator.map.TileSet",
	 tileset = {"3x3/base", "3x3/tunnel", "3x3/windy_tunnel"},
	 tunnel_chance = 100,
	 ['.'] = "OLD_FLOOR",
	 ['#'] = "OLD_WALL",
	 ['+'] = "DOOR",
	 ["'"] = "DOOR",
	 force_last_stair = true,
	 up = "UP",
	 down = "DOWN",
      },
      actor = {
	 class = "mod.class.generator.actor.Random",nb_npc = {5, 7},
	 guardian = "REK_BANSHEE_RINGLEADER", guardian_level = 1,
      },
      trap = { class = "engine.generator.trap.Random", nb_trap = {0, 0}, },
   },
   levels =
      {
	 [1] = {
	    width = 20, height=20,
	    generator = { map = {
			     up = "UP_WILDERNESS",
	    }, },
	 },
	 [3] = {
	    no_level_connectivity = true,
	    generator =  {
	       map = {
		  down = "REK_DECO_FLOOR_BANSHEE_GRAVE",
		  class = "engine.generator.map.Forest",
		  edge_entrances = {4,6},
		  zoom = 4,
		  sqrt_percent = 30,
		  noise = "fbm_perlin",
		  floor = function()
		     if rng.chance(20) then return "FLOWER" else return "GRASS" end
		  end,
		  wall = "TREE",
		  up = "GRASS_UP4",
		  door = "GRASS",
		  do_ponds = {
		     nb = {0, 2},
		     size = {w=25, h=25},
		     pond = {{0.6, "DEEP_WATER"}, {0.8, "DEEP_WATER"}},
		  },
	       },
	       actor = {
		  class = "mod.class.generator.actor.OnSpots",
		  nb_npc = {20, 30},
		  filters = { {max_ood=2}, },
		  nb_spots = 2, on_spot_chance = 35,
	       },
	       object = {
		  class = "engine.generator.object.OnSpots",
		  nb_object = {6, 9},
		  nb_spots = 2, on_spot_chance = 80,
	       },
	       trap = {
		  class = "engine.generator.trap.Random",
		  nb_trap = {0, 0},
	       },
	    }
	 },
      },
   
   post_process = function(level)
      game:placeRandomLoreObject("NOTE"..level.level)
   end,
}
