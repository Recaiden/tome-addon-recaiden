local Object = require "mod.class.Object"

function getAspectResists(self, t)
   return self:combatTalentScale(t, 2, 25)
end

newTalent{
   name = "Sand Aspect", short_name = "REK_WYRMIC_SAND",
   type = {"wild-gift/wyrm-sand", 1},
   require = {
      stat = { wil=function(level) return 10 + (level-1) * 4 end },
      level = function(level) return 0 + (level-1) * 3 end,
      special =
	 {
	    desc="One level in Prismatic Blood per additional aspect",
	    fct=function(self) 
	       return self:getTalentLevelRaw(self.T_REK_WYRMIC_MULTICOLOR_BLOOD) > numAspects(self) or self:knowTalent(self.T_REK_WYRMIC_SAND)
	    end
	 },
   },
   points = 5,
   mode = "passive",

   on_learn = function(self, t)
      if self.rek_wyrmic_dragon_damage == nil then
	 self.rek_wyrmic_dragon_damage = {
	    name="Physical",
	    nameStatus="Blinded",
	    nameDrake=(DamageType:get(DamageType.PHYSICAL) or "").text_color.."Sand Drake#LAST#",
	    damtype=DamageType.PHYSICAL,
	    status=DamageType.REK_WYRMIC_SAND,
	    talent=self.T_REK_WYRMIC_SAND
	 }
      end
   end,
   on_unlearn = function(self, t) onUnLearnAspect(self) end,
   
   -- Get resists for use in Prismatic Blood
   getResists = getAspectResists,
   getPenetration = function(self, t) return 10 + self:combatTalentMindDamage(t, 15, 30) end,
   passives = function(self, t, p)
      local resist = t.getResists(self, t) / 2
      self:talentTemporaryValue(p, "resists", {[DamageType.PHYSICAL] = resist})
   end,
   info = function(self, t)
      local resist = t.getResists(self, t) / 2
      return ([[You can take on the power of Sand Wyrms using Prismatic Blood.  You will gain %d%% physical resistance. 

This talent passively improves your Draconic Combat talents, causing them to reduce enemy armor by %d for 3 turns (#SLATE#Physical vs. Physical#LAST#).

Sand Damage can inflict Blind (#SLATE#Mindpower vs. Physical#LAST#).
]]):format(resist, t.getPenetration(self, t))
   end,
}

--{
--	stat = { wil=function(level) return 22 + (level-1) * 2 end },
--	level = function(level) return 10 + (level-1)  end,
--}

newTalent{
   name = "Burrow", short_name = "REK_WYRMIC_SAND_BURROW",
   type = {"wild-gift/wyrm-sand", 2},
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
   equilibrium = 15,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 15)) end,
   range = 1,
   requires_target = true,
   no_energy = true,
   tactical = { CLOSEIN = 0.5, ESCAPE = 0.5 },
   
   on_learn = function(self, t) onLearnHigherAbility(self) end,
   on_unlearn = function(self, t) onUnLearnHigherAbility(self) end,
   
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 9, 0.5, 0, 2)) end,
   action = function(self, t)
      self:setEffect(self.EFF_BURROW, t.getDuration(self, t), {power=0})
      return true
   end,
   info = function(self, t)
      local duration = t.getDuration(self, t)
      local desc = ([[You break through the earth as easily as a sandworm, allowing you to burrow through earthen walls for %d turns.
]]):format(duration)
      if not hasHigherAbility(self) then
	 return desc..[[

#YELLOW#Learning this talent will unlock the higher aspect abilities in all 6 elements at the cost of a category point.  You still require Prismatic Blood to learn more aspects. #LAST#]]
      else
	 return desc
      end 
   end,
}

newTalent{
   name = "Tremorsense", short_name = "REK_WYRMIC_SAND_TREMOR",
   type = {"wild-gift/wyrm-sand", 3},
   require = gifts_req_high2,
   points = 5,
   cooldown = 12,
   equilibrium = 8,
   no_energy = true,
   radius = function(self, t) return math.floor(self:combatScale(self:getCun(10, true) * self:getTalentLevel(t), 5, 0, 55, 50)) end,
   getDuration = function(self, t)
      return 1
      --return math.floor(self:combatTalentScale(t, 4, 8))
   end,
   getDamage = function(self, t)
      return self:combatTalentWeaponDamage(t, 0.7, 1.9)
   end,
   getRange = function(self, t) return math.floor(self:combatTalentScale(t, 4, 10)) end,
   no_npc_use = true,
   action = function(self, t)
      local rad = self:getTalentRadius(t)
      self:setEffect(self.EFF_REK_WYRMIC_TREMORSENSE, t.getDuration(self, t), {
			range = rad,
			actor = 1,
			level = self:getTalentLevelRaw(t)
      })
      return true
   end,
   
   info = function(self, t)
      local range = t.radius(self, t)
      local dash = t.getRange(self, t)
      local damage = t.getDamage(self, t)*100
      return ([[Sense foes around you in a radius of %d.  Then, this talent will be replaced with the ability to burrow underground and emerge near an enemy within range %d, attacking it for %d%% damage.

Activating this talent is instant, but the burrowing attack takes a turn.
Cunning: Improves detection radius
Talent Level: Improves range]]):format(range, dash, damage)
   end,
}

newTalent{
   name = "Burrowing Charge", short_name = "REK_WYRMIC_SAND_TREMOR_CHARGE",
   type = {"wild-gift/other", 1},
   require = gifts_req_high2,
   points = 5,
   range = function(self, t) return math.floor(self:combatTalentScale(t, 4, 10)) end,
   tactical = { CLOSEIN = 2, ATTACK = { PHYSICAL = 0.5 } },
   requires_target = true,
   is_melee = true,
   is_teleport = true,
   target = function(self, t) return {type="hit", pass_terrain = true, range=self:getTalentRange(t)} end,
   getDamage = function(self, t)
      return self:combatTalentWeaponDamage(t, 0.7, 1.9)
   end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      
      if not self:teleportRandom(x, y, 0) then game.logSeen(self, "You can't burrow there!") return true end
      
      game:playSoundNear(self, "talents/teleport")
      
      -- Attack ?
      if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
	 local multiplier = t.getDamage(self, t)
	 self:attackTarget(target, nil, multiplier, true)
      end

      if self:hasEffect(self.EFF_REK_WYRMIC_TREMORSENSE) then
	 self:removeEffect(self.EFF_REK_WYRMIC_TREMORSENSE)
      end
      
      return true
   end,
   
   info = function(self, t)
      local multiplier = t.getDamage(self, t)
      return ([[Burrow underground and emerge near an enemy, attacking it for %d%% damage.]]):format( multiplier * 100 )
   end,
}

newTalent{
   name = "Quake", short_name = "REK_WYRMIC_SAND_QUAKE",
   type = {"wild-gift/wyrm-sand", 4},
   require = gifts_req_high3,
   points = 5,
   random_ego = "attack",
   message = "@Source@ shakes the ground!",
   equilibrium = 10,
   cooldown = 20,
   tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
   range = 1,
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
   no_npc_use = true,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 3.2) end,
   
   action = function(self, t)
      -- Reset
      if self.talents_cd[self.T_REK_WYRMIC_SAND_TREMOR] then
	 self.talents_cd[self.T_REK_WYRMIC_SAND_TREMOR] = 0
      end
      
      --Attack everyone nearby
      local tg = {type="ball", range=0, selffire=false, radius=self:getTalentRadius(t), talent=t, no_restrict=true}
      self:project(tg, self.x, self.y, function(px, py, tg, self)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target ~= self then
			 local hit = self:attackTarget(target, DamageType.PHYSKNOCKBACK, self:combatTalentWeaponDamage(t, 1.3, 2.1), true)
		      end
      end)

      --Put up the sand walls
      --Copied from anomaly entomb
      self:project(tg, self.x, self.y, function(px, py, tg, self)
		      local oe = game.level.map(px, py, Map.TERRAIN)
		      if oe and not oe:attr("temporary") and not oe.special
			 and not game.level.map:checkAllEntities(px, py, "block_move")
		      then
			 -- it stores the current terrain in "old_feat" and restores it when it expires
			 local e = Object.new{
			    old_feat = oe,
			    name = "sand wall", image = "terrain/sand/sandwall_5_1.png",
			    display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
			    desc = "a slowly collapsing wall of sand, raised by an earthquake",
			    type = "wall", subtype = "floor",
			    always_remember = true,
			    can_pass = {pass_wall=1},
			    does_block_move = true,
			    show_tooltip = true,
			    block_move = true,
			    block_sight = true,
			    temporary = 5,
			    x = px, y = py,
			    canAct = false,
			    act = function(self)
			       self:useEnergy()
			       self.temporary = self.temporary - 1
			       if self.temporary <= 0 then
				  game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
				  game.nicer_tiles:updateAround(game.level, self.x, self.y)
				  game.level:removeEntity(self)
				  game.level.map:scheduleRedisplay()
			       end
			    end,
			    dig = function(src, x, y, old)
			       game.level:removeEntity(old, true)
			       game.level.map:scheduleRedisplay()
			       return nil, old.old_feat
			    end,
			    summoner_gain_exp = true,
			    summoner = self,
			 }
			 e.tooltip = mod.class.Grid.tooltip
			 game.level:addEntity(e)
			 --game.zone:addEntity(game.level, g, "terrain", i, j)
			 game.level.map(px, py, Map.TERRAIN, e)
		      end
      end)
      return true
   end,
   
   info = function(self, t)
      local radius = self:getTalentRadius(t)
      local dam = t.getDamage(self, t)
      return ([[You slam the ground, shaking the area around you in a radius of %d.
Creatures caught by the quake will be damaged for %d%% weapon damage, and knocked back up to 3 tiles away.
Empty spaces in the area will be filled with unstable sand walls which collapse after 5 turns.

If you know the Tremorsense talent, its cooldown will be reset.]]):format(radius, dam * 100)
   end,
}
