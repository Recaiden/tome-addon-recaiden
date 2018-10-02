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
   name = "Mummy Crypt",
   level_range = {1, 5},
   level_scheme = "player",
   max_level = 3,
   decay = {300, 800},
   actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
   width = 35, height = 35,
   --	all_remembered = true,
   all_lited = true,
   day_night = true,
   tier1 = true,
   --   tier1_escort = 2, --no escort
   persistent = "zone",
   ambient_music = {"Anne_van_Schothorst_-_Passed_Tense.ogg", "weather/dungeon_base.ogg"},
   min_material_level = function() return game.state:isAdvanced() and 3 or 1 end,
   max_material_level = function() return game.state:isAdvanced() and 4 or 1 end,
   generator =  {
      map = {
	 class = "engine.generator.map.TileSet",
	 tileset = {"5x5/base", "5x5/tunnel", "5x5/windy_tunnel", "5x5/crypt"},
	 tunnel_chance = 100,
	 ['.'] = "OLD_FLOOR",
	 ['#'] = {"OLD_WALL","WALL","WALL","WALL","WALL"},
	 ['+'] = "DOOR",
	 ["'"] = "DOOR",
	 up = "UP",
	 down = "DOWN",
      },
      actor = {
	 class = "mod.class.generator.actor.OnSpots",
	 nb_npc = {20, 30},
	 filters = { {max_ood=2}, },
	 nb_spots = 2, on_spot_chance = 35,
	 guardian = "GOLEMGUARD", guardian_level = 1,
	 guardian_spot = {type="guardian", subtype="guardian"},
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
   },
   levels =
      {
	 [1] = {
	    width = 50, height=50,
	    generator = { map = {
			     start_tiles = {{tile="LONG_TUNNEL_82", x=8, y=0}},
			     up = "UP_WILDERNESS",
	    }, },
	 },
	 [3] = {
	    generator = { map = {
			     --end_road = true,
			     --end_road_room = "zones/prox",
			     force_last_stair = true,
			     down = "TOCRYPT",
	    }, },
	 },
      },
   
   post_process = function(level)
      game:placeRandomLoreObject("NOTE"..level.level)
      
      game.state:makeAmbientSounds(level, {
				      wind={ chance=120, volume_mod=1.5, pitch=0.9, files={"ambient/forest/wind1","ambient/forest/wind2","ambient/forest/wind3","ambient/forest/wind4"}},
				      bird={ chance=600, volume_mod=0.75, files={"ambient/forest/bird1","ambient/forest/bird2","ambient/forest/bird3","ambient/forest/bird4","ambient/forest/bird5","ambient/forest/bird6","ambient/forest/bird7"}},
				      cricket={ chance=1200, volume_mod=0.75, files={"ambient/forest/cricket1","ambient/forest/cricket2"}},
      })
   end,
   
   foreground = function(level, x, y, nb_keyframes)
      if not config.settings.tome.weather_effects or not level.foreground_particle then return end
      level.foreground_particle.ps:toScreen(x, y, true, 1)
      
      if nb_keyframes > 10 then return end
      if nb_keyframes > 0 and rng.chance(400 / nb_keyframes) then local s = game:playSound("ambient/horror/ambient_horror_sound_0"..rng.range(1, 6)) if s then s:volume(s:volume() * 1.5) end end
   end,
}
