-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2016 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

return {
   name = "Kidnappers' Hideout",
   level_range = {1, 5},
   level_scheme = "player",
   max_level = 2,
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
	 [2] = {
	    no_level_connectivity = true,
	    generator = { map = {
			     down = "OLD_FLOOR",
	    }, },
	 },
      },
   
   post_process = function(level)
      game:placeRandomLoreObject("NOTE"..level.level)
   end,
}
