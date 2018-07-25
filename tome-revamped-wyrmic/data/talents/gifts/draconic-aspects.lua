local Object = require "mod.class.Object"

newTalent{
   name = "Fire Aspect", short_name = "REK_WYRMIC_FIRE",
   image= "talents/wing_buffet.png",
   type = {"wild-gift/draconic-aspects", 1},
   require = aspect_req_1,
   points = 5,
   equilibrium = 5,
   cooldown = 12,
   range = 1,
   requires_target = true,
   no_energy = true,
   -- Get resists for use in Prismatic Blood
   getResists = function(self, t) return self:combatTalentScale(t, 10, 30) end,
   -- Cleanse setup for Bellowing Roar
   getCleanseDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5.5)) end,
   getCleanseNb = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 1, 3)) end,
   tactical = { DISABLE = 2 },
   requires_target = true,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   on_pre_use = function(self, t)
      if self:attr("never_move") then return false end
      return true
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      local tx, ty, sx, sy = target.x, target.y, self.x, self.y
      local hitted = self:attackTarget(target, nil, 0, true)
      
      if  not self.dead and tx == target.x and ty == target.y then
	 if not self:canMove(tx,ty,true) or not target:canMove(sx,sy,true) then
	    self:logCombat(target, "Terrain prevents #Source# from switching places with #Target#.")
	    return true
	 end
	 -- Displace
	 if not target.dead then
	    self:move(tx, ty, true)
	    target:move(sx, sy, true)
	 end
      end
      return true
   end,
   info = function(self, t)
      local duration = t.getCleanseDuration(self, t)
      local number = t.getCleanseNb(self, t)
      local resist = t.getResists(self, t)
      return ([[You can take on the power of Fire Wyrms using Prismatic Blood.  While active, you will gain %d%% fire resistance.  You can activate this talent to outmaneuver an adjacent enemy, hitting them for 0%% damage and quickly switching places with them.

This talent passively improves your Bellowing Roar, causing it to reduce the duration of up to %d detrimental effects by %d turns while Fire Aspect is active.
]]):format(resist, number, duration)
   end,
}

