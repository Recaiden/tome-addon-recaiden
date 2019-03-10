local Object = require "mod.class.Object"

newTalent{
   name = "Draconic Strikes", short_name = "REK_WYRMIC_UTILITY_ONHIT",
   type = {"wild-gift/draconic-utility", 1},
   require = elem_req_1,
   points = 5,
   equilibrium = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 15)) end,
   range = 1,
   requires_target = true,
   no_energy = true,
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 9, 0.5, 0, 2)) end,
   getPower = function(self, t)
      local perc_missing = (self.max_life - self.life) / self.max_life
      return self:combatTalentSpellDamage(t, 5, 40) * (1 + (perc_missing * 1.5))
   end,
   action = function(self, t)
      self:setEffect(self.EFF_REK_WYRMIC_EMBERS, t.getDuration(self, t), {power=t.getPower(self, t)})
      game:playSoundNear(self, "talents/devouringflame")
      return true
   end,
   info = function(self, t)
      local dam = t.getPower(self, t)
      local dur = t.getDuration(self, t)
      local damtype = DamageType.REK_WYRMIC_NULL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 damtype = source.damtype
      end
      
      return ([[Surge with draconic power, adding %d on-hit damage of your active element for the next %d turns.  The damage increases the lower your life is.
]]):format(damDesc(self, damtype, dam), dur)
   end,
}

newTalent{
   name = "Hindering Aura", short_name = "REK_WYRMIC_UTILITY_SLOW",
   type = {"wild-gift/draconic-utility", 1},
   require = elem_req_2,
   points = 5,
   equilibrium = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 15)) end,
   range = 1,
   requires_target = true,
   no_energy = true,
   tactical = { DISABLE = 2 },
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 60) end,
   getDuration = function(self, t) return math.floor(self:combatScale(self:combatMindpower(0.04) + self:getTalentLevel(t)/2, 6, 0, 7.67, 5.67)) end,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
   end,
   action = function(self, t)
      local damage = self:mindCrit(t.getDamage(self, t))
      local duration = t.getDuration(self, t)
      local actor = self
      local radius = self:getTalentRadius(t)
      -- Add a lasting map effect
      game.level.map:addEffect(self,
			       self.x, self.y, duration,
			       DamageType.REK_WYRMIC_ACID_SLOW, damage,
			       radius,
			       5, nil,
			       engine.MapEffect.new{color_br=80, color_bg=255, color_bb=25, effect_shader="shader_images/magic_effect.png"},
			       function(e)
				  e.x = e.src.x
				  e.y = e.src.y
				  return true
			       end,
			       false
      )
      game:playSoundNear(self, "talents/cloud")
      return true
   end,
   info = function(self, t)
      local radius = self:getTalentRadius(t)
      local duration = t.getDuration(self, t)
      local slow = t.getDamage(self, t)
      return ([[Fill the area around you in radius %d with chaotic elemental energy for %d turns, causing it to slow the movement speed of enemies within by %d%% (#SLATE#Mindpower vs. Physical#LAST#).  The aura moves with you.
]]):format(radius, duration, slow)
   end,
}

newTalent{
   name = "Burrow", short_name = "REK_WYRMIC_UTILITY_BURROW",
   type = {"wild-gift/draconic-utility", 3},
   image = "talents/burrow.png",
   require = elem_req_3,
   points = 5,
   equilibrium = 15,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 15)) end,
   range = 1,
   requires_target = true,
   no_energy = true,
   tactical = { CLOSEIN = 0.5, ESCAPE = 0.5 },
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 9, 0.5, 0, 2)) end,
   action = function(self, t)
      self:setEffect(self.EFF_BURROW, t.getDuration(self, t), {power=0})
      return true
   end,
   info = function(self, t)
      local duration = t.getDuration(self, t)
      return ([[Melt, break and shatter obstacles before you, allowing you to burrow through earthen walls for %d turns.
]]):format(duration)
   end,
}


