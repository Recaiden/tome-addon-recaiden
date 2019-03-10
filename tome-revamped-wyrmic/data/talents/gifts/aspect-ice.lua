local Object = require "mod.class.Object"

function getAspectResists(self, t)
   return self:combatTalentScale(t, 2, 25)
end

newTalent{
   name = "Icy Armor", short_name = "REK_WYRMIC_COLD",
   type = {"wild-gift/wyrm-ice", 1},
   require = {
      stat = { wil=function(level) return 10 + (level-1) * 4 end },
      level = function(level) return 0 + (level-1) * 3 end,
      special =
	 {
	    desc="One level in Prismatic Blood per additional aspect",
	    fct=function(self) 
	       return self:getTalentLevelRaw(self.T_REK_WYRMIC_MULTICOLOR_BLOOD) > numAspects(self) or self:knowTalent(self.T_REK_WYRMIC_COLD)
	    end
	 },
   },
   points = 5,
   mode = "sustained",
   cooldown = 8,
   sustain_equilibrium = 0,
   -- Get resists for use in Prismatic Blood
   getResists = getAspectResists,
   -- Scaly Skin setup
   getDamageOnMeleeHit = function(self, t) return 10 +  self:combatTalentMindDamage(t, 10, 30) end,
   passives = function(self, t, p)
      local resist = t.getResists(self, t)
      self:talentTemporaryValue(p, "resists", {[DamageType.COLD] = resist})
      self:talentTemporaryValue(p, "iceblock_pierce", math.floor(4*self:getTalentLevel(t)))
   end,
   activate = function(self, t )
      --Ice Aspect
      local ret = {}
      ret["onhit"] = self:addTemporaryValue("on_melee_hit", {[DamageType.COLD]=self:callTalent(self.T_REK_WYRMIC_COLD, "getDamageOnMeleeHit")})
      return ret
   end,
   deactivate = function(self, t, p)
      if p.onhit then
	 self:removeTemporaryValue("on_melee_hit", p.onhit)
      end
      return true
   end,
   info = function(self, t)
      local resist = t.getResists(self, t)
      local retal = t.getDamageOnMeleeHit(self, t)
      return ([[You can take on the power of Ice Wyrms using Prismatic Blood.  You gain %d%% cold resistance. 

While sustained, this talent protects you with a layer of cold, causing you to deal %0.2f cold damage as retaliation to any enemies that physically strike you.

Ice is Cold damage that can inflict Slow(20%% global, no save) and Freeze (#SLATE#Mindpower vs. Physical#LAST#).

Each point in Ice Wyrm talents lets you pierce through ice blocks, reducing the damage they absorb by a total of %d%%.]]):format(resist, damDesc(self, DamageType.COLD, retal), self:attr("iceblock_pierce") or 0)
   end,
}

newTalent{
   name = "Ice Wall", short_name = "REK_WYRMIC_COLD_WALL",
   type = {"wild-gift/wyrm-ice", 2},
   require = {
      stat = { wil=function(level) return 22 + (level-1) * 2 end },
      level = function(level) return 10 + (level-1) end,
      special =
	 {
	    desc="Higher Aspect Abilities unlocked",
	    fct=function(self) 
	       return self:knowTalent(self.T_REK_WYRMIC_FIRE_HEAL)
		  or self:knowTalent(self.T_REK_WYRMIC_COLD_WALL)
		  or self:knowTalent(self.T_REK_WYRMIC_ELEC_SHOCK)
		  or self:knowTalent(self.T_REK_WYRMIC_SAND_BURROW)
		  or self:knowTalent(self.T_REK_WYRMIC_ACID_AURA)
		  or self:knowTalent(self.T_REK_WYRMIC_VENM_PIN)
		  or self.unused_talents_types >= 1
	    end
	 },
   },
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
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
   getLength = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 3, 7)/2)*2 end,
   getIceDamage = function(self, t) return self:combatTalentMindDamage(t, 3, 15) end,
   getIceRadius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "iceblock_pierce", math.floor(4*self:getTalentLevel(t)))
   end,
   on_learn = function(self, t) onLearnHigherAbility(self) end,
   on_unlearn = function(self, t) onUnLearnHigherAbility(self) end,
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
      local desc = ([[Summons an icy wall of %d length for %d turns. Ice walls are transparent, but block projectiles and enemies.
		Ice walls also emit freezing cold, dealing %0.2f damage for each ice wall within radius %d of an enemy, and with each wall giving a 25%% chance to freeze an enemy. This cold cannot hurt the talent user or their allies.
]]):format(3 + math.floor(self:getTalentLevel(t) / 2) * 2, t.getDuration(self, t), damDesc(self, DamageType.COLD, icedam),  icerad)
      if not hasHigherAbility(self) then
	 return desc..[[

#YELLOW#Learning this talent will unlock the higher aspect abilities in all 6 elements at the cost of a category point.  You still require Prismatic Blood to learn more aspects. #LAST#]]
      else
	 return desc
      end 
   end,
}


newTalent{
   name = "Frozen Heart", short_name = "REK_WYRMIC_COLD_SHIELD",
   type = {"wild-gift/wyrm-ice", 3},
   require = gifts_req_high2,
   mode = "passive",
   points = 5,
   getArmor = function(self, t) return self:combatTalentMindDamage(t, 2, 40) end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 50, 200) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "iceblock_pierce", math.floor(4*self:getTalentLevel(t)))
      self:talentTemporaryValue(p, "flat_damage_armor", {all=t.getArmor(self, t)})
   end,

   callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp, no_martyr)
      if dam >= t.getArmor(self, t) * 2 then
	 self:setEffect(self.EFF_REK_WYRMIC_SHATTERED_ICE, 5, {})
	 if src then
	    local x, y = self:getTarget(src)
	    self:project(src, x, y, DamageType.REK_WYRMIC_COLD, t.getDamage(self, t), nil)
	 end
      end
      return {dam=dam}
   end,
   
   info = function(self, t)
      return ([[Coat yourself in plates of ice, providing %d damage reduction against all attacks.  When you take damage greater than twice this amount in a single hit, your armor shatters, dealing %d ice damage to the attacker but reducing your damage reduction for 5 turns.]]):format(t.getArmor(self, t), damDesc(self, DamageType.COLD, t.getDamage(self, t)))
   end,
}

