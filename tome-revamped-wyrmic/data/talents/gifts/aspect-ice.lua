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
         desc="You can learn a new aspect every 6 levels",
         fct=function(self)
            return self:knowTalent(self.T_REK_WYRMIC_COLD) or self.level >= numAspectsKnown(self)*6
	    end
	 },
   },
   points = 5,
   on_learn = function(self, t)
      if self.rek_wyrmic_dragon_damage == nil then
	 self.rek_wyrmic_dragon_damage = {
	    name="Cold",
	    nameStatus="Frozen",
	    nameDrake=(DamageType:get(DamageType.COLD).text_color or "").."Cold Drake#LAST#",
	    damtype=DamageType.COLD,
	    status=DamageType.REK_WYRMIC_COLD,
	    talent=self.T_REK_WYRMIC_COLD
	 }
      end
      onLearnAspect(self, t)
   end,
   on_unlearn = function(self, t) onUnLearnAspect(self) end,
   
   mode = "sustained",
   cooldown = 8,
   sustain_equilibrium = 5,
   -- Get resists for use in Prismatic Blood
   getResists = getAspectResists, 
   getDamageOnMeleeHit = function(self, t) return 10 +  self:combatTalentMindDamage(t, 10, 30) end,
   getAllRes = function(self, t) return self:combatTalentScale(t, 4, 15, 0.75, 0, 0, true) end,
   getIcepen = function(self, t)
      local pen = self:combatScale(
         self:getTalentLevel(t) + self:getTalentLevel(self.T_REK_WYRMIC_COLD_WALL) + self:getTalentLevel(self.T_REK_WYRMIC_COLD_SHIELD) + self:getTalentLevel(self.T_REK_WYRMIC_COLD_COUNTER),
         0, 0, 100, 20)
      return math.min(100, pen)
   end,
   passives = function(self, t, p)
      local resist = t.getResists(self, t)
      self:talentTemporaryValue(p, "resists", {[DamageType.COLD] = resist, all = t.getAllRes(self, t)})
      
      --self:talentTemporaryValue(p, "iceblock_pierce", math.floor(4*self:getTalentLevel(t)))
      self:talentTemporaryValue(p, "iceblock_pierce", t.getIcepen(self, t))
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
      local icepen = math.min(100, t.getIcepen(self, t))
      return ([[You can take on the power of Ice Wyrms, giving you %d%% cold resistance. 
While sustained, this talent protects you with a layer of cold, increasing your resistance to damge by %d%% and causing you to deal %0.1f cold damage as retaliation to any enemies that physically strike you.

Ice is Cold damage that can inflict Slow (20%% global, no save) and Freeze (#SLATE#Mindpower vs. Physical#LAST#).

Each point in Ice Wyrm talents lets you pierce through ice blocks, reducing the damage they absorb by %d%%.]]):format(resist, t.getAllRes(self, t), damDesc(self, DamageType.COLD, retal), icepen)
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
	    desc="Advanced aspect talents learnable",
	    fct=function(self) 
	       return self:knowTalent(self.T_REK_WYRMIC_COLD_WALL)
		  or self.unused_talents_types >= 1
	    end
	 },
   },
   points = 5,
   random_ego = "defensive",
   equilibrium = 10,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 30, 15)) end,
   range = 10,
   tactical = { ATTACKAREA = 2, DISABLE = 2 },
   requires_target = true,
   target = function(self, t)
      local halflength = math.floor(t.getLength(self,t)/2)
      local block = function(_, lx, ly)
	 return game.level.map:checkAllEntities(lx, ly, "block_move")
      end
      return {type="wall", range=self:getTalentRange(t), halflength=halflength, talent=t, halfmax_spots=halflength+1, nolock=true, block_radius=block} 
   end,
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
   getStats = function(self, t) return self:getWil()*0.5 end,
   getLifeRating = function(self, t) return math.floor(self:combatStatScale("wil", 0.5, 2)) end,
   getLength = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 3, 7)/2)*2 end,
   getIceDamage = function(self, t) return self:combatTalentMindDamage(t, 3, 15) end,
   getIceRadius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "iceblock_pierce", math.floor(4*self:getTalentLevel(t)))
   end,
   on_learn = function(self, t) onLearnHigherAbility(self, t) end,
   on_unlearn = function(self, t) onUnLearnHigherAbility(self, t) end,
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
		      local NPC = require "mod.class.NPC"
		      local wall = NPC.new{
			 type = "immovable", subtype = "ice",
			 display = "#", blood_color = colors.BLUE,
			 stats = { str=t.getStats(self, t), dex=t.getStats(self, t), wil=t.getStats(self, t), mag=t.getStats(self, t), con=t.getStats(self, t), cun=t.getStats(self, t) },
			 infravision = 10,
			 no_breath = 1,
			 never_move = 1,
			 cant_be_moved = 1,
			 name = "ice wall", color=colors.BLUE,
			 desc = "A tremendous block of glacial ice blocks your path.  It radiates a bone-deep cold into the air",
			 resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/iceblock.png", display_h=1, display_y=-1}}},
			 level_range = {self.level, self.level}, exp_worth = 0,
			 rank = 2,
			 size_category = 3,
			 autolevel = "wildcaster",
			 life_rating = 10 + t.getLifeRating(self, t),
			 negative_status_effect_immune = 1,
			 combat_armor = math.floor(self.level^.75),
			 combat_armor_hardiness = 100,
			 resists = {[DamageType.COLD] = 100},
			 dam = ice_damage,
			 radius = ice_radius,
			 summoner = self, summoner_gain_exp=true,
			 summon_time = t.getDuration(self, t),
			 on_act = function(self)
			    local t = self.summoner:getTalentFromId(self.T_ICE_WALL)
			    local tg = {type="ball", range=0, radius=self.radius, friendlyfire=false, talent=t, x=self.x, y=self.y}
			    self.summoner.__project_source = self
			    self.summoner:project(tg, self.x, self.y, engine.DamageType.ICE, self.dam)
			    self.summoner.__project_source = nil
			    self:useEnergy()
			 end,

			 ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
			 no_drops = true, keep_inven_on_death = false,
			 faction = self.faction,
		      }
		      wall:resolve()
		      wall:resolve(nil, true)		
		      game.zone:addEntity(game.level, wall, "actor", px, py)
		      if target then m:setTarget(target) end
		      if game.party:hasMember(self) then
			 wall.remove_from_party_on_death = true
			 game.party:addMember(wall, {
						 control=false,
						 temporary_level = true,
						 type="summon",
						 title="Summon",
			 })
		      end
      end)
      return true
   end,
   info = function(self, t)
      local icerad = t.getIceRadius(self, t)
      local icedam = t.getIceDamage(self, t)
      local icepen = self:callTalent(self.T_REK_WYRMIC_COLD, "getIcepen")
      local notice = (self:getTalentLevelRaw(t) == 1000 or (self:getTalentLevelRaw(t) < 2)) and [[


#YELLOW#Learning the advanced ice talents costs a category point.#LAST#]] or ""
      return ([[Summons an icy barrier of %d length for %d turns. Each empty space will be filled with a destructible but durable Ice Wall. Ice walls emit freezing cold, dealing %0.1f damage to enemies within radius %d with a 25%% chance to freeze.
Mindpower: improves damage
Willpower: improves ice wall life

Each point in Ice Wyrm talents lets you pierce through ice blocks, reducing the damage they absorb by %d%%.%s]]):format(3 + math.floor(self:getTalentLevel(t) / 2) * 2, t.getDuration(self, t), damDesc(self, DamageType.COLD, icedam),  icerad, icepen, notice)
   end,
}


newTalent{
   name = "Frozen Heart", short_name = "REK_WYRMIC_COLD_SHIELD",
   type = {"wild-gift/wyrm-ice", 3},
   require = gifts_req_high2,
   mode = "passive",
   points = 5,
   getArmor = function(self, t) return self:combatTalentMindDamage(t, 2, 50) end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 50, 200) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "iceblock_pierce", math.floor(4*self:getTalentLevel(t)))
      self:talentTemporaryValue(p, "flat_damage_armor", {all=t.getArmor(self, t)})
   end,

   callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp, no_martyr)
      if dam >= t.getArmor(self, t) * 8 then
	 -- Only deal damage on the first stack of shattering
	 local pristine = false
	 if not self:hasEffect(self.EFF_REK_WYRMIC_SHATTERED_ICE) then
	    pristine = true
	 end
	 self:setEffect(self.EFF_REK_WYRMIC_SHATTERED_ICE, 5, {power=5})
	 if src then
	    local x, y = src.x, src.y
	    if pristine then
	       self:project(src, x, y, DamageType.REK_WYRMIC_COLD, t.getDamage(self, t), nil)
	    end
	 end
      end
      return {dam=dam}
   end,
   
   info = function(self, t)
      local icepen = self:callTalent(self.T_REK_WYRMIC_COLD, "getIcepen")
      return ([[Coat yourself in plates of ice, providing %d damage reduction against all attacks.  When you take damage greater than eight times this amount in a single hit, your ice plating cracks, reducing the protection it provides by 5 for 5 turns. If it was not already cracked, this deals %d ice damage to the attacker.

Mindpower: Improves damage reduction and armor

Each point in Ice Wyrm talents lets you pierce through ice blocks, reducing the damage they absorb by %d%%.]]):format(t.getArmor(self, t), damDesc(self, DamageType.COLD, t.getDamage(self, t)), icepen)
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
   getReduction = function(self, t) return self:combatTalentMindDamage(t, .20, .60) end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 40, 400) end,
   getAbsorb = function(self, t) return self:combatTalentMindDamage(t, 0.66, 1.50) end,
   action = function(self, t)
      self:setEffect(self.EFF_REK_WYRMIC_AVALANCHE, 3,
		     {
			defend = t.getReduction(self, t),
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
      local icepen = self:callTalent(self.T_REK_WYRMIC_COLD, "getIcepen")
      return ([[Take a defensive stance while you build up your strength.  For the next 3 turns, you absorb %d%% of incoming damage and disarm (#SLATE#Mindpower vs. Physical#LAST#) enemies that strike you in melee.  After this time, you release a burst of ice in a radius 6 around you.  The damage is %d plus %d%% of the absorbed damage.

Remember: you can cancel the effect to create the avalanche early.

Each point in Ice Wyrm talents lets you pierce through ice blocks, reducing the damage they absorb by %d%%.]]):format(reduction, damDesc(self, DamageType.COLD, dam), conv, icepen)
   end,
}