newTalent{
   name = "Cold Aspect", short_name = "REK_WYRMIC_COLD",
   image= "talents/wing_buffet.png",
   type = {"wild-gift/draconic-aspects", 1},
   require = aspect_req_1,
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
   -- Get resists for use in Prismatic Blood
   getResists = function(self, t) return self:combatTalentScale(t, 10, 30) end,
   -- Scaly Skin setup
   getDamageOnMeleeHit = function(self, t) return 10 +  self:combatTalentMindDamage(t, 10, 30) end,
   -- Active's parameters
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
   getLength = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 3, 7)/2)*2 end,
   getIceDamage = function(self, t) return self:combatTalentMindDamage(t, 3, 15) end,
   getIceRadius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      local ice_damage = self:mindCrit(t.getIceDamage(self, t))
      local ice_radius = t.getIceRadius(self, t)
      local _ _, _, _, x, y = self:canProject(tg, x, y)
      if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end
      
      self:project(tg, x, y, function(px, py, tg, self)
		      local oe = game.level.map(px, py, Map.TERRAIN)
		      if not oe or oe.special then return end
		      if not oe or oe:attr("temporary") or game.level.map:checkAllEntities(px, py, "block_move") then return end
		      local e = Object.new{
			 old_feat = oe,
			 name = "ice wall", image = "npc/iceblock.png",
			 desc = "a summoned, transparent wall of ice",
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
			    local t = self.summoner:getTalentFromId(self.T_ICE_WALL)
			    local tg = {type="ball", range=0, radius=self.radius, friendlyfire=false, talent=t, x=self.x, y=self.y}
			    self.summoner.__project_source = self
			    self.summoner:project(tg, self.x, self.y, engine.DamageType.ICE, self.dam)
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
      local resist = t.getResists(self, t)
      local retal = t.getDamageOnMeleeHit(self, t)
      return ([[You can take on the power of Ice Wyrms using Prismatic Blood.  While active, you will gain %d%% cold resistance.  You can activate this talent to create a wall of ice with %d length for %d turns. Ice walls are transparent, but block projectiles and enemies, and emit freezing cold, dealing %0.2f damage for each ice wall within radius %d of an enemy, and with each wall giving a 25%% chance to freeze an enemy. This cold cannot hurt the talent user or their allies.

This talent passively improves your Scaled Skin, causing it to deal %0.2f cold damage to any enemies that physically strike you while Cold Aspect is Active.
]]):format(resist,
	      3 + math.floor(self:getTalentLevel(t) / 2) * 2,
	   t.getDuration(self, t),
	   damDesc(self, DamageType.COLD, icedam),
	   icerad,
	   damDesc(self, DamageType.COLD, retal))
   end,
}

newTalent{
   name = "Storm Aspect", short_name = "REK_WYRMIC_ELEC",
   image= "talents/wing_buffet.png",
   type = {"wild-gift/draconic-aspects", 1},
   require = aspect_req_1,
   points = 5,
   equilibrium = 10,
   cooldown = 25,
   range = 10,
   tactical = { CLOSEIN = 2, ESCAPE = 2 },
   requires_target = true,
   no_energy = true,
   levelup_screen_break_line = true,
   -- Get resists for use in Prismatic Blood
   getResists = function(self, t) return self:combatTalentScale(t, 10, 30) end,
   -- Setup for Lightning Speed
   getSpeed = function(self, t) return self:combatTalentScale(t, 470, 750, 0.75) end,
   getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 1.1, 3.1)) end,
   getPercent = function(self, t)
      return self:combatLimit(self:combatTalentMindDamage(t, 10, 45), 90, 0, 0, 31, 31) -- Limit to <90%
   end,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   on_pre_use = function(self, t)
      if self:attr("never_move") then return false end
      return true
   end,

   callbackOnTalentPost = function(self, t, ab)
      if ab.id ~= self.T_REK_WYRMIC_ELEC then
	 if self:hasEffect(self.EFF_REK_LIGHTNING_SPEED) then
		self:removeEffect(self.EFF_REK_LIGHTNING_SPEED)
	end
      end
   end,
   
   action = function(self, t)
      self:setEffect(self.EFF_REK_LIGHTNING_SPEED, self:mindCrit(t.getDuration(self, t)), {power=t.getSpeed(self, t)})
      return true
   end,
   info = function(self, t)
      local resist = t.getResists(self, t)
      return ([[You can take on the power of Storm Wyrms using Prismatic Blood.  While active, you will gain %d%% lightning resistance.  You can activate this talent to transform into pure lightning, moving %d%% faster for %d game turns, during which you will have an additional 30%% physical damage resistance and 100%% lightning resistance.
		Any actions other than moving will stop this effect.
		Note: since you will be moving very fast, game turns will pass very slowly.

This talent passively improves your Elemental Crash, causing it to Electrocute enemies for %d%% of their maximum life (Only 2/3 effectiveness against Elites and Rares, 1/2 effectiveness against Uniques or Bosses, and 2/5 effectiveness against Elite Bosses and above) while Storm Aspect is active.
]]):format(resist, t.getSpeed(self, t), t.getDuration(self, t), t.getPercent(self, t))
   end,
}