newTalent{
   name = "Shape Walls", short_name = "REK_WYRMIC_UTILITY_WALL",
   image = "talents/ice_wall.png",
   type = {"wild-gift/draconic-utility", 4},
   require = elem_req_4,
   points = 5,
   random_ego = "defensive",
   equilibrium = 10,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 30, 15)) end,
   range = 10,
   tactical = { DISABLE = 2 },
   requires_target = true,
   target = function(self, t)
      local halflength = math.floor(t.getLength(self,t)/2)
      local block = function(_, lx, ly)
	 return game.level.map:checkAllEntities(lx, ly, "block_move")
      end
      return {type="wall", range=self:getTalentRange(t), halflength=halflength, talent=t, halfmax_spots=halflength+1, block_radius=block} 
   end,
  
   -- Active's parameters
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
   getLength = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 3, 7)/2)*2 end,
   getIceDamage = function(self, t) return self:combatTalentMindDamage(t, 3, 15) end,
   getIceRadius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
   
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      
      local _ _, _, _, x, y = self:canProject(tg, x, y)
      if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end

      local ice_damage = self:mindCrit(t.getIceDamage(self, t))
      local ice_radius = t.getIceRadius(self, t)
      --Swap
      swapAspectByName(self, "Cold")
      self:project(tg, x, y, function(px, py, tg, self)
		      local oe = game.level.map(px, py, Map.TERRAIN)
		      if not oe or oe.special then return end
		      if not oe or oe:attr("temporary") or game.level.map:checkAllEntities(px, py, "block_move") then return end
		      local e = Object.new{
			 old_feat = oe,
			 name = "energy wall", image = "npc/iceblock.png",
			 desc = "a summoned, transparent wall of draconic energy",
			 type = "wall",
			 display = '#', color=colors.LIGHT_BLUE, back_color=colors.BLUE,
			 always_remember = true,
			 can_pass = {pass_wall=1},
			 does_block_move = true,
			 show_tooltip = true,
			 block_move = true,
			 block_sight = false,
			 temporary = 4 + self:getTalentLevel(t),
			 x = px, y = py,
			 canAct = false,
			 dam = ice_damage,
			 radius = ice_radius,
			 act = function(self)
			    local damtype = DamageType.REK_WYRMIC_NULL
			    local damtypeStatus = DamageType.REK_WYRMIC_NULL
			    local source = self.summoner.rek_wyrmic_dragon_damage
			    if source then
			       damtype = source.damtype
			       damtypeStatus = source.status
			    end
			    local t = self.summoner:getTalentFromId(self.T_REK_WYRMIC_UTILITY_WALL)
			    
			    local tg = {type="ball", range=0, radius=self.radius, friendlyfire=false, talent=t, x=self.x, y=self.y}
			    self.summoner.__project_source = self
			    self.summoner:project(tg, self.x, self.y, damtypeStatus, self.dam)
			    self.summoner.__project_source = nil
			    self:useEnergy()
			    self.temporary = self.temporary - 1
			    if self.temporary <= 0 then
			       game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
			       game.level:removeEntity(self)
			       game.level.map:updateMap(self.x, self.y)
			       game.nicer_tiles:updateAround(game.level, self.x, self.y)
			    end
			 end,
			 dig = function(src, x, y, old)
			    game.level:removeEntity(old, true)
			    return nil, old.old_feat
			 end,
			 summoner_gain_exp = true,
			 summoner = self,
		      }
		      e.tooltip = mod.class.Grid.tooltip
		      game.level:addEntity(e)
		      game.level.map(px, py, Map.TERRAIN, e)
		      --	game.nicer_tiles:updateAround(game.level, px, py)
		      --	game.level.map:updateMap(px, py)
      end)
      
      return true
   end,
   info = function(self, t)
      local icerad = t.getIceRadius(self, t)
      local icedam = t.getIceDamage(self, t)
      local name = "Physical"
      local nameStatus = "unaffected otherwise (you don't have an aspect)"
      local damtype = DamageType.PHYSICAL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 name = DamageType:get(source.damtype).text_color..DamageType:get(source.damtype).name.."#LAST#"
	 damtype = source.damtype
	 nameStatus = source.nameStatus
      end
      return ([[Create a wall of energy with %d length for %d turns. These walls are transparent, but block projectiles and enemies.  The walls also emit destructive energy, dealing %0.2f damage of your active element for each  wall within radius %d of an enemy, and with each wall giving a 15%% chance for the enemy to be to %s. This cannot hurt the user or their allies.
]]):format(3 + math.floor(self:getTalentLevel(t) / 2) * 2, t.getDuration(self, t), damDesc(self, damtype, icedam),  icerad, nameStatus)
   end,
}
