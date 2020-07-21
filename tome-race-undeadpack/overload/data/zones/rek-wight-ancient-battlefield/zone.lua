return {
   name = "Ancient Battlefield",
   level_range = {1, 5},
   level_scheme = "player",
   max_level = 1,
   actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
   width = 18, height = 18,
   ambient_music = "Swashing the buck.ogg",
   no_worldport = true,
   max_material_level = 1,
   all_lited = true,
   generator =  {
      map = {
         class = "engine.generator.map.Static",
         map = "rek-old-battle-field",
      },
   },
   on_enter = function(lev)
      game.level.turn_counter = 101 * 10
      game.level.max_turn_counter = 101 * 10
      game.level.turn_counter_desc = "Your fellow undead are rising from the ground!"
      
      -- Spawn the adventurer
      local spot = game.level:pickSpot{type="pop", subtype="graverobber"}
      if not game.level.map(spot.x, spot.y, game.level.map.ACTOR) then
         local m = game.zone:makeEntityByName(game.level, "actor", "REK_WIGHT_GRAVEROBBER")
         --local m = game.zone:makeEntity(game.level, "actor")
         if m then
            game.zone:addEntity(game.level, m, "actor", spot.x, spot.y)
            m:setTarget(game.player)
         end
      end

      for i = 1, 6 do
         -- Pop an undead
         local spot = game.level:pickSpot{type="pop", subtype="undead"}
         if not game.level.map(spot.x, spot.y, game.level.map.ACTOR) then
            local m = game.zone:makeEntity(game.level, "actor")
            if m then
               game.zone:addEntity(game.level, m, "actor", spot.x, spot.y)
               m.faction = "undead"
            end
         end
      end
      
      
   end,
   on_turn = function(self)
      if game.level.turn_counter then
         game.level.turn_counter = game.level.turn_counter - 1
         game.player.changed = true
         if game.level.turn_counter < 0 then
            game.level.turn_counter = nil
            local spot = game.level:pickSpot{type="pop", subtype="graverobber"}
            local g = game.zone:makeEntityByName(game.level, "terrain", "CAVE_LADDER_UP_WILDERNESS")
            game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
            
            require("engine.ui.Dialog"):simpleLongPopup("Onslaught", "You spot an opening! You could climb up out of the grave if you wish.", 400)
         elseif game.level.turn_counter % 50 == 0 then
            -- Pop an undead
            local spot = game.level:pickSpot{type="pop", subtype="undead"}
            if not game.level.map(spot.x, spot.y, game.level.map.ACTOR) then
               local m = game.zone:makeEntity(game.level, "actor")
               if m then
                  game.zone:addEntity(game.level, m, "actor", spot.x, spot.y)
                  m.faction = "undead"
               end
            end
         end
      end
   end,
}