newTalent{
   name = "Sand Aspect", short_name = "REK_WYRMIC_SAND",
   image= "talents/wing_buffet.png",
   type = {"wild-gift/draconic-aspects", 1},
   require = aspect_req_1,
   points = 5,
   equilibrium = 15,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 15)) end,
   range = 1,
   requires_target = true,
   no_energy = true,
   -- Get resists for use in Prismatic Blood
   getResists = function(self, t) return self:combatTalentScale(t, 10, 30) end,
   tactical = { CLOSEIN = 0.5, ESCAPE = 0.5 },
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7, 0.5, 0, 2)) end,
   getPenetration = function(self, t) return 10 + self:combatTalentMindDamage(t, 15, 30) end,
   on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
   on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
   action = function(self, t)
      self:setEffect(self.EFF_BURROW, t.getDuration(self, t), {power=0})
      return true
   end,
   info = function(self, t)
      local duration = t.getDuration(self, t)
      local resist = t.getResists(self, t) / 2
      return ([[You can take on the power of Sand Wyrms using Prismatic Blood.  While active, you will gain %d%% physical resistance. You can activate this talent to allow you to burrow into earthen walls for %d turns.

This talent passively improves your Claw Sweep, causing it to reduce enemy armor by %d for 3 turns.
]]):format(resist, duration, t.getPenetration(self, t))
   end,
}
newTalent{
   name = "Acid Aspect", short_name = "REK_WYRMIC_ACID",
   image= "talents/wing_buffet.png",
   type = {"wild-gift/draconic-aspects", 1},
   require = aspect_req_1,
   points = 5,
   equilibrium = 5,
   cooldown = 12,
   range = 1,
   requires_target = true,
   no_energy = true,
   -- Get resists for use in Prismatic Blood
   getResists = function(self, t) return self:combatTalentScale(t, 10, 30) end,
   -- For elemental Spray
   getCorrodeDur = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.8)) end,
   getAtk = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
   getArmor = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
   getDefense = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
   
   tactical = { DISABLE = 2 },
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 30, 140) end,
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
			       DamageType.MINDSLOW, damage,
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
      local resist = t.getResists(self, t)
      local radius = self:getTalentRadius(t)
      local duration = t.getDuration(self, t)
      return ([[You can take on the power of Acid Wyrms using Prismatic Blood.  While active, you will gain %d%% acid resistance.  You can activate this talent to dissolve the ground around you in radius %d for %d turns causing it to slow enemies within.  The aura of dissolution moves with you.

This talent passively improves your Elemental Spray, causing it to corrode affected enemies if Acid Aspect is active.
]]):format(resist, radius, duration)
   end,
}
newTalent{
   name = "Venom Aspect", short_name = "REK_WYRMIC_VENM",
   image= "talents/wing_buffet.png",
   type = {"wild-gift/draconic-aspects", 1},
   require = aspect_req_1,
   points = 5,
   equilibrium = 15,
   cooldown = 12,
   range = 0,
   requires_target = true,
   levelup_screen_break_line = true,
   -- Get resists for use in Prismatic Blood
   getResists = function(self, t) return self:combatTalentScale(t, 10, 30) end,
   -- Cleanse setup for Bellowing Roar
   tactical = { DISABLE = 2 },
   getDamageStinger = function(self, t) return 2 + self:combatTalentStatDamage(t, "cun", 4, 20) * 0.6 end,
   getIntensify = function(self, t) return self:combatTalentMindDamage(t, 0.3, 1.2) end,
   getRange = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 4.5)) end,
   getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 5)) end,
   action = function(self, t)
      local tg = {type="ball", nolock=true, range=0, radius = 5, friendlyfire=false}
      self:project(tg, self.x, self.y,
		   function(px, py)
		      local target = game.level.map(px, py, engine.Map.ACTOR)
		      if not target then
			 return
		      end
		      for eff_id, p in pairs(target.tmp) do
			 local e = target.tempeffect_def[eff_id]
			 if e.subtype.poison and p.power and e.status == "detrimental" then
			    p.power = p.power * (1+t.getIntensify(self, t))
			    if target:canBe("pin") then
			       target:setEffect(target.EFF_PINNED, t.getDur(self, t),
						{apply_power=999})
			    else
			       game.logSeen(target, "%s resists the pin!",
					    target.name:capitalize())
			    end
			 end
		      end
		   end
      )
      return true
   end,
   info = function(self, t)
      local resist = t.getResists(self, t)
      local dam = t.getDamageStinger(self, t)
      return ([[You can take on the power of Venom Wyrms using Prismatic Blood.  While active, you will gain %d%% nature resistance. You can activate this talent to torment poisoned foes within range 5, pinning them for %d turns (no save) and increasing the remaining damage of their poisons by %d%%.

This talent passively improves your Lashing Tail, causing it to expose enemies to poison (%d damage over 3 turns) if Venom Aspect is active.

Mindpower: Improves poison intensification
Cunning: Improves on-hit poison
]]):format(resist, t.getDur(self, t), t.getIntensify(self, t)*100, dam)
   end,
}
