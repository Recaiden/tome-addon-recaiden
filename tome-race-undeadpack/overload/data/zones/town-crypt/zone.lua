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
   name = "Mummification Room",
   level_range = {1, 5},
   level_scheme = "player",
   max_level = 1,
   decay = {300, 800, only={object=true}, no_respawn=true},
   actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
   width = 196, height = 80,
   --width = 25, height = 25,
   all_remembered = true,
   all_lited = true,
   day_night = true,
   persistent = "zone",
   ambient_music = {"Anne_van_Schothorst_-_Passed_Tense.ogg", "weather/dungeon_base.ogg"},
   allow_respec = "limited",
   min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
   max_material_level = function() return game.state:isAdvanced() and 4 or 1 end,
   generator =  {
      map = {
	 class = "engine.generator.map.Static",
	 map = "towns/mummy",
			
--	 class = "engine.generator.map.TileSet",
--	 tileset = {"5x5/base", "5x5/tunnel", "5x5/windy_tunnel", "5x5/crypt"},
--	 tunnel_chance = 100,
--	 ['.'] = "OLD_FLOOR",
--	 ['#'] = {"OLD_WALL","WALL","WALL","WALL","WALL"},
--	 ['+'] = "DOOR",
--	 ["'"] = "DOOR",
--	 up = "UP",
--	 down = "DOWN",
      },
      actor = {
	 class = "mod.class.generator.actor.OnSpots",
	 nb_npc = {0, 0},
	 filters = { {max_ood=2}, },
	 nb_spots = 2, on_spot_chance = 35,
      },
      object = {
	 class = "engine.generator.object.OnSpots",
	 nb_object = {0, 0},
	 nb_spots = 2, on_spot_chance = 80,
      },
      trap = {
	 class = "engine.generator.trap.Random",
	 nb_trap = {0, 0},
      },
   },
   levels =
      {
	 [1] = {
	    generator = { map = {
			     up = "TOMUMMYDUNGEON",
	    }, },
	 },
      },
   
   post_process = function(level)
      -- Place a lore note on each level

      game.state:makeAmbientSounds(level, {
	dungeon2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/dungeon/dungeon1","ambient/dungeon/dungeon2","ambient/dungeon/dungeon3","ambient/dungeon/dungeon4","ambient/dungeon/dungeon5"}},
      })
   end,
}