-- Logic for the talent is in the effect
newTalent{
   name = "Gathering Avalanche", short_name = "REK_WYRMIC_COLD_COUNTER",
   type = {"wild-gift/wyrm-ice", 4},
   require = gifts_req_high3,
   points = 5,
   equilibrium = 10,
   cooldown = 25,
   tactical = { DISABLE = 1, DEFEND = 3 },
   requires_target = false,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "iceblock_pierce", math.floor(4*self:getTalentLevel(t)))
   end,
   getReduction = function(self, t) return self:combatTalentMindDamage(t, .30, .60) end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 40, 400) end,
   getAbsorb = function(self, t) return self:combatTalentMindDamage(t, 0.66, 1.50) end,

   action = function(self, t)
      self:setEffect(self.EFF_REK_WYRMIC_AVALANCHE, 3,
		     {
			defend=t.getReduction(self, t),
			conversion = t.getAbsorb(self, t),
			stored = t.getDamage(self, t)
		     }
      )
      return true
   end,   
   
   info = function(self, t)
      local reduction = t.getReduction(self, t) * 100
      local dam = t.getDamage(self, t)
      local conv = t.getAbsorb(self, t) * 100
      return ([[Take a defensive stance while you build up your strength.  For the next 3 turns, you absorb %d%% of incoming damage and disarm (#SLATE#Mindpower vs. Physical#LAST#) enemies that strike you in melee.  After this time, you release a burst of ice in a radius 6 around you.  The damage is %d plus %d%% of the absorbed damage.

Remember: you can cancel the effect to create the avalanche early.]]):format(reduction, damDesc(self, DamageType.COLD, dam), conv)
   end,
}
